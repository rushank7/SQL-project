select * 
From [covid database]..[covid vaccinations]
order by 3,4

Select location, date, total_cases, total_deaths, population
From [covid database]..[covid deaths]
order by 1,2

-- Total cases vs Total deaths
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
From [covid database]..[covid deaths]
where location like '%Germany%'
order by 1,2

-- total cases vs total population
Select location, date, population, total_cases,  (total_cases/population)*100 as percentagepopulationinfected
From [covid database]..[covid deaths]
where location like '%Germany%'
order by 1,2

-- looking at countries with highest infection rate compared to population
select location, population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
from [covid database]..[covid deaths]
group by location,population
order by PercentPopulationInfected desc

-- showing countries with highest death count population
Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
from [covid database]..[covid deaths]
Where continent is not null 
Group by Location
order by TotalDeathCount desc

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
from [covid database]..[covid deaths]
Where continent is not null 
Group by continent
order by TotalDeathCount desc

-- global numbers

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_death, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as totaldeathpercentage
From [covid database]..[covid deaths]
where continent is not null	
order by 1,2


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [covid database]..[covid deaths] dea
Join [covid database]..[covid vaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3;


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [covid database]..[covid deaths] dea
Join [covid database]..[covid vaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

From [covid database]..[covid deaths] dea
Join [covid database]..[covid vaccinations] vac

-- Using Temp Table to perform Calculation on Partition By in previous query

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


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 