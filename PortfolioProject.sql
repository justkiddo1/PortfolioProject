USE PortfolioProject

SELECT * FROM CovidDeaths WHERE continent is not null ORDER BY 3,4;

--SELECT * FROM CovidVaccinations ORDER BY 3,4;

-- Select Data that we are going to be using 
SELECT Location,date,total_cases,new_cases,total_deaths,population FROM CovidDeaths 
WHERE continent is not null ORDER BY 1,2 ;

-- Looking for Total Cases and Total Deaths
-- Shows likelihood off dying if you contract covid in United States
SELECT Location,date,total_cases,total_deaths, (total_deaths / total_cases )*100 AS DeathPercent
FROM CovidDeaths WHERE Location like '%states%' ORDER BY 1,2 ;

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid in US
SELECT Location,date,Population,total_cases , (total_cases / Population )*100 AS DeathPercent
FROM CovidDeaths WHERE Location like '%states%' ORDER BY 1,2 ;

-- Looking at Countries with Highest Infection Rate compared to Population
SELECT Location,Population,Max(total_cases) , Max((total_cases / Population ))*100 AS PercentPopulationInfected
FROM CovidDeaths GROUP BY Location,Population ORDER BY PercentPopulationInfected DESC ;

-- Showing Countries with Highest Death Count per Population
SELECT Location,MAX(cast(total_Deaths as int)) as TotalDeathCount
FROM CovidDeaths 
WHERE continent is not null
GROUP BY location ORDER BY TotalDeathCount DESC;

-- Showing continents with the highest death count per population
SELECT continent,MAX(cast(total_Deaths as int)) as TotalDeathCount
FROM CovidDeaths 
WHERE continent is not null
GROUP BY continent ORDER BY TotalDeathCount DESC;

-- GLOBAL NUMBERS
select date,SUM(new_cases) as Total_cases,SUM(CAST(new_deaths as int)) as Total_death,SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from CovidDeaths where continent is not null group by date order by 1,2;

-- Looking at Total Population vs Vaccinations
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION by dea.Location order by dea.Location,dea.Date)
as RollingPeopleVaccinated--,(RollingPeopleVaccinated/Population)*100
from CovidDeaths dea join CovidVaccinations vac 
	on dea.location=vac.location and dea.date=vac.date 
where dea.continent is not null order by 2,3 ;

-- USE CTE
With PopvsVac(continent,Location,Date,Population,new_vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION by dea.Location order by dea.Location,dea.Date)
as RollingPeopleVaccinated--,(RollingPeopleVaccinated/Population)*100
from CovidDeaths dea join CovidVaccinations vac 
	on dea.location=vac.location and dea.date=vac.date 
where dea.continent is not null 
)
select *,(RollingPeopleVaccinated/Population)*100 from PopvsVac;

-- TEMP TABLE 

DROP TABLE if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_vaccinations numeric,
	RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION by dea.Location order by dea.Location,dea.Date)
as RollingPeopleVaccinated--,(RollingPeopleVaccinated/Population)*100
from CovidDeaths dea join CovidVaccinations vac 
	on dea.location=vac.location and dea.date=vac.date 
--where dea.continent is not null

select *,(RollingPeopleVaccinated/Population)*100 from #PercentPopulationVaccinated;

-- Creating View to store data for later visualizations
Create view PercentPopulationVaccinted as 
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION by dea.Location order by dea.Location,dea.Date)
as RollingPeopleVaccinated--,(RollingPeopleVaccinated/Population)*100
from CovidDeaths dea join CovidVaccinations vac 
	on dea.location=vac.location and dea.date=vac.date 
where dea.continent is not null ;

select * from PercentPopulationVaccinted;







