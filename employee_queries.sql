-- =====================================================
-- ScienceQtech Employee Performance Mapping Project
-- MySQL queries
-- =====================================================

-- Q1. Create database and import CSV files
CREATE DATABASE employee;
USE employee;
-- Import the CSV files using MySQL Workbench: Table Data Import Wizard
-- emp_record_table.csv
-- proj_table.csv
-- data_science_team.csv

-- Q2. ER diagram: created in MySQL Workbench via Database > Reverse Engineer

-- Q3. Employee ID, name, gender and department
SELECT
    EMP_ID,
    FIRST_NAME,
    LAST_NAME,
    GENDER,
    DEPT AS DEPARTMENT
FROM emp_record_table;

-- Q4. Employees by rating
-- Rating less than 2
SELECT EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPT AS DEPARTMENT, EMP_RATING
FROM emp_record_table
WHERE EMP_RATING < 2;

-- Rating greater than 4
SELECT EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPT AS DEPARTMENT, EMP_RATING
FROM emp_record_table
WHERE EMP_RATING > 4;

-- Rating between 2 and 4 (inclusive)
SELECT EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPT AS DEPARTMENT, EMP_RATING
FROM emp_record_table
WHERE EMP_RATING BETWEEN 2 AND 4;

-- Q5. Concatenate first and last names of Finance employees
SELECT CONCAT(FIRST_NAME, ' ', LAST_NAME) AS NAME
FROM emp_record_table
WHERE DEPT = 'Finance';

-- Q6. Managers and the count of their reporters
SELECT
    manager.EMP_ID,
    manager.FIRST_NAME,
    manager.LAST_NAME,
    COUNT(employee.EMP_ID) AS NUMBER_OF_REPORTERS
FROM emp_record_table AS manager
INNER JOIN emp_record_table AS employee
    ON manager.EMP_ID = employee.MANAGER_ID
GROUP BY
    manager.EMP_ID,
    manager.FIRST_NAME,
    manager.LAST_NAME;

-- Q7. Healthcare and Finance employees using UNION
SELECT EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPT
FROM emp_record_table
WHERE DEPT = 'Healthcare'
UNION
SELECT EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPT
FROM emp_record_table
WHERE DEPT = 'Finance';

-- Q8. Maximum rating in each department (window function)
SELECT
    EMP_ID,
    FIRST_NAME,
    LAST_NAME,
    ROLE,
    DEPT AS DEPARTMENT,
    EMP_RATING,
    MAX(EMP_RATING) OVER (PARTITION BY DEPT) AS MAX_DEPT_RATING
FROM emp_record_table;

-- Q9. Minimum and maximum salary for each role
SELECT
    ROLE,
    MIN(SALARY) AS MIN_SALARY,
    MAX(SALARY) AS MAX_SALARY
FROM emp_record_table
GROUP BY ROLE;

-- Q10. Rank employees by experience
SELECT
    EMP_ID,
    FIRST_NAME,
    LAST_NAME,
    EXP,
    RANK() OVER (ORDER BY EXP DESC) AS EXPERIENCE_RANK
FROM emp_record_table;

-- Q11. View for employees earning more than 6000
CREATE OR REPLACE VIEW high_salary_employees AS
SELECT *
FROM emp_record_table
WHERE SALARY > 6000;

SELECT *
FROM high_salary_employees;

-- Q12. Employees with more than 10 years of experience (nested query)
SELECT *
FROM emp_record_table
WHERE EMP_ID IN (
    SELECT EMP_ID
    FROM emp_record_table
    WHERE EXP > 10
);

-- Q13. Stored procedure: employees with more than 3 years of experience
DELIMITER //
CREATE PROCEDURE GetExperiencedEmployees()
BEGIN
    SELECT *
    FROM emp_record_table
    WHERE EXP > 3;
END //
DELIMITER ;

CALL GetExperiencedEmployees();

-- Q14. Stored function: compare data science team roles with experience standard
DELIMITER //
CREATE FUNCTION GetStandardRole(exp INT)
RETURNS VARCHAR(50)
DETERMINISTIC
BEGIN
    DECLARE standard_role VARCHAR(50);
    IF exp <= 2 THEN
        SET standard_role = 'JUNIOR DATA SCIENTIST';
    ELSEIF exp <= 5 THEN
        SET standard_role = 'ASSOCIATE DATA SCIENTIST';
    ELSEIF exp <= 10 THEN
        SET standard_role = 'SENIOR DATA SCIENTIST';
    ELSEIF exp <= 12 THEN
        SET standard_role = 'LEAD DATA SCIENTIST';
    ELSEIF exp <= 16 THEN
        SET standard_role = 'MANAGER';
    ELSE
        SET standard_role = 'OUT OF RANGE';
    END IF;
    RETURN standard_role;
END //
DELIMITER ;

SELECT
    EMP_ID,
    FIRST_NAME,
    LAST_NAME,
    EXP,
    ROLE AS ASSIGNED_ROLE,
    GetStandardRole(EXP) AS STANDARD_ROLE,
    CASE
        WHEN UPPER(TRIM(ROLE)) = GetStandardRole(EXP)
        THEN 'MATCH'
        ELSE 'MISMATCH'
    END AS STATUS
FROM data_science_team;

-- Q15. Index on first name (prefix index because FIRST_NAME is TEXT)
-- Before creating the index
EXPLAIN
SELECT *
FROM emp_record_table
WHERE FIRST_NAME = 'Eric';

CREATE INDEX idx_first_name
ON emp_record_table (FIRST_NAME(50));

-- After creating the index
EXPLAIN
SELECT *
FROM emp_record_table
WHERE FIRST_NAME = 'Eric';

-- Q16. Bonus = 5% of salary x employee rating
SELECT
    EMP_ID,
    FIRST_NAME,
    LAST_NAME,
    SALARY,
    EMP_RATING,
    (SALARY * 0.05 * EMP_RATING) AS BONUS
FROM emp_record_table;

-- Q17. Average salary by continent and country
SELECT
    CONTINENT,
    COUNTRY,
    AVG(SALARY) AS AVERAGE_SALARY
FROM emp_record_table
GROUP BY CONTINENT, COUNTRY
ORDER BY CONTINENT, COUNTRY;
