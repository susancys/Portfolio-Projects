-- Exploratory Data Analysis

SELECT *
FROM layoffs_staging2;

#Percentage_laid_off alone is not quite important as there is no data about the total number of employees

-- The maximum of laid off data/how big the layoff is
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;

-- Companies that were laid off completely
SELECT * 
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

-- Companies with the most total layoffs
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- Earliest and latest date of layoffs
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;

-- Which industry has laid off most people?
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

-- Compare the total layoffs by year
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;

-- Figure out the industry that has the largest number of layoff
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

-- Zoom in layoff details by YEAR

WITH company_year AS
(
SELECT company, YEAR(`date`) AS years, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
)
, company_year_rank AS (
SELECT company, years, total_laid_off, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC)
	AS ranking
FROM company_year
)
SELECT company, years, total_laid_off, ranking
FROM company_year_rank
WHERE ranking <= 3
AND years IS NOT NULL
ORDER BY years DESC, total_laid_off DESC;

-- Rolling total of layoffs per month

SELECT SUBSTRING(date,1,7) AS dates, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY dates
ORDER BY dates ASC;

-- Use it in a CTE to query off of it

WITH DATE_CTE AS
(
SELECT SUBSTRING(date,1,7) AS dates, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY dates
ORDER BY dates ASC
)
SELECT dates, SUM(total_laid_off) OVER (ORDER BY dates ASC) as rolling_total_layoffs
FROM DATE_CTE
ORDER BY dates ASC;

