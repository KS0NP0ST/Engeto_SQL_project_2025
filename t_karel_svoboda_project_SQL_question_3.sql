SELECT *	
FROM t_karel_svoboda_project_SQL_primary_final;

---

CREATE VIEW category_price_year_compare AS
SELECT
    EXTRACT(YEAR FROM price_date_from)::int AS year,
    price_category_name,
    price_value
FROM t_karel_svoboda_project_SQL_primary_final;

---

SELECT *	
FROM category_price_year_compare;

---

CREATE VIEW category_price_year_avg AS
SELECT
    year,
    price_category_name,
    AVG(price_value) AS avg_price
FROM category_price_year_compare
GROUP BY year, price_category_name;

---

CREATE VIEW category_price_year_change AS
SELECT
    year,
    price_category_name,
    avg_price,
    ROUND(((avg_price - LAG(avg_price) OVER (PARTITION BY price_category_name ORDER BY year)) / LAG(avg_price) OVER (PARTITION BY price_category_name ORDER BY year) * 100 )::numeric , 2) AS percent_change
FROM category_price_year_avg;

---

SELECT * 
FROM category_price_year_change;

---

SELECT 
    price_category_name,
    ROUND(AVG(percent_change)::numeric, 2) AS avg_percent_change
FROM category_price_year_change
WHERE percent_change IS NOT NULL
GROUP BY price_category_name
HAVING AVG(percent_change) > 0
ORDER BY avg_percent_change ASC
LIMIT 1;
