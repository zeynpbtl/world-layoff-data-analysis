


SELECT *
FROM layoffs_staging2;

SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;



SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;


SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;


SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

SELECT *
FROM layoffs_staging2;

SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;

SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;


SELECT company, AVG(percentage_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;


SELECT SUBSTRING(`date`, 1, 7) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC;


WITH Rolling_Total AS
(
SELECT SUBSTRING(`date`, 1, 7) AS `MONTH`, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC
)
SELECT `MONTH`, total_off,
SUM(total_off) OVER(ORDER BY `MONTH`) AS rolling_total
FROM Rolling_Total;



SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;


SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 	DESC;

WITH Company_Year (company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
), Company_Year_Rank AS
(SELECT *, DENSE_RANK() OVER(PARTITION BY years
ORDER BY total_laid_off DESC) AS ranking
FROM Company_Year
WHERE years IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <= 5;


SELECT company, location, total_laid_off, percentage_laid_off,
ROUND(total_laid_off / percentage_laid_off, 0) AS estimated_headcount_before_layoffs
FROM layoffs_staging2
WHERE total_laid_off IS NOT NULL
AND percentage_laid_off IS NOT NULL
AND percentage_laid_off > 0
ORDER BY estimated_headcount_before_layoffs DESC
;

SELECT 
    CASE 
        WHEN funds_raised_millions < 50 THEN '1. Düşük (<50M)'
        WHEN funds_raised_millions BETWEEN 50 AND 200 THEN '2. Orta (50M-200M)'
        WHEN funds_raised_millions BETWEEN 200 AND 500 THEN '3. Yüksek (200M-500M)'
        ELSE '4. Çok Yüksek (500M+)' 
    END AS funding_bucket,
    COUNT(*) AS company_count,
    ROUND(AVG(percentage_laid_off), 4) AS avg_percentage_laid_off,
    ROUND(AVG(total_laid_off), 2) AS avg_total_laid_off
FROM layoffs_staging2
WHERE funds_raised_millions IS NOT NULL 
  AND percentage_laid_off IS NOT NULL
GROUP BY funding_bucket
ORDER BY funding_bucket;