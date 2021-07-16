select *
From Covid19Project..CovidDeaths
Order by 3,4

--Select *
--From Covid19Project..CovidVaccines
--Order by 3,4


-- Select Relevant Column

Select Location,Date, total_cases, new_cases, total_deaths, population
From Covid19Project..CovidDeaths
Order by 1,2

-- Total cases vs Total Death
Select Location,Date, total_cases, total_deaths, (total_deaths/total_cases) AS DeathPercentage
From Covid19Project..CovidDeaths
WHERE Location like '%Malaysia%' AND total_deaths IS NOT NULL
Order by 2 DESC

-- Total Cases Vs Population
Select Location,Date, total_cases, population, (total_cases/population)*100 AS CovidPercentage
From Covid19Project..CovidDeaths
WHERE Location like '%Malaysia%'
Order by 2 DESC

-- Country with highest infection rate compared to Population
Select Location, MAX(total_cases) as CumCases, population, MAX((total_Cases/population))*100 AS PopulationInfected
From Covid19Project..CovidDeaths
Group by Location,population
Order by 4 DESC

-- Country with highest Death number from COVID
Select Location,MAX(CAST(total_deaths as int)) as DeathCount
From Covid19Project..CovidDeaths
where continent is not null
Group by Location
Order by DeathCount desc

-- Group by Continent
Select Continent,MAX(CAST(total_deaths as int)) as DeathCount
From Covid19Project..CovidDeaths
where continent is not null
Group by CONTINENT

-- Daily Global COVID Cases
SELECT date, SUM(new_cases) as TotalCases, SUM(cast(total_deaths as int)) as TotalDeaths
FROM Covid19Project..CovidDeaths
WHERE Continent is not null
GROUP BY date
Order by date desc

-- Total Cases as of 14/7/2021 Global COVID Cases
SELECT SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100  as WorldDeathRate
FROM Covid19Project..CovidDeaths
WHERE Continent is not null

-- total population that vaccinated (CTE)
with PopVSVac (Continent, location,date, population,new_vaccinations, TotVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,SUM(CONVERT(int,new_vaccinations)) OVER (Partition by dea.location order by dea.date) as TotVaccinated
FROM Covid19Project..CovidDeaths dea
JOIN Covid19Project..CovidVaccines vac
	on dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
select *,(TotVaccinated/population) as VaccinationRate
FROM popVSVac

-- Temporary Table
DROP TABLE if exists #PercentPopulationVacccinated
create TABLE #PercentPopulationVacccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
TotVaccinated numeric
)

Insert into #PercentPopulationVacccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,SUM(CONVERT(int,new_vaccinations)) OVER (Partition by dea.location order by dea.date) as TotVaccinated
FROM Covid19Project..CovidDeaths dea
JOIN Covid19Project..CovidVaccines vac
	on dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

select *,(TotVaccinated/population) as VaccinationRate
FROM #PercentPopulationVacccinated

-- Create view for Data Visualization
Create VIEW PercentPopulationVacccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,SUM(CONVERT(int,new_vaccinations)) OVER (Partition by dea.location order by dea.date) as TotVaccinated
FROM Covid19Project..CovidDeaths dea
JOIN Covid19Project..CovidVaccines vac
	on dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL