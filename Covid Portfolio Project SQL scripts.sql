/*

Covid-19 Data Exploration
Skills Used - Aggregate functions, Converting data types, Joins, Window function, CTE's, Temp table, Creating View

*/

SELECT * 
from PortfolioProject.dbo.CovidDeaths 
where continent is not null
order by 3,4;

--Select data that we are going to be starting with 
Select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2;

--Total cases Vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%India%'
order by 1,2;

--Total Cases Vs Population
--Shows what % of population infected with covid
Select location, date, population, total_cases, (total_cases/population)*100 as PercentageAffected
from PortfolioProject..CovidDeaths
where location like '%India%'
order by 1,2;

--Countries with highest infection rate compared to popultion
Select location, population, max(total_cases) as Highest_Infection_Count, max((total_cases/population)*100) as PercentPopulationInfected
from PortfolioProject..CovidDeaths
Group By Location, population
order by PercentPopulationInfected desc;

--Countries with the highest death count
Select location, max(cast(total_deaths as int)) as Total_Death_Count, population
from PortfolioProject..CovidDeaths
where continent is not null
Group By Location, population
order by Total_Death_Count desc;

--Breaking things down by Continent
--Showing the continents with the highest death count per population
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc

--Global Numbers
Select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, (sum(cast(new_deaths as int))/sum(new_cases)*100) as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2;

Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, (sum(cast(new_deaths as int))/sum(new_cases)*100) as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null;

--Total Poplation Vs Total Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int, vac.new_vaccinations)) 
	over (partition by dea.location order by dea.location, dea.date) as Rolling_people_vaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3;

--Useing Common Table Expression to perform Calculation on Partition By in previous query
with PopvsVac(continent, loacation, date, population, new_vaccinations, Rolling_People_Vaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int, vac.new_vaccinations)) 
	over (partition by dea.location order by dea.location, dea.date) as Rolling_People_Vaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *,(Rolling_People_Vaccinated/population)*100 as Rolling_Percent_People_Vaccinated
from PopvsVac;

--Using Temp Table to perform Calculation on Partition By in previous query
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
Rolling_People_Vaccinated numeric,
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int, vac.new_vaccinations)) 
	over (partition by dea.location order by dea.location, dea.date) as Rolling_People_Vaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *,(Rolling_People_Vaccinated/population)*100 as Rolling_Percent_People_Vaccinated
from #PercentPopulationVaccinated
order by 2;

--Creating View to store data for later Visualization
Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int, vac.new_vaccinations)) 
	over (partition by dea.location order by dea.location, dea.date) as Rolling_People_Vaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
