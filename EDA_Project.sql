-- EXPLORATORY DATA ANALYSIS ON COMPANY LAYOFFS BETWEEN 2020 AND 2023 Q1

-- 1. Companies with 100% Layoffs Ordered by Funds Raised
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

-- 2. Total Layoffs by Company
SELECT company, SUM(layoffs_staging2.total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- 3. Layoffs Data Start and End Dates
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;

-- 4. Total Layoffs by Industry
SELECT industry, SUM(layoffs_staging2.total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

-- 5. Total Layoffs by Country
SELECT country, SUM(layoffs_staging2.total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

-- 6. Total Layoffs by Year
SELECT YEAR(`date`), SUM(layoffs_staging2.total_laid_off)
FROM layoffs_staging2
GROUP by YEAR(`date`)
ORDER BY 1 DESC;

-- 7. Total Layoffs by Company Stage
SELECT stage, SUM(layoffs_staging2.total_laid_off)
FROM layoffs_staging2
GROUP by stage
ORDER BY 2 DESC;

-- 8. Average Layoffs by Company
SELECT company, AVG(layoffs_staging2.total_laid_off)
FROM layoffs_staging2
GROUP by company
ORDER BY 2 DESC;

-- 9. Rolling Laid Off by Month
SELECT SUBSTRING(`date`, 1,7) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC;

-- 10. Rolling Total Laid Off by Month
WITH Rolling_Total AS ( SELECT SUBSTRING(`date`, 1,7) AS `MONTH`, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC )
SELECT `MONTH`, total_off, SUM(total_off) OVER(ORDER BY `MONTH`) as rolling_total
FROM Rolling_Total;

-- THE COMPANY BY THE YEAR AND HOW MANY PEOPLE THEY LAID OFF
-- 11. Layoffs by Company and Year
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC;

-- 12. TOTAL LAYOFF BY TOP COMPANIES OVER THE YEARS WITH RANKING
-- 1ST CTE STARTS
WITH Company_Year(company, years, total_laid_off) AS (SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)), -- 1ST CTE ENDS
    Company_Year_Rank AS (SELECT *, DENSE_RANK() over (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking -- 2ND CTE STARTS
FROM Company_Year
WHERE years IS NOT NULL) -- 2ND CTE ENDS
SELECT * -- FILTERING BASED ON THE RANK
FROM Company_Year_Rank
WHERE Ranking <= 5;

-- FUTURE WORK COULD INCLUDE COMPANY AND PERCENTAGE LAID OFF