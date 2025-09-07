SELECT *
FROM economies;

---

CREATE TABLE european_states (
    zeme VARCHAR(100) PRIMARY KEY);

INSERT INTO european_states (zeme) VALUES
('Austria'),('Belgium'),('Bulgaria'),('Croatia'),('Cyprus'),
('Czech Republic'),('Denmark'),('Estonia'),('Finland'),('France'),
('Germany'),('Greece'),('Hungary'),('Ireland'),('Italy'),
('Latvia'),('Lithuania'),('Luxembourg'),('Malta'),('Netherlands'),
('Poland'),('Portugal'),('Romania'),('Slovakia'),('Slovenia'),
('Spain'),('Sweden');

---

CREATE VIEW european_states_compare AS
SELECT
    economies.country AS zeme,
    economies.year AS rok,
    economies.gdp AS hruby_domaci_produkt,
    economies.gini AS gini_koeficient,
    economies.population AS populace
FROM economies
JOIN european_states ON economies.country = european_states.zeme
WHERE economies.year BETWEEN 2006 AND 2018 AND economies.country <> 'Czech Republic';

---

SELECT * 
FROM european_states_compare;

