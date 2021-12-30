/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/


create database portfolio_project_covid;

-- getting rid of unwanted data
select * from 
portfolio_project_covid.dbo.coviddeaths$
where continent is not null
order by 3,4;


-- selecting data to be used

select location,date, total_cases, new_cases, total_deaths,
population from portfolio_project_covid.dbo.coviddeaths$ 
order by 1,2;

-- Looking at Total Cases vs Total Deaths

select location,date, total_cases, total_deaths, 
(total_deaths/total_cases)*100 as death_percentage
from portfolio_project_covid.dbo.coviddeaths$ 
order by 1,2;

-- shows likelihood of dying if you contract covid in your country 

select location,date, total_cases, total_deaths, 
(total_deaths/total_cases)*100 as death_percentage
from portfolio_project_covid.dbo.coviddeaths$ 
where location like '%india%' and total_deaths is not null
order by 1,2;

-- Looking at Total Cases vs Population
 -- Shows what perecetage of population got covid

select location,date, population, total_cases,  
(total_cases/population)*100 as percent_pop_infected
from portfolio_project_covid.dbo.coviddeaths$ 
where location like '%india%' and total_deaths is not null
order by 1,2;


-- Countries with Highest Infection Rate compared to Population

select location, population, max(total_cases) as Highest_Infected_Country,  
max((total_cases/population)*100) as percent_pop_infected
from portfolio_project_covid.dbo.coviddeaths$ 
group by location, population
order by percent_pop_infected desc;

-- Countries with the Highest Death Count per Population

select location, max(cast(total_deaths as int)) as Total_death_count  
from portfolio_project_covid.dbo.coviddeaths$ where continent is not null
group by location
order by Total_death_count desc;

-- Continents with Highest Death Counts

select continent, max(cast(total_deaths as int)) as Total_death_count  
from portfolio_project_covid.dbo.coviddeaths$ where continent is not null
group by continent
order by Total_death_count desc;


-- Global Numbers
    -- Datewise
select date,sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as 
total_deaths, 
(sum(cast(new_deaths as int))/sum(new_cases))*100 as death_percentage
from portfolio_project_covid.dbo.coviddeaths$ 
where continent is not null
group by date
order by 1,2;

--  Overall worldwide Numbers
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as 
total_deaths, 
(sum(cast(new_deaths as int))/sum(new_cases))*100 as death_percentage
from portfolio_project_covid.dbo.coviddeaths$ 
where continent is not null
order by 1,2;


-- Looking at Total Population vs Vaccination

select death.continent, death.location, death.date, death.population,
vaccine.new_vaccinations, sum(cast(vaccine.new_vaccinations as int)) over (partition by
death.location order by death.location, death.date) as RollingPopVaccinated
from portfolio_project_covid.dbo.coviddeaths$  death 
join
portfolio_project_covid.dbo.covidvaccinations$ vaccine
on death.location=vaccine.location and death.date=vaccine.date
where death.continent is not null
order by 2,3;


-- Using CTE to perform Calculation on Partition by in previous query

with PopvsVac (continent, location, date, population,new_vaccinations,RollingPopVaccinated)
as
(select death.continent, death.location, death.date, death.population,
vaccine.new_vaccinations, sum(cast(vaccine.new_vaccinations as int)) over (partition by
death.location order by death.location, death.date) as RollingPopVaccinated
from portfolio_project_covid.dbo.coviddeaths$  death 
join
portfolio_project_covid.dbo.covidvaccinations$ vaccine
on death.location=vaccine.location and death.date=vaccine.date
where death.continent is not null)
select *, (RollingPopVaccinated/population)*100
from PopvsVac;


-- Using Temp table to perform Calculation on Partition by in previous query

drop table if exists PercentagePopVaccinated
create table #PercentagePopVaccinated
( continent nvarchar(255), location nvarchar(255),
date datetime, population numeric, new_vaccinations numeric, 
RollingPopVaccinated numeric)

insert into #PercentagePopVaccinated
select death.continent, death.location, death.date, death.population,
vaccine.new_vaccinations, sum(convert(int,vaccine.new_vaccinations)) over (partition by
death.location order by death.location, death.date) as RollingPopVaccinated
from portfolio_project_covid.dbo.coviddeaths$  death 
join
portfolio_project_covid.dbo.covidvaccinations$ vaccine
on death.location=vaccine.location and death.date=vaccine.date

select *, (RollingPopVaccinated/population)*100
from #PercentagePopVaccinated;


-- Creating view to store data for later visualizations

create view #PercentagePopVaccinated as 
select death.continent, death.location, death.date, death.population,
vaccine.new_vaccinations, sum(convert(int,vaccine.new_vaccinations)) over (partition by
death.location order by death.location, death.date) as RollingPopVaccinated
from portfolio_project_covid.dbo.coviddeaths$  death 
join
portfolio_project_covid.dbo.covidvaccinations$ vaccine
on death.location=vaccine.location and death.date=vaccine.date
where death.continent is not null)




