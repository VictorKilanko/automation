# Automate SQL to extract, clean, summarize, alert me weekly

-- Snapshot Stage
CREATE TABLE IF NOT EXISTS employee_snapshots (
    snapshot_date DATETIME,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    age INT,
    gender VARCHAR(10)
);

DELIMITER $$

CREATE EVENT weekly_employee_snapshot
ON SCHEDULE EVERY 1 WEEK
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    INSERT INTO employee_snapshots
    SELECT NOW(), first_name, last_name, age, gender
    FROM employee_demographics;
END $$
DELIMITER ;

-- Cleaning Stage

CREATE TABLE IF NOT EXISTS employee_cleaned (
    snapshot_date DATETIME,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    age INT,
    gender VARCHAR(10)
);

DELIMITER $$

CREATE EVENT weekly_employee_cleaning
ON SCHEDULE EVERY 1 WEEK
STARTS CURRENT_TIMESTAMP + INTERVAL 5 MINUTE
DO
BEGIN
    INSERT INTO employee_cleaned
    SELECT 
        snapshot_date,
        TRIM(first_name),
        TRIM(last_name),
        NULLIF(age, ''),
        CONCAT(UPPER(LEFT(TRIM(gender),1)), LOWER(SUBSTRING(TRIM(gender),2)))
    FROM employee_snapshots
    WHERE snapshot_date = (SELECT MAX(snapshot_date) FROM employee_snapshots);
END $$
DELIMITER ;

-- Summary Stage

CREATE TABLE IF NOT EXISTS employee_summary (
    summary_date DATE,
    total_employees INT,
    avg_age DECIMAL(5,2),
    male_count INT,
    female_count INT
);

DELIMITER $$

CREATE EVENT weekly_employee_summary
ON SCHEDULE EVERY 1 WEEK
STARTS CURRENT_TIMESTAMP + INTERVAL 10 MINUTE
DO
BEGIN
    INSERT INTO employee_summary
    SELECT 
        CURDATE(),
        COUNT(*),
        AVG(age),
        SUM(CASE WHEN gender = 'Male' THEN 1 ELSE 0 END),
        SUM(CASE WHEN gender = 'Female' THEN 1 ELSE 0 END)
    FROM employee_cleaned
    WHERE snapshot_date = (SELECT MAX(snapshot_date) FROM employee_cleaned);
END $$
DELIMITER ;

-- Alerts Stage

CREATE TABLE IF NOT EXISTS alerts (
    alert_time DATETIME,
    message VARCHAR(255)
);

DELIMITER $$

CREATE EVENT weekly_data_alerts
ON SCHEDULE EVERY 1 WEEK
STARTS CURRENT_TIMESTAMP + INTERVAL 15 MINUTE
DO
BEGIN
    -- Missing ages
    INSERT INTO alerts (alert_time, message)
    SELECT NOW(), CONCAT(first_name, ' ', last_name, ' is missing age')
    FROM employee_cleaned
    WHERE snapshot_date = (SELECT MAX(snapshot_date) FROM employee_cleaned)
      AND age IS NULL;

    -- Gender not recognized
    INSERT INTO alerts (alert_time, message)
    SELECT NOW(), CONCAT(first_name, ' ', last_name, ' has invalid gender: ', gender)
    FROM employee_cleaned
    WHERE snapshot_date = (SELECT MAX(snapshot_date) FROM employee_cleaned)
      AND gender NOT IN ('Male','Female');
END $$
DELIMITER ;
