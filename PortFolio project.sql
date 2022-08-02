select *
from [Portfolio project]..coviddeaths
order by 3,4


--select *
--from [Portfolio project]..coviddeaths
--order by 3,4
--select Data we are going to be using


select Location,date,total_cases, new_cases, total_deaths, population
FROM [Portfolio project]..coviddeaths
Order by 1,3

--Changing dtype for total cases and total deaths
Alter table coviddeaths alter column total_deaths float
Alter table coviddeaths alter column total_cases float

--Looking at Total Cases vs Total Deaths
select Location,date,total_cases, total_deaths, (total_deaths / nullif (total_cases,0)) * 100 as PercentagePopulation
FROM [Portfolio project]..coviddeaths
--WHERE location = 'Botswana'
WHERE continent is not null
Order by 1,2
 
 --Looking at Total Cases vs Population
 Alter table coviddeaths alter column population float
 select Location,date, population, total_cases,(total_deaths / nullif (population,0)) * 100 as PercentagePopulation
FROM [Portfolio project]..coviddeaths
--WHERE location = 'Botswana'
WHERE continent is not null
Order by 1,2

--Countries with Highest Infection rate compared with Population
Alter table coviddeaths alter column population float
 select Location,population, MAX(total_cases) as HighestInfectionCount, Max(total_deaths / nullif (population,0)) * 100 as PercentagePopulation
FROM [Portfolio project]..coviddeaths
--WHERE location = 'Slovenia'
WHERE continent is not null
Group by location, population
Order by PercentagePopulation desc

--Countries with Highest Death Count per Population
Alter table coviddeaths alter column population float
 select Location, MAX(cast(total_deaths as int)) as TotaldeathCount
FROM [Portfolio project]..coviddeaths
--WHERE location = 'Slovenia'
WHERE continent is not null
Group by location
Order by TotaldeathCount desc

--                  BREAK DOWN BY CONTINENTS

--Continents with highest death count per population
 select continent, MAX(cast(total_deaths as int)) as TotaldeathCount
FROM [Portfolio project]..coviddeaths
--WHERE location = 'Slovenia'
WHERE continent is not null
Group by continent
Order by TotaldeathCount desc

--GLOBAL NUMBERS
Alter table coviddeaths alter column new_deaths float
Alter table coviddeaths alter column new_cases float
select SUM(new_cases) as total_cases, SUM(new_deaths)as total_deaths, SUM(new_deaths) / nullif(SUM(new_cases),0)* 100 as DeathPercentage
FROM [Portfolio project]..coviddeaths
--WHERE location = 'Botswana'
WHERE continent is not null
--Group by date
Order by 1,2 

--Joining deaths and Vaccinations
Select *
From [Portfolio project]..coviddeaths dea
join [Portfolio project]..covidvaccinations vac
On dea.location = vac.location
and dea.date = vac.date


--Total Population vs Vaccinations


--Creating a Temporary Table
CREATE Table #PercentagePopulationVaccinated (
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population float,
New_Vaccinations float,
RollingPeopleVaccinated numeric
)
Alter table #PercentagePopulationVaccinated alter column new_vaccinations float


insert into #PercentagePopulationVaccinated
Select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location, dea.date) as 
RollingPeopleVaccinated
From [Portfolio project]..coviddeaths dea
join [Portfolio project]..covidvaccinations vac
On dea.location = vac.location
and dea.date = vac.date
--WHERE dea.location = 'Botswana'
WHERE dea.continent is not null
order by 2,3
Select *, (RollingPeopleVaccinated/nullif (Population,0))
from #PercentagePopulationVaccinated

--      CREATING VIEWS FOR LATER VISUALAZATIONS
Create View PercentagePopulationVaccinated as
Select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location, dea.date) as 
RollingPeopleVaccinated
From [Portfolio project]..coviddeaths dea
join [Portfolio project]..covidvaccinations vac
On dea.location = vac.location
and dea.date = vac.date
--WHERE dea.location = 'Botswana'
WHERE dea.continent is not null
--order by 2,3