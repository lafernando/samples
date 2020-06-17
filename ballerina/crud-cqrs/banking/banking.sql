CREATE DATABASE BANKING_DB;
use BANKING_DB;

CREATE TABLE BRANCH (branch_id VARCHAR(50), name VARCHAR(1024), address VARCHAR(1024), PRIMARY KEY(branch_id));

CREATE TABLE ACCOUNT (account_id VARCHAR(50), name VARCHAR(1024), address VARCHAR(1024), balance DECIMAL(15,4), 
                      state VARCHAR(10), branch_id VARCHAR(50), PRIMARY KEY(account_id), 
                      FOREIGN KEY (branch_id) REFERENCES BRANCH(branch_id));

CREATE TABLE ACCOUNT_LOG (account_log_id VARCHAR(50), account_id VARCHAR(50), event_type VARCHAR(50), 
                         event_type_version INT, event_payload VARCHAR(2048), PRIMARY KEY(account_log_id), 
                         FOREIGN KEY (account_id) REFERENCES ACCOUNT(account_id));


INSERT INTO BRANCH (branch_id, name, address) VALUES ("BWI", "Beloit", "554 West Oak Meadow Rd. Beloit, WI 53511");
INSERT INTO BRANCH (branch_id, name, address) VALUES ("GNC", "Greenville", "658 Birchwood Court Greenville, NC 27834");
INSERT INTO BRANCH (branch_id, name, address) VALUES ("RGA", "Roswell", "1 Circle Rd. Roswell, GA 30075");
INSERT INTO BRANCH (branch_id, name, address) VALUES ("CRI", "Cranston", "25 Foxrun St. Cranston, RI 02920");
