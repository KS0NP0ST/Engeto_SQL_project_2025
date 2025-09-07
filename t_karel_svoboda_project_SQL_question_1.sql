CREATE VIEW payroll_year_industry AS
SELECT
  year,
  payroll_industry_code,
  payroll_industry_name,
  payroll_calculation_code,
  payroll_calculation_type,
  payroll_value
FROM t_karel_svoboda_project_SQL_primary_final;

---

SELECT *
FROM payroll_year_industry;

---

CREATE VIEW compare_avg_payroll AS
SELECT
  year,
  payroll_industry_name AS industry_name,
  AVG(payroll_value) AS avg_payroll
FROM payroll_year_industry
WHERE payroll_calculation_type = 'přepočtený' AND payroll_value IS NOT NULL
GROUP BY year, payroll_industry_name;

---

SELECT * 
FROM compare_avg_payroll 
ORDER BY industry_name, year;

---

SELECT
    industry_name,
    year,
    avg_payroll,
    avg_payroll - LAG(avg_payroll) OVER (PARTITION BY industry_name ORDER BY year) AS result
FROM compare_avg_payroll
ORDER BY industry_name, year;

---

SELECT *
FROM (
    SELECT
        industry_name,
        year,
        ROUND(avg_payroll) AS avg_payroll,
        ROUND((avg_payroll - LAG(avg_payroll) OVER (PARTITION BY industry_name ORDER BY year)) / LAG(avg_payroll) OVER (PARTITION BY industry_name ORDER BY year) * 100, 2) AS result_percent
    FROM compare_avg_payroll
) subSelect_x
WHERE result_percent < 0
ORDER BY result_percent  DESC;

