/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4


-- Select Data that we are going to be starting with

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

select location, date, total_cases,  total_deaths, (CAST(total_deaths AS FLOAT) / total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%' 
and continent is not null 
order by 1,2

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

select location, date, population ,total_cases, (CAST(total_cases AS FLOAT)/ population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%states%'
order by 1,2


-- Countries with Highest Infection Rate compared to Population

select location, population ,MAX(total_cases) as HighestInfectionCount, MAX((CAST(total_cases AS FLOAT)/ population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%states%'
group by location, population
order by PercentPopulationInfected desc


-- Countries with Highest Death Count per Population

select location, MAX(total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by location
order by TotalDeathCount desc

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

select continent, MAX(total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where continent is not null
where location like '%states%'
group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS

select SUM(new_cases) as TotalCases,  SUM(new_deaths) as TotalDeaths, (CAST(SUM(new_deaths) AS FLOAT))/ SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null 
--group by date
order by 1,2


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(CAST(cv.new_vaccinations AS INT)) OVER(partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths cd
join PortfolioProject..CovidVaccinations cv
	on cd.location = cv.location and cd.date = cv.date
where cd.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

WITH PopvsVac(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS(
	select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(CAST(cv.new_vaccinations AS INT)) OVER(partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths cd
join PortfolioProject..CovidVaccinations cv
	on cd.location = cv.location and cd.date = cv.date
where cd.continent is not null 
--order by 2,3
)
select *, (CAST(RollingPeopleVaccinated AS FLOAT))/population*100 as TotalVacc
from PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_vaccinations numeric,
	RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(CAST(cv.new_vaccinations AS INT)) OVER(partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths cd
join PortfolioProject..CovidVaccinations cv
	on cd.location = cv.location and cd.date = cv.date
--where cd.continent is not null 
--order by 2,3

select *, (CAST(RollingPeopleVaccinated AS FLOAT))/population*100 as TotalVacc
from #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

drop view if exists PercentPopulationVaccinated
create view PercentPopulationVaccinated as
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(CAST(cv.new_vaccinations AS INT)) OVER(partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths cd
join PortfolioProject..CovidVaccinations cv
	on cd.location = cv.location and cd.date = cv.date
where cd.continent is not null 
--order by 2,3

select *
from PercentPopulationVaccinated





















