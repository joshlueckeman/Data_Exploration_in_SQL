Select*
From Portfolio_1..['Covid-Deaths$']
where continent is not null
order by 3,4

--Select *
--From Portfolio_1..['Covid-Vaccinations$']
--order by 3,4

--Select Data that we are going to be using

Select Location, date, total_cases,new_cases,total_deaths, population
From Portfolio_1..['Covid-Deaths$']
order by 1,2

-- Looking  at Total Cases vs Total Deaths
-- Shows liklelihood of dying if you contract covid in your country
Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Portfolio_1..['Covid-Deaths$']
--Where location like '%states%'
where continent is not null
order by 1,2


--Looking at Total Cases vs Population
--Shows what percentage of population got Covid

Select continent, date,population,total_cases, (total_cases/Population)*100 as PercentPopulationInfected
From Portfolio_1..['Covid-Deaths$']
Where location like '%states%'
order by 1,2

--Looking at Countries with highest Infection Rate compared to Population

Select continent,population, Max(total_cases) as HighestInfectionCount, Max((total_cases/Population))*100 as PercentPopulationInfected
From Portfolio_1..['Covid-Deaths$']
--Where Location like '%states%'
Group by continent,population
order by PercentPopulationInfected desc

-- Showing Countries with the Highest Death Count per Population

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
From Portfolio_1..['Covid-Deaths$']
--Where Location like '%states%'
where continent is not null
Group by Continent
order by TotalDeathCount desc


-- LETS BREAK THINGS DOWN BY CONTINENT

-- Showing the continents with the highest death count per population

Select continent, SUM(cast(total_deaths as int)) as TotalDeathCount
From Portfolio_1..['Covid-Deaths$']
--Where Location like '%states%'
where continent is not null 
Group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/ SUM(New_Cases)*100 as DeathPercentage
From Portfolio_1..['Covid-Deaths$']
--Where location like '%states%'
where continent is not null
Group By date
order by 1,2

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/ SUM(New_Cases)*100 as DeathPercentage
From Portfolio_1..['Covid-Deaths$']
--Where location like '%states%'
where continent is not null
--Group By date
order by 1,2


--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as Rolling_Vaccinations 
From Portfolio_1..['Covid-Deaths$'] dea
Join Portfolio_1..['Covid-Vaccinations$'] vac
On dea.location =vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1,2,3

--USE CTE

With PopvsVac (Continent,Location,Date,Population, new_vaccinations, Rolling_Vaccinations)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as Rolling_Vaccinations
--, (Rolling_Vaccinations/population)*100
From Portfolio_1..['Covid-Deaths$'] dea
Join Portfolio_1..['Covid-Vaccinations$'] vac
On dea.location =vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3
)
Select *,(Rolling_Vaccinations/population)*100 as VaccinationPercentage
From PopvsVac

--TEMP TABLE

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
Rolling_Vaccinations numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as Rolling_Vaccinations
--, (Rolling_Vaccinations/population)*100
From Portfolio_1..['Covid-Deaths$'] dea
Join Portfolio_1..['Covid-Vaccinations$'] vac
On dea.location =vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 1,2,3

Select *,(Rolling_Vaccinations/population)*100 as VaccinationPercentage
From #PercentPopulationVaccinated

--Creating View to Store Data for later Visulaizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as Rolling_Vaccinations
--, (Rolling_Vaccinations/population)*100
From Portfolio_1..['Covid-Deaths$'] dea
Join Portfolio_1..['Covid-Vaccinations$'] vac
On dea.location =vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3


Select *
From PercentPopulationVaccinated