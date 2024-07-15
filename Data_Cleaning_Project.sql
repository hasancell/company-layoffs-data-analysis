-- GOALS IN THIS DATA CLEANING PROJECT

-- STEP 1: Remove Duplicates

-- STEP 2: Standardize the Data

-- STEP 3: Look for NULL values or Blank Values

-- STEP 4: Remove Any columns

-- Create layoff staging table, the new table will have the same columns as the original.
CREATE TABLE layoffs_staging LIKE layoffs;


-- STEP 1: REMOVING DUPLICATES

-- Check all the records
SELECT *
FROM layoffs_staging;

-- Inserting all records from the original table into staging table.
INSERT layoffs_staging
SELECT *
FROM layoffs;

SELECT *,
ROW_NUMBER() OVER (PARTITION BY
    company, industry, total_laid_off, percentage_laid_off, `date`) as row_num
FROM layoffs_staging;

-- Identify duplicate records using ROW_NUMBER() window function
WITH duplicate_cte AS (SELECT *,
                              ROW_NUMBER() OVER (PARTITION BY
                                  company, location, industry, total_laid_off,
                                  percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
                       FROM layoffs_staging)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

SELECT *
FROM layoffs_staging
WHERE company = 'Casper';

-- GO TO SQL SCRIPTING AND REQUEST AND COPY ORIGINAL DLL AND PASTE HERE
CREATE TABLE `layoffs_staging2` ( -- ADDED ANOTHER TABLE CALLED LAYOFF_STAGING2
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT # ADDED ROW_NUM COLUMN AS INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Insert records into the new staging table with row numbers
INSERT INTO layoffs_staging2
SELECT *,
                              ROW_NUMBER() OVER (PARTITION BY
                                  company, location, industry, total_laid_off,
                                  percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
                       FROM layoffs_staging;

-- FIND DUPLICATES BY WHERE CLAUSE IS LARGER THAN 1
SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

DELETE
FROM layoffs_staging2
WHERE row_num > 1;

SELECT *
from layoffs_staging2;

-- STEP 2: STANDARDIZING DATA

-- WE CAN WRITE A QUERY TO COMPARE THE COMPANY COLUMN WITH TRIMMED VERSION TO SEE IF THERE IS ANY ERROR
SELECT company, (TRIM(company))
FROM layoffs_staging2;

-- UPDATE THE COMPANY COLUMN WITH TRIMMED FUNCTION
UPDATE layoffs_staging2
SET company = TRIM(company);

-- CHECK THE INDUSTRY COLUMN TO SEE IF THERE ARE ANY ANOMALIES
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;
-- IN INDUSTRY COLUMN, THERE ARE SOME RECORDS CALLED CRYPTO CURRENCY, CRYPTOCURRENCY, AND CRYPTO
-- AS MOST OF THEM ARE CRYPTO WE'RE GONNA CHANGE THEM ALL TO CRYPTO
SELECT industry
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT DISTINCT location
FROM layoffs_staging2
ORDER BY 1;

-- DÃ¼sseldorf, FlorianÃ³polis, MalmÃ¶ are TYPOS.
UPDATE layoffs_staging2
SET location = 'Dusseldorf'
WHERE location ='DÃ¼sseldorf';

UPDATE layoffs_staging2
SET location = 'Malmo'
WHERE location ='MalmÃ¶';

UPDATE layoffs_staging2
SET location = 'Florianopolis'
WHERE location ='FlorianÃ³polis';

SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;

SELECT *
FROM layoffs_staging2
WHERE country LIKE 'United States%'
ORDER BY country DESC;


-- COMPARE COUNTRIES ENDING WITH A DOT
SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1;

-- TRIM United States. with UNITED STATES
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

SELECT *
FROM layoffs_staging2;

-- THE DATE COLUMN IN OUR DATASET HAS TEXT TYPE INSTEAD WE NEED A DATE TYPE
SELECT `date`, str_to_date(`date`, '%m/%d/%Y') # %m/%d/%Y date format
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = str_to_date(`date`, '%m/%d/%Y');

SELECT `date`
FROM layoffs_staging2
ORDER BY 1;

-- ACTUALLY CHANGE THE TYPE OF DATE COLUMN
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

SELECT *
FROM layoffs_staging2;


SELECT *
FROM layoffs_staging2
WHERE country = 'China';

-- STEP 3 : LOOK FOR NULL OR BLANK VALUES

-- RECORDS WHO HAVE MORE THAN ONE NULL ARE BASICALLY USELESS
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL OR industry ='';

SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb';

UPDATE layoffs_staging2
set industry = NULL
WHERE industry = '';

-- Update 'industry' column where necessary
SELECT t1.industry, t2.industry
FROM layoffs_staging2 AS t1
JOIN layoffs_staging2 AS t2 ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '') AND t2.industry IS NOT NULL;

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 AS t2
    ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL AND t2.industry IS NOT NULL;

-- DELETE UNNECESSARY RECORDS

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

-- STEP 4: DELETE THE ROW NUM COLUMN
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

-- FINAL CHECK
SELECT *
FROM layoffs_staging2;
