-- Create Schema for Danny's Diner

CREATE DATABASE IF NOT EXISTS dannys_diner;
USE dannys_diner;

-- Table: sales
CREATE TABLE sales (
  customer_id VARCHAR(1),
  order_date DATE,
  product_id INTEGER
);

-- Table: menu
CREATE TABLE menu (
  product_id INTEGER PRIMARY KEY,
  product_name VARCHAR(50),
  price INTEGER
);

-- Table: members
CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);
