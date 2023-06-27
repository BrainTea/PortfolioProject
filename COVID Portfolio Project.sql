Select *
From PortfolioProject..CovidDeaths
Where continent is not NULL
Order By 3,4

Select *
From PortfolioProject..CovidVaccinations
Order By 3,4

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Selecting data that we are going to be using --

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order BY 1,2

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Looking at Total Cases vs Total Deaths --
-- Shows likelihood of dying if you contract covid in your country --
-- We can change which country we are looking at by changing whats in '%' --

Select location, date, total_cases, total_deaths, 
	CONVERT(DECIMAL(18, 4), (CONVERT(DECIMAL(18, 4), total_deaths) / CONVERT(DECIMAL(18, 4), total_cases))) as DeathsOverTotal
From PortfolioProject..CovidDeaths
Where location = 'United States' and continent is not NULL
Order BY 1,2

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Looking at Total Cases vs Population --
-- Shows what percentage of population got covid --

Select location, date, population, total_cases, Convert(Decimal(18,4),(total_cases/population)*100) as CasesOverPopulation
From PortfolioProject..CovidDeaths
Where location = 'United States' and continent is not NULL
Order BY 1,2

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Looking at Countries with Highest Infection Rates compared to Population --

Select location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where continent is not NULL
Group by location, population
Order by PercentPopulationInfected desc

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Showing Countries with the Highest Death Count per Population --

Select location, Max(Cast(total_deaths as bigint)) as TotalDeathCountry
From PortfolioProject..CovidDeaths
Where continent is not NULL
Group by location
Order by TotalDeathCountry desc

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Showing Continents with the Highest Death Count --

Select location, Max(Cast(total_deaths as bigint)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is NULL 
	and location not like '% income'
Group by location
Order by TotalDeathCount Desc

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Global Numbers of total cases and deaths --

Select date,Sum(new_cases) as total_cases, Sum(cast(new_deaths as bigint)) as total_deaths, (Sum(cast(new_deaths as int))/NullIf(Sum(new_cases)*100, 0)) as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group by date
Order by 1

Select Sum(new_cases) as total_cases, Sum(cast(new_deaths as bigint)) as total_deaths, (Sum(cast(new_deaths as bigint))/(Sum(new_cases)*100)) as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is not null

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Looking at Total Population vs Vaccinations --

Select Dea.continent, Dea.location, Dea.date, Dea.population, vac.new_vaccinations, 
	sum(convert(bigint,Vac.new_vaccinations)) OVER (Partition by Dea.location Order by Dea.location, Dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths Dea
Join PortfolioProject..CovidVaccinations Vac
	On Dea.location = Vac.location
	and Dea.date = Vac.date
Where Dea.continent is not null
Order by 1,2,3


-- Using CTE --

With PopvsVac(continent, location, date, population, new_vaccination, RollingPeopleVaccinated)
as
(Select Dea.continent, Dea.location, Dea.date, Dea.population, vac.new_vaccinations, 
	sum(convert(bigint,Vac.new_vaccinations)) OVER (Partition by Dea.location Order by Dea.location, Dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths Dea
Join PortfolioProject..CovidVaccinations Vac
	On Dea.location = Vac.location
	and Dea.date = Vac.date
Where Dea.continent is not null
)
Select *, (RollingPeopleVaccinated/population)*100 as PercentageVaccinated
From PopvsVac
Order by 1,2,3


-- Using TEMP Table --

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated
Select Dea.continent, Dea.location, Dea.date, Dea.population, vac.new_vaccinations, 
	sum(convert(bigint,Vac.new_vaccinations)) OVER (Partition by Dea.location Order by Dea.location, Dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths Dea
Join PortfolioProject..CovidVaccinations Vac
	On Dea.location = Vac.location
	and Dea.date = Vac.date
Where Dea.continent is not null

Select *,(RollingPeopleVaccinated/population)*100 as PercentageVaccinated
From #PercentPopulationVaccinated
Order by 1,2,3

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Creating View to store data for later visualizations --

Create View PercentPopulationVaccinated as
Select Dea.continent, Dea.location, Dea.date, Dea.population, vac.new_vaccinations, 
	sum(convert(bigint,Vac.new_vaccinations)) OVER (Partition by Dea.location Order by Dea.location, Dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths Dea
Join PortfolioProject..CovidVaccinations Vac
	On Dea.location = Vac.location
	and Dea.date = Vac.date
Where Dea.continent is not null

Create View ContinentsDeathCount as
Select location, Max(Cast(total_deaths as bigint)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is NULL 
	and location not like '% income'
Group by location

Create View USPopvsCases as
Select location, date, population, total_cases, Convert(Decimal(18,4),(total_cases/population)*100) as CasesOverPopulation
From PortfolioProject..CovidDeaths
Where location = 'United States' and continent is not NULL