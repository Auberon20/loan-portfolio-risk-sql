-- 03_transform_curated.sql - типизация и разбивка кредитов по стадиям риска
--
-- issue_month превращаем в дату, а loan_status - в стадию по логике IFRS 9:
--   Stage 1 - платит вовремя (Current)
--   Stage 2 - небольшая просрочка (грейс-период, 16-30 дней)
--   Stage 3 - серьезная просрочка (31-120 дней) или дефолт (Charged Off)
--   Closed  - кредит уже закрыт (Fully Paid), в анализ риска не входит
--
-- Оговорка: граница Stage 2/Stage 3 - упрощение. В данных нет более
-- мелкого деления после 31 дня, а порог дефолта по IFRS 9 - 90+ дней,
-- поэтому весь бакет "31-120 дней" условно отнесен к Stage 3.

DROP TABLE IF EXISTS loans;

CREATE TABLE loans AS
SELECT
    loan_id,
    state,
    homeownership,
    annual_income,
    debt_to_income,
    delinq_2y,
    months_since_last_delinq,
    grade,
    sub_grade,
    loan_purpose,
    application_type,
    loan_amount,
    term,
    interest_rate,
    installment,
    TO_DATE(issue_month, 'Mon-YYYY') AS issue_date,
    loan_status,
    balance,
    paid_total,
    paid_principal,
    paid_interest,
    CASE
        WHEN loan_status = 'Current'                THEN 'Stage 1'
        WHEN loan_status IN ('In Grace Period',
                              'Late (16-30 days)')   THEN 'Stage 2'
        WHEN loan_status IN ('Late (31-120 days)',
                              'Charged Off')          THEN 'Stage 3'
        WHEN loan_status = 'Fully Paid'               THEN 'Closed'
        ELSE 'Unknown'
    END AS ifrs9_stage,
    (loan_status = 'Charged Off') AS is_realized_default
FROM loans_raw;

ALTER TABLE loans ADD PRIMARY KEY (loan_id);
CREATE INDEX idx_loans_grade ON loans (grade);
CREATE INDEX idx_loans_stage ON loans (ifrs9_stage);
CREATE INDEX idx_loans_issue_date ON loans (issue_date);

-- Таблица допущений по вероятности дефолта (PD) для каждого грейда.
-- Цифры иллюстративные - для демонстрации расчета резерва на SQL,
-- не результат реальной модели.
DROP TABLE IF EXISTS pd_assumptions_by_grade;

CREATE TABLE pd_assumptions_by_grade (
    grade   text PRIMARY KEY,
    pd_12m  numeric   -- вероятность дефолта в горизонте 12 месяцев (proxy)
);

INSERT INTO pd_assumptions_by_grade (grade, pd_12m) VALUES
    ('A', 0.02),
    ('B', 0.05),
    ('C', 0.10),
    ('D', 0.16),
    ('E', 0.24),
    ('F', 0.32),
    ('G', 0.40);

-- Проверка результата трансформации
SELECT ifrs9_stage, COUNT(*) AS loans, SUM(balance) AS total_balance
FROM loans
GROUP BY ifrs9_stage
ORDER BY ifrs9_stage;
