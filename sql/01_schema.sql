-- 01_schema.sql - таблица под сырые данные
--
-- Источник: Lending Club, кредиты за январь-март 2018 (набор loans_full_schema
-- из пакета OpenIntro). https://github.com/vincentarelbundock/Rdatasets/blob/master/csv/openintro/loans_full_schema.csv
--
-- Таблица повторяет структуру csv как есть, без изменений.

DROP TABLE IF EXISTS loans_raw;

CREATE TABLE loans_raw (
    loan_id                            integer PRIMARY KEY,
    emp_title                          text,
    emp_length                         numeric,
    state                               text,
    homeownership                       text,
    annual_income                       numeric,
    verified_income                     text,
    debt_to_income                      numeric,
    annual_income_joint                 numeric,
    verification_income_joint           text,
    debt_to_income_joint                numeric,
    delinq_2y                           integer,
    months_since_last_delinq            numeric,
    earliest_credit_line                integer,
    inquiries_last_12m                  integer,
    total_credit_lines                  integer,
    open_credit_lines                   integer,
    total_credit_limit                  numeric,
    total_credit_utilized               numeric,
    num_collections_last_12m            integer,
    num_historical_failed_to_pay        integer,
    months_since_90d_late               numeric,
    current_accounts_delinq             integer,
    total_collection_amount_ever        numeric,
    current_installment_accounts        integer,
    accounts_opened_24m                 integer,
    months_since_last_credit_inquiry    numeric,
    num_satisfactory_accounts           integer,
    num_accounts_120d_past_due          integer,
    num_accounts_30d_past_due           integer,
    num_active_debit_accounts           integer,
    total_debit_limit                   numeric,
    num_total_cc_accounts               integer,
    num_open_cc_accounts                integer,
    num_cc_carrying_balance             integer,
    num_mort_accounts                   integer,
    account_never_delinq_percent        numeric,
    tax_liens                           integer,
    public_record_bankrupt              integer,
    loan_purpose                        text,
    application_type                    text,
    loan_amount                         numeric,
    term                                integer,
    interest_rate                       numeric,
    installment                         numeric,
    grade                               text,
    sub_grade                           text,
    issue_month                         text,   -- 'Jan-2018' и т.п., распарсим в curated-слое
    loan_status                         text,
    initial_listing_status              text,
    disbursement_method                 text,
    balance                             numeric,
    paid_total                          numeric,
    paid_principal                      numeric,
    paid_interest                       numeric,
    paid_late_fees                      numeric
);
