Select *
From [portfolio project ]..covidDeaths
Where continent is not null
order by 3,4

-- Select *
-- From [portfolio project ]..CovidVaccinations
-- order by 3,4

-- Select Data that we are going to be using

Select Location, date, total_cases,new_cases, total_deaths, population  
From [portfolio project ]..covidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths 
-- Shows likelihood of dying if  you contract covid in your country 


SELECT 
    location,
    date,
    total_cases,
    total_deaths,
    TRY_CAST(total_deaths AS FLOAT) 
        / NULLIF(TRY_CAST(total_cases AS FLOAT), 0)*100 AS DeathPercentage
FROM [portfolio project]..CovidDeaths
ORDER BY 1, 2;


Select Location, date, total_cases, total_deaths, (total_deaths/total_cases) *100 as DeathPercentage
From [portfolio project ]..covidDeaths
Where  location like '%states%' 
order by 1,2


-- Looking at Total Cases vs Population 
--  Shows what percentage of population got Covid

Select Location, date, total_cases, Population, (total_cases/population *100) as PercentPopulationInfected
From [portfolio project ]..covidDeaths
Where  location like '%states%' 
order by 1,2

-- Loooking at Countries with Higest Infection Rate compared to population 

Select Location, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population *100)) as PercentPopulationInfected
From [portfolio project ]..covidDeaths
--  Where  location like '%states%' 
Group by Location, Population
order by PercentPopulationInfected desc

-- Showing Countries with the Highest Death Count Per Population 

Select Location, MAX(Total_Deaths) as TotalDeathCount
From [portfolio project ]..covidDeaths
Where continent is NOT NULL 
Group by Location
order by TotalDeathCount desc

-- LETS BREAK THINGS DOWN BY CONTINENT 
-- Showing coontintents with highest death count 

Select continent, MAX(Total_Deaths) as TotalDeathCount
From [portfolio project ]..covidDeaths
Where continent is NOT NULL 
Group by continent
order by TotalDeathCount desc

-- Looking at nulls as well (gives more accurate cotinent number for death count) 
Select Location, MAX(Total_Deaths) as TotalDeathCount
From [portfolio project ]..covidDeaths
Where continent is NULL 
Group by Location
order by TotalDeathCount desc

-- Global Numbers 
-- changed nvar to int data type

Select date, SUM(CAST(new_cases AS INT)) as total_cases, SUM(CAST(new_deaths AS INT))  as total_deaths, (SUM(CAST(new_deaths as INT)) * 100.0 ) / NULLIF(SUM(CAST(new_cases AS INT)),0) AS DeathPercentage 
From [portfolio project ]..covidDeaths
where continent is not null 
Group by date 
order by 1,2


-- for total cases death percentage by removing date

Select SUM(CAST(new_cases AS INT)) as total_cases, SUM(CAST(new_deaths AS INT))  as total_deaths, (SUM(CAST(new_deaths as INT)) * 100.0 ) / NULLIF(SUM(CAST(new_cases AS INT)),0) AS DeathPercentage 
From [portfolio project ]..covidDeaths
where continent is not null 
order by 1,2


 -- USE CTE 
 With PopsVsVac(contintent, location, date, population, new_vaccinations, RollingPeopleVaccinated) 
 as 
 (
 -- looking total population vs vaccinations 
SELECT dea.continent, dea.location,  dea.date, dea. population, vac.new_vaccinations,
SUM(COALESCE(TRY_CAST(vac.new_vaccinations as BIGINT),0)) OVER (Partition by dea.location 
Order by dea.location, dea.date) AS RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population) *100
From [portfolio project ]..covidDeaths dea
Join [portfolio project ]..CovidVaccinations vac 
    On dea.location = vac.location 
    and dea.date = vac.date
 where dea.continent is not null 
-- order by 2,3
 )
Select *, (RollingPeopleVaccinated *100.0/Population) AS PercentPeopleVaccinated 
from PopsVsVac; 

-- Temp Table

DROP TABLE if exists #PercentPopulationVaccinated 
Create Table  #PercentPopulationVaccinated 
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric, 
New_vaccinations numeric,
RollingPeopleVaccinated numeric 
)

Insert into #PercentPopulationVaccinated 
SELECT dea.continent, dea.location,  dea.date, dea. population, vac.new_vaccinations,
SUM(COALESCE(TRY_CAST(vac.new_vaccinations as BIGINT),0)) OVER (Partition by dea.location 
Order by dea.location, dea.date) AS RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population) *100
From [portfolio project ]..covidDeaths dea
Join [portfolio project ]..CovidVaccinations vac 
    On dea.location = vac.location 
    and dea.date = vac.date
 where dea.continent is not null 

Select *, (RollingPeopleVaccinated *100.0/Population) AS PercentPeopleVaccinated 
from #PercentPopulationVaccinated 

-- Creating View to store for data visializations 


USE [portfolio project];
GO

Create View dbo.PercentPopulationVaccinated 
AS
SELECT 
dea.continent, 
dea.location,  
dea.date, 
dea. population, 
vac.new_vaccinations,
SUM(COALESCE(TRY_CAST(vac.new_vaccinations as BIGINT),0)) 
    OVER (Partition by dea.location 
    Order by dea.location, dea.date) AS RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population) *100
From [portfolio project ]..covidDeaths dea
Join [portfolio project ]..CovidVaccinations vac 
    On dea.location = vac.location 
    and dea.date = vac.date
 where dea.continent is not null 
 

 Select * 
 From PercentPopulationVaccinated