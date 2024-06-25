--Total deaths vs Total cases
Select location, date, total_cases,total_deaths, 
round((CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100,2) AS Deathpercentage
from Portfolio_Project..covidDeaths
order by 1,2; 

-- what percentage of total population are gone in covid
Select location, date, population, total_cases,
(CONVERT(float, total_cases) / NULLIF(CONVERT(bigint, population), 0)) * 100 AS total_case_percent
from Portfolio_Project..covidDeaths

--Countries with highest infection rate
Select location ,population, max(convert(bigint,total_cases)) as HighestInfectionCount,
max((CONVERT(float, total_cases) / NULLIF(CONVERT(bigint, population), 0)) * 100) as PercentPopulationInfected
from Portfolio_Project..CovidDeaths
group by location,population
order by PercentPopulationInfected desc

--continents with highest death count per population 

SELECT continent, MAX(CAST(total_deaths AS INT)) AS HighestDeathCount
FROM Portfolio_Project..CovidDeaths
WHERE continent IS not NULL AND LTRIM(RTRIM(continent)) != ''
GROUP BY continent
ORDER BY HighestDeathCount DESC;

--Death percent across the world by date
Select sum(cast(new_cases as int)) as Totalcase,sum(cast (new_deaths as int)) as toataldeaths,
(sum(cast (new_deaths as float))/nullif(sum(cast (new_cases as float)),0)*100) as deathPercentage
from Portfolio_Project..CovidDeaths


--Population vs Vaccinations
WITH PopVsVac AS (
    SELECT 
        cd.continent,
        cd.location,
        cd.date,
        cd.population,
        cv.new_vaccinations,
        SUM(CONVERT(BIGINT, cv.new_vaccinations)) 
            OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS Cumelative_New_vaccinations
    FROM 
        Portfolio_Project..CovidDeaths cd 
    JOIN 
        Portfolio_Project..CovidVaccinations cv 
        ON cd.location = cv.location
        AND cd.date = cv.date
    WHERE 
        cv.continent IS NOT NULL 
        AND LTRIM(RTRIM(cv.continent)) != ''
)
SELECT *,round((Convert(float,Cumelative_New_vaccinations)) / NULLIF(convert(float,population), 0)*100,2) AS New_Vac_percent,
from PopVsVac

-- Creating view for later
Create view Total_deathVsCases as
Select location, date, total_cases,total_deaths, 
round((CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100,2) AS Deathpercentage
from Portfolio_Project..covidDeaths;

CREATE VIEW PopVsVacView AS
WITH PopVsVac AS (
    SELECT 
        cd.continent,
        cd.location,
        cd.date,
        cd.population,
        cv.new_vaccinations,
        SUM(CONVERT(BIGINT, cv.new_vaccinations)) 
            OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS Cumelative_New_vaccinations
        FROM 
        Portfolio_Project..CovidDeaths cd 
    JOIN 
        Portfolio_Project..CovidVaccinations cv 
        ON cd.location = cv.location
        AND cd.date = cv.date
    WHERE 
        cv.continent IS NOT NULL 
        AND LTRIM(RTRIM(cv.continent)) != ''
)
SELECT *,
       (Cumelative_New_vaccinations / NULLIF(CAST(population AS FLOAT), 0)) * 100 AS New_Vac_percent 
FROM PopVsVac
--ORDER BY location, date;





