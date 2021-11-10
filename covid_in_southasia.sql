CREATE DATABASE covid;

USE covid;

SELECT * FROM main;

-- Overview of tables

SELECT * FROM main;

SELECT * FROM vaccinations;

SELECT * FROM economic;

SELECT * FROM facilities;

SELECT * FROM life_expectancy;

SELECT * FROM stringency;


-- Mortality Rate by Country

SELECT
	location,
	MAX(population) as population,
	MAX(total_cases) AS total_cases,
	MAX(total_deaths) AS total_deaths,
	((MAX(CAST((total_deaths) AS FLOAT))/MAX(CAST((total_cases) AS FLOAT))))*100 AS mortality_rate
FROM main
GROUP BY location
ORDER BY 4 DESC;



-- Percentage Population Infected by Country

SELECT
	location,
	MAX(population) as population,
	MAX(total_cases) AS total_cases,
	((MAX(CAST((total_cases) AS FLOAT))/MAX(CAST((population) AS FLOAT))))*100 AS pct_population_infected

FROM main
GROUP BY location
ORDER BY 4 DESC;


-- Effect of Population Density on Infection Rate

SELECT
	location,
	MAX(population) as population,
	MAX(population_density) AS population_density,
	((MAX(CAST((total_cases) AS FLOAT))/MAX(CAST((population) AS FLOAT))))*100 AS pct_population_infected,
	MAX(total_cases) AS total_cases,
	MAX(total_deaths) AS total_deaths
FROM main
GROUP BY location
ORDER BY 3 DESC;


-- Effect of GDP on Infection & Mortality Rate

SELECT
	m.location,
	MAX(m.population) as population,
	MAX(e.gdp_per_capita) as gdp_per_capita,
	((MAX(CAST((m.total_cases) AS FLOAT))/MAX(CAST((m.population) AS FLOAT))))*100 AS pct_population_infected,
	MAX(m.total_cases) AS total_cases,
	MAX(m.total_deaths) AS total_deaths,
	((MAX(CAST((m.total_deaths) AS FLOAT))/MAX(CAST((m.total_cases) AS FLOAT))))*100 AS mortality_rate
FROM main m
	JOIN economic e
		ON m.location = e.location
			AND m.date = e.date
GROUP BY m.location
ORDER BY 3 DESC;


-- Effect of Vaccinations on Mortality Rate

SELECT
	m.location,
	MAX(m.population) as population,
	MAX(m.total_cases) AS total_cases,
	MAX(m.total_deaths) AS total_deaths,
	((MAX(CAST((v.people_fully_vaccinated) AS FLOAT))/MAX(CAST((m.population) AS FLOAT))))*100 AS people_fully_vaccinated,
	((MAX(CAST((m.total_deaths) AS FLOAT))/MAX(CAST((m.total_cases) AS FLOAT))))*100 AS mortality_rate
FROM main m
	JOIN vaccinations v
		ON m.location = v.location
			AND m.date = v.date
GROUP BY m.location
ORDER BY 5 DESC;


-- Correlation of Life Expectancy with Infection and Mortality Rate

SELECT
	m.location,
	MAX(m.population) as population,
	((MAX(CAST((m.total_cases) AS FLOAT))/MAX(CAST((m.population) AS FLOAT))))*100 AS pct_population_infected,
	MAX(m.total_cases) AS total_cases,
	MAX(m.total_deaths) AS total_deaths,
	((MAX(CAST((m.total_deaths) AS FLOAT))/MAX(CAST((m.total_cases) AS FLOAT))))*100 AS mortality_rate,
	MAX(l.life_expectancy) AS life_expectancy
FROM main m
	JOIN life_expectancy l
		ON m.location = l.location
			AND m.date = l.date
GROUP BY m.location
ORDER BY 7 DESC;


-- Correlation of Old Age with Mortality Rate

SELECT
	m.location,
	MAX(m.population) as population,
	((MAX(CAST((m.total_cases) AS FLOAT))/MAX(CAST((m.population) AS FLOAT))))*100 AS pct_population_infected,
	MAX(m.total_cases) AS total_cases,
	MAX(m.total_deaths) AS total_deaths,
	((MAX(CAST((m.total_deaths) AS FLOAT))/MAX(CAST((m.total_cases) AS FLOAT))))*100 AS mortality_rate,
	MAX(a.median_age) AS median_age,
	MAX(a.aged_65_older) AS aged_65_older,
	MAX(a.aged_70_older) AS age_70_and_above
FROM main m
	JOIN age_group a
		ON m.location = a.location
			AND m.date = a.date
GROUP BY m.location
ORDER BY 6 DESC;


-- Effect of availability of Hospital Beds on Mortality Rate

SELECT
	m.location,
	MAX(m.total_cases) AS total_cases,
	MAX(m.total_deaths) AS total_deaths,
	((MAX(CAST((m.total_deaths) AS FLOAT))/MAX(CAST((m.total_cases) AS FLOAT))))*100 AS mortality_rate,
	MAX(f.hospital_beds_per_thousand) AS hospital_beds_per_thousand
FROM main m
	JOIN facilities f
		ON m.location = f.location
			AND m.date = f.date
GROUP BY m.location
ORDER BY 5 DESC;


-- Aggregates for South Asia

WITH by_country (location, population, cases, deaths, full_vaccinations)
AS
(	SELECT
		m.location,
		MAX(m.population) AS population,
		MAX(m.total_cases) AS cases,
		MAX(m.total_deaths) AS deaths,
		MAX(v.people_fully_vaccinated) AS full_vaccinations
	FROM main m
		JOIN vaccinations AS v
			ON m.date = v.date
				AND m.location = v.location
	GROUP BY m.location
)

SELECT
	SUM(b.population) population,
	SUM(b.cases) AS total_cases,
	SUM(b.deaths) AS total_deaths,
	SUM(b.full_vaccinations) AS full_vaccinations,
	(SUM(CAST((b.cases) AS FLOAT))/SUM(CAST((b.population) AS FLOAT)))*100 AS pct_population_infected,
	(SUM(CAST((b.deaths) AS FLOAT))/SUM(CAST((b.cases) AS FLOAT)))*100 AS mortality_rate,
	(SUM(CAST((b.full_vaccinations) AS FLOAT))/SUM(CAST((b.population) AS FLOAT)))*100 AS pct_population_fully_vaccinated
FROM by_country b;


-- Exports for Visualization

-- Aggregate numbers by country

SELECT
	m.location,
	MAX(m.population) AS population,
	MAX(m.total_cases) AS cases,
	MAX(m.total_deaths) AS deaths,
	MAX(v.people_fully_vaccinated) AS full_vaccinations
FROM main m
	JOIN vaccinations AS v
		ON m.date = v.date
			AND m.location = v.location
GROUP BY m.location
ORDER BY m.location;