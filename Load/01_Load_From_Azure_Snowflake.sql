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

---> create the Table
CREATE OR REPLACE TABLE ispire_citytable (
  name VARCHAR,
  population INTEGER
)
COMMENT = 'using same city csv file i am creating table';



---> query the empty Table
SELECT * FROM ispire_citytable;


CREATE OR REPLACE STORAGE INTEGRATION blob_snowflake_city_ispire
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = 'AZURE'
  AZURE_TENANT_ID = 'YOUR_TENENT_ID'
  ENABLED = TRUE
  STORAGE_ALLOWED_LOCATIONS = (
    'azure://storageaccount_name.blob.core.windows.net/containerName/'
  )
  COMMENT = 'reading data from blob to import into snowflake city table';

DESCRIBE INTEGRATION blob_snowflake_city_ispire;

SHOW STORAGE INTEGRATIONS;

CREATE OR REPLACE STAGE azure_storage_data_ispire
URL = 'azure://storageaccount_name.blob.core.windows.net/containerName/folder1/'
CREDENTIALS = ( AZURE_SAS_TOKEN = 'YOUR_SAS_STORAGE_TOKEN' )
FILE_FORMAT = ( TYPE = CSV );

SHOW STAGES;

COPY INTO ispire_citytable
FROM @azure_storage_data_ispire
FILES = ('city.csv')
FILE_FORMAT = (
  TYPE = CSV
  SKIP_HEADER = 1
);


SELECT * FROM ispire_citytable;
