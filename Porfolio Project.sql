
select *
From PortfolioProject..CovidDeaths
where continent is not null
order by 3,4


--select *
--From PortfolioProject..CovidVacinations
--order by 3,4

--select Data that we are going to be using


select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

--looking at toal cases vs total deaths
--shows liklihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (CAST(total_deaths as float))/(CAST(total_cases as float)) * 100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

--looking at total cases vs population
--shows what percent of population got covid
select location, date, population, total_cases, (total_cases/population) * 100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2


--looking at countries with highest infection rate compared to population
select location, population, MAX(cast(total_cases as bigint)) as HighestInfectionCount, MAX((total_cases/population)) * 100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--where location like '%states%'
Group by location, population
order by PercentPopulationInfected desc


--showing countries with highest death count per population

--LET'S BREAK THINGS DOWN BY CONTINENT

-- showing continents with highest death count per population

select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS

select   sum(cast(total_cases as decimal)) as total_cases, sum(cast(total_deaths as decimal)) as total_deaths, SUM(cast(total_deaths as decimal))/SUM(cast(total_cases as decimal)) *100 as DeathPercentage
From PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
--group by date
order by 1,2

-- looking at total population vs vacinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by
dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) * 100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVacinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE CTE

with POPvsVAC (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by
dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) * 100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVacinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population) * 100
From POPvsVAC


--TEMP TABLE

DROP table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by
dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) * 100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVacinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population) * 100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

create view PercentPeopleVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by
dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) * 100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVacinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
From PercentPeopleVaccinated