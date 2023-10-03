Create DATABASE Portfolio;

SELECT *
FROM [dbo].[CovidVaccinattion];


SELECT *
FROM [dbo].[CovidDeath]
WHERE continent IS NOT NULL
ORDER BY 3,4

-- Observing the locations, cases and  total deaths 
SELECT [location],[date],[population],[new_cases],[total_cases],[total_deaths]  
FROM [dbo].[CovidDeath]
WHERE continent IS NOT NULL
ORDER BY location, date;

--Alter the CovidDeaths Table to change the data type from nVARCHAR to FLOAT
ALTER TABLE [dbo].[CovidDeath]
ALTER COLUMN [total_cases] FLOAT;

ALTER TABLE [dbo].[CovidDeath]
ALTER COLUMN [total_deaths] FLOAT;


-- Looking at the percentage of death by covid 
-- The Chance of getting covid19 in Nigeria
SELECT [location],[date],[total_cases],[total_deaths], CAST((total_deaths/total_cases)*100 AS DECIMAL(10,2)) AS Percentage_of_death 
FROM [dbo].[CovidDeath]
WHERE location LIKE 'Nigeria'
ORDER BY location, date;

-- Comparing the total covid cases to the popopulation of Nigeria
-- To know the percentage of people with covid in the country
SELECT [location],[date],[population],[total_cases], (total_cases/population)*100 AS percentage_of_cases
FROM [dbo].[CovidDeath]
WHERE location LIKE 'Nigeria'
ORDER BY location, date;

--The highest percentage cases by location (Worldwide)
SELECT [location],[population],MAX(total_cases) AS Highest_Case, MAX((total_cases/population)*100) AS percentage_of_Case
FROM [dbo].[CovidDeath]
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY percentage_of_Case DESC;

--The highest percentage of people that died due to Covid
SELECT [location],[population],MAX(total_deaths) AS Highest_death, MAX((total_deaths/population)*100) AS percentage_of_death
FROM [dbo].[CovidDeath]
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY percentage_of_death DESC;

-- Countries with highest number of death due to covid
SELECT [location],MAX(total_deaths) AS Highest_death
FROM [dbo].[CovidDeath]
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY Highest_death DESC

--Death count by continent
SELECT continent,MAX(total_deaths) AS Highest_death
FROM [dbo].[CovidDeath]
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Highest_death DESC

-- Global death rate, daily trends 
SELECT [date],SUM(new_cases) AS Total_cases, SUM(new_deaths) AS Total_death, SUM(new_deaths)/NULLIF(sum(new_cases), 0)*100 AS Percentage_of_death
FROM [dbo].[CovidDeath]
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date, Total_cases;

-- Global total death rate 
SELECT SUM(new_cases) AS Total_cases, SUM(new_deaths) AS Total_death, SUM(new_deaths)/NULLIF(sum(new_cases), 0)*100 AS Percentage_of_death
FROM [dbo].[CovidDeath]
WHERE continent IS NOT NULL
ORDER BY Total_cases;

--Vaccination per day
-- Using CTE to calculate the percentage of people vaccinated
WITH PopVac (continent, location, date, population, new_vaccinations, PeopleVaccinated)
AS
(
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(CAST(cv.new_vaccinations AS FLOAT)) OVER (PARTITION BY cv.location ORDER BY cv.location, cv.date) AS PeopleVaccinated
FROM [dbo].[CovidVaccinattion] CV
JOIN [dbo].[CovidDeath] CD
ON cv.location = cd.location
AND cv.date = cd.date
WHERE cv.continent IS NOT NULL
)
SELECT *, (PeopleVaccinated/population)*100 AS percentage_Vaccinated
FROM PopVac

