select * from portfolioProject..covidDeath
where continent!=''
order by 3,4

--select * from portfolioProject..covidVac
--order by 3,4

--Select Data that ým gonna use it

Select location,date,total_cases,new_cases,total_deaths,population
from portfolioProject..covidDeath
where continent!=''
order by location,date

--lookin that death percentage
Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Deaths_Pergentage
from portfolioProject..covidDeath
where continent!=''
order by location,date

--looking and total cases vs population,show as population pergentage got covid

Select location,date,total_cases ,population,(total_cases/population)*100 as Infection_Pergentage
from portfolioProject..covidDeath
where continent!=''
order by location

--looking and hightest infection rate of countries

Select location,max(total_cases)as max_cases,population,max((total_cases/population))*100 as Infection_Pergentage
from portfolioProject..covidDeath
where continent!=''
group by location,population
order by  Infection_Pergentage desc

--showing hightest death count per population of countries

Select location,max(cast(total_deaths as int))as max_death
from portfolioProject..covidDeath
where continent!=''
group by location
order by  max_death desc
-- total death cound in each continent
select continent ,sum(cast(new_deaths as float)) as TotalDeathCount
from portfolioProject..covidDeath
where continent!=''
group by continent
order by  TotalDeathCount desc
--total deaths count in each country
select location ,sum(cast(new_deaths as float)) as TotalDeathCount
from portfolioProject..covidDeath
where continent!=''
group by location
order by  TotalDeathCount desc

--each country ınfection percantege
select location,population,date,max(total_cases) as HighestInfectionCount,max(total_cases/population*100)as PercentPopulationInfection
from portfolioProject..covidDeath
group by location,population,date
order by PercentPopulationInfection desc


-- show the continent's death of death
Select continent,max(cast(total_deaths as int))as max_death
from portfolioProject..covidDeath
where continent!=''
group by continent
order by  max_death desc

--select total sum new cases and new deaths
select sum(cast(new_cases as float)) as total_cases,sum(cast(new_deaths as float)) as total_deaths,
sum(cast(new_deaths as float))/sum(cast(new_cases as float))*100 as Deaths_Percentage
from portfolioProject..covidDeath
where continent!=''


--global cases and death pergentage

select date,sum(new_cases) as new_cases,sum(cast(new_deaths as int)) as new_deaths ,sum(cast(new_deaths as int))/sum(new_cases)*100 as Pergentage_Deaths
from portfolioProject..covidDeath
where continent!=''
group by date
order by date
--check vac table
select * from portfolioProject..covidVac
--join deaths table and vaccinated table

select * from portfolioProject..covidDeath as dea join portfolioProject..covidVac as vac
on dea.location=vac.location
and dea.date=vac.date

--total population and vaccinations,
select dea.continent,dea.location,dea.date,dea.population,cast(vac.new_vaccinations as float) as new_vac_count,
sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as total_vac_count
from portfolioProject..covidDeath as dea join portfolioProject..covidVac as vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent!=''
order by 2,3

--use cte and find a pergentage of vaccinadet people in population
with PopvsVac (continent,location,date,population,new_vaccinations,total_vac_count)
as
(
select dea.continent,dea.location,dea.date,dea.population,cast(vac.new_vaccinations as float) as new_vac_count,
sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as total_vac_count
from portfolioProject..covidDeath as dea join portfolioProject..covidVac as vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent!=''
--order by 2,3
)

select *, (total_vac_count/population)*100  as per_vac
from PopvsVac

--create temp table and do smae thing
drop table if exists PercentPopVac
create table PercentPopVac
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
total_vac_count numeric
)
insert into PercentPopVac
select dea.continent,dea.location,dea.date,dea.population,cast(vac.new_vaccinations as float) as new_vac_count,
sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as total_vac_count
from portfolioProject..covidDeath as dea join portfolioProject..covidVac as vac
on dea.location=vac.location
and dea.date=vac.date
--where dea.continent!=''
--order by 2,3
select *, (total_vac_count/population)*100  as per_vac
from PercentPopVac

--Creat View
create view PercentPopVac_view as
select dea.continent,dea.location,dea.date,dea.population,cast(vac.new_vaccinations as float) as new_vac_count,
sum(convert(float,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as total_vac_count
from portfolioProject..covidDeath as dea join portfolioProject..covidVac as vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent!=''
--order by 2,3


select * from PercentPopVac_view

