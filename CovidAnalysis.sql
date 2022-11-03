SELECT *
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null   -- Otherwise it will also display contitents as locations
order by 3,4

--Select *
--FROM PortfolioProject..CovidVaccinations$
--order by 3,4

Select location,date,total_cases,new_cases,total_deaths,population
From PortfolioProject..CovidDeaths$
Order by 1,2

-- cases to deaths ratio (Likelihood of dying if you contract COVID 19 IN a Country)

Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 As DeathPercentage
From PortfolioProject..CovidDeaths$
Where location like '%morocco%'
Order by 1,2

--  Cases to population ratio (Likelihood of getting COVID 19 In a country)

Select location,date,total_cases,population,(total_cases/population)*100 As CasesPercentage
From PortfolioProject..CovidDeaths$
-- Where location like '%morocco%'
Order by 1,2

-- Coutries with the highest infection rate compared to population

Select location, MAX(total_cases) As MaxCases,population,MAX((total_cases/population)*100) As MaxCasesPercentage
From PortfolioProject..CovidDeaths$
-- Where location like '%new zealand%'
GROUP BY location,population
Order by 4 DESC

-- Countries with highest death count per population

Select location, MAX(cast(total_deaths as int)) As MaxDeaths,population,MAX((total_deaths/population)*100) As MaxDeathsPercentage    --Issue with total_deaths data type nvchar when using aggregate like MAX
From PortfolioProject..CovidDeaths$
WHERE continent is not null	         --Delete this line to show deaths by areas (Union Europe, North America...)
GROUP BY location,population
Order by 2 DESC


-- Continents with highest deaths count

Select location, MAX(cast(total_deaths as int)) As MaxDeaths,population,MAX((total_deaths/population)*100) As MaxDeathsPercentage
From PortfolioProject..CovidDeaths$
WHERE continent is null	         --When continent is null location has the continent name
GROUP BY location,population
Order by 4 DESC

-- Global Numbers

Select SUM(new_cases) As GlobalCases, SUM(CAST(new_deaths as int)) as GlobalDeaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as GlobalDeathsPercentage
From PortfolioProject..CovidDeaths$
WHERE continent is not null
--GROUP BY date
Order by 1,2


--TOTAL VACCINATIONS Per country (To review)

Select dea.location, dea.population, SUM(CAST(vac.new_vaccinations as int)) as total_vac, SUM(CAST(vac.new_vaccinations as int))/dea.population*100 as vacc_ratio
From PortfolioProject..CovidDeaths$ as dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Group By dea.location, dea.population         -- To review : ratio > 100% ?
--Where dea.location like '%canada%'
Order by 1 


-- Vaccination rate per population 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated-- We partition by location so that the sum reset when location is changed. Partion by allow us to agregate on a specific column
--to calculate RollingPeopleVaccinated/population we use CTE (next query) 
From PortfolioProject..CovidDeaths$ as dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

-- USE CTE

With PopvsVacc (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated  -- We partition by location so that the sum reset when location is changed. Partion by allow us to agregate on a specific column
From PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
-- Order by 2,3
)

Select *, RollingPeopleVaccinated/Population*100 as VaccPercentage
From PopvsVacc;

-- USE CTE 2

With LastPopvsVacc (Continent, Location, Population, New_Vaccinations, LastPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.Location) as RollingPeopleVaccinated  -- We partition by location so that the sum reset when location is changed. Partion by allow us to agregate on a specific column
From PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null --and dea.location like '%israel%' > 100% ???
-- Order by 2,3
)

Select *, LastPeopleVaccinated/Population*100 as LastVaccPercentage
From LastPopvsVacc


-- USING TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent varchar(255),
Location varchar(255),
Date datetime,
Population numeric,
New_Vaccination numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated  -- We partition by location so that the sum reset when location is changed. Partion by allow us to agregate on a specific column
From PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
-- Order by 2,3

Select * from #PercentPopulationVaccinated


-- Creating Views for data visualisation uses


DROP View if exists PercentPopulationVaccinated
-- use PortfolioProject  --Use this if the view saves in the master database instead of your current database
Create View PercentPopulationVaccinated As
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated  -- We partition by location so that the sum reset when location is changed. Partion by allow us to agregate on a specific column
From PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
-- Order by 2,3