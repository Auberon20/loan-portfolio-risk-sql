-- 02_load_data.sql - загрузка csv в таблицу loans_raw
-- Запуск из корня проекта: psql -d loan_reserves -f sql/02_load_data.sql
-- (путь к data/ ищется от папки, откуда запущен psql)

\copy loans_raw FROM 'data/loans_full_schema.csv' WITH (FORMAT csv, HEADER true, NULL '');

-- Быстрая проверка, что загрузка прошла как ожидается
SELECT COUNT(*) AS rows_loaded FROM loans_raw;
