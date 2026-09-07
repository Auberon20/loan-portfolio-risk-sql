-- Бизнес-вопрос: если применить упрощённую логику резервирования в духе
-- IFRS 9 (стадии 1/2/3 + PD*LGD), сколько резерва нужно отложить под
-- текущий портфель, и как резерв распределён по стадиям и грейдам?
--
-- Допущения (проговорены и в README, и в комментариях 03_transform_curated.sql):
--   - LGD (доля потерь при дефолте) берём единой константой 55% -
--     типичное отраслевое допущение для необеспеченных потребительских
--     кредитов, а не расчётная величина по этим данным.
--   - Stage 1: ожидаемые потери за 12 месяцев = balance * pd_12m * LGD.
--   - Stage 2: lifetime-PD аппроксимируем как pd_12m * 3 (упрощение;
--     в реальной модели лестница PD по месяцам, здесь - proxy),
--     не выше 100%.
--   - Stage 3: кредит уже в дефолте/глубокой просрочке, PD = 100%,
--     резерв = balance * LGD.
--   - Closed (Fully Paid) в резервировании не участвует - кредита
--     больше нет на балансе как риска.

WITH ecl_calc AS (
    SELECT
        l.loan_id,
        l.grade,
        l.ifrs9_stage,
        l.balance,
        p.pd_12m,
        0.55 AS lgd,
        CASE l.ifrs9_stage
            WHEN 'Stage 1' THEN l.balance * p.pd_12m * 0.55
            WHEN 'Stage 2' THEN l.balance * LEAST(p.pd_12m * 3, 1.0) * 0.55
            WHEN 'Stage 3' THEN l.balance * 0.55
            ELSE 0
        END AS ecl
    FROM loans l
    JOIN pd_assumptions_by_grade p USING (grade)
    WHERE l.ifrs9_stage <> 'Closed'
)
SELECT
    ifrs9_stage,
    grade,
    COUNT(*) AS loans_count,
    SUM(balance) AS total_balance,
    ROUND(SUM(ecl), 2) AS estimated_reserve,
    ROUND(100.0 * SUM(ecl) / NULLIF(SUM(balance), 0), 2) AS reserve_rate_pct
FROM ecl_calc
GROUP BY ifrs9_stage, grade
ORDER BY ifrs9_stage, grade;

-- Итог одной строкой: совокупный резерв по всему портфелю
WITH ecl_calc AS (
    SELECT
        l.balance,
        CASE l.ifrs9_stage
            WHEN 'Stage 1' THEN l.balance * p.pd_12m * 0.55
            WHEN 'Stage 2' THEN l.balance * LEAST(p.pd_12m * 3, 1.0) * 0.55
            WHEN 'Stage 3' THEN l.balance * 0.55
            ELSE 0
        END AS ecl
    FROM loans l
    JOIN pd_assumptions_by_grade p USING (grade)
    WHERE l.ifrs9_stage <> 'Closed'
)
SELECT
    SUM(balance) AS portfolio_balance,
    ROUND(SUM(ecl), 2) AS total_reserve,
    ROUND(100.0 * SUM(ecl) / SUM(balance), 2) AS reserve_rate_pct
FROM ecl_calc;
