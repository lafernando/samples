CREATE DATABASE BANKING_DB;
use BANKING_DB;

CREATE TABLE BRANCH (branchId VARCHAR(50), name VARCHAR(1024), address VARCHAR(1024), PRIMARY KEY(branchId));

CREATE TABLE ACCOUNT (accountId VARCHAR(50), name VARCHAR(1024), address VARCHAR(1024), balance DECIMAL(15,4), 
                      state VARCHAR(10), branchId VARCHAR(50), PRIMARY KEY(accountId), 
                      FOREIGN KEY (branchId) REFERENCES BRANCH(branchId));

CREATE TABLE ACCOUNT_LOG (accountLogId INT AUTO_INCREMENT, accountId VARCHAR(50), eventType VARCHAR(50), 
                          eventPayload VARCHAR(2048), eventTimestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
                          PRIMARY KEY(accountLogId));

CREATE TABLE ACCOUNT_ACTIVE_RATIO (branchId VARCHAR(50), ratio FLOAT);

INSERT INTO BRANCH (branchId, name, address) VALUES ("BWI", "Beloit", "554 West Oak Meadow Rd. Beloit, WI 53511");
INSERT INTO BRANCH (branchId, name, address) VALUES ("GNC", "Greenville", "658 Birchwood Court Greenville, NC 27834");
INSERT INTO BRANCH (branchId, name, address) VALUES ("RGA", "Roswell", "1 Circle Rd. Roswell, GA 30075");
INSERT INTO BRANCH (branchId, name, address) VALUES ("CRI", "Cranston", "25 Foxrun St. Cranston, RI 02920");

DELIMITER $$
CREATE PROCEDURE RefreshAccountActiveRatios()
BEGIN
  TRUNCATE TABLE ACCOUNT_ACTIVE_RATIO;
  INSERT INTO ACCOUNT_ACTIVE_RATIO SELECT branchId, SUM(CASE WHEN state="ACTIVE" THEN 1 ELSE 0 END) / COUNT(*) AS ratio FROM ACCOUNT GROUP BY branchId;
END;
$$
DELIMITER ;
