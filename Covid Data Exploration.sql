SELECT *
FROM PorfolioProject..CovidDeaths

SELECT *
FROM PorfolioProject..CovidVaccinations

SELECT [location], [date], total_cases, new_cases, total_deaths, [population]
FROM CovidDeaths
ORDER BY 1,2

--- Looking at Total Cases Vs Total Deaths

SELECT [location], [date], total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE [location] LIKE '%states%'
ORDER BY [location],[date]

--- Showing likelihood of dying if you contract covid in our country

SELECT [location], [date], total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE [location] = 'Myanmar'
ORDER BY [location],[date]

--- Looking at Total Cases Vs Population
--- Shows what percentage of population got Covid

SELECT [location], [date], total_cases, [population], (total_cases/[population])*100 AS DeathPercentage
FROM CovidDeaths
WHERE [location] LIKE '%states%'
ORDER BY [location],[date]

SELECT [location], [date], total_cases, [population], (total_cases/[population])*100 AS PercentPopulation
FROM CovidDeaths
WHERE [location] = 'Myanmar'
ORDER BY [location],[date]

--- Looking at Countries with Highest Infection Rate compared to Population

SELECT [location], [population], MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/[population])*100 AS PercentPopulationInfected
FROM CovidDeaths
---WHERE [location] LIKE '%states%'
GROUP BY [location], [population]
ORDER BY PercentPopulationInfected DESC

--- Showing Countries with Highest Death Count per Population

SELECT [location], MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY [location]
ORDER BY TotalDeathCount DESC

--- Let's Break things down by Contient

SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

---Showing contients with the highest death count per population

SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

---GLOBAL NUMBERS

SELECT [date],SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY [date]
ORDER BY total_cases DESC


--- Looking at Total Population Vs Vaccinations

SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations, SUM(CONVERT(INT, CV.new_vaccinations)) OVER(PARTITION BY CD.location ORDER BY CD.location, CD.date) AS  RollingPeopleVaccinated
FROM CovidDeaths CD
JOIN CovidVaccinations CV ON CD.location = CV.location and CD.date = CV.date
WHERE CD.continent IS NOT NULL
ORDER BY 2, 3

--- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations, SUM(CONVERT(INT, CV.new_vaccinations)) OVER(PARTITION BY CD.location ORDER BY CD.location, CD.date) AS  RollingPeopleVaccinated
FROM CovidDeaths CD
JOIN CovidVaccinations CV ON CD.location = CV.location and CD.date = CV.date
WHERE CD.continent IS NOT NULL
--ORDER BY 2, 3
)
SELECT *, (RollingPeopleVaccinated/Population)*100 AS VaccinatedPercentage
FROM PopvsVac

 ---TEMP TABLE

 DROP TABLE if exists #PercentPopulationVaccinated
 CREATE TABLE #PercentPopulationVaccinated
 (
 Continent NVARCHAR(255),
 Location NVARCHAR(255),
 Date DATETIME,
 Population NUMERIC,
 New_Vaccinations NUMERIC,
 RollingPeopleVaccinated NUMERIC
 )

 INSERT INTO #PercentPopulationVaccinated 
 SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations, SUM(CONVERT(INT, CV.new_vaccinations)) OVER(PARTITION BY CD.location ORDER BY CD.location, CD.date) AS  RollingPeopleVaccinated
FROM CovidDeaths CD
JOIN CovidVaccinations CV ON CD.location = CV.location and CD.date = CV.date
WHERE CD.continent IS NOT NULL
ORDER BY 2, 3

SELECT *, (RollingPeopleVaccinated/Population)*100 AS VaccinatedPercentage
FROM #PercentPopulationVaccinated

---Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
 SELECT CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations, SUM(CONVERT(INT, CV.new_vaccinations)) OVER(PARTITION BY CD.location ORDER BY CD.location, CD.date) AS  RollingPeopleVaccinated
FROM CovidDeaths CD
JOIN CovidVaccinations CV ON CD.location = CV.location and CD.date = CV.date
WHERE CD.continent IS NOT NULL
---ORDER BY 2, 3

SELECT *
FROM PercentPopulationVaccinated


