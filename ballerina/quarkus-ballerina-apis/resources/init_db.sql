CREATE TABLE customer (
    customer_id     SERIAL PRIMARY KEY,
    first_name      VARCHAR(100) NOT NULL,
    middle_name     VARCHAR(100),
    last_name       VARCHAR(100) NOT NULL,
    suffix          VARCHAR(100),
    email           VARCHAR(100),
    phone           VARCHAR(100)
);

insert into customer (first_name, middle_name, last_name, suffix, email, phone) values ('John', 'J', 'Doe', 'Jr.', 'john@doe.com', '4081131195');