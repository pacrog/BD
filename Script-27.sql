Create database hw_1

-- Таблица клиенты
CREATE TABLE Customer (
    customer_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    gender VARCHAR(10),
    DOB DATE,
    job_title VARCHAR(100),
    job_industry_category VARCHAR(50),
    wealth_segment VARCHAR(50),
    deceased_indicator BOOLEAN,
    owns_car BOOLEAN,
    address VARCHAR(255),
    postcode VARCHAR(20),
    state VARCHAR(50),
    country VARCHAR(50),
    property_valuation DECIMAL(15,2)
);

-- Таблица продукты
CREATE TABLE Product (
    product_id INT PRIMARY KEY,
    brand VARCHAR(50) NOT NULL,
    product_line VARCHAR(50),
    product_class VARCHAR(50),
    product_size VARCHAR(50),
    list_price DECIMAL(10,2),
    standard_cost DECIMAL(10,2)
);

-- Таблица транзакции
CREATE TABLE Transaction (
    transaction_id INT PRIMARY KEY,
    product_id INT NOT NULL,
    customer_id INT NOT NULL,
    transaction_date DATE NOT NULL,
    online_order BOOLEAN,
    order_status VARCHAR(20),
    CONSTRAINT fk_product FOREIGN KEY (product_id) REFERENCES Product(product_id),
    CONSTRAINT fk_customer FOREIGN KEY (customer_id) REFERENCES Customer(customer_id)
);
