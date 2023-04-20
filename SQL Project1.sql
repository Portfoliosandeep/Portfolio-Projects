--looking at total cases vs total deaths--
select
location,
date,
total_cases,
total_deaths,
round((total_deaths/total_cases)*100,2) as DeathPercentage
from CovidDeaths$
where location like '%states%' and continent is not null
order by 1,2;

--lokking at total Cases vs population---
--shows what percentage of popultion got covid--
select
location,
date,
total_cases,
population,
(total_cases/population)*100 as ContractionPercentage
from CovidDeaths$
--where location like '%states%'
where continent is not null
order by 1,2;

--looking at countries with highest infection rate compared to population--
select
location,
population,
max(total_Cases) as HighestInfectionCount,
max(total_cases/population)*100 as Percentageofpopulationinfected
from CovidDeaths$
where continent is not null
group by population,location
--where location like '%states%'
order by Percentageofpopulationinfected desc;

--showing countries with highest death count per population--

select
location,
max(total_deaths) as TotaldeathCount
from CovidDeaths$
where continent is not null
group by location
--where location like '%states%'
order by TotaldeathCount desc;

--lets break things by continent-
select
continent,
max(total_deaths) as TotaldeathCount
from CovidDeaths$
where continent is not null
group by continent
--where location like '%states%'
order by TotaldeathCount desc;

--Global Numbers--
SET ANSI_WARNINGS Off
select
sum(new_cases) as total_Cases,
sum(new_deaths)as total_Deaths,
sum(new_deaths)/nullif(sum(new_cases),0)*100 as  DeathPercentage
from CovidDeaths$
--where location like '%states%' 
where continent is not null
order by 1,2;

--looking at total population vs vaccinations
with popvsvac as (
select 
d.continent,
d.location,
 d.date,
d.population,
v.new_vaccinations,
sum(convert (bigint,v.new_vaccinations)) over(partition by d.location order by d.location,d.date) as rolling_total_Vaccinations
from CovidVaccinations$ v
join CovidDeaths$ d
	on v.location=d.location
	and v.date=d.date
where d.continent is not null
)

select *,
(rolling_total_Vaccinations/population)*100 
from popvsvac;

--creating views--

create view percentpopulationvaccinated as
select 
d.continent,
d.location,
 d.date,
d.population,
v.new_vaccinations,
sum(convert (bigint,v.new_vaccinations)) over(partition by d.location order by d.location,d.date) as rolling_total_Vaccinations
from CovidVaccinations$ v
join CovidDeaths$ d
	on v.location=d.location
	and v.date=d.date
where d.continent is not null
order by 2,3;

