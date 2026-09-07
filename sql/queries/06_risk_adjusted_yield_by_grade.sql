-- Бизнес-вопрос: компенсирует ли более высокая ставка по младшим
-- грейдам (D/E/F/G) более высокий ожидаемый уровень потерь, или
-- risk-adjusted доходность там на самом деле ниже?

WITH ecl_by_grade AS (
    SELECT
        l.grade,
        SUM(l.balance) AS total_balance,
        ROUND(AVG(l.interest_rate), 2) AS avg_interest_rate,
        SUM(
            CASE l.ifrs9_stage
                WHEN 'Stage 1' THEN l.balance * p.pd_12m * 0.55
                WHEN 'Stage 2' THEN l.balance * LEAST(p.pd_12m * 3, 1.0) * 0.55
                WHEN 'Stage 3' THEN l.balance * 0.55
                ELSE 0
            END
        ) AS estimated_reserve
    FROM loans l
    JOIN pd_assumptions_by_grade p USING (grade)
    WHERE l.ifrs9_stage <> 'Closed'
    GROUP BY l.grade
)
SELECT
    grade,
    total_balance,
    avg_interest_rate,
    ROUND(100.0 * estimated_reserve / total_balance, 2) AS reserve_rate_pct,
    ROUND(avg_interest_rate - (100.0 * estimated_reserve / total_balance), 2)
        AS risk_adjusted_spread_pct
FROM ecl_by_grade
ORDER BY grade;
