-- Бизнес-вопрос: как портфель распределён по статусам просрочки
-- (бакетам), и какая доля баланса приходится на каждый бакет?

SELECT
    loan_status,
    COUNT(*) AS loans_count,
    SUM(balance) AS total_balance,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct_of_loans,
    ROUND(100.0 * SUM(balance) / SUM(SUM(balance)) OVER (), 1) AS pct_of_balance
FROM loans
GROUP BY loan_status
ORDER BY total_balance DESC;
