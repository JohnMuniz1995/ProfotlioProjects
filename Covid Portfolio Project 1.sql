

Select *
 From PortfolioProject.dbo.CovidDeaths
 Where continent is not null
 order by 3,4


 --Select *
 --From PortfolioProject..CovidVaccinations$
 --order by 3,4

 Select Location, date, total_cases, new_cases, total_deaths, population
 From PortfolioProject..CovidDeaths
 order by 1,2

 -- Shows likelihood of dying if you contract covid in your Country
 Select Location, date, Population, total_cases, (Total_deaths/total_cases)*100 as DeathPercentage
 From PortfolioProject..CovidDeaths
 --Where location like '%states%'
 order by 1,2


 -- Showing Countries with Highest Death Count per Population

 Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
 From PortfolioProject..CovidDeaths
 Where continent is not null
 Group by Location
 order by TotalDeathCount desc

 --LET'S BREAK THINGS DOWN BY CONTINENT
 Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
 From PortfolioProject..CovidDeaths
 Where continent is not null
 Group by continent
 order by TotalDeathCount desc

 --Showing continents with the highest death count per population
  Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
 From PortfolioProject..CovidDeaths
 Where continent is not null
 Group by continent
 order by TotalDeathCount desc




-- Global NUMBERS

SELECT SUM(new_cases)as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM
	(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
--Group By date
order by 1,2

--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE CTE

With PopvsVac (Continent, Location, Date, Population,New_Vaccination, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




--CREATING View to store data for later visualization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
