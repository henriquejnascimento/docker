-- Creating the database
CREATE DATABASE "test-database";

-- Connects to the newly created database
\c "test-database";

-- Creating the schema
CREATE SCHEMA "test-schema";

-- Creating the table within the schema
CREATE TABLE "test-schema"."test-table" (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255)
);
