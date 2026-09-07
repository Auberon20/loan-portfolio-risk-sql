-- Бизнес-вопрос: отличается ли ранняя просрочка между когортами выдачи
-- (январь/февраль/март 2018)? Это упрощённый аналог vintage-анализа -
-- в данных всего 3 месяца выдач в одном срезе, поэтому это не полная
-- vintage-кривая по годам, а сравнение "свежести" когорт на одну дату среза.

WITH cohort_stats AS (
    SELECT
        issue_date,
        COUNT(*) AS loans_count,
        SUM(balance) AS total_balance,
        ROUND(100.0 * SUM(balance) FILTER (WHERE ifrs9_stage IN ('Stage 2', 'Stage 3'))
              / NULLIF(SUM(balance), 0), 2) AS delinquent_balance_pct
    FROM loans
    WHERE ifrs9_stage <> 'Closed'
    GROUP BY issue_date
)
SELECT
    issue_date,
    loans_count,
    total_balance,
    delinquent_balance_pct,
    RANK() OVER (ORDER BY delinquent_balance_pct DESC) AS risk_rank
FROM cohort_stats
ORDER BY issue_date;
