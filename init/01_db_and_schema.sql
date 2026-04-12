-- -- 01_db_and_schema.sql

\echo 'Creating coffee_shop database...'
CREATE DATABASE coffee_shop;

\echo 'Creating analytics schema for coffee_shop database...'
CREATE SCHEMA IF NOT EXISTS analytics;
