
Select *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

--Select Data that we are going to be using

Select Location, date, total_cases, new_cases,total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeatPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2

--Looking at Total Cases vs Population
--Show what percentage of population got Covid
Select Location, date,population , total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc

-- Showing Countries with Highest Death Count per Poplution

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths 
--Where location like '%states%'
Where continent is not null
Group by Location
order by TotalDeathCount desc


-- Let's BREAK THINK DOWN BY CONTINENT


-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths 
--Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeatPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
--Group by date
order by 1,2


--Looking at Total Popolation vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations)) over (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated --(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

--Use CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations)) over (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated --(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Contintent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations)) over (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated --(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3


Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- Creating View to store for later visualizations


CREATE View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(int,vac.new_vaccinations)) over (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated --(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated

