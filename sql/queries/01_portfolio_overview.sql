-- Бизнес-вопрос: как выглядит портфель в целом - сколько кредитов,
-- на какую сумму, и как он разбит по грейду и продукту (цели кредита)?

SELECT
    grade,
    COUNT(*) AS loans_count,
    SUM(balance) AS total_balance,
    ROUND(AVG(interest_rate), 2) AS avg_interest_rate,
    ROUND(100.0 * SUM(balance) / SUM(SUM(balance)) OVER (), 1) AS pct_of_portfolio
FROM loans
GROUP BY grade
ORDER BY grade;
