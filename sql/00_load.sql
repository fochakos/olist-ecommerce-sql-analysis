-- Load the nine Olist CSV files into DuckDB tables with short names.
-- Run from the project root: python src/build_db.py

CREATE OR REPLACE TABLE customers AS
SELECT * FROM read_csv('data/olist_customers_dataset.csv', header = true);

CREATE OR REPLACE TABLE orders AS
SELECT * FROM read_csv('data/olist_orders_dataset.csv', header = true,
    types = {
        'order_purchase_timestamp': 'TIMESTAMP',
        'order_approved_at': 'TIMESTAMP',
        'order_delivered_carrier_date': 'TIMESTAMP',
        'order_delivered_customer_date': 'TIMESTAMP',
        'order_estimated_delivery_date': 'TIMESTAMP'
    });

CREATE OR REPLACE TABLE order_items AS
SELECT * FROM read_csv('data/olist_order_items_dataset.csv', header = true);

CREATE OR REPLACE TABLE payments AS
SELECT * FROM read_csv('data/olist_order_payments_dataset.csv', header = true);

-- Review comments contain line breaks and quotes, so parse them strictly.
CREATE OR REPLACE TABLE reviews AS
SELECT * FROM read_csv('data/olist_order_reviews_dataset.csv', header = true,
    quote = '"', escape = '"', strict_mode = false);

CREATE OR REPLACE TABLE products AS
SELECT * FROM read_csv('data/olist_products_dataset.csv', header = true);

CREATE OR REPLACE TABLE sellers AS
SELECT * FROM read_csv('data/olist_sellers_dataset.csv', header = true);

CREATE OR REPLACE TABLE geolocation AS
SELECT * FROM read_csv('data/olist_geolocation_dataset.csv', header = true);

CREATE OR REPLACE TABLE category_translation AS
SELECT * FROM read_csv('data/product_category_name_translation.csv', header = true);
