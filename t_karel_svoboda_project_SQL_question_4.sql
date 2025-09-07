CREATE VIEW price_payroll_compare AS
SELECT
  year,
  payroll_industry_code AS industry_code,
  payroll_industry_name AS industry_name,
  payroll_calculation_code AS calculation_code,
  payroll_calculation_type AS calculation_type,
  payroll_value
FROM t_karel_svoboda_project_SQL_primary_final;

---

SELECT *
FROM price_payroll_compare;

---

SELECT 
  year,
  industry_name,
  AVG(payroll_value) AS avg_payroll
FROM price_payroll_compare
WHERE calculation_type = 'přepočtený' AND payroll_value IS NOT NULL
GROUP BY year, industry_name;

---

CREATE VIEW price_payroll_compare_percent_change AS
SELECT 
  YEAR,
  industry_name,
  ROUND(AVG(payroll_value)::NUMERIC, 2) AS average_payroll,
  ROUND((AVG(payroll_value) - LAG(AVG(payroll_value)) OVER (PARTITION BY industry_name ORDER BY year)) / LAG(AVG(payroll_value)) OVER (PARTITION BY industry_name ORDER BY year) * 100, 2) AS payroll_percent_change
FROM price_payroll_compare
WHERE calculation_type = 'přepočtený' AND payroll_value IS NOT NULL
GROUP BY YEAR, industry_name;

---

SELECT *
FROM price_payroll_compare_percent_change;

--

CREATE VIEW price_year_avg_all AS
SELECT
  year,
  AVG(price_value) AS avg_price_all
FROM (
  SELECT DISTINCT
    year,
    price_category_code,
    price_value
  FROM t_karel_svoboda_project_SQL_primary_final
  WHERE price_value IS NOT NULL) AS distinct_prices
GROUP BY year;

---

CREATE VIEW price_year_percent_change_all AS
SELECT
  year,
  avg_price_all,
  ROUND(((avg_price_all - LAG(avg_price_all) OVER (ORDER BY year)) / LAG(avg_price_all) OVER (ORDER BY year) * 100 )::numeric , 2) AS price_percent_change
FROM price_year_avg_all;

---

SELECT *
FROM price_year_percent_change_all;

---

CREATE VIEW payroll_country_year_avg AS
SELECT
  year,
  AVG(payroll_value) AS country_avg_payroll
FROM (
  SELECT DISTINCT
    year,
    payroll_industry_code,
    payroll_calculation_type,
    payroll_value
  FROM t_karel_svoboda_project_SQL_primary_final
  WHERE payroll_calculation_type = 'přepočtený' AND payroll_value IS NOT NULL) AS distinct_payroll
GROUP BY year;

---

SELECT * 
FROM payroll_country_year_avg;

---

CREATE VIEW payroll_country_percent_change AS
SELECT
  year,
  country_avg_payroll,
  ROUND(
    (country_avg_payroll - LAG(country_avg_payroll) OVER (ORDER BY year)) / LAG(country_avg_payroll) OVER (ORDER BY year) * 100 , 2) AS payroll_percent_change_country
FROM payroll_country_year_avg;

---

SELECT *
FROM payroll_country_percent_change;

---

SELECT
  price.year,
  price.price_percent_change AS price_year_on_year_percent,
  payroll.payroll_percent_change_country AS payroll_year_on_year_percent,
  ROUND(price.price_percent_change - payroll.payroll_percent_change_country, 2) AS gap_percentage
FROM price_year_percent_change_all AS price
JOIN payroll_country_percent_change AS payroll ON price.year = payroll.year
WHERE price.price_percent_change IS NOT NULL AND payroll.payroll_percent_change_country IS NOT NULL AND (price.price_percent_change - payroll.payroll_percent_change_country) > 10
ORDER BY gap_percentage DESC, price.year;
