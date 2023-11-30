Select *
from CovidDeath$
order by 3,4

Select *
from CovidVaccination$

--Death Percentage in VietNam
select location, date, total_cases, total_deaths, convert(float,total_deaths)/convert(float,total_cases)*100 as DeathsPercentage
from CovidDeath$
where location like 'vietnam'
and continent is not null
order by 2 

--Infected Percentage in VietNam
select location, date, total_cases,population_density, (total_cases/(population_density*1000000))*100 as InfectedPercentage
from CovidDeath$
where location like 'vietnam'
and continent is not null
order by 2

--Highest infection count in the world
select location, population_density, MAX(convert(float,total_cases)) as HighestInfectionCount, Max((convert(float,total_cases)/(population_density*1000000))*100) as InfectedPercentage
from CovidDeath$
where continent is not null
Group by location,population_density
order by InfectedPercentage DESC

--Countries with highest death count per population
select location,Max(convert(float,total_deaths)) as HighestDeathCount
from CovidDeath$
where continent is not null
group by location
order by HighestDeathCount desc

--Continents with dead count per population
select location,Max(convert(float,total_deaths)) as HighestDeathCount
from CovidDeath$
where continent is null
group by location
order by HighestDeathCount desc 

--Global count infection and death
select date, sum(new_cases) as TotalCase, sum(cast(new_deaths as int)) as TotalDeath, sum((new_cases/(population_density*1000000)*100)) as NewCaseperPopulation
from CovidDeath$
where continent is not null
group by date
order by 1,2

--Total new case and death in the world
select sum(new_cases) as TotalCase, sum(cast(new_deaths as int)) as TotalDeath
from CovidDeath$
where continent is not null
order by 1,2

select *
from CovidDeath$ dea
join CovidVaccination$ vac
	on dea.location=vac.location and dea.date=vac.date

--
select dea.continent, dea.location, dea.date,dea.population_density, vac.new_vaccinations, sum(cast(vac.new_vaccinations as float)) over (partition by dea.location)
from CovidDeath$ dea
join CovidVaccination$ vac
	on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
order by 2,3

--
select dea.continent, dea.location, dea.date,dea.population_density, vac.new_vaccinations, sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location,dea.date) as PeopleVaccinated
from CovidDeath$ dea
join CovidVaccination$ vac
	on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
order by 2,3

--Contries with people vaccinated and per
with PopvsVac (continent, location,date,population_density,new_vaccinations,PeopleVaccinated)
as(
select dea.continent, dea.location, dea.date,dea.population_density, vac.new_vaccinations, sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location,dea.date) as PeopleVaccinated
from CovidDeath$ dea
join CovidVaccination$ vac
	on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
)
select *, (PeopleVaccinated/(population_density*1000000)*100) as PercentageVaccinated
from PopvsVac


--
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population_density numeric,
new_vaccinations numeric,
PeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date,dea.population_density, vac.new_vaccinations, sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location,dea.date) as PeopleVaccinated
from CovidDeath$ dea
join CovidVaccination$ vac
	on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null

select *
from #PercentPopulationVaccinated

--
create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date,dea.population_density, vac.new_vaccinations, sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location,dea.date) as PeopleVaccinated
from CovidDeath$ dea
join CovidVaccination$ vac
	on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null

select *
from PercentPopulationVaccinated

--