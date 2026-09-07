-- Бизнес-вопрос: какие конкретные кредиты дают наибольший вклад в
-- риск внутри своего грейда (топ-3 по балансу среди проблемных
-- кредитов Stage 2/3 в каждом грейде)? Практическая задача в духе
-- "топ должников" - куда в первую очередь смотреть риск-менеджеру.

SELECT *
FROM (
    SELECT
        loan_id,
        grade,
        state,
        loan_purpose,
        ifrs9_stage,
        balance,
        interest_rate,
        ROW_NUMBER() OVER (PARTITION BY grade ORDER BY balance DESC) AS rank_in_grade
    FROM loans
    WHERE ifrs9_stage IN ('Stage 2', 'Stage 3')
) ranked
WHERE rank_in_grade <= 3
ORDER BY grade, rank_in_grade;
