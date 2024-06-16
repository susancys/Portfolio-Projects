-- Analyze application data from 2023 and identify application trends
-- Queries include: GROUP BY, CASE WHEN, table & column modify, data cleaning

Use portfolioproject;
ALTER TABLE application_data_2023 RENAME TO applicationdata2023;
SELECT * FROM applicationdata2023;
ALTER TABLE applicationdata2023 RENAME COLUMN ï»¿application_id TO app_id;

-- All applicants
#Count the ratio of ineligible vs. all applicants
SELECT (COUNT(CASE WHEN status = 'Ineligible' THEN 1 END)/COUNT(*))*100 AS ineligible_percentage
FROM applicationdata2023;

#Count the ratio of applicants with disabilities vs. all applicants
SELECT (COUNT(CASE WHEN disability_flag = 'Yes' THEN 1 END)/COUNT(*))*100 AS disability_percentage
FROM applicationdata2023;

#Count the ratio of reapplicants vs. all applicants
SELECT (COUNT(CASE WHEN prev_applied_times > 0 THEN 1 END)/COUNT(*))*100 AS reapply_percentage
FROM applicationdata2023;

-- Age Group
#Add an age column
ALTER TABLE applicationdata2023 ADD COLUMN age INT;
ALTER TABLE applicationdata2023 MODIFY age INT AFTER dob;

#Alter dob into proper format
ALTER TABLE applicationdata2023 ADD COLUMN birthdate DATE;
UPDATE applicationdata2023
SET birthdate = STR_TO_DATE(dob, '%m/%d/%Y');
ALTER TABLE applicationdata2023 DROP COLUMN dob;
ALTER TABLE applicationdata2023 MODIFY birthdate DATE AFTER gender;

#Insert age info in the column
UPDATE applicationdata2023
SET age = TIMESTAMPDIFF(YEAR, birthdate, '2023-09-01') - 
          (DATE_FORMAT('2023-09-01', '%m%d') < DATE_FORMAT(birthdate, '%m%d'));
          
#Count the maximum, minimum and average age of all applicants
SELECT MAX(age) AS max_app_age 
FROM applicationdata2023;

SELECT MIN(age) AS min_app_age 
FROM applicationdata2023;

SELECT AVG(age) AS avg_app_age 
FROM applicationdata2023;

-- Gender
#Count number of applicants whose gender is not female or male
SELECT COUNT(gender) AS num_gender_non_female_male
FROM applicationdata2023
WHERE gender NOT IN ('F', 'M');

-- Institution
#Clean duplicate institution name and combine (UBC, UBCV, UBCO)
UPDATE applicationdata2023
SET highest_level_inst_name = 'University of British Columbia'
WHERE highest_level_inst_name IN(
'University of British Columbia - Vancouver', 
'University of British Columbia - Okanagan', 
'UBC', 
'The University of British Columbia', 
'The University of British Columbia - Vancouver', 
'UBC-O', 
'University of British Columbia- Okanagan'
);
DELETE FROM applicationdata2023
WHERE highest_level_inst_name IS NULL;

#Count the number of each institution
SELECT highest_level_inst_name, COUNT(highest_level_inst_name) AS num_from_institution
FROM applicationdata2023
GROUP BY highest_level_inst_name
ORDER BY num_from_institution DESC;

-- MCAT
#Calculate the average of the total MCAT score excluding ineligible applicants and round the number
SELECT ROUND(AVG(mcat_score_total), 2) AS avg_mcat
FROM applicationdata2023
WHERE status <> 'Ineligible';

-- Admitted class
#Age: maximum, minimum and average
SELECT max(age) AS max_class_age 
FROM applicationdata2023
WHERE status = 'Offer Accepted';

SELECT min(age) AS min_class_age 
FROM applicationdata2023
WHERE status = 'Offer Accepted';

SELECT avg(age) AS avg_class_age 
FROM applicationdata2023
WHERE status = 'Offer Accepted';

-- Prepare data for visualization
SELECT * 
FROM applicationdata2023
WHERE status <> 'Ineligible';

SELECT *
FROM applicationdata2023;