--Loading the data
select *
from CovidProject..covid_deaths
where continent is not null
order by 3,4


Select Location,date, total_cases, new_cases, total_deaths, population
from CovidProject..covid_deaths
order by 1,2


--looking at Total cases vs total deaths
Select Location,date, total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from CovidProject..covid_deaths
where location like '%states%'
order by 1,2


--looking at the total cases vs population
Select Location,date, population,total_cases,(total_cases/population)*100 as PercentageofpopulationInfected
from CovidProject..covid_deaths
where location= 'China'
order by 1,2


--looking at countries with highest infection rate compared to population and find highest one
Select Location,population,max(total_cases) as HighestInfectionCount,
max((total_cases/population)*100) as MaxCovidCasesPercentage
from CovidProject..covid_deaths
group by Location, Population
order by MaxCovidCasesPercentage desc


--Showing the continents with the highest death count
Select continent,max(cast(total_deaths as int)) as TotalDeathCount
from CovidProject..covid_deaths
where continent is not null
group by continent
order by TotalDeathCount desc


--Showing the countries with the highest death count
Select Location,max(cast(total_deaths as int)) as TotalDeathCount
from CovidProject..covid_deaths
where continent is not null
group by Location
order by TotalDeathCount desc


--Showing the GLOBAL numbers of DeathOfNewlyInfected
Select date, SUM(new_cases) as total_new_cases,sum(cast(new_deaths as int)) as total_new_deaths, 
round((sum(cast(new_deaths as int))/sum(new_cases))*100,2) as DeathPercentageGlobal
from CovidProject..covid_deaths
where continent is not null 
group by date
order by 4

--Total Global numbers
Select SUM(new_cases) as total_new_cases,sum(cast(new_deaths as int)) as total_new_deaths, 
round((sum(cast(new_deaths as int))/sum(new_cases))*100,2) as DeathPercentageGlobal
from CovidProject..covid_deaths
where continent is not null 
order by 1,2

--New Table
--Looking at Total Population vs Vaccinations
Select dt.continent,dt.location,dt.date,dt.population,vc.new_vaccinations,
SUM(convert(int,vc.new_vaccinations)) 
over (Partition by dt.location order by dt.location,dt.date) as SumPeopleVaccinated
from CovidProject..covid_deaths dt
Join CovidProject..covid_vaccinations vc
on dt.location= vc.location
and dt.date=vc.date
where dt.continent is not null 
order by 2,3

-- use CTE

With PopvsVac (Continent, Location, Date, Population,new_vaccinations, SumPeopleVaccinated)
as
(Select dt.continent,dt.location,dt.date,dt.population,vc.new_vaccinations,
SUM(convert(int,vc.new_vaccinations)) 
over (Partition by dt.location order by dt.location,dt.date) as SumPeopleVaccinated
from CovidProject..covid_deaths dt
Join CovidProject..covid_vaccinations vc
on dt.location= vc.location
and dt.date=vc.date
where dt.continent is not null 
)
select *, (SumPeopleVaccinated/Population)*100 as PercentPopulationVaccinated
from PopvsVac

--TEMP table
Drop Table if Exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
SumPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dt.continent,dt.location,dt.date,dt.population,vc.new_vaccinations,
SUM(convert(int,vc.new_vaccinations)) 
over (Partition by dt.location order by dt.location,dt.date) as SumPeopleVaccinated
from CovidProject..covid_deaths dt
Join CovidProject..covid_vaccinations vc
on dt.location= vc.location
and dt.date=vc.date
where dt.continent is not null 

select *, (SumPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated

--Creating View to store date for Visualisations later

Create View PercentPopulationVaccine as
Select dt.continent,dt.location,dt.date,dt.population,vc.new_vaccinations,
SUM(convert(int,vc.new_vaccinations)) 
over (Partition by dt.location order by dt.location,dt.date) as SumPeopleVaccinated
from CovidProject..covid_deaths dt
Join CovidProject..covid_vaccinations vc
on dt.location= vc.location
and dt.date=vc.date
where dt.continent is not null 


Select *
from PercentPopulationVaccine
