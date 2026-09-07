-- Бизнес-вопрос: в каких сегментах (грейд, цель кредита, тип
-- собственности на жильё, штат) выше доля проблемных кредитов
-- (NPL = Stage 3, т.е. существенная просрочка/дефолт)?

-- 4.1 NPL по грейду
SELECT
    grade,
    COUNT(*) AS loans_count,
    SUM(balance) AS total_balance,
    COALESCE(SUM(balance) FILTER (WHERE ifrs9_stage = 'Stage 3'), 0) AS npl_balance,
    ROUND(100.0 * COALESCE(SUM(balance) FILTER (WHERE ifrs9_stage = 'Stage 3'), 0)
          / NULLIF(SUM(balance), 0), 2) AS npl_ratio_pct
FROM loans
WHERE ifrs9_stage <> 'Closed'
GROUP BY grade
ORDER BY grade;

-- 4.2 NPL по цели кредита (loan_purpose), с фильтром на сегменты
-- с достаточным объёмом (HAVING), чтобы не было шума на малых выборках
SELECT
    loan_purpose,
    COUNT(*) AS loans_count,
    SUM(balance) AS total_balance,
    ROUND(100.0 * COALESCE(SUM(balance) FILTER (WHERE ifrs9_stage = 'Stage 3'), 0)
          / NULLIF(SUM(balance), 0), 2) AS npl_ratio_pct
FROM loans
WHERE ifrs9_stage <> 'Closed'
GROUP BY loan_purpose
HAVING COUNT(*) >= 50
ORDER BY npl_ratio_pct DESC NULLS LAST;

-- 4.3 NPL по типу собственности на жильё
SELECT
    homeownership,
    COUNT(*) AS loans_count,
    ROUND(100.0 * COALESCE(SUM(balance) FILTER (WHERE ifrs9_stage = 'Stage 3'), 0)
          / NULLIF(SUM(balance), 0), 2) AS npl_ratio_pct
FROM loans
WHERE ifrs9_stage <> 'Closed'
GROUP BY homeownership
ORDER BY npl_ratio_pct DESC NULLS LAST;

-- 4.4 Топ-10 штатов по NPL ratio среди штатов с заметным портфелем (HAVING)
SELECT
    state,
    COUNT(*) AS loans_count,
    SUM(balance) AS total_balance,
    ROUND(100.0 * COALESCE(SUM(balance) FILTER (WHERE ifrs9_stage = 'Stage 3'), 0)
          / NULLIF(SUM(balance), 0), 2) AS npl_ratio_pct
FROM loans
WHERE ifrs9_stage <> 'Closed'
GROUP BY state
HAVING COUNT(*) >= 100
ORDER BY npl_ratio_pct DESC NULLS LAST
LIMIT 10;
