create schema bubsbooties;

use bubsbooties;

CREATE TABLE products (
    product_id INT NOT NULL,
    product_name VARCHAR(30) NOT NULL UNIQUE,
    productCount_in_stock INT NOT NULL,
    PRIMARY KEY (product_id)
);

insert into products values
(1, 'Product_A', 10),
(2, 'Product_B', 5),
(3, 'Product_C', 5),
(4, 'Product_D', 10),
(5, 'Product_E', 1);

SELECT 
    *
FROM
    products;

CREATE TABLE customers (
    customer_id INT NOT NULL,
    first_name VARCHAR(30) NOT NULL,
    last_name VARCHAR(30) NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    PRIMARY KEY (customer_id)
);

insert into customers (customer_id, first_name, last_name, email) values
(1, 'Aman','Singh', 'amans1@xyz.com'),
(2, 'Ram','Sagar', 'rams2@xyz.com'),
(3, 'Mohit','', 'mohit3@xyz.com'),
(4, 'Rohan','Roy', 'rroy4@xyz.com'),
(5, 'Priya','Kumari', 'priyak5@xyz.com'),
(6, 'Nikhil','Raj', 'nraj6@xyz.com'),
(7, 'Riya','Gupta', 'riyagupta7@xyz.com'),
(8, 'Sonu','Supari', 'sssupari8@xyz.com'),
(9, 'Khushi','Sinha', 'khushis9@xyz.com'),
(10, 'Raju','Chaurasiya', 'rajuc10@xyz.com');

SELECT 
    *
FROM
    customers;

CREATE TABLE employees (
    employee_id INT NOT NULL,
    first_name VARCHAR(30) NOT NULL,
    last_name VARCHAR(30) NULL,
    start_date DATE NOT NULL,
    position_held VARCHAR(20) NOT NULL,
    PRIMARY KEY (employee_id)
);

insert into employees (employee_id, first_name, last_name, start_date, position_held) values
(1, 'Alia', '', '2020-10-10','Manager'),
(2, 'Ramesh', 'Sahni', '2020-10-10','Salesman'),
(3, 'Suresh', 'Sharma', '2020-10-11','Salesman');

SELECT 
    *
FROM
    employees;

CREATE TABLE customer_purchases (
    customer_purchase_id INT NOT NULL,
    customer_id INT NOT NULL,
    product_id INT NOT NULL,
    employee_id INT NOT NULL,
    purchase_date DATE NOT NULL,
    amount INT NOT NULL,
    PRIMARY KEY (customer_purchase_id)
);

insert into customer_purchases values
(1, 2, 1, 2, '2020-10-10', 100),
(2, 10, 5, 3, '2020-10-10', 1000),
(3, 3, 4, 3, '2020-10-11', 50),
(4, 5, 1, 3, '2020-10-11', 100),
(5, 6, 3, 2, '2020-10-11', 150),
(6, 9, 2, 3, '2020-10-12', 200),
(7, 8, 2, 2, '2020-10-12', 200),
(8, 1, 2, 2, '2020-10-13', 200),
(9, 7, 4, 2, '2020-10-13', 50),
(10, 4, 1, 3, '2020-10-13', 100),
(11, 1, 3, 2, '2020-10-14', 150),
(12, 10, 1, 3, '2020-10-14', 100),
(13, 5, 3, 2, '2020-10-15', 150),
(14, 5, 3, 3, '2020-10-15', 150),
(15, 9, 4, 2, '2020-10-15', 50);

SELECT 
    *
FROM
    customer_purchases;

alter table customer_purchases
add constraint foreign key (customer_id) references customers (customers_id);

alter table customer_purchases
add constraint foreign key (product_id) references products (product_id);

alter table customer_purchases
add constraint foreign key (employee_id) references employees (employee_id);

CREATE 
    TRIGGER  updateProducts
 AFTER INSERT ON customer_purchases FOR EACH ROW 
    UPDATE products SET productCount_in_stock = productCount_in_stock - 1 WHERE
        product_id = new.product_id;
    
insert into customer_purchases values
(16, 6, 4, 3, '2020-10-10', 50);