use military;


-- 1) OPERATIONS (master table for operations)
CREATE TABLE IF NOT EXISTS OPERATIONS (
  Operation_ID VARCHAR(30) NOT NULL,
  Operation_Name VARCHAR(100),
  Operation_Start_DateTime DATETIME,
  Operation_Priority TINYINT,                       
  Operation_Nature VARCHAR(80),
  Operation_Habitat VARCHAR(40),
  Operation_Expenditure DECIMAL(15,2),
  Friendlies_Contact_ID VARCHAR(30),
  Operation_Location_Country VARCHAR(60),
  Operation_Location_City VARCHAR(60),
  Operation_Location_X DECIMAL(9,6),
  Operation_Location_Y DECIMAL(9,6),
  PRIMARY KEY (Operation_ID)
);

-- 2) SQUADS
CREATE TABLE IF NOT EXISTS SQUADS (
  Squad_ID INT NOT NULL,
  Squad_Personnel_Count INT,
  Squad_Name VARCHAR(100),
  Squad_Creation_Date DATE,
  Squad_Operation_Assigned VARCHAR(30),
  Squad_Status VARCHAR(30),
  Squad_Leader VARCHAR(80),
  Squad_Casualties INT,
  Squad_Experience INT,         
  Squad_Specialisation VARCHAR(80),
  Squad_Rating TINYINT,         
  PRIMARY KEY (Squad_ID),
  KEY idx_squads_op (Squad_Operation_Assigned),
  CONSTRAINT fk_squads_operation FOREIGN KEY (Squad_Operation_Assigned)
    REFERENCES OPERATIONS (Operation_ID) ON DELETE SET NULL ON UPDATE CASCADE
);

-- 3) PERSONNEL
CREATE TABLE IF NOT EXISTS PERSONNEL (
  First_Name VARCHAR(50),
  Last_Name VARCHAR(50),
  Government_ID VARCHAR(50),
  DOB DATE,
  `1st_Contact_Relative_Contact_ID` VARCHAR(30),
  Home_City VARCHAR(80),
  ArmedServices_ID VARCHAR(30) NOT NULL,
  Squad_ID INT,
  Branch VARCHAR(40),
  Blood_Group VARCHAR(5),
  Current_Rank VARCHAR(50),
  Current_Operation_Assigned VARCHAR(30),
  Current_Operation_Role_Assigned VARCHAR(80),
  Personnel_Status VARCHAR(30),             
  Response_Days INT,                        
  PRIMARY KEY (ArmedServices_ID),
  KEY idx_personnel_squad (Squad_ID),
  KEY idx_personnel_op (Current_Operation_Assigned),
  CONSTRAINT fk_personnel_squad FOREIGN KEY (Squad_ID)
    REFERENCES SQUADS (Squad_ID) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_personnel_operation FOREIGN KEY (Current_Operation_Assigned)
    REFERENCES OPERATIONS (Operation_ID) ON DELETE SET NULL ON UPDATE CASCADE
);

-- 4) EQUIPMENT
CREATE TABLE IF NOT EXISTS EQUIPMENT (
  Equipment_ID INT NOT NULL,
  Equipment_Type_Code VARCHAR(30),
  Equipment_Type VARCHAR(80),
  Equipment_Name VARCHAR(120),
  Current_User_Assigned VARCHAR(30),         
  Current_Operation_Assigned VARCHAR(30),
  Equipment_Status VARCHAR(30),
  Equipment_Maintenance_Need TINYINT,        
  PRIMARY KEY (Equipment_ID),
  KEY idx_equipment_user (Current_User_Assigned),
  KEY idx_equipment_op (Current_Operation_Assigned),
  CONSTRAINT fk_equipment_user FOREIGN KEY (Current_User_Assigned)
    REFERENCES PERSONNEL (ArmedServices_ID) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_equipment_operation FOREIGN KEY (Current_Operation_Assigned)
    REFERENCES OPERATIONS (Operation_ID) ON DELETE SET NULL ON UPDATE CASCADE
);

-- 5) ALERTS
CREATE TABLE IF NOT EXISTS ALERTS (
  Alert_Code VARCHAR(30) NOT NULL,
  Operation_ID VARCHAR(30),
  Severity TINYINT,            
  Description VARCHAR(200),
  PRIMARY KEY (Alert_Code),
  KEY idx_alerts_op (Operation_ID),
  CONSTRAINT fk_alerts_operation FOREIGN KEY (Operation_ID)
    REFERENCES OPERATIONS (Operation_ID) ON DELETE CASCADE ON UPDATE CASCADE
);

-- 6) LOGISTICS
-- Composite key (Operation_ID + Equipment_Type_Required) to avoid duplicate rows for same equipment type per op
CREATE TABLE IF NOT EXISTS LOGISTICS (
    Operation_ID VARCHAR(30),
    Equipment_Type_Required VARCHAR(30),
    Equipment_Count INT,
    FOREIGN KEY (Operation_ID) REFERENCES OPERATIONS(Operation_ID)
);


-- 7) INTEL
CREATE TABLE IF NOT EXISTS INTEL (
  Intel_ID VARCHAR(30) NOT NULL,
  Intel_DateTime DATETIME,
  Operation_ID VARCHAR(30),
  Threat_Level TINYINT,        
  Intel_Summary VARCHAR(255),
  PRIMARY KEY (Intel_ID),
  KEY idx_intel_op (Operation_ID),
  CONSTRAINT fk_intel_operation FOREIGN KEY (Operation_ID)
    REFERENCES OPERATIONS (Operation_ID) ON DELETE SET NULL ON UPDATE CASCADE
);


LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/MILITARY/OPERATIONS.csv'
INTO TABLE OPERATIONS
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/MILITARY/SQUADS.csv'
INTO TABLE SQUADS
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/MILITARY/PERSONNEL.csv'
INTO TABLE PERSONNEL
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/MILITARY/EQUIPMENT.csv'
INTO TABLE EQUIPMENT
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/MILITARY/ALERTS.csv'
INTO TABLE ALERTS
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/MILITARY/LOGISTICS.csv'
INTO TABLE LOGISTICS
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/MILITARY/INTEL.csv'
INTO TABLE INTEL
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;










-- QUERIES

-- 1. List all operations with their names and countries
SELECT Operation_ID, Operation_Name, Operation_Location_Country FROM OPERATIONS;

-- 2. Find all squads that are currently active
SELECT Squad_ID, Squad_Name, Squad_Status FROM SQUADS WHERE Squad_Status = 'active';

-- 3. Show all personnel currently assigned to any operation
SELECT First_Name, Last_Name, Current_Operation_Assigned FROM PERSONNEL WHERE Current_Operation_Assigned IS NOT NULL;

-- 4. List all equipment that is damaged
SELECT Equipment_ID, Equipment_Name, Equipment_Status FROM EQUIPMENT WHERE Equipment_Status = 'damaged';

—- 5. Show all operations that have the word "Recon" in their name or nature
SELECT Operation_ID, Operation_Name, Operation_Nature 
FROM OPERATIONS 
WHERE Operation_Name LIKE '%Recon%' OR Operation_Nature LIKE '%Recon%';

-- 6. Show the total number of squads
SELECT COUNT(*) AS Total_Squads FROM SQUADS;

-- 7. Show the number of personnel in each branch
SELECT Branch, COUNT(*) AS Personnel_Count FROM PERSONNEL GROUP BY Branch;

-- 8. Display all operations that started after 2024
SELECT Operation_ID, Operation_Name, Operation_Start_DateTime FROM OPERATIONS WHERE YEAR(Operation_Start_DateTime) > 2024;

-- 9. Find all logistics requests for UAVs
SELECT * FROM LOGISTICS WHERE Equipment_Type_Required = 'UAV';

-- 10. Show all intel reports with a high threat level (>7)
SELECT * FROM INTEL WHERE Threat_Level > 7;

-- 11. List all personnel whose response time is above 20 days
SELECT First_Name, Last_Name, Response_Days FROM PERSONNEL WHERE Response_Days > 20;

-- 12. Find all squads that have suffered any casualties
SELECT Squad_ID, Squad_Name, Squad_Casualties 
FROM SQUADS 
WHERE Squad_Casualties > 0;

-- 13. Count the number of alerts per operation
SELECT Operation_ID, COUNT(*) AS Total_Alerts FROM ALERTS GROUP BY Operation_ID;

-- 14. List all operations and their total logistics equipment requested
SELECT Operation_ID, SUM(Equipment_Count) AS Total_Equipment_Requested FROM LOGISTICS GROUP BY Operation_ID;

-- 15. Find the maximum operation expenditure
SELECT MAX(Operation_Expenditure) AS Highest_Expenditure FROM OPERATIONS;






-- SUBQUERIES

-- 1. Find operations that have higher expenditure than the average expenditure
SELECT Operation_ID, Operation_Name, Operation_Expenditure
FROM OPERATIONS
WHERE Operation_Expenditure > (SELECT AVG(Operation_Expenditure) FROM OPERATIONS);

-- 2. Find squads with a rating above the average rating of all squads
SELECT Squad_ID, Squad_Name, Squad_Rating
FROM SQUADS
WHERE Squad_Rating > (SELECT AVG(Squad_Rating) FROM SQUADS);

-- 3. Find personnel assigned to the operation with the highest expenditure
SELECT First_Name, Last_Name, Current_Operation_Assigned
FROM PERSONNEL
WHERE Current_Operation_Assigned = (
  SELECT Operation_ID 
  FROM OPERATIONS 
  ORDER BY Operation_Expenditure DESC 
  LIMIT 1
);

-- 4. Find equipment assigned to the operation that has the highest number of alerts
SELECT Equipment_Name, Equipment_Type, Current_Operation_Assigned
FROM EQUIPMENT
WHERE Current_Operation_Assigned = (
  SELECT Operation_ID 
  FROM ALERTS 
  GROUP BY Operation_ID 
  ORDER BY COUNT(*) DESC 
  LIMIT 1
);

-- 5. List all squads that are part of the most recently started operation
SELECT Squad_ID, Squad_Name, Squad_Operation_Assigned
FROM SQUADS
WHERE Squad_Operation_Assigned = (
  SELECT Operation_ID 
  FROM OPERATIONS 
  ORDER BY Operation_Start_DateTime DESC 
  LIMIT 1
);

-- 6. Find all operations located in the same country as the most expensive operation
SELECT Operation_ID, Operation_Name, Operation_Location_Country
FROM OPERATIONS
WHERE Operation_Location_Country = (
  SELECT Operation_Location_Country 
  FROM OPERATIONS 
  ORDER BY Operation_Expenditure DESC 
  LIMIT 1
);

-- 7. Find all personnel assigned to the operation with the highest threat level
SELECT First_Name, Last_Name, Current_Operation_Assigned
FROM PERSONNEL
WHERE Current_Operation_Assigned = (
  SELECT Operation_ID 
  FROM INTEL 
  GROUP BY Operation_ID 
  ORDER BY AVG(Threat_Level) DESC 
  LIMIT 1
);

– 8. Find operations that have more than 3 logistics requests
SELECT Operation_ID, COUNT(*) AS Total_Logistics_Items
FROM LOGISTICS
GROUP BY Operation_ID
HAVING COUNT(*) > (
  SELECT AVG(cnt) FROM (SELECT COUNT(*) AS cnt FROM LOGISTICS GROUP BY Operation_ID) AS avg_log
);

-- 9. Find all operations that have above-average alert severity
SELECT DISTINCT Operation_ID
FROM ALERTS
WHERE Operation_ID IN (
  SELECT Operation_ID 
  FROM ALERTS 
  GROUP BY Operation_ID 
  HAVING AVG(Severity) > (SELECT AVG(Severity) FROM ALERTS)
);

-- 10. Find the squad leader of the most experienced squad
SELECT Squad_Leader, Squad_Experience
FROM SQUADS
WHERE Squad_Experience = (
  SELECT MAX(Squad_Experience) FROM SQUADS
);

-- 11. Find all operations that have received any alerts with maximum severity (10)
SELECT Operation_ID, Description, Severity
FROM ALERTS
WHERE Operation_ID IN (
  SELECT DISTINCT Operation_ID
  FROM ALERTS
  WHERE Severity = 10
);

-- 12. Find operations where the average threat level is higher than the overall average
SELECT Operation_ID, AVG(Threat_Level) AS Avg_Threat
FROM INTEL
GROUP BY Operation_ID
HAVING AVG(Threat_Level) > (SELECT AVG(Threat_Level) FROM INTEL);

-- 13. Find the operation(s) that have the most total personnel assigned
SELECT Current_Operation_Assigned AS Operation_ID, COUNT(*) AS Total_Personnel
FROM PERSONNEL
GROUP BY Current_Operation_Assigned
HAVING COUNT(*) = (
  SELECT MAX(PCount)
  FROM (
    SELECT COUNT(*) AS PCount 
    FROM PERSONNEL 
    GROUP BY Current_Operation_Assigned
  ) AS PersonnelCounts
);

-- 14. Find all personnel working in operations located in “Urban” habitat areas
SELECT First_Name, Last_Name, Current_Operation_Assigned
FROM PERSONNEL
WHERE Current_Operation_Assigned IN (
  SELECT Operation_ID 
  FROM OPERATIONS 
  WHERE Operation_Habitat = 'Urban'
);

-- 15. List all operations that are located in the same city as “OP005”
SELECT Operation_ID, Operation_Name, Operation_Location_City
FROM OPERATIONS
WHERE Operation_Location_City = (
  SELECT Operation_Location_City 
  FROM OPERATIONS 
  WHERE Operation_ID = 'OP005'
);
