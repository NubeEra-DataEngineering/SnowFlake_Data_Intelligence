---> set Role Context
USE ROLE ACCOUNTADMIN;

---> set Warehouse Context
USE WAREHOUSE DWH_ISPIRE;

---> set the Database
USE DATABASE IRIS_DB_ISPIRE;

---> set the Schema
SET user_name = current_user();
SET schema_name = 'PUBLIC';
USE SCHEMA IDENTIFIER($schema_name);


-- create the Truck table
CREATE OR REPLACE TABLE truck
(
    truck_id NUMBER(38,0),
    menu_type_id NUMBER(38,0),
    primary_city VARCHAR(16777216),
    region VARCHAR(16777216),
    iso_region VARCHAR(16777216),
    country VARCHAR(16777216),
    iso_country_code VARCHAR(16777216),
    franchise_flag NUMBER(38,0),
    year NUMBER(38,0),
    make VARCHAR(16777216),
    model VARCHAR(16777216),
    ev_flag NUMBER(38,0),
    franchise_id NUMBER(38,0),
    truck_opening_date DATE
);

CREATE OR REPLACE STAGE blob_stage
url = 's3://sfquickstarts/tastybytes/'
file_format = (type = csv);

---> copy the Truck file into the Truck table
COPY INTO truck
FROM @blob_stage/raw_pos/truck/;


SELECT * FROM truck
LIMIT 10;


CREATE OR REPLACE TABLE truck_dev CLONE truck;


SELECT
    t.truck_id,
    t.year,
    t.make,
    t.model
FROM truck_dev t
ORDER BY t.truck_id;


UPDATE truck_dev
    SET make = 'Ford' WHERE make = 'Ford_';

SELECT * FROM truck_dev where make = 'Ford';

SELECT
    truck_id,
    year,
    make,
    model,
    CONCAT(year,' ',make,' ',REPLACE(model,' ','_')) AS truck_type
FROM truck_dev;

ALTER TABLE truck_dev
    ADD COLUMN truck_type VARCHAR(100);

UPDATE truck_dev
    SET truck_type =  CONCAT(year,make,' ',REPLACE(model,' ','_'));


SELECT
    truck_id,
    year,
    truck_type
FROM truck_dev
ORDER BY truck_id;


SELECT
    query_id,
    query_text,
    user_name,
    query_type,
    start_time
FROM TABLE(information_schema.query_history())
WHERE 1=1
    AND query_type = 'UPDATE'
    AND query_text LIKE '%truck_dev%'
ORDER BY start_time DESC;

SET query_id =
    (
    SELECT TOP 1
        query_id
    FROM TABLE(information_schema.query_history())
    WHERE 1=1
        AND query_type = 'UPDATE'
        AND query_text LIKE '%SET truck_type =%'
    ORDER BY start_time DESC
    );

SELECT
    truck_id,
    make,
    truck_type
FROM truck_dev
BEFORE(STATEMENT => $query_id)
ORDER BY truck_id;

CREATE OR REPLACE TABLE truck_dev
    AS
SELECT * FROM truck_dev
BEFORE(STATEMENT => $query_id); 


UPDATE truck_dev t
    SET truck_type = CONCAT(t.year,' ',t.make,' ',REPLACE(t.model,' ','_'));

ALTER TABLE truck_dev
    SWAP WITH truck;

SELECT
    t.truck_id,
    t.truck_type
FROM truck t
WHERE t.make = 'Ford';

DROP TABLE truck;

UNDROP TABLE truck;

select * from truck;

