SELECT *
FROM economies;

---

CREATE OR REPLACE VIEW economies_same_years AS
SELECT 
    economies.year,
    economies.gdp AS hruby_domaci_produkt,
    economies.gini AS gini_koeficient,
    economies.population AS populace
FROM economies
JOIN countries ON economies.country = countries.country
WHERE countries.country = 'Czech Republic' AND economies.year BETWEEN 2006 AND 2018;

---

select * 
FROM economies_same_years;

---

CREATE OR REPLACE VIEW average_payroll_and_price_by_year AS
SELECT
    year,
    AVG(payroll_value) AS prumerna_mzda,
    AVG(price_value) AS prumerna_cena_potravin
FROM t_karel_svoboda_project_SQL_primary_final
WHERE year BETWEEN 2006 AND 2018
GROUP BY year;

---

SELECT *
FROM average_payroll_and_price_by_year;

---

CREATE VIEW comparison_gdp_payroll_price_growth AS
SELECT
    economies_same_years.year,
    ROUND(((economies_same_years.hruby_domaci_produkt - LAG(economies_same_years.hruby_domaci_produkt) OVER (ORDER BY economies_same_years.year)) 
          / LAG(economies_same_years.hruby_domaci_produkt) OVER (ORDER BY economies_same_years.year) * 100)::numeric, 2) 
          AS mezirocni_rust_hrubeho_domaciho_produktu_v_procentech,
    ROUND(((average_payroll_and_price_by_year.prumerna_mzda - LAG(average_payroll_and_price_by_year.prumerna_mzda) OVER (ORDER BY economies_same_years.year)) 
          / LAG(average_payroll_and_price_by_year.prumerna_mzda) OVER (ORDER BY economies_same_years.year) * 100)::numeric, 2) 
          AS mezirocni_rust_prumerne_mzdy_v_procentech,
    ROUND(((average_payroll_and_price_by_year.prumerna_cena_potravin - LAG(average_payroll_and_price_by_year.prumerna_cena_potravin) OVER (ORDER BY economies_same_years.year)) 
          / LAG(average_payroll_and_price_by_year.prumerna_cena_potravin) OVER (ORDER BY economies_same_years.year) * 100)::numeric, 2) 
          AS mezirocni_rust_prumerne_ceny_potravin_v_procentech
FROM economies_same_years
JOIN average_payroll_and_price_by_year ON economies_same_years.year = average_payroll_and_price_by_year.year;

---

SELECT *
FROM comparison_gdp_payroll_price_growth;

---

CREATE VIEW gdp_payroll_price_lag_comparison AS
SELECT
    year,
    LAG(mezirocni_rust_hrubeho_domaciho_produktu_v_procentech, 1) OVER (ORDER BY year) AS rust_hrubeho_domaciho_produktu_predchoziho_roku_v_procentech,
    mezirocni_rust_prumerne_mzdy_v_procentech AS rust_prumerne_mzdy_v_tomto_roce_v_procentech,
    mezirocni_rust_prumerne_ceny_potravin_v_procentech AS rust_prumerne_ceny_potravin_v_tomto_roce_v_procentech
FROM comparison_gdp_payroll_price_growth
WHERE year > 2006;

---

SELECT *
FROM gdp_payroll_price_lag_comparison;


--kolerace ve stejném roce
SELECT 
  corr(mezirocni_rust_hrubeho_domaciho_produktu_v_procentech,
       mezirocni_rust_prumerne_mzdy_v_procentech) AS korelace_hruby_domaci_produkt_versus_mzdy_stejny_rok,
  corr(mezirocni_rust_hrubeho_domaciho_produktu_v_procentech,
       mezirocni_rust_prumerne_ceny_potravin_v_procentech) AS korelace_hruby_domaci_produkt_versus_ceny_stejny_rok
FROM comparison_gdp_payroll_price_growth
WHERE mezirocni_rust_hrubeho_domaciho_produktu_v_procentech IS NOT NULL AND mezirocni_rust_prumerne_mzdy_v_procentech IS NOT NULL AND mezirocni_rust_prumerne_ceny_potravin_v_procentech IS NOT NULL;

---

--kolerace se zpožděním o jeden rok
SELECT
  corr(rust_hrubeho_domaciho_produktu_predchoziho_roku_v_procentech,
       rust_prumerne_mzdy_v_tomto_roce_v_procentech) AS korelace_hruby_domaci_produkt_minuly_rok_versus_mzdy_tento_rok,
  corr(rust_hrubeho_domaciho_produktu_predchoziho_roku_v_procentech,
       rust_prumerne_ceny_potravin_v_tomto_roce_v_procentech) AS korelace_hruby_domaci_produkt_minuly_rok_versus_ceny_tento_rok
FROM gdp_payroll_price_lag_comparison
WHERE rust_hrubeho_domaciho_produktu_predchoziho_roku_v_procentech IS NOT NULL AND rust_prumerne_mzdy_v_tomto_roce_v_procentech IS NOT NULL AND rust_prumerne_ceny_potravin_v_tomto_roce_v_procentech IS NOT NULL;
