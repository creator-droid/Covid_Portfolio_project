Select *
From PortfolioProject.dbo.['owid-covid-data$']
where continent is not null
Order BY 3, 4

 --Select data that we are going to be using 
Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject.dbo.['owid-covid-data$']
where continent is not null
Order by 1,2
 

 --Estimate of dying of covid if one lives in the South Africa
Select Location, date, total_cases, total_deaths, (CONVERT(float, total_deaths)/ NULLIF(CONVERT(float,total_cases), 0))*100 as DeathPercentage
From PortfolioProject.dbo.['owid-covid-data$']
Where location like '%South Africa%'
Order by 1,2

--Percentage of people who got covid in South Africa
Select Location, date, total_cases, total_deaths, population,(CONVERT(float, total_cases )/ NULLIF(CONVERT(float,population), 0))*100 as TotalCases
From PortfolioProject.dbo.['owid-covid-data$']
Where location like '%South Africa%'
Order by 1,2

-- Countries with Highest Infection Rate Compared to Population
SELECT Location , Population , MAX(total_cases) as HighestInfecionCount, MAX ((total_cases/population)) *100 as PercentPopulationInfection
FROM PortfolioProject.dbo.['owid-covid-data$']
GROUP BY location, population
Order by PercentPopulationInfection desc

-- Countries with highest death rate per population
SELECT Location , MAX(cast(total_deaths as int)) as HighestDeathCount 
FROM PortfolioProject.dbo.['owid-covid-data$']
WHERE continent is null 
GROUP BY location
Order by HighestDeathCount desc

--CONTINENTS DATA ANALYSIS

-- Continenets with highest death rate per population
SELECT continent , MAX(cast(total_deaths as int)) as HighestDeathCount 
FROM PortfolioProject.dbo.['owid-covid-data$']
WHERE continent is not null 
GROUP BY continent
Order by HighestDeathCount desc

--GLOBAL NUMBERS
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject.dbo.['owid-covid-data$']
--Where location like '%South Africa%'
where continent is not null 
GROUP BY date
order by 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject.dbo.['owid-covid-data$'] dea
Join PortfolioProject.dbo.covidvaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject.dbo.['owid-covid-data$'] dea
Join PortfolioProject.dbo.covidvaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject.dbo.['owid-covid-data$'] dea
Join PortfolioProject.dbo.covidvaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject.dbo.['owid-covid-data$'] dea
Join PortfolioProject.dbo.covidvaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 






 
