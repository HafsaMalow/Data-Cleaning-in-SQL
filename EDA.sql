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