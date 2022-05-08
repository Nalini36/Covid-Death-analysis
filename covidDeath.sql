select * from CovidDeaths$;

select * from CovidDeaths$ 
where continent is not null
order by 3,4

select * from CovidVaccinations$
order by 3,4

select location,date,total_cases,new_cases,total_deaths,population from CovidDeaths$
order by 1,2;

--total cases vs total death

select location,date,total_cases,total_deaths from CovidDeaths$
order by 1,2;


select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Deathpercentage from CovidDeaths$
where location='india'
order by 1,2;


--lokking at toal cases vs population

select location,date,population ,total_cases,(total_cases/population)*100 as infectedpercentage from CovidDeaths$
where location='india'
order by 1,2;


--looking at the countreis with heighest infection rte complared to population

select location,population ,max(total_cases) as heighestInfectedCount,max((total_cases/population))*100 as infectedpercentage from CovidDeaths$
group by location,population
order by infectedpercentage DESC;

select location,population , date,max(total_cases) as heighestInfectedCount,max((total_cases/population))*100 as infectedpercentage from CovidDeaths$
group by location,population,date
order by infectedpercentage DESC;


---showing the highest death count population
select location, max(cast(total_deaths as int)) as totaldeathcount from CovidDeaths$
where continent is not null
group by location
order by totaldeathcount  DESC;


--breking down the things  by continents

select continent, max(cast(total_deaths as int)) as totaldeathcount from CovidDeaths$
where continent is not null
group by continent
order by totaldeathcount  DESC;


select continent, max(cast(total_deaths as int)) as totaldeathcount from CovidDeaths$
where continent is  not null
group by continent
order by totaldeathcount  DESC;



 



--GLOBAL NUMBERS


SELECT sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from CovidDeaths$ 
where continent is not null
order by 1,2;


---join both the table,
---looking at total population and vaccinations


select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
sum(convert(bigint,cv.new_vaccinations)) OVER (partition by cd.location order by cd.location,cd.date)as RollingPeopleVaccinated
from CovidDeaths$ cd
join CovidVaccinations$ cv
on cd.location=cv.location
and cd.date=cv.date
where cd.continent is not null
order by 2,3;


---with CTE
with popvsVac(continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as(
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
sum(convert(bigint,cv.new_vaccinations)) OVER (partition by cd.location order by cd.location,cd.date)as RollingPeopleVaccinated
from CovidDeaths$ cd
join CovidVaccinations$ cv
on cd.location=cv.location
and cd.date=cv.date
where cd.continent is not null
-- order by 2,3;
)
 select *,(RollingPeopleVaccinated/population)*100 as pecentage from popvsVac


 --temp table
 DROP TABLE if exists #percentPopulationvaccinated
	create table #percentPopulationvaccinated
	( continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	population numeric,
	new_vaccinations numeric,
	RollingPeopleVaccinated numeric
	)


 insert into #percentPopulationvaccinated


 select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
sum(convert(bigint,cv.new_vaccinations)) OVER (partition by cd.location order by cd.location,cd.date)as RollingPeopleVaccinated
from CovidDeaths$ cd
join CovidVaccinations$ cv
on cd.location=cv.location
and cd.date=cv.date
where cd.continent is not null
-- order by 2,3;
select *,(RollingPeopleVaccinated/population)*100 as pecentage from #percentPopulationvaccinated

--creating views for storing data for later visualization


create view percentPopulationvaccinated as
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
sum(convert(bigint,cv.new_vaccinations)) OVER (partition by cd.location order by cd.location,cd.date)as RollingPeopleVaccinated
from CovidDeaths$ cd
join CovidVaccinations$ cv
on cd.location=cv.location
and cd.date=cv.date
where cd.continent is not null



