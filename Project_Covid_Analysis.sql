SELECT *
FROM Project_1.dbo.CovidVaccinations

SELECT *
FROM Project_1.dbo.CovidDeaths


SELECT location, date,total_cases, new_cases, total_deaths, population
FROM Project_1.dbo.CovidDeaths
ORDER BY 1,2

-- Looking at Total cases vs Total Deaths
-- Likelihood of dying if you contract covid in the United Kingdom

SELECT location, date,total_cases, total_deaths, (total_deaths/total_cases) * 100 AS DeathPercentage
FROM Project_1.dbo.CovidDeaths
WHERE location = 'United Kingdom' AND total_cases <> 0
ORDER BY 5 DESC


--Total case vs Population
--Shows percentage of population infected with covid in United Kingdom

SELECT location, date, total_cases, Population, (total_cases/Population) * 100 AS InfectedPopulation
FROM Project_1.dbo.CovidDeaths
WHERE location = 'United Kingdom' AND total_cases <> 0
ORDER BY 5 DESC


--Looking at Countries with Highest Infections Rate compared to Population

SELECT location, MAX (total_cases) AS HighestInfectionCount, Population, MAX((total_cases/Population)) * 100 AS InfectedPopulationPercentage
FROM Project_1.dbo.CovidDeaths
GROUP BY location, Population  
ORDER by 4 DESC



--Showing countries with highest death count per population

SELECT location, MAX (total_deaths) AS Total_deaths, Population, MAX((total_deaths/Population)) * 100 AS DeathPopulationpercentage
FROM Project_1.dbo.CovidDeaths
WHERE continent <> location AND continent is not NULL
GROUP BY location, Population  
ORDER by 4 


--Breaking down by continents

--Showing continents with the highest death count 

SELECT continent, MAX (total_deaths) AS Total_deaths 
FROM Project_1.dbo.CovidDeaths
WHERE continent is not NULL
GROUP BY continent 
ORDER by Total_deaths DESC



--GLOBAL numbers for new cases and new deaths on daily basis
--Casting data in column new_cases and new_deaths to integers

SELECT date, SUM(CAST (new_cases as int)) AS total_cases, SUM(CAST (new_deaths as int)) AS total_deaths 
--(SUM(CAST (new_deaths as int))/SUM(CAST (new_cases as int))) * 100 AS DailyDeathPercentage
FROM Project_1.dbo.CovidDeaths
WHERE continent is not NULL 
GROUP BY date
Order by 1




--Looking at Total population vs Vaccinations


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location) as RollingPeopleVaccinated
FROM Project_1.dbo.CovidDeaths dea
JOIN Project_1.dbo.CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date 
WHERE dea.continent is not NULL
ORDER BY 2,3



--USE CTE to be able to use new windows function column 'RollingPeopleVaccianted' to perform calculations

With PopvsVac -- OPTIONAL TO ADD (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location) as RollingPeopleVaccinated
FROM Project_1.dbo.CovidDeaths dea
JOIN Project_1.dbo.CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date 
WHERE dea.continent is not NULL
)

Select *, (RollingPeopleVaccinated/Population) * 100
FROM PopvsVac



--TEMP TABLE
--Using the temp table to be able to use the new 'RollingPeopleVaccianted' column to perform calculations

DROP TABLE if exists #PercentagePopulationVaccinated
CREATE TABLE #PercentagePopulationVaccinated
(
Continent varchar (50),
Location varchar (50),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentagePopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location) as RollingPeopleVaccinated
FROM Project_1.dbo.CovidDeaths dea
JOIN Project_1.dbo.CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date 
WHERE dea.continent is not NULL

Select *, (RollingPeopleVaccinated/Population) * 100
FROM #PercentagePopulationVaccinated



--creating view to store data for later visualizations

Create View PercentagePopulationVaccinated
AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location) as RollingPeopleVaccinated
FROM Project_1.dbo.CovidDeaths dea
JOIN Project_1.dbo.CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date 
WHERE dea.continent is not NULL



Select *
From PercentagePopulationVaccinated