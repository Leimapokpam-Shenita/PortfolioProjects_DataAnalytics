USE PortfolioProject
GO
SELECT *
FROM PortfolioProject..covidDeath
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject.dbo.covidVaccination
--ORDER BY 3,4
--SELECT data that we are going to be using
SELECT location,date,total_cases,new_cases,total_deaths,population
From PortfolioProject..covidDeath
ORDER BY 1,2

--looking at total cases vs total deaths
--Shows likelihood of dying if you contract covid in your country
SELECT location,date,total_cases,total_deaths,(total_deaths/NULLIF(total_cases,0))*100 AS Death_cases_ratio
From PortfolioProject..covidDeath
WHERE location like '%states%'AND total_deaths<>0
ORDER BY 1,2

--looking at total cases vs population
--shows percentage of population which got covid
SELECT location,date,total_cases,population,(total_cases/NULLIF(population,0))*100 AS CasesPercentage
From PortfolioProject..covidDeath
WHERE location like '%India%' AND total_cases<>0
ORDER BY 1,2

--WHAT Countries have highest infection rate compared to population
SELECT location,MAX(total_cases)HighestInfectionCount,AVG(population) AS Avgpopulation,MAX((total_cases/NULLIF(population,0)))*100 AS CasesPercentage
From PortfolioProject..covidDeath
WHERE total_cases<>0
GROUP BY location
ORDER BY 4 DESC

--LET'S BREAK THINGS DOWN BY CONTINENT
SELECT continent,MAX(total_deaths) HighestDeathCount
From PortfolioProject..covidDeath
WHERE continent is not null AND continent<>''
GROUP BY continent
ORDER BY 2 DESC

--showing countries with highest death count per population
SELECT location,MAX(total_deaths) HighestDeathCount
From PortfolioProject..covidDeath
WHERE continent is not null AND continent<>''
GROUP BY location
ORDER BY 2 DESC


--GLOBAL NUMBERS

SELECT SUM(new_cases)AS TotalCases,SUM(cast(new_deaths as int))as TotalDeath ,SUM(cast(new_deaths as int))/NULLIF(SUM(new_cases),0)*100 as DeathPercentage
From PortfolioProject..covidDeath
WHERE continent<>''AND continent is not null
--GROUP BY date
ORDER BY 1,2

WITH PopvsVac(continent,location,date,population,new_vaccinations,RolloverSum)
as(
--Looking at total population vs vaccination
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.date,dea.location) AS RolloverSum
--,RolloverSum/population*100
FROM PortfolioProject..covidDeath dea
JOIN  PortfolioProject..covidVaccination vac
 On dea.location=vac.location
 and dea.date=vac.date
 WHERE dea.continent<>'' AND dea.continent is not null AND population is not null 
 --ORDER BY 2,3
 )
 SELECT*,(RolloverSum/population)*100 AS PopvsVac
 FROM PopvsVac
 Order by 5 desc
--USE CTE/TEMP TABLE


--TEMPTABLE to perform calculation on partititon by in prevoius query
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
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.date,dea.location) AS RolloverSum
--,RolloverSum/population*100
FROM PortfolioProject..covidDeath dea
JOIN  PortfolioProject..covidVaccination vac
 On dea.location=vac.location
 and dea.date=vac.date
 WHERE dea.continent<>'' AND dea.continent is not null AND population is not null 
 --ORDER BY 2,3
 

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

---CREATING VIEW to store data for later visualisation

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..covidDeath dea
Join PortfolioProject..covidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
