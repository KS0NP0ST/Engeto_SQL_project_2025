SELECT *
FROM t_karel_svoboda_project_SQL_primary_final ;

---

SELECT 
  price_value AS value,
  price_category_code AS category_code,
  price_date_from AS date_from,
  price_date_to AS date_to
FROM t_karel_svoboda_project_SQL_primary_final
WHERE price_category_code IN ('111301', '114201');

---

SELECT 
  MIN(price_date_from) AS min_year,
  MAX(price_date_to)   AS max_year
FROM t_karel_svoboda_project_SQL_primary_final
WHERE price_category_code IN ('111301', '114201');

---

SELECT 
  price_value AS value,
  price_category_code AS category_code,
  price_date_from::date AS date
FROM t_karel_svoboda_project_SQL_primary_final
WHERE price_date_from::date = '2006-01-02' AND price_category_code IN ('111301', '114201');

---

SELECT 
  price_value AS value,
  price_category_code AS category_code,
  price_date_to::date AS date
FROM t_karel_svoboda_project_SQL_primary_final
WHERE price_date_to::date = '2018-12-16' AND price_category_code IN ('111301', '114201');

---

CREATE VIEW czechia_price_oldest_latest_period AS
SELECT 
  price_value AS value,
  price_category_code AS category_code,
  price_date_from::date AS date
FROM t_karel_svoboda_project_SQL_primary_final
WHERE price_category_code IN ('111301', '114201') AND price_date_from = (SELECT MIN(price_date_from) FROM t_karel_svoboda_project_SQL_primary_final)

UNION ALL

SELECT 
  price_value AS value,
  price_category_code AS category_code,
  price_date_to::date AS date
FROM t_karel_svoboda_project_SQL_primary_final
WHERE price_category_code IN ('111301', '114201') AND price_date_to = (SELECT MAX(price_date_to) FROM t_karel_svoboda_project_SQL_primary_final);

---

SELECT *
FROM czechia_price_oldest_latest_period;

---

CREATE OR REPLACE VIEW price_wage_view AS
SELECT
  year,
  payroll_industry_code AS industry_code,
  payroll_industry_name AS industry_name,
  payroll_calculation_code AS calculation_code,
  payroll_calculation_type AS calculation_type,
  payroll_value,
  price_category_code,
  price_category_name,
  price_unit,
  price_value
FROM t_karel_svoboda_project_SQL_primary_final;

---

SELECT
  price_wage_view.year,
  price_wage_view.industry_name,
  AVG(price_wage_view.payroll_value) / czechia_price_oldest_latest_period.value AS quantity,
  AVG(price_wage_view.payroll_value) AS avg_payroll_value,
  czechia_price_oldest_latest_period.category_code,
  czechia_price_oldest_latest_period.date,
  czechia_price_oldest_latest_period.value AS price_value
FROM price_wage_view
JOIN czechia_price_oldest_latest_period ON price_wage_view.price_category_code = czechia_price_oldest_latest_period.category_code
WHERE price_wage_view.calculation_type = 'přepočtený' AND price_wage_view.year IN ('2006','2018')
GROUP BY price_wage_view.year, price_wage_view.industry_name, czechia_price_oldest_latest_period.category_code, czechia_price_oldest_latest_period.date, czechia_price_oldest_latest_period.value
ORDER BY price_wage_view.year, price_wage_view.industry_name;

---

SELECT
  price_wage_view.year,
  price_wage_view.industry_name,
  AVG(price_wage_view.payroll_value) AS avg_payroll,
  yearly.avg_price,
  yearly.category_name AS product,
  CAST(AVG(price_wage_view.payroll_value) / yearly.avg_price AS INT) AS quantity
FROM price_wage_view
JOIN (
    SELECT 
        price_category_code AS category_code,
        price_category_name AS category_name,
        year,
        AVG(price_value) AS avg_price
    FROM t_karel_svoboda_project_SQL_primary_final
    WHERE price_category_code IN ('111301','114201')
    GROUP BY price_category_code, price_category_name, year
) AS yearly ON price_wage_view.price_category_code = yearly.category_code AND price_wage_view.year = yearly.year
WHERE price_wage_view.calculation_type = 'přepočtený' AND price_wage_view.year IN (2006, 2018)
GROUP BY price_wage_view.year, price_wage_view.industry_name, yearly.category_code, yearly.avg_price, yearly.category_name
ORDER BY price_wage_view.year, price_wage_view.industry_name, product;

