CREATE TABLE Employee (id INT, name VARCHAR(100), age INT, PRIMARY KEY(id));

CREATE OR REPLACE PROCEDURE add_emp (id IN NUMBER, name IN VARCHAR2, age IN NUMBER)
IS
BEGIN
  
  INSERT INTO Employee (id, name, age) VALUES (id, name, age);

END;

