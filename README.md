# DW_lab_6730202621
วรวัฒน์ พรหมคุณ
## Introducing OLAP for Northwind OLTP Database
**What's the current setup or architecture?**

- Northwind traders are companies that buy and sell special foods worldwide.
- This is a practice database made by Microsoft to showcase its product features and for learning purposes.
- The current setup combines on-site and older systems.
- They use MySQL for their main daily sales transactions.
- MySQL is also used for creating and running reports, but it's not efficient because analytical queries slow down the transaction system.

### Identifying Business Requirements
Throughout the interview process with the business and stakeholders, the following business processses were identified:
- **Sales Overview:**
Overall sales reports to understand better, what is being sold to our customers, what sells the most, where and what sells the least, the goal is to have a general overview of how the business is going.

This means the business is looking forward to getting insights on sales overview.

### Identifying required tables from ERD
<img src="./readme_images/northwind-oltp-erd.png">
From the above ERD diagram of the OLTP transactional system, we identify the following required tables that will enable us to meet the business requirements:

<br>
<li>Customers - Customers who buy items from Northwind</li>
<li>Employees - Those who work for Northwind</li>
<li>Orders - Sales Order transactions taking place between the customers & Northwind</li>
<li>Order Details - Order Details for the Orders placed by customer</li>
<li>Inventory Transaction - Transaction details of each inventory</li>
<li>Products - Current Northwind products that customers can purchase</li>
<li>Shippers - Shipped orders from Northwind to customers</li>
<li>Suppliers - Supplies Northwind with required items</li>
<li>Invoices - Invoice created for each order</li>

### **Staging Layer**
In the staging layer, we have the following tables:
- customers: load customers from datasets/customer.csv and insert ingestion timestamp.
- employees: load employees from datasets/employees.csv and insert ingestion timestamp.
- orders: load orders from datasets/orders.csv and insert ingestion timestamp.
- order_details: load order_details from datasets/order_details.csv and insert ingestion timestamp.
- inventory_transactions: load inventory_transactions from datasets/inventory_transactions.csv and insert ingestion timestamp.
- products: load products from datasets/products.csv and filter out rows where supplier_ids contains multiple semicolon-delimited values and insert ingestion timestamp.
- shippers: load shippers from datasets/shippers.csv and insert ingestion timestamp.
- suppliers: load suppliers from datasets/suppliers.csv and insert ingestion timestamp.
- invoices: load invoices from datasets/invoices.csv and insert ingestion timestamp.

### **Datawarehouse Layer**
<img src="./readme_images/logical-model.png">

# dim_products.sql
WITH source AS (
    SELECT
        p.id AS product_id,
        p.product_code,
        p.product_name,
        p.description,
        s.company AS supplier_company,
        p.standard_cost,
        p.list_price,
        p.reorder_level,
        p.target_level,
        p.quantity_per_unit,
        p.discontinued,
        p.minimum_reorder_quantity,
        p.category,
        p.attachments,
        current_localtimestamp() AS insertion_timestamp
    FROM {{ ref('stg_products') }} AS p
    LEFT JOIN {{ ref('stg_suppliers') }} AS s
        ON s.id = CAST(NULLIF(split_part(p.supplier_ids, ';', 1), '') AS INTEGER)
),

unique_source AS (
    SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY product_id ORDER BY product_id) AS row_number
    FROM source
)

SELECT
    product_id,
    product_code,
    product_name,
    description,
    supplier_company,
    standard_cost,
    list_price,
    reorder_level,
    target_level,
    quantity_per_unit,
    discontinued,
    minimum_reorder_quantity,
    category,
    attachments,
    insertion_timestamp
FROM unique_source
WHERE row_number = 1
