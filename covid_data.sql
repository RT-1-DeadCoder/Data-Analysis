create schema covid;

use covid;

SHOW GLOBAL VARIABLES LIKE 'local_infile';
SET GLOBAL local_infile= true;

drop table if exists covid_deaths;

create table covid_deaths(
	iso_code CHAR(10),
	continent CHAR(15),
	location VARCHAR(100),
	date VARCHAR(15),
	population BIGINT,
	total_cases INT,
	new_cases INT,
	new_cases_smoothed FLOAT,
	total_deaths INT,
	new_deaths INT,
	new_deaths_smoothed FLOAT,
	total_cases_per_million FLOAT,
	new_cases_per_million FLOAT,
	new_cases_smoothed_per_million FLOAT,
	total_deaths_per_million FLOAT,
	new_deaths_per_million FLOAT,
	new_deaths_smoothed_per_million FLOAT,
	reproduction_rate FLOAT,
	icu_patients INT,
	icu_patients_per_million FLOAT,
	hosp_patients INT,
	hosp_patients_per_million FLOAT,
	weekly_icu_admissions INT,
	weekly_icu_admissions_per_million FLOAT,
	weekly_hosp_admissions INT,
	weekly_hosp_admissions_per_million FLOAT
);

UPDATE covid_deaths SET date = STR_TO_DATE(date, '%Y-%m-%d');

load data local infile 'C:/Users/KIIT/Downloads/CovidDeaths.csv' into table covid_deaths
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

drop table if exists covid_vaccinations;

create table covid_vaccinations(
	iso_code CHAR(10),
	continent CHAR(15),
	location VARCHAR(100),
	date VARCHAR(15),
	total_tests BIGINT,
	new_tests BIGINT,
	total_tests_per_thousand FLOAT,
	new_tests_per_thousand FLOAT,
	new_tests_smoothed INT,
	new_tests_smoothed_per_thousand FLOAT,
	positive_rate FLOAT,
	tests_per_case FLOAT,
	tests_units varchar(40),
	total_vaccinations BIGINT,
	people_vaccinated BIGINT,
	people_fully_vaccinated BIGINT,
	total_boosters INT,
	new_vaccinations INT,
	new_vaccinations_smoothed INT,
	total_vaccinations_per_hundred FLOAT,
	people_vaccinated_per_hundred FLOAT,
	people_fully_vaccinated_per_hundred FLOAT,
	total_boosters_per_hundred FLOAT,
	new_vaccinations_smoothed_per_million FLOAT,
	new_people_vaccinated_smoothed INT,
	new_people_vaccinated_smoothed_per_hundred FLOAT,
	stringency_index FLOAT,
	population_density FLOAT,
	median_age FLOAT,
	aged_65_older FLOAT,
	aged_70_older FLOAT,
	gdp_per_capita FLOAT,
	extreme_poverty FLOAT,
	cardiovasc_death_rate FLOAT,
	diabetes_prevalence FLOAT,
	female_smokers FLOAT,
	male_smokers FLOAT,
	handwashing_facilities FLOAT,
	hospital_beds_per_thousand FLOAT,
	life_expectancy FLOAT,
	human_development_index FLOAT,
	excess_mortality_cumulative_absolute FLOAT,
	excess_mortality_cumulative FLOAT,
	excess_mortality FLOAT,
	excess_mortality_cumulative_per_million FLOAT
);

UPDATE covid_vaccinations SET date = date_format(str_to_date(date, '%d-%m-%Y'), '%Y-%m-%d');

load data local infile 'C:/Users/KIIT/Downloads/CovidVaccinations.csv' into table covid_vaccinations
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;


select * from covid_deaths;

select * from covid_vaccinations;


select location, date_format(str_to_date(date, '%d-%m-%Y'), '%Y-%m-%d') as date, total_cases, new_cases, total_deaths, population
from covid_deaths
where continent!=""
order by location, date;


-- Total Cases vs Total Deaths
select location, date_format(str_to_date(date, '%d-%m-%Y'), '%Y-%m-%d') as date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as death_rate
from covid_deaths
where continent!=""
order by location, date;


-- Population vs Total Cases
select location, date_format(str_to_date(date, '%d-%m-%Y'), '%Y-%m-%d') as date, population, total_cases, (total_cases/population)*100 as percent_population_infected
from covid_deaths
where continent!=""
order by location, date;


-- Highest Infection Rate compared to Population
select location, population, max(total_cases) as highest_infection_count, max((total_cases/population)*100) as max_percent_population_infected
from covid_deaths
where continent!=""
group by location, population
order by max_percent_population_infected desc;


-- Highest Death Count
select location, max(total_deaths) as max_death_count
from covid_deaths
where continent!=""
group by location
order by max_death_count desc;


-- Highest Death Count with respect to Continents
select continent, sum(new_deaths) as max_death_count
from covid_deaths
where continent!=""
group by continent
order by max_death_count desc;


-- Cases and Deaths per day
select date_format(str_to_date(date, '%d-%m-%Y'), '%Y-%m-%d') as date, sum(new_cases) as total_case_count, sum(new_deaths) as total_death_count, (sum(new_deaths)/sum(new_cases))*100 as death_percent
from covid_deaths
where continent!=""
group by date
order by date;


-- Total cases and deaths across the world
select sum(new_cases) as total_case_count, sum(new_deaths) as total_death_count, (sum(new_deaths)/sum(new_cases))*100 as death_percent
from covid_deaths
where continent!="";


-- Vaccinations
select cd.continent, cd.location, date_format(str_to_date(cd.date, '%d-%m-%Y'), '%Y-%m-%d') as date, cd.population, cv.new_vaccinations, sum(new_vaccinations) over (partition by cd.location order by cd.location, date_format(str_to_date(cd.date, '%d-%m-%Y'), '%Y-%m-%d')) as total_no_of_people_vaccinated
from covid_deaths cd
join covid_vaccinations cv on cd.location=cv.location and cd.date=cv.date
where cd.continent!=""
order by cd.location, date;

-- Total Vaccinations vs Population
-- Using CTE (Common Table Expression)
With vac_wrt_pop (continent, location, date, population, new_vaccinations, total_no_of_people_vaccinated)
as
(
	select cd.continent, cd.location, date_format(str_to_date(cd.date, '%d-%m-%Y'), '%Y-%m-%d') as date, cd.population, cv.new_vaccinations, sum(new_vaccinations) over (partition by cd.location order by cd.location, date_format(str_to_date(cd.date, '%d-%m-%Y'), '%Y-%m-%d')) as total_no_of_people_vaccinated
	from covid_deaths cd
	join covid_vaccinations cv on cd.location=cv.location and cd.date=cv.date
	where cd.continent!=""
)

select *, (total_no_of_people_vaccinated/population)*100 as vaccinated_population_percent			-- The values are going over 100% because in the 'new_vaccinations' table 2nd dosage is also being considered
from vac_wrt_pop
order by location, date;

--- Creating some VIEWS

create view TotalCasesVsTotalDeaths as
select location, date_format(str_to_date(date, '%d-%m-%Y'), '%Y-%m-%d') as date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as death_rate
from covid_deaths
where continent!=""
order by location, date;

create view PopulationVsTotalCases as
select location, date_format(str_to_date(date, '%d-%m-%Y'), '%Y-%m-%d') as date, population, total_cases, (total_cases/population)*100 as percent_population_infected
from covid_deaths
where continent!=""
order by location, date;

create view HighestInfectionRateVsPopulation as
select location, population, max(total_cases) as highest_infection_count, max((total_cases/population)*100) as max_percent_population_infected
from covid_deaths
where continent!=""
group by location, population
order by max_percent_population_infected desc;

create view Continent_DeathCount as
select continent, sum(new_deaths) as max_death_count
from covid_deaths
where continent!=""
group by continent
order by max_death_count desc;

create view CasesAndDeathsPerDay as
select date_format(str_to_date(date, '%d-%m-%Y'), '%Y-%m-%d') as date, sum(new_cases) as total_case_count, sum(new_deaths) as total_death_count, (sum(new_deaths)/sum(new_cases))*100 as death_percent
from covid_deaths
where continent!=""
group by date
order by date;

select * from casesanddeathsperday;

create view VaccinationData as
select cd.continent, cd.location, date_format(str_to_date(cd.date, '%d-%m-%Y'), '%Y-%m-%d') as date, cd.population, cv.new_vaccinations, sum(new_vaccinations) over (partition by cd.location order by cd.location, date_format(str_to_date(cd.date, '%d-%m-%Y'), '%Y-%m-%d')) as total_no_of_people_vaccinated
from covid_deaths cd
join covid_vaccinations cv on cd.location=cv.location and cd.date=cv.date
where cd.continent!=""
order by cd.location, date;
