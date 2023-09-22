
SET ARITHABORT OFF;
SET ANSI_WARNINGS OFF;

SELECT *
FROM PortfolioProject..CovidDeaths
Order by 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--Order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
Order by 1,2

-- Total Cases vs Total Deaths
-- Probability of contracting the virus when residing in this country.
Select location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'India'
Order by 1,2

-- Total Cases v Population
Select location, date, total_cases, population, (total_cases / population)*100 as CasePercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'India'
Order by 1,2

--Countries with highest infection rate w.r.t population
Select location, population, MAX(total_cases) as MaxCaseCount, MAX((total_cases / population))*100 as InfectionRate
FROM PortfolioProject..CovidDeaths
--WHERE location = 'India'
WHERE continent is null
Group By location, population
Order by InfectionRate DESC
-- India ranks at 177 with an infection rate of 3.2% as of 2023.

--Continent infection rate w.r.t population
Select continent, MAX(total_cases) as MaxCasesCount, MAX((total_cases / population))*100 as InfectionRate
FROM PortfolioProject..CovidDeaths
--WHERE location = 'India'
WHERE continent is not null
Group By continent
Order by MaxCasesCount DESC

--Countries with highest Death Rate due to Covid-19
Select location, population, MAX(total_deaths) as MaxDeathCount, MAX((total_deaths / population))*100 as MaxDeathRate
FROM PortfolioProject..CovidDeaths
--WHERE location = 'India'
WHERE continent is null
Group By location, population
Order by MaxDeathRate DESC

--Continents with highest Death Rate due to Covid-19
Select location, MAX(total_deaths) as MaxdeathCount, MAX((total_deaths / population))*100 as DeathRate
FROM PortfolioProject..CovidDeaths
--WHERE location = 'India'
WHERE continent is not null
Group By location
Order by MaxDeathCount DESC


-- GLOBAL NUMBERS
-- Increase in number of cases with duration. 
Select date, SUM(total_cases) as MaxCaseCount --(total_cases / total_deaths)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location = 'India'
WHERE continent is not null
Group By date
Order by date DESC


-- New cases registered w.r.t duration.
Select date, SUM(new_cases) as NewCaseCount --(total_cases / total_deaths)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location = 'India'
WHERE continent is not null
Group By date
Order by date DESC

-- Increase in number of deaths with duration.
Select date, SUM(total_deaths) as TotalDeathCount, SUM(total_cases) as TotalCaseCount, (SUM(total_deaths)/SUM(total_cases))*100 as DeathPercentage--(total_cases / total_deaths)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location = 'India'
WHERE continent is not null
Group By date
Order by date DESC


Select date, SUM(new_deaths) as NewDeathCount, SUM(new_cases) as NewCaseCount, (SUM(new_deaths)/SUM(new_cases))*100 as DeathPercentage--(total_cases / total_deaths)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location = 'India'
WHERE continent is not null
Group By date
Order by date DESC


--Overall Outlook
Select SUM(total_deaths) as TotalDeathCount, SUM(total_cases) as TotalCaseCount, (SUM(total_deaths)/SUM(total_cases))*100 as DeathPercentage--(total_cases / total_deaths)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location = 'India'
WHERE continent is not null

Select SUM(new_deaths) as NewDeathCount, SUM(new_cases) as NewCaseCount, (SUM(new_deaths)/SUM(new_cases))*100 as DeathPercentage--(total_cases / total_deaths)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null

--Total Population vs Vaccinations
--JOINING BOTH TABLES
Select CD.continent,CD.location, CD.date, CD.population, CV.new_vaccinations
From PortfolioProject..Coviddeaths CD
Join PortfolioProject..CovidVaccinations CV
ON CD.date = CV.date
AND CD.location = CV.location
WHERE CD.continent is NOT NULL
Order by 1,2,3

-- Progression of Vaccines Rolling Out
Select CD.continent,CD.location, CD.date, CD.population, CV.new_vaccinations
,SUM(cast (CV.new_vaccinations as int)) OVER (Partition By CD.Location Order By CD.Location,CD.date) as VaccinationTally
From PortfolioProject..Coviddeaths CD
Join PortfolioProject..CovidVaccinations CV
ON CD.date = CV.date
AND CD.location = CV.location
WHERE CD.continent is NOT NULL
Order by 1,2,3

--USING CTE
WITH PeopleToVaccine (Continent,Location,Date,Population,new_vaccinations,VaccinationTally)
as 
(
Select CD.continent,CD.location, CD.date, CD.population, CV.new_vaccinations
,SUM(cast (CV.new_vaccinations as int)) OVER (Partition By CD.Location Order By CD.Location,CD.date) as VaccinationTally
--(VaccinationTally/Population)*100
From PortfolioProject..Coviddeaths CD
Join PortfolioProject..CovidVaccinations CV
ON CD.date = CV.date
AND CD.location = CV.location
WHERE CD.continent is NOT NULL
--Order by 1,2,3
)
Select * , (VaccinationTally/Population)*100
FROM PeopleToVaccine

--CREATING A TEMP TABLE
DROP TABLE IF EXISTS #PPV
CREATE TABLE #PPV
--PercentPeopleVaccinated
(Continent nvarchar(50), Location nvarchar(50), Date datetime, Population numeric, New_Vaccinations numeric, VaccinationTally numeric)

INSERT INTO #PPV
Select CD.continent,CD.location, CD.date, CD.population, CV.new_vaccinations
,SUM(cast (CV.new_vaccinations as int)) OVER (Partition By CD.Location Order By CD.Location,CD.date) as VaccinationTally
--(VaccinationTally/Population)*100
From PortfolioProject..Coviddeaths CD
Join PortfolioProject..CovidVaccinations CV
ON CD.date = CV.date
AND CD.location = CV.location
--WHERE CD.continent is NOT NULL
--Order by 1,2,3

Select * , (VaccinationTally/Population)*100
FROM #PPV

CREATE VIEW PPV as
Select CD.continent,CD.location, CD.date, CD.population, CV.new_vaccinations
,SUM(cast (CV.new_vaccinations as int)) OVER (Partition By CD.Location Order By CD.Location,CD.date) as VaccinationTally
--(VaccinationTally/Population)*100
From PortfolioProject..Coviddeaths CD
Join PortfolioProject..CovidVaccinations CV
ON CD.date = CV.date
AND CD.location = CV.location
WHERE CD.continent is NOT NULL
--Order by 1,2,3

Select *
FROM PPV


