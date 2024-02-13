Select * 
From PortfolioProject..CovidDeaths
Where continent is not null
Order By 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--Order By 3,4

--Select Data that I am going to be using 

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
Order By 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract Covid in your country

SELECT
    location,
    date,
    total_cases,
    total_deaths,
    (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 As DeathPercentage
FROM PortfolioProject..covidDeaths
Where location like '%states%'
and continent is not null
ORDER BY 1, 2;

--Looking at Total Cases Vs Population
--Shows what percentage of population got Covid

Select Location, date, Population, total_cases, (total_cases/Population)*100 As PercentPopulationInfected
FROM PortfolioProject..covidDeaths
--Where location like '%states%'
Where continent is not null
ORDER BY 1, 2;


--What country has the highest infection rates compared to population?

Select Location, Population, MAX(total_cases) As HighestInfetionCount, MAX((total_cases/Population))*100 As PercentPopulationInfected
FROM PortfolioProject..covidDeaths
--Where location like '%states%'
Where continent is not null
Group By Location, Population
ORDER BY PercentPopulationInfected Desc

--Showing countries with Highest Death Count per Population

Select Location, MAX(cast(total_deaths as int)) As TotalDeathCount
FROM PortfolioProject..covidDeaths
--Where location like '%states%'
Where continent is not null
Group By Location
ORDER BY TotalDeathCount Desc

--Showing the cintinents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) As TotalDeathCount
FROM PortfolioProject..covidDeaths
--Where location like '%states%'
Where continent is not null
Group By continent
ORDER BY TotalDeathCount Desc

--Global Numbers

SELECT SUM(new_cases) As total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int)) / SUM(New_cases)*100 As DeathPercentage
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
--Group By date
ORDER BY 1,2;

--Joining CovidVaccinations Table with CovidDeaths Table
--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order By dea.location, dea.date ) As RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 (error in this line since you cannot use the enw alias name. So have to create a temp table)
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location 
AND dea.date = vac.date
Where dea.continent is not null
Order By 1,2,3

--Use CTE

With PopVSVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
As 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order By dea.location, dea.date ) As RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 (error in this line since you cannot use the enw alias name. So have to create a temp table)
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location 
AND dea.date = vac.date
Where dea.continent is not null
--Order By 1,2,3
)
Select *, (RollingPeopleVaccinated/Population*100) 
From PopVSVac

--Temp Table

Drop Table if exists #PercentPopulationVaccinated --This alllows you to be able to edit the created table
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order By dea.location, dea.date ) As RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 (error in this line since you cannot use the enw alias name. So have to create a temp table)
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location 
AND dea.date = vac.date
Where dea.continent is not null
--Order By 1,2,3

Select *, (RollingPeopleVaccinated/Population*100) 
From #PercentPopulationVaccinated


--Creating View to store data for visualization 

Create View PercentPopulationVaccinated As
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order By dea.location, dea.date ) As RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 (error in this line since you cannot use the enw alias name. So have to create a temp table)
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location 
AND dea.date = vac.date
Where dea.continent is not null
--Order By 1,2,3

Select * 
From PercentPopulationVaccinated
