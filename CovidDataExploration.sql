/*
COVID-19 DATA EXPLORATION

SKILLS SHOWCASED: 
	** Joins
	** CTE's
	** Temp Tables
	** Windows Functions
	** Aggregate Functions
	** Creating Views
	** Converting Data Types
*/

SELECT *
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL 
ORDER BY 3,4


-- SELECT DATA THAT WE ARE GOING TO BE STARTING WITH

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidProject..CovidDeaths
WHERE continent is not null 
ORDER BY 1,2


-- TOTAL CASES vs TOTAL DEATHS
-- THIS SHOWS THE LIKELIHOOD OF DYINGIF YOU CONTRACT COVID-19 IN YOUR COUNTRY

SELECT location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidProject..CovidDeaths
WHERE location = 'Zimbabwe' AND continent IS NOT NULL 
ORDER BY 1,2


-- TOTAL CASES vs POPULATION
-- SHOWS WHAT PERCENTAGE OF POPULATION IS INFECTED WITH COVID-19

SELECT location, date, population, total_cases,  (total_cases/population)*100 AS PercentPopulationInfected
FROM CovidProject..CovidDeaths
ORDER BY 1,2


-- COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION

SELECT location, population, MAX(total_cases) AS HighestInfectionCount,  MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM CovidProject..CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC


-- COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION 

SELECT location, MAX(CAST(Total_deaths AS INT)) AS TotalDeathCount
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY location
ORDER BY TotalDeathCount DESC



-- BREAKING THINGS DOWN BY CONTINENT
-- SHOWING CONTINENTS WITH THE HIGHEST DEATH COUNT PER POPULATION

SELECT continent, MAX(CAST(Total_deaths AS INT)) AS TotalDeathCount
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC



-- GLOBAL NUMBERS

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(New_Cases)*100 AS DeathPercentage
FROM CovidProject..CovidDeaths
WHERE continent is not null 
ORDER BY 1,2



-- TOTAL POPULATION vs VACCINATIONS
-- SHOWS THE PERCENTAGE OF POPULATION THAT HAS RECEIVED AT LEAST ONE COVID-19 VACCINE

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM CovidProject..CovidDeaths dea
JOIN CovidProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


-- USING CTE TO PERFORM A CALCULATION ON [PARTITION BY] IN PREVIOUS QUERY

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM CovidProject..CovidDeaths dea
JOIN CovidProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac



-- USING TEMP TABLE TO PERFORM A CALCULATION ON [PARTITION BY] IN PREVIOUS QUERY

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM CovidProject..CovidDeaths dea
JOIN CovidProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated

-- CREATING A VIEW TO STORE DATA FOR LATER VISUALIZATIONS

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM CovidProject..CovidDeaths dea
JOIN CovidProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT * FROM PercentPopulationVaccinated
