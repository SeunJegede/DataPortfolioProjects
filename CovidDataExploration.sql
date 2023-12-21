Select * from
CovidPortfolioProject..CovidDeaths
order by 1,2

Select * from
CovidPortfolioProject..CovidVaccinations


-- Select the data needed
Select location, date, total_cases, new_cases, total_deaths, population_density
from CovidPortfolioProject..CovidDeaths
order by 1,2

-- total deaths vs total cases
-- checking the likeliness of deaths occuring in a country due to infection
Select location, date, total_cases, total_deaths, (convert(float, total_deaths)/convert(float, total_cases))*100 as DeathPercentage
from CovidPortfolioProject..CovidDeaths
where location like '%nigeria%'
order by 1,2

Select convert(float, (convert (float, total_deaths)/convert(float, total_cases)))*100 as DeathPercentage
from CovidPortfolioProject..CovidDeaths

-- show what percentage of population contracted covid

Select continent, max(population) as totalPopulation
from CovidPortfolioProject..CovidDeaths
where continent is not null
group by continent
order by continent desc

--Total cases vs population
-- how many covid infections in population of a location
Select location, population, date, total_cases, (convert(float, population)/convert(float, total_cases))*100 as InfectionPercentage
from CovidPortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

--Countries with highest infection rate
Select location, population, max(total_cases) as maxCases, max((convert(float, total_cases)/convert(float, population)))/100 as PercentInfectionbyPopulation
from CovidPortfolioProject..CovidDeaths
--where location like '%states%'
group by location, population
order by PercentInfectionbyPopulation desc

--Showing countries with highest covid d--th count
Select location, max(total_deaths) as maxDeaths, max((convert(float, total_deaths)/convert(float, population)))/100 as PercentTotalDth
from CovidPortfolioProject..CovidDeaths
where continent is not null
group by location
order by maxDeaths desc

--ordering by continent
Select continent, max(total_deaths) as maxDeaths, max((convert(float, total_deaths)/convert(float, population)))/100 as PercentTotalDth
from CovidPortfolioProject..CovidDeaths
where continent is not null
group by continent
order by maxDeaths desc

--GLOBAL NUMBERS
-- Checking the total death percentage globally , cases vs dths, per day

Select date, sum(new_cases) as totalCases, sum(new_deaths) as totalDeaths, (sum(new_deaths)/sum(new_cases)+10)*100 as GlobalDthPercentage
from CovidPortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

--Total Population vs Vaccination
-- Show the percentage of the popultion that has received a covid vaccination

Select dea.location, dea.date, dea.continent, dea.population, vacs.new_vaccinations,
sum(convert(float, vacs.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingVaccinationNumbers
from CovidPortfolioProject..CovidVaccinations vacs
join CovidPortfolioProject..CovidDeaths dea
on vacs.location = dea.location
and vacs.date = dea.date
where dea.continent  is not null 
order by 1,2


-- Now to find the percentage of the location population that has been vaccinated
With PopulationVaccinated(Location, Date, Continent, Population, NewVaccinations, RollingVaccinationNumbers)
as
(
Select dea.location, dea.date, dea.continent, dea.population, vacs.new_vaccinations,
sum(convert(float, vacs.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingVaccinationNumbers
from CovidPortfolioProject..CovidVaccinations vacs
join CovidPortfolioProject..CovidDeaths dea
on vacs.location = dea.location
and vacs.date = dea.date
where dea.continent  is not null 
--order by 1,2
)
Select *, RollingVaccinationNumbers/Population * 100 as PopVacPercent
from PopulationVaccinated

--Temp table
Drop table if exists #PopulationVaccinatedPercentage
Create Table #PopulationVaccinatedPercentage
(
Location nvarchar(255),
Date datetime,
Continent nvarchar(255),
Population numeric,
NewVaccinations numeric,
RollingVaccinationNumbers numeric,
)
Insert into #PopulationVaccinatedPercentage
Select dea.location, dea.date, dea.continent, dea.population, vacs.new_vaccinations,
sum(convert(float, vacs.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingVaccinationNumbers
from CovidPortfolioProject..CovidVaccinations vacs
join CovidPortfolioProject..CovidDeaths dea
on vacs.location = dea.location
and vacs.date = dea.date
-- where dea.continent  is not null 
--order by 1,2
Select *, RollingVaccinationNumbers/Population * 100 as PopVacPercent
from #PopulationVaccinatedPercentage

--Creating views

CREATE VIEW PopulationVaccinatedPercent as
Select dea.location, dea.date, dea.continent, dea.population, vacs.new_vaccinations,
sum(convert(float, vacs.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingVaccinationNumbers
from CovidPortfolioProject..CovidVaccinations vacs
join CovidPortfolioProject..CovidDeaths dea
on vacs.location = dea.location
and vacs.date = dea.date
where dea.continent  is not null 
--order by 1,2

Select *
from PopulationVaccinatedPercent

Create view PopulationVaccinated as
Select dea.location, dea.date, dea.continent, dea.population, vacs.new_vaccinations,
sum(convert(float, vacs.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingVaccinationNumbers
from CovidPortfolioProject..CovidVaccinations vacs
join CovidPortfolioProject..CovidDeaths dea
on vacs.location = dea.location
and vacs.date = dea.date
where dea.continent  is not null 

Select *
from PopulationVaccinated
