/***************************************************************************
 * BookStore Database Project
 * Members: 1. Teddy Anangwe
			2. Nelius Wandia
			3. Sam mubea
 ***************************************************************************/

/* =========================
   STEP 1: Create the Database
   ========================= */
CREATE DATABASE IF NOT EXISTS BookStoreDB;
USE BookStoreDB;


/* =========================
   STEP 2: Create Tables 
   ========================= */

/* 1. book_language*/
CREATE TABLE book_language (
    language_id INT AUTO_INCREMENT PRIMARY KEY,          -- Primary key
    language_name VARCHAR(50) NOT NULL UNIQUE             -- Unique language name
);


/* 2. publisher: Stores publisher details */
CREATE TABLE publisher (
    publisher_id INT AUTO_INCREMENT PRIMARY KEY,         -- Primary key
    publisher_name VARCHAR(100) NOT NULL UNIQUE          -- Unique publisher name
);


/* 3. author: Stores author details */
CREATE TABLE author (
    author_id INT AUTO_INCREMENT PRIMARY KEY,            -- Primary key
    first_name VARCHAR(50),                               -- First name of the author
    last_name VARCHAR(50)                                 -- Last name of the author
);


/* 4. book: Stores book details including links to language and publisher */
CREATE TABLE book (
    book_id INT AUTO_INCREMENT PRIMARY KEY,              -- Primary key
    title VARCHAR(255) NOT NULL,                          -- Book title
    isbn VARCHAR(20) UNIQUE,                              -- Book ISBN (unique)
    publication_year YEAR,                                -- Year of publication
    price DECIMAL(8,2),                                   -- Book price with two decimals
    language_id INT,                                      -- Foreign key: book language
    publisher_id INT,                                     -- Foreign key: publisher
    FOREIGN KEY (language_id) REFERENCES book_language(language_id),
    FOREIGN KEY (publisher_id) REFERENCES publisher(publisher_id)
);


/* 5. book_author: Join table for the many-to-many relationship between books and authors */
CREATE TABLE book_author (
    book_id INT,                                          -- FK referencing book
    author_id INT,                                        -- FK referencing author
    PRIMARY KEY (book_id, author_id),                     -- Composite primary key
    FOREIGN KEY (book_id) REFERENCES book(book_id),
    FOREIGN KEY (author_id) REFERENCES author(author_id)
);


/* 6. country: Reference table for countries */
CREATE TABLE country (
    country_id INT AUTO_INCREMENT PRIMARY KEY,           -- Primary key
    country_name VARCHAR(100) NOT NULL UNIQUE            -- Unique country name
);


/* 7. address_status: Stores statuses for addresses (e.g., current, old) */
CREATE TABLE address_status (
    status_id INT AUTO_INCREMENT PRIMARY KEY,            -- Primary key
    status_description VARCHAR(50) NOT NULL UNIQUE        -- Unique description of status
);


/* 8. address: Stores physical address details */
CREATE TABLE address (
    address_id INT AUTO_INCREMENT PRIMARY KEY,           -- Primary key
    street VARCHAR(255),                                  -- Street address
    city VARCHAR(100),                                    -- City
    state VARCHAR(100),                                   -- State/Region
    zip_code VARCHAR(20),                                 -- Postal code
    country_id INT,                                       -- Foreign key: country
    FOREIGN KEY (country_id) REFERENCES country(country_id)
);


/* 9. customer: Stores customer details */
CREATE TABLE customer (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,          -- Primary key
    first_name VARCHAR(50),                               -- Customer first name
    last_name VARCHAR(50),                                -- Customer last name
    email VARCHAR(100) UNIQUE                             -- Unique email address
);


/* 10. customer_address: Maps customers to their addresses
       (customers can have multiple addresses and each address can have a status) */
CREATE TABLE customer_address (
    customer_id INT,                                      -- FK referencing customer
    address_id INT,                                       -- FK referencing address
    status_id INT,                                        -- FK referencing address_status
    PRIMARY KEY (customer_id, address_id),                -- Composite primary key
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
    FOREIGN KEY (address_id) REFERENCES address(address_id),
    FOREIGN KEY (status_id) REFERENCES address_status(status_id)
);


/* 11. shipping_method: Stores available shipping methods for orders */
CREATE TABLE shipping_method (
    shipping_method_id INT AUTO_INCREMENT PRIMARY KEY,   -- Primary key
    method_name VARCHAR(50) NOT NULL UNIQUE              -- Unique name of the shipping method
);


/* 12. order_status: Reference table for order statuses */
CREATE TABLE order_status (
    status_id INT AUTO_INCREMENT PRIMARY KEY,            -- Primary key
    status_description VARCHAR(50) NOT NULL UNIQUE        -- Unique status description
);


/* 13. cust_order: Stores customer orders */
CREATE TABLE cust_order (
    order_id INT AUTO_INCREMENT PRIMARY KEY,             -- Primary key
    customer_id INT,                                      -- FK referencing customer
    order_date DATETIME DEFAULT CURRENT_TIMESTAMP,        -- Order creation date
    shipping_method_id INT,                               -- FK referencing shipping_method
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
    FOREIGN KEY (shipping_method_id) REFERENCES shipping_method(shipping_method_id)
);


/* 14. order_line: Stores the individual books and quantities for each order */
CREATE TABLE order_line (
    order_id INT,                                         -- FK referencing cust_order
    book_id INT,                                          -- FK referencing book
    quantity INT NOT NULL,                                -- Quantity ordered of the book
    price_at_purchase DECIMAL(8,2) NOT NULL,              -- Price at time of purchase
    PRIMARY KEY (order_id, book_id),                      -- Composite primary key
    FOREIGN KEY (order_id) REFERENCES cust_order(order_id),
    FOREIGN KEY (book_id) REFERENCES book(book_id)
);


/* 15. order_history: Tracks the status changes of an order over time */
CREATE TABLE order_history (
    history_id INT AUTO_INCREMENT PRIMARY KEY,           -- Unique history record id
    order_id INT,                                         -- FK referencing cust_order
    status_id INT,                                        -- FK referencing order_status
    status_change_date DATETIME DEFAULT CURRENT_TIMESTAMP, -- Date/time of status change
    FOREIGN KEY (order_id) REFERENCES cust_order(order_id),
    FOREIGN KEY (status_id) REFERENCES order_status(status_id)
);


/* =========================
   STEP 3: User Management & Access Control
   ========================= */

/* Create a read-only user for limited query access */
CREATE USER 'seventeenthatyate'@'localhost' IDENTIFIED BY 'Scylla@8434';
GRANT SELECT ON BookStoreDB.* TO 'seventeenthatyate'@'localhost';

/* Create an admin user with full privileges */
CREATE USER 'admin'@'localhost' IDENTIFIED BY 'Scylla.@8434.';
GRANT ALL PRIVILEGES ON BookStoreDB.* TO 'admin'@'localhost';

/* Apply the changes to the privileges */
FLUSH PRIVILEGES;


/* =========================
   STEP 4: Sample Queries for Testing and Data Retrieval
   ========================= */

/* 
   Query 1: Retrieve all books along with their language, publisher, and associated authors.
*/
use bookstoredb;
SELECT 
    b.book_id,
    b.title,
    b.isbn,
    b.publication_year,
    b.price,
    bl.language_name,
    p.publisher_name,
    CONCAT(a.first_name, ' ', a.last_name) AS author_name
FROM book b
LEFT JOIN book_language bl ON b.language_id = bl.language_id
LEFT JOIN publisher p ON b.publisher_id = p.publisher_id
LEFT JOIN book_author ba ON b.book_id = ba.book_id
LEFT JOIN author a ON ba.author_id = a.author_id;


/* 
   Query 2: Retrieve all orders placed by a specific customer 
   along with shipping method and basic customer details.
*/
SELECT 
    co.order_id,
    co.order_date,
    sm.method_name,
    c.first_name,
    c.last_name
FROM cust_order co
JOIN shipping_method sm ON co.shipping_method_id = sm.shipping_method_id
JOIN customer c ON co.customer_id = c.customer_id
WHERE co.customer_id = 1;


/* 
   Query 3: View the status history for a given order 
*/
SELECT 
    oh.history_id,
    oh.status_change_date,
    os.status_description
FROM order_history oh
JOIN order_status os ON oh.status_id = os.status_id
WHERE oh.order_id = 101;
