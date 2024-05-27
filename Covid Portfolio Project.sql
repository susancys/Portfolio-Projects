#Covid 19 Data Exploration
#Skills used: Joins, CTE's, Temporary Tables, Window Functions, Aggregate Functions, Views, Converting Data Types

-- Modify column name properly

USE portfolioproject;
ALTER TABLE coviddeaths2 RENAME COLUMN date TO record_date;
ALTER TABLE covidvaccinations2 RENAME COLUMN date TO record_date;

-- Modify data type from date strings to the data formate matching MySQL

ALTER TABLE coviddeaths2 ADD COLUMN record_date_converted DATE;
SET @@session.sql_mode = 'ALLOW_INVALID_DATES';
UPDATE coviddeaths2
SET record_date_converted = STR_TO_DATE(record_date, '%m/%d/%y');
ALTER TABLE coviddeaths2 DROP COLUMN record_date;
ALTER TABLE coviddeaths2 MODIFY record_date_converted DATE AFTER location;

ALTER TABLE covidvaccinations2 ADD COLUMN record_date_converted DATE;
SET @@session.sql_mode = 'ALLOW_INVALID_DATES';
UPDATE covidvaccinations2
SET record_date_converted = STR_TO_DATE(record_date, '%m/%d/%y');
ALTER TABLE covidvaccinations2 DROP COLUMN record_date;
ALTER TABLE covidvaccinations2 MODIFY record_date_converted DATE AFTER location;


-- Select data that we are going to starting with

SELECT * 
	FROM coviddeaths2
    WHERE continent IS NOT NULL AND continent <>'';
SELECT location, record_date_converted, total_cases, new_cases, total_deaths, population
	FROM coviddeaths2
    WHERE continent IS NOT NULL AND continent <> ''
    ORDER BY iso_code, continent;

-- Total cases vs. total deaths
-- Shows likelihood of death if one gets Covid in their country

SELECT location, record_date_converted, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
	FROM coviddeaths2
    WHERE continent IS NOT NULL AND continent <> ''
    ORDER BY iso_code, continent;

-- Total cases vs. population
-- Demonstrates the percentage of population infected with Covid

SELECT location, record_date_converted, population, total_cases, (total_cases/population)*100 AS Percentage_Population_Infected
	FROM coviddeaths2
    ORDER BY iso_code, continent;

-- Countries with highest infection rate compared to Population

SELECT location, population, MAX(total_cases) AS highest_infection_count, MAX((total_cases/population))*100 AS percent_population_infected
	FROM coviddeaths2
    GROUP BY location, population
    ORDER BY percent_population_infected DESC;

-- Countries with highest death count per Population

SELECT location, MAX(total_deaths) AS total_death_count
	FROM coviddeaths2
    WHERE continent IS NOT NULL AND continent <> ''
    GROUP BY location
    ORDER BY total_death_count DESC;

-- Breaking data down by Continent
-- Showing continents withi the highest death count per Population

SELECT continent, MAX(CAST(total_deaths AS float)) AS total_death_count
	FROM coviddeaths2
    WHERE continent IS NOT NULL AND continent <> ''
    GROUP BY continent
    ORDER BY total_death_count DESC;

-- Global numbers

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS float)) AS total_deaths, SUM(CAST(new_deaths AS float))/SUM(new_cases)*100 AS death_percentage
	FROM coviddeaths2
    WHERE continent IS NOT NULL AND continent <> ''
    ORDER BY iso_code, continent;

-- Total population vs. vaccinations
-- Demonstrates percentage of population that has received a minimum of 1 vaccine

SELECT dea.continent, dea.location, dea.record_date_converted, dea.population, vac.new_vaccinations, SUM(CONVERT(vac.new_vaccinations, float))
OVER(PARTITION BY dea.location ORDER BY dea.location, dea.record_date_converted) AS rolling_people_vaccinated
	FROM coviddeaths2 dea 
    JOIN covidvaccinations2 vac
    ON dea.location = vac.location AND dea.record_date_converted = vac.record_date_converted
    WHERE dea.continent IS NOT NULL AND dea.continent <> ''
    ORDER BY continent, location;

-- Use CTE to perform calculation on Partition By in previous query

With Pop_vs_vac (continent, location, record_date_converted, population, new_vaccinations, rolling_people_vaccinated)
AS
(
SELECT dea.continent, dea.location, dea.record_date_converted, dea.population, vac.new_vaccinations, SUM(CONVERT(vac.new_vaccinations, float))
OVER(PARTITION BY dea.location ORDER BY dea.location, dea.record_date_converted) AS rolling_people_vaccinated
	FROM coviddeaths2 dea 
    JOIN covidvaccinations2 vac
    ON dea.location = vac.location AND dea.record_date_converted = vac.record_date_converted
    WHERE dea.continent IS NOT NULL AND dea.continent <> ''
)
SELECT *, (rolling_people_vaccinated/population)*100 AS vaccination_rate_population
FROM pop_vs_vac;

-- Use temporary tables to perform calculations on Partition By in previous query

DROP TABLE IF EXISTS percent_population_vaccinated;
CREATE TABLE percent_population_vaccinated
(
continent varchar(255),
location varchar(255),
record_date_converted date,
population int,
new_vaccinations int,
rolling_people_vaccinated int
)
SELECT dea.continent, dea.location, dea.record_date_converted, dea.population, vac.new_vaccinations, SUM(CONVERT(vac.new_vaccinations, float))
OVER(PARTITION BY dea.location ORDER BY dea.location, dea.record_date_converted) AS rolling_people_vaccinated
	FROM coviddeaths2 dea 
    JOIN covidvaccinations2 vac
    ON dea.location = vac.location AND dea.record_date_converted = vac.record_date_converted
    WHERE dea.continent IS NOT NULL AND dea.continent <> '';
SELECT *, (rolling_people_vaccinated/population)*100 AS vaccination_rate_population
FROM percent_population_vaccinated;

-- Create view to store data for visualizations

DROP VIEW IF EXISTS v_percent_population_vaccinated;
CREATE VIEW v_percent_population_vaccinated AS
SELECT dea.continent, dea.location, dea.record_date_converted, dea.population, vac.new_vaccinations, SUM(CONVERT(vac.new_vaccinations, float))
OVER(PARTITION BY dea.location ORDER BY dea.location, dea.record_date_converted) AS rolling_people_vaccinated
    FROM coviddeaths2 dea
    JOIN covidvaccinations2 vac
		ON dea.location = vac.location
        AND dea.record_date_converted = vac.record_date_converted
	WHERE dea.continent IS NOT NULL AND dea.continent <>'';