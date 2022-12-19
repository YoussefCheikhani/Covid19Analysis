Select *
From CovidData..CovidDeaths$
Order by 3,5 desc

--Select *
--From CovidData..CovidVaccinations$
--order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From CovidData..CovidDeaths$
Order by 1,2

--Deaths to Cases Ratio by country

Select location, Max(total_deaths)/MAX(total_cases) as DeathsToCasesRatio
From CovidData..CovidDeaths$
Group by location
Order by DeathsToCasesRatio desc

--Total Cases vs Total Deaths percetage

Select location,date, total_deaths, total_cases, (total_deaths/total_cases)*100 as DeathPercentage
From CovidData..CovidDeaths$
where location like '%morocco%'
Order by 5 desc

/*
Queries to create Tables for Tableau Project
*/

-- Table 1: Global Numbers (Cases, Deaths, Ratio) 

Select SUM(new_cases) as global_cases, SUM(CAST(new_deaths as int)) as global_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From CovidData..CovidDeaths$
Where continent is not null

--Double check

Select MAX(total_cases) as total_cases, MAX(Cast(total_deaths as int)) as total_deaths, MAX(Cast(total_deaths as int))/MAX(total_cases)*100 as DeathPercentage
From CovidData..CovidDeaths$
Where location = 'World'

--Table 2: Total Deaths Per Continent

Select location, MAX(Cast(total_deaths as int)) as TotalDeathCount
From CovidData..CovidDeaths$
Where continent is null
And location not in ('World','European Union','International', 'Lower middle income', 'Low income', 'Upper middle income', 'High income')
Group by location
order by TotalDeathCount desc

--Double Check

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From CovidData..CovidDeaths$
Where continent is null
And location not in ('World','European Union','International', 'Lower middle income', 'Low income', 'Upper middle income', 'High income')
Group by location
order by TotalDeathCount desc

--Table 3 : Percentage of Population Infected By Country

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases)/population*100 as PercentPopulationInfected
From CovidData..CovidDeaths$
--Where location like '%egy%'
Group by location,population
Order by PercentPopulationInfected desc

--Table 4 : Percentage of Population Infected By Country and Date

Select location, population, date, MAX(total_cases) as HighestInfectionCount, MAX(total_cases)/population*100 as PercentPopulationInfected
From CovidData..CovidDeaths$
--Where location like '%egy%'
Group by location,population,date
Order by PercentPopulationInfected desc
