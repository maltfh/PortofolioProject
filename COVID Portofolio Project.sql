
SELECT * 
FROM PortofolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT * 
--FROM PortofolioProject..CovidVaccinations
--ORDER BY 3,4

-- select data that we are going to be using
--SELECT location, date, total_cases, new_cases, total_deaths, population
--FROM PortofolioProject..CovidDeaths
--ORDER BY 1,2


-- looking at total cases vs total deaths
-- shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortofolioProject..CovidDeaths
WHERE location like '%indonesia%'
and WHERE continent is not null
ORDER BY 1,2

-- looking at total cases vs population 
-- shows what percentage of population got covid 
SELECT location, date, population, total_deaths, (total_cases/population)*100 as PercentPopulationInfected
FROM PortofolioProject..CovidDeaths
--WHERE location like '%indonesia%'
ORDER BY 1,2


-- looking at countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
FROM PortofolioProject..CovidDeaths
--WHERE location like '%indonesia%'
GROUP BY location, population
ORDER BY PercentPopulationInfected desc


-- showing countries with highest death count per population 

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortofolioProject..CovidDeaths
--WHERE location like '%indonesia%'
WHERE continent is not null
GROUP BY location, population
ORDER BY TotalDeathCount desc



-- lets break things done by continent 
-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortofolioProject..CovidDeaths
--Where location like '%indonesia%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc


SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortofolioProject..CovidDeaths
--WHERE location like '%indonesia%'
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount desc


-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortofolioProject..CovidDeaths 
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2



-- looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location, 
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortofolioProject..CovidDeaths dea
join Portofolioproject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- using CTE to perform calculation on 'partition by' in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortofolioProject..CovidDeaths dea
Join PortofolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- using temp table to perform calculation on 'partition by' in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(250),
Location nvarchar(250),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortofolioProject..CovidDeaths dea
Join PortofolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- creating view to store data for later visualizations

Create view PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortofolioProject..CovidDeaths dea
Join PortofolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3


Select *
From PercentPopulationVaccinated