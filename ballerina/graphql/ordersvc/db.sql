CREATE DATABASE ORDER_DB;
use ORDER_DB;

CREATE TABLE CUSTOMER (id INT AUTO_INCREMENT, name VARCHAR(1024), address VARCHAR(10240), PRIMARY KEY(id));

CREATE TABLE SHIPPER (id INT AUTO_INCREMENT, name VARCHAR(1024), phone VARCHAR(1024), PRIMARY KEY(id));

CREATE TABLE ORDERS (id INT AUTO_INCREMENT, customerId INT, shipperId INT, date VARCHAR(1024), notes VARCHAR(10240), 
                     FOREIGN KEY (customerId) REFERENCES CUSTOMER(id),
                     FOREIGN KEY (shipperId) REFERENCES SHIPPER(id),
                     PRIMARY KEY(id));

INSERT INTO SHIPPER (name, phone) VALUES ("FedEx", "(408)275-5593");
INSERT INTO SHIPPER (name, phone) VALUES ("UPS", "(408)275-4415");
INSERT INTO CUSTOMER (name, address) VALUES ("Jack Smith", "No 10, N 1st St, San Jose");
INSERT INTO CUSTOMER (name, address) VALUES ("Nimal Perera", "No 22, Galle Road, Colombo 02");
INSERT INTO ORDERS (customerId, shipperId, date, notes) VALUES (1, 1, "2021/01/01", "Doorstep delivery");
INSERT INTO ORDERS (customerId, shipperId, date, notes) VALUES (2, 2, "2021/01/25", "Street pickup");