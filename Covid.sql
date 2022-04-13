Select *
From Covid..CovidDeaths


--Total Cases vs Total Deaths


Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Covid..CovidDeaths
Order by 1,2

--Total Cases vs Total Deaths in United States


Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Covid..CovidDeaths
Where location like '%states%'
Order by 1,2

--Total Cases vs Population in United States
--Shows the percentage of population that got covid


Select Location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
From Covid..CovidDeaths
Where location like '%states%'
Order by 1,2

--Countries with Highest Infection Rate compared to Population


Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From Covid..CovidDeaths
Group By Location, population
Order by PercentPopulationInfected desc


-- Same thing but dates included


Select Location, Population, date, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From Covid..CovidDeaths
Group By Location, population, date
Order by PercentPopulationInfected desc


-- Countries with Highest Death Count per Population


Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From Covid..CovidDeaths
Where continent is not null 
Group by Location
order by TotalDeathCount desc


-- Continents with the Highest Death Count per Population


Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From Covid..CovidDeaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc


-- Continents with the Sum of Death Count per Population


Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From Covid..CovidDeaths
Where continent is null
and location not in ('World', 'European Union', 'International', 'Upper middle income', 'High income', 'Lower middle income', 'Low income')
Group by location
order by TotalDeathCount desc


-- GLOBAL NUMBERS


Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From Covid..CovidDeaths
where continent is not null 
order by 1,2


Select *
From Covid..CovidVaccinations



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as BIGINT)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Covid..CovidDeaths dea
Join Covid..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Vaccine correlates with Death
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, dea.total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
, SUM(Cast(vac.new_vaccinations as BIGINT)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Covid..CovidDeaths dea
Join Covid..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3



-- CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Covid..CovidDeaths dea
Join Covid..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Covid..CovidDeaths dea
Join Covid..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 as PercentPopulationVaccinated
From #PercentPopulationVaccinated




-- View for visualization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Covid..CovidDeaths dea
Join Covid..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 