--CREATE DATABASE PortfolioDatabase

/* COVİD 19 Data Exploration */


-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From [PortfolioDatabase]..[covid-data]
Where continent is not null 
order by 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [PortfolioDatabase]..[covid-data]
Where location = 'Turkey'
And continent is not null 
Order by 1,2

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases,  round((total_cases/population)*100,10) as PercentPopulationInfected
From [PortfolioDatabase]..[covid-data]
--Where location = 'Turkey'
order by 1,2


-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From [PortfolioDatabase]..[covid-data]
Group by Location, Population
order by PercentPopulationInfected desc


-- Countries with Highest Death Count per Population

Select location, max(Total_deaths) as totaldeathcounts
From [PortfolioDatabase]..[covid-data]
where continent is not null
group by Location
ORDER by totaldeathcounts desc

-- Showing contintents with the highest death count per population

Select continent , max(total_deaths) as totaldeathcounts
From [PortfolioDatabase]..[covid-data]
WHERE continent is not NULL
group BY continent
ORDER by totaldeathcounts desc

-- Global Numbers

select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths,sum(new_deaths)/sum(new_cases)*100 as DeathPercentage
From [PortfolioDatabase]..[covid-data]
where continent is not NULL


--  Looking at the Total Poulation vs Vaccinations

SELECT new_vaccinations,population,location,location,date, sum(new_vaccinations) over (partition by location order by location, date) as peoplevaccinated
From [PortfolioDatabase]..[covid-data]
where new_vaccinations is not NULL
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With VacvsPop
as(
    SELECT new_vaccinations,population,location,date, sum(new_vaccinations) over (partition by location order by location,  date) as peoplevaccinated
    From [PortfolioDatabase]..[covid-data]
    where new_vaccinations is not NULL
)
SELECT * ,(peoplevaccinated/population)*100 as percentagevaccinated
from VacvsPop


-- Using Temp Table to perform Calculation on Partition By in previous query
DROP Table if exists #PercentPopulationVaccinated
Create TABLE  #PercentPopulationVaccinated 
(
Continent NVARCHAR(255),
Location NVARCHAR(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
peoplevaccinated numeric
)    

Insert INTO #PercentPopulationVaccinated 
SELECT continent,location,date,population, New_vaccinations,
SUM(new_vaccinations) over (partition by location order by location, date) as peoplevaccinated
From [PortfolioDatabase]..[covid-data]
where New_vaccinations is not NULL

Select *, (peoplevaccinated/population)*100 as PercentPopulationVaccinated
From #PercentPopulationVaccinated  


-- Creating View to store data for later visualizations


CREATE VIEW people_vac_percentage AS
SELECT continent,location,date,population, New_vaccinations,
SUM(new_vaccinations) over (partition by location order by location, date) as peoplevaccinated
From [PortfolioDatabase]..[covid-data]
where New_vaccinations is not NULL

select *
FROM people_vac_percentage