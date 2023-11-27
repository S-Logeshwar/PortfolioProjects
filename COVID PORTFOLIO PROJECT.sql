select * from PortfolioProject..CovidDeaths order by 3,4
select * from PortfolioProject..CovidVaccinations order by 3,4
select location,date,total_cases,new_cases,total_deaths,population from PortfolioProject..CovidDeaths
order by 1,2
--DEATH PERCENTAGE
select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage from PortfolioProject..CovidDeaths
where location like '%india%'
order by 1,2
select TYPE_NAME(total_deaths) from PortfolioProject..CovidDeaths
select total_deaths from port
ALTER TABLE portfolioproject..coviddeaths
ALTER COLUMN total_deaths float;

--LOOKING AT TOTAL CASES VS POPULATION
--SHOWS WHAT PERCENTAGE OF POPULATION GOT COVID
select location,date,total_cases,population, (total_cases/population)*100 as DeathPercentage from PortfolioProject..CovidDeaths
where location like '%india%' order by 1,2

--LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION
select location,population,MAX(TOTAL_CASES)as highest_infection_count, max(((total_cases/population))*100) as percentPopulationInfected from PortfolioProject..CovidDeaths
--where location like '%india%' 
Group by Location,population
order by percentPopulationInfected desc
--LETS BREAK THINGS DOWN BY CONTINENT
select location,MAX(Total_Deaths) as TotalDeathCount from PortfolioProject..CovidDeaths
--where location like '%india%'
where continent is null
Group by location 
order by TotalDeathCount desc

--SHOWING COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION
select location,MAX(Total_Deaths) as TotalDeathCount from PortfolioProject..CovidDeaths
--where location like '%india%'
where continent is not null
Group by Location 
order by TotalDeathCount desc

--SHOWING THE CONTINENTS WITH THE HIGHEST DEATH COUNT PER POPULATION
select continent,Max(Total_Deaths) as totalDeathCount 
from PortfolioProject..CovidDeaths 
where continent is not null 
group by continent 
order by TotalDeathCount desc

--GLOBAL NUMBERS (INCORRECT)
select date,SUM(NEW_CASES) as total_cases,sum(cast(New_deaths as int)) as total_deaths, SUM(Cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage from PortfolioProject..CovidDeaths
--where location like '%india%'
where continent is not null
--group by date
order by 1,2
--LOOKING AT TOTAL POPULATION VS VACCINATIONS

with PopvsVac (Continent,Location,Date,population,New_Vaccinations,RollingpeopleVaccinated)
as
(

SELECT DEA.CONTINENT,DEA.LOCATION,DEA.DATE,DEA.POPULATION,VAC.NEW_VACCINATIONS,SUM(CAST(VAC.NEW_VACCINATIONS AS BIGINT)) OVER (PARTITION BY DEA.LOCATION order by dea.location,
dea.date) AS RollingPeopleVaccinated 
--(RollingPeopleVaccinated/Population)*100
FROM PortfolioProject..COVIDDEATHS DEA
JOIN PortfolioProject..CovidVaccinations VAC
ON DEA.LOCATION=VAC.LOCATION AND DEA.DATE = VAC.DATE
WHERE DEA.CONTINENT IS NOT NULL
--ORDER BY 2,3
)
select *,(RollingPeopleVaccinated/Population)*100
from popvsvac
--USE CTE

Drop table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from PortfolioProject..CovidDeaths dea join portfolioproject..covidvaccinations vac on dea.location = vac.location and dea.date=vac.date
--where dea.continent is not null
select *,(rollingpeoplevaccinated/population)*100 from #PercentPopulationVaccinated

--CREATEING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

CREATE VIEW PercentPopulationVaccinated AS
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from PortfolioProject..CovidDeaths dea join portfolioproject..covidvaccinations vac on dea.location = vac.location and dea.date=vac.date
WHERE DEA.CONTINENT IS NOT NULL
--ORDER BY 2,3

SELECT * FROM PercentPopulationVaccinated

--QUERIES USED FOR TABLEU VISUALIZATION

-- 1. 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location


--Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
----Where location like '%states%'
--where location = 'World'
----Group By date
--order by 1,2


-- 2. 

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


-- 3.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


-- 4.


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc
