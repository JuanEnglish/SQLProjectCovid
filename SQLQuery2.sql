SELECT *
FROM ProjectCovid..CovidDeaths
ORDER BY 3,4;

--SELECT *
--FROM ProjectCovid..CovidVaccinations
--ORDER BY 3,4;

--Select Data for deaths and new cases and total deaths

SELECT location, date, total_cases, new_cases,  total_deaths, population
FROM ProjectCovid..CovidDeaths
ORDER BY 1,2;

--Select Total Cases vs Total Death

SELECT location, date, total_cases, total_deaths, (total_deaths / NULLIF(total_cases,0)) * 100 AS death_rate
FROM ProjectCovid..CovidDeaths
ORDER BY 1,2;

--Select Total Cases vs Total Death in Australia
--The percentage of population who have got Covid in Australia

SELECT location, date, total_cases, population, (total_deaths / NULLIF(population,0)) * 100 AS infected_population_australia_rate
FROM ProjectCovid..CovidDeaths
WHERE location = 'Australia'
ORDER BY 1,2;

--Select the total of highest infected population value in Australia

SELECT location, date, MAX(total_cases) OVER() AS highest_infected_population, population, MAX((total_deaths / NULLIF(population,0)) * 100) OVER() AS Highes_infected_australia_rate
FROM ProjectCovid..CovidDeaths
WHERE location = 'Australia'
ORDER BY 1,2;

--Select the highest infection number compared to population per country in descending order

SELECT location, population, MAX(total_cases) AS highest_infection_count, MAX((total_cases / NULLIF(population,0)) * 100) AS highest_infection_rate
FROM ProjectCovid..CovidDeaths
GROUP BY location, population
ORDER BY highest_infection_rate DESC;

-- Select the countries with highest death count per population

SELECT location, MAX(CAST(total_deaths AS INT)) AS total_death_count
FROM ProjectCovid..CovidDeaths
WHERE continent != '' AND continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC;

--Select the total death numbers per continents

SELECT continent, MAX(CAST(total_deaths AS INT)) AS total_death_count
FROM ProjectCovid..CovidDeaths
WHERE continent != '' AND continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC;

--Global Numbers for deaths

SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths,
SUM(new_deaths) / SUM(new_cases) * 100 AS death_percentage
FROM ProjectCovid..CovidDeaths
WHERE continent IS NOT NULL AND continent != ''
ORDER BY 1,2;

--Selecting the total population vs vaccinations with Windows

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.date) AS RollingPeopleVaccinated
FROM ProjectCovid..CovidDeaths dea
JOIN ProjectCovid..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND dea.continent != ''
ORDER BY 2,3;

--Using CTE

WITH popsVac ( continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.date) AS RollingPeopleVaccinated
FROM ProjectCovid..CovidDeaths dea
JOIN ProjectCovid..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND dea.continent != ''
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM popsVac;

--Temporal Table

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continet nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.date) AS RollingPeopleVaccinated
FROM ProjectCovid..CovidDeaths dea
JOIN ProjectCovid..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL AND dea.continent != ''
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100 AS vaccinated_population_rate
FROM #PercentPopulationVaccinated;

--Create a view for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.date) AS RollingPeopleVaccinated 
FROM ProjectCovid..CovidDeaths dea
JOIN ProjectCovid..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND dea.continent != '';
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated;