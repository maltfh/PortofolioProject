/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/



SELECT * 
FROM PortofolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

	
SELECT * 
FROM PortofolioProject..CovidVaccinations
ORDER BY 3,4

	
-- Select data that we are going to be using
	
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortofolioProject..CovidDeaths
ORDER BY 1,2


-- Looking at total cases vs total deaths
-- Shows likelihood of dying if you contract covid in your country
	
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortofolioProject..CovidDeaths
WHERE location like '%indonesia%'
and WHERE continent is not null
ORDER BY 1,2

	
-- Looking at total cases vs population 
-- Shows what percentage of population got covid 
	
SELECT location, date, population, total_deaths, (total_cases/population)*100 as PercentPopulationInfected
FROM PortofolioProject..CovidDeaths
--WHERE location like '%indonesia%'
ORDER BY 1,2


-- Looking at countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
FROM PortofolioProject..CovidDeaths
--WHERE location like '%indonesia%'
GROUP BY location, population
ORDER BY PercentPopulationInfected desc


-- Showing countries with highest death count per population 

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortofolioProject..CovidDeaths
--WHERE location like '%indonesia%'
WHERE continent is not null
GROUP BY location, population
ORDER BY TotalDeathCount desc


-- Lets break things done by continent 
-- Showing contintents with the highest death count per population

SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortofolioProject..CovidDeaths
--WHERE location like '%indonesia%'
WHERE continent is not null 
GROUP BY continent
ORDER BY TotalDeathCount desc


SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortofolioProject..CovidDeaths
--WHERE location like '%indonesia%'
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount desc


-- GLOBAL NUMBERS

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM PortofolioProject..CovidDeaths 
--WHERE location like '%states%'
wHERE continent is not null 
--GROUP BY Date
ORDER BY 1,2


-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location, 
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortofolioProject..CovidDeaths dea
JOIN Portofolioproject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null 
ORDER BY 2,3


-- Using CTE to perform calculation on Partition By in previous query

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortofolioProject..CovidDeaths dea
JOIN PortofolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null 
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


-- Using temp table to perform calculation on partition by in previous query

DROP Table if exists #PercentPopulationVaccinated
CREATE Table #PercentPopulationVaccinated
(
Continent nvarchar(250),
Location nvarchar(250),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortofolioProject..CovidDeaths dea
JOIN PortofolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent is not null 
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


-- Creating view to store data for later visualizations

CREATE view PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortofolioProject..CovidDeaths dea
JOIN PortofolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null 
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated

