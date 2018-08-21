CREATE DATABASE Employee;

use Employee;

CREATE TABLE Employee (
  id INT NOT NULL AUTO_INCREMENT,
  name VARCHAR(128),
  age INT,
  PRIMARY KEY (id)
);

INSERT INTO Employee VALUES (1,'Will Smith',45),(2,'Johnny Depp',55),(5,'Sunil Perera',66);

