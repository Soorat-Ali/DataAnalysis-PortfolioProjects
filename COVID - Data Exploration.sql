SELECT *
FROM [Portfolio Project]..CovidDeaths
WHERE continent IS NOT null
order by 3,4

--SELECT *
--FROM [Portfolio Project]..CovidVaccinations
--order by 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project]..CovidDeaths
WHERE continent IS NOT null
order by 1,2

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM [Portfolio Project]..CovidDeaths
WHERE location like '%Pakistan%'
AND continent IS NOT null
order by 1,2

--Looking at total cases vs population
-- shows what percentage of population got covid
SELECT Location, date, total_cases, population, (total_cases/population)*100 AS PercentageInfected
FROM [Portfolio Project]..CovidDeaths
WHERE location like '%Pakistan%'
AND continent IS NOT null
order by 1,2


-- Looking at countries with highest infection rate compared to population
SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentagePopulationInfectedBy
FROM [Portfolio Project]..CovidDeaths
--Where location like '%states%'
WHERE continent IS NOT null
Group by location,population
order by PercentagePopulationInfectedBy DESC

--Showing the countries with highest death count per population
SELECT Location, MAX(cast(total_deaths as int))AS TotalDeathCount
FROM [Portfolio Project]..CovidDeaths
--Where location like '%states%'
WHERE continent IS NOT null
Group by location,population
order by TotalDeathCount DESC


-- LET'S BREAK THINGS DOWN BY CONTINENT
SELECT continent, MAX(cast(total_deaths as int))AS TotalDeathCount
FROM [Portfolio Project]..CovidDeaths
--Where location like '%states%'
WHERE continent IS NOT null
Group by continent
order by TotalDeathCount DESC

-- Showing the Continent with highest death count
SELECT continent, MAX(cast(total_deaths as int))AS TotalDeathCount
FROM [Portfolio Project]..CovidDeaths
--Where location like '%states%'
WHERE continent IS NOT null
Group by continent
order by TotalDeathCount DESC

-- GLOBAL NUMBERS 
SELECT date, SUM(new_cases) AS TotalCases, SUM(cast(new_deaths as int)) AS TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM [Portfolio Project]..CovidDeaths
--WHERE location like '%Pakistan%'
WHERE continent IS NOT null
GROUP BY date
order by 1,2



-- Looking at Total Population vs vacination
-- USE CTE 
with PopvsVac (continent, location, date, population, NewVacinations ,RollingPeopleVacinated)
as
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER(Partition By dea.location Order By dea.location, dea.Date) AS RollingPeopleVacinated
--,(RollingPeopleVacinated/population)*100
FROM [Portfolio Project]..CovidDeaths dea 
JOIN [Portfolio Project]..CovidVaccinations vac 
	ON dea.location = vac.location
	AND dea.date = vac.date 
WHERE dea.continent is not NULL
--Order By 2,3
)
SELECT *, (RollingPeopleVacinated/population)*100
FROM PopvsVac




--TEMP TABLE
DROP Table IF EXISTS #PercentPopulationVacinated
CREATE TABLE #PercentPopulationVacinated
(
Continent nvarchar (255),
Location nvarchar(255),
Date datetime,
Population numeric,
NewVacination numeric,
RollingPeopleVacinated numeric
)

INSERT INTO #PercentPopulationVacinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER(Partition By dea.location Order By dea.location, dea.Date) AS RollingPeopleVacinated
--,(RollingPeopleVacinated/population)*100
FROM [Portfolio Project]..CovidDeaths dea 
JOIN [Portfolio Project]..CovidVaccinations vac 
	ON dea.location = vac.location
	AND dea.date = vac.date 
WHERE dea.continent is not NULL
--Order By 2,3

SELECT *, (RollingPeopleVacinated/population)*100
FROM #PercentPopulationVacinated


-- Creating view to store data for later visualiztion
CREATE VIEW PercentPopulationVacinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER(Partition By dea.location Order By dea.location, dea.Date) AS RollingPeopleVacinated
--,(RollingPeopleVacinated/population)*100
FROM [Portfolio Project]..CovidDeaths dea 
JOIN [Portfolio Project]..CovidVaccinations vac 
	ON dea.location = vac.location
	AND dea.date = vac.date 
WHERE dea.continent is not NULL
--Order By 2,3