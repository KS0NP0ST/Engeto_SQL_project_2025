CREATE TABLE t_karel_svoboda_project_SQL_primary_final AS
SELECT
  czechia_payroll.payroll_year AS year,
  czechia_payroll_industry_branch.code AS payroll_industry_code,
  czechia_payroll_industry_branch.name AS payroll_industry_name,
  czechia_payroll_calculation.code AS payroll_calculation_code,
  czechia_payroll_calculation.name AS payroll_calculation_type,
  czechia_payroll.value AS payroll_value,
  czechia_price_category.code AS price_category_code,
  czechia_price_category.name AS price_category_name,
  czechia_price_category.price_unit AS price_unit,
  czechia_price.value AS price_value,
  czechia_price.date_from::date AS price_date_from,
  czechia_price.date_to::date AS price_date_to
FROM czechia_payroll
JOIN czechia_payroll_industry_branch ON czechia_payroll.industry_branch_code = czechia_payroll_industry_branch.code
JOIN czechia_payroll_calculation ON czechia_payroll.calculation_code = czechia_payroll_calculation.code
JOIN czechia_price ON czechia_payroll.payroll_year = EXTRACT(YEAR FROM czechia_price.date_from)
JOIN czechia_price_category ON czechia_price.category_code = czechia_price_category.code;

---

SELECT *
FROM t_karel_svoboda_project_SQL_primary_final;