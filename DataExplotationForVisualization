----------------SOURCE: https://ourworldindata.org/



--Select data that we are going to be using
SELECT 
location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

--Select total cases vs total deaths 
SELECT 
location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
where location like 'Argentina%'
ORDER BY 1,2

--Total cases vs population 
SELECT 
location, date, total_cases, population, (total_cases/population)*100 as Percent_Pop_infected
FROM PortfolioProject..CovidDeaths
where location like 'Argentina%'
ORDER BY 1,2

--Highest infection rate compared to population by country
SELECT 
location, population, MAX(total_cases) as HighestInfectionCount, --el mas alto de ese pais
MAX((total_cases/population))*100 as Percent_pop_infected
FROM PortfolioProject..CovidDeaths
--where location like 'Argentina%'
GROUP BY location, population
ORDER BY Percent_pop_infected desc


--Showing countries with highest death count per population (deathcount read as string, converted to int)
SELECT 
location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
where continent is not null --si el continent es not null la location quedan solo paises
GROUP BY location
ORDER BY TotalDeathCount desc


-- Showing by continent // highest death count per population
SELECT 
location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
where continent is null --si el continent es null estamos solo viendo locations que serian continentes
GROUP BY location
ORDER BY TotalDeathCount desc


-- Worldwide / global numbers death percent in time
SELECT
date, SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercent_byDate
--new cases float OK, new deaths nvarchar tenemos que castearlo como int dividimos para el porcentaje
FROM PortfolioProject..CovidDeaths
where continent is not null
group by date
ORDER BY 1,2


--Worldwide death percentage
SELECT
SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercent_byDate
--new cases float OK, new deaths nvarchar tenemos que castearlo como int dividimos para el porcentaje
FROM PortfolioProject..CovidDeaths
where continent is not null


--Both tables union
Select *
From PortfolioProject..CovidDeaths as Dea
Join PortfolioProject..CovidVacs as Vac
	on dea.location = vac.location
	and dea.date = vac.date


-- Total vaccinations vs total population by country
SELECT
dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location ORDER BY dea.location, dea.date) as TotalSum_vacc  --suma de vaccs a lo largo del tiempo, partition para que cuente por locations, bigint pq excedimos el maximo de int
From PortfolioProject..CovidDeaths as Dea
Join PortfolioProject..CovidVacs as Vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null and population is not null
ORDER BY 2,3 --order por location




-- Percentage of population vacc // how we use a new column for calculations with CTE

WITH PopvsVac (Continen, Location, Date, Population, New_Vaccinations, TotalSum_vacc)
as (
SELECT
dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location ORDER BY dea.location, dea.date) as TotalSum_vacc
FROM PortfolioProject..CovidDeaths as Dea
Join PortfolioProject..CovidVacs as Vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3 no se puede ordenar
)
SELECT *,
(TotalSum_vacc/population)*100 as PercentageVacc --ahora seleccionamos todo y sumamos el calculo con las columnas nuevas
FROM PopvsVac






-- Temp table same result

DROP TABLE IF exists #PercentPopulationVacc  --si haces algun cambio en los WHERE la query no falla
Create Table #PercentPopulationVacc   --hay que aclarar que tipo de dato es porque estamos creando una tabla nueva
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
TotalSum_vacc numeric)


Insert into #PercentPopulationVacc   --
SELECT
dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location ORDER BY dea.location, dea.date) as TotalSum_vacc

FROM PortfolioProject..CovidDeaths as Dea
Join PortfolioProject..CovidVacs as Vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null


SELECT *,
(TotalSum_vacc/population)*100 as PercentageVacc --nueva columna creada con resultado del select
FROM #PercentPopulationVacc



--Create a view to store data for tableau (later visualization)

CREATE VIEW PercentPopulationVaccinated as
SELECT
dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location ORDER BY dea.location, dea.date) as TotalSum_vacc

FROM PortfolioProject..CovidDeaths as Dea
Join PortfolioProject..CovidVacs as Vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null



--- Ver la view que se creo, es definitiva y se puede descargar para data visualization
Select * from PercentPopulationVaccinated


------------------------------------------------------------------------ PROYECT 2 for general tables for later viz
--1. Query for data visualization in tableau

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

--2.
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
