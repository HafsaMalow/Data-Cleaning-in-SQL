SELECT *
FROM layoffs;

-- first thing we want to do is create a staging table. This is the one we will work in and clean the data. We want a table with the raw data in case something happens
CREATE TABLE layoffs_staging
LIKE layoffs;


SELECT *
FROM layoffs_staging;

INSERT layoffs_staging 
SELECT * 
FROM layoffs ;


-- now when we are data cleaning we usually follow a few steps
-- 1. check for duplicates and remove any
-- 2. standardize data and fix errors
-- 3. Look at null values and see what 
-- 4. remove any columns and rows that are not necessary - few ways


-- 1. Remove Duplicates

# First let's check for duplicates


SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off,`date`) AS row_num
FROM layoffs_staging;


WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, 
total_laid_off,percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT * 
FROM duplicate_cte
WHERE row_num > 1;


SELECT *
FROM layoffs_staging
WHERE company = 'Casper';


CREATE TABLE layoffs_staging2 (
`company` text,
`location`text,
`industry`text,
`total_laid_off` INT,
`percentage_laid_off` text,
`date` text,
`stage`text,
`country` text,
`funds_raised_millions` int,
row_num INT
);

SELECT * 
FROM layoffs_staging2
WHERE row_num > 1;

INSERT layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, 
total_laid_off,percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

DELETE FROM layoffs_staging2
WHERE row_num > 1;






-- 2. Standardize Data


SELECT company, TRIM(company)
from layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);


SELECT DISTINCT industry
from layoffs_staging2;

UPDATE layoffs_staging2
SET industry ='Crypto'
WHERE industry LIKE 'Crypto%';

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2 
ORDER BY 1;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States ';

SELECT `date`,
STR_TO_DATE(`date`,'%m/%d/%Y')
FROM layoffs_staging2;
 
 UPDATE layoffs_staging2
 SET `date` = STR_TO_DATE(`date`,'%m/%d/%Y');
 
 ALTER TABLE layoffs_staging2
 MODIFY COLUMN `date` DATE;
 

-- 3. Look at Null Values

SELECT *
FROM layoffs_staging2 
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';


SELECT * 
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = ''; 

SELECT * 
FROM layoffs_staging2
WHERE company ='Airbnb';


SELECT t1.industry, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
     ON t1.company = t2.company
WHERE(t1.industry IS NULL OR t1.industry = '')
AND t2.industry  IS NOT NULL;

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- 4. remove any columns and rows we need to
SELECT *
FROM layoffs_staging2 
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;


DELETE
FROM layoffs_staging2 
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;



SELECT * 
FROM layoffs_staging2;


-- Exploratory Data Analysis
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;

SELECT * 
FROM layoffs_staging2
WHERE percentage_laid_off = 1 
ORDER BY funds_raised_millions DESC;

SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company;

SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;


SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;


SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

SELECT  YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;

SELECT  stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;


SELECT  company, SUM(percentage_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- rolling total of layoffs per month

SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC;

-- cte
WITH rolling_total AS
(
SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC
)
SELECT `MONTH`,total_off
 ,SUM(total_off) OVER(ORDER BY `MONTH`) AS rolling_total
FROM rolling_total;

-- company layoffs per year

SELECT  company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

WITH Company_Year AS 
(
SELECT company,YEAR(date) AS Years,SUM(total_laid_off) AS total_laid_off
fROM layoffs_staging2
GROUP BY company,YEAR(date)
)
,Company_Year_Rank AS (
SELECT company,years,total_laid_off,DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
FROM Company_Year
)
SELECT company, years,total_laid_off,ranking
FROM Company_Year_Rank
WHERE ranking <=5
AND years IS NOT NULL
ORDER BY years ASC, total_laid_off DESC;

select *
from layoffs_staging2;

-- Percentage layoffs per industry per year
WITH Industry_Year AS 
(
SELECT industry,YEAR(date) AS Years,SUM(percentage_laid_off) AS percentage_laid_off
fROM layoffs_staging2
GROUP BY industry,YEAR(date)
)
,Industry_Year_Rank AS (
SELECT industry,years,percentage_laid_off,DENSE_RANK() OVER(PARTITION BY years ORDER BY percentage_laid_off DESC) AS ranking
FROM Industry_Year
)
SELECT industry, years,percentage_laid_off,ranking
FROM Industry_Year_Rank
WHERE ranking <=5
AND years IS NOT NULL
ORDER BY years ASC, percentage_laid_off DESC;


-- layoffs per industry per year
WITH Industry_Year AS 
(
SELECT industry,YEAR(date) AS Years,SUM(total_laid_off) AS total_laid_off
fROM layoffs_staging2
GROUP BY industry,YEAR(date)
)
,Industry_Year_Rank AS (
SELECT industry,years,total_laid_off,DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
FROM Industry_Year
)
SELECT industry, years,total_laid_off,ranking
FROM Industry_Year_Rank
WHERE ranking <=5
AND years IS NOT NULL
ORDER BY years ASC, total_laid_off DESC;