CREATE TABLE Employee (id INT, name VARCHAR(128), age INT, team VARCHAR(128), PRIMARY KEY(id));

CREATE OR REPLACE PROCEDURE add_emp (id IN NUMBER, name IN VARCHAR2, age IN NUMBER, team VARCHAR2)
IS
BEGIN
  
  INSERT INTO Employee (id, name, age, team) VALUES (id, name, age, team);

END;

