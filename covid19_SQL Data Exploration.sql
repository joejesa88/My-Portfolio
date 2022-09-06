/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

-- Select data that we will be starting with
SELECT location, date_info, total_cases, new_cases, total_deaths, population
FROM coviddeaths
WHERE continent is not NULL AND continent != ''
ORDER BY location, date_info;

-- Total Cases vs Total Deaths
-- Chances of dying if infected by covid-19 in Malaysia
SELECT location, date_info, total_cases, total_deaths, (total_deaths/total_cases)*100 As death_rate
FROM coviddeaths
WHERE location = 'Malaysia' AND continent is not NULL AND continent != ''
ORDER BY location, date_info;

-- Total Cases vs Population
-- Shows the percetage of population in Malaysia that has covid
SELECT location, date_info, total_cases, population, (total_cases/population)*100 As PercentCases
FROM coviddeaths
WHERE location = 'Malaysia' AND continent is not NULL AND continent != ''
ORDER BY location, date_info;

-- Countries with highest infection rate against the population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 As PercentCases
FROM coviddeaths
WHERE continent is not NULL AND continent != ''
GROUP BY location, population
ORDER BY PercentCases DESC;

-- -- Countries with highest death count per population
SELECT location, population, MAX(total_deaths) as HighestDeathCount, MAX(total_deaths/population)*100 As PercentDeaths
FROM coviddeaths
WHERE continent is not NULL AND continent != ''
GROUP BY location, population
ORDER BY PercentDeaths DESC;

-- Breaking query down by continent 
-- Continents with the highest deathcount
SELECT  continent, MAX(total_deaths) as HighestDeathCount
FROM coviddeaths
WHERE continent is not NULL AND continent != ''
GROUP BY continent
ORDER BY HighestDeathCount DESC;

-- Global cases and death percentage
SELECT  date_info,  SUM(total_cases), SUM(total_deaths), (SUM(total_deaths)/SUM(total_cases))*100 AS DeathPercentage
FROM coviddeaths
WHERE continent is not NULL AND continent != ''
ORDER BY date_info, total_cases, total_deaths,DeathPercentage;

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
SELECT cd.continent, cd.location, cd.date_info, cd.population, cv.new_vaccinations, 
SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date_info) AS RollingSumVaccinations
FROM coviddeaths AS cd
JOIN covidvaccinations AS cv
ON cd.location = cv.location
AND cd.date_info = cv.date_info
WHERE cv.new_vaccinations != 0 AND cd.continent != '';

-- Using CTE to perform Calculation on Partition By in previous query
WITH PopVac (continent, location, date_info, population, new_vaccinations, RollingSumVaccinations)
AS
( 
SELECT cd.continent, cd.location, cd.date_info, cd.population, cv.new_vaccinations, 
SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date_info) AS RollingSumVaccinations
FROM coviddeaths AS cd
JOIN covidvaccinations AS cv
ON cd.location = cv.location
AND cd.date_info = cv.date_info
WHERE cv.new_vaccinations != 0 AND cd.continent != ''
)
SELECT *,  (RollingSumVaccinations/population)*100 AS PercentVaccinated
FROM PopVac;

-- Using Temp Table to perform Calculation on Partition By in previous query
DROP TABLE IF exists #PercentVaccinated
CREATE TABLE #PercentVaccinated
(
Continent VARCHAR(30),
Location VARCHAR(30),
Date_info DATE,
Population BIGINT,
New_vaccinations INT
)
INSERT INTO #PercentVaccinated
SELECT cd.continent, cd.location, cd.date_info, cd.population, cv.new_vaccinations, 
SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date_info) AS RollingSumVaccinations
FROM coviddeaths AS cd
JOIN covidvaccinations AS cv
ON cd.location = cv.location
AND cd.date_info = cv.date_info
WHERE cv.new_vaccinations != 0 AND cd.continent != ''

SELECT *,  (RollingSumVaccinations/population)*100 AS PercentVaccinated
FROM #PercentVaccinated;

-- Creating View to store data for later visualizations
CREATE VIEW PercentVaccinated AS
SELECT cd.continent, cd.location, cd.date_info, cd.population, cv.new_vaccinations, 
SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date_info) AS RollingSumVaccinations
FROM coviddeaths AS cd
JOIN covidvaccinations AS cv
ON cd.location = cv.location
AND cd.date_info = cv.date_info
WHERE cv.new_vaccinations != 0 AND cd.continent != '';

