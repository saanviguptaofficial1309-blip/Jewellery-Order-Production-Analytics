
CREATE DATABASE IF NOT EXISTS lgd_order_analytics;

USE lgd_order_analytics;

SELECT DATABASE();

CREATE TABLE clients (
    client_id INT AUTO_INCREMENT PRIMARY KEY,
    client_name VAR
    CHAR(100) NOT NULL,
    client_type VARCHAR(50),
    contact_email VARCHAR(100),
    contact_phone VARCHAR(20),
    city VARCHAR(50),
    account_manager VARCHAR(100),
    onboarding_date DATE,
    client_status ENUM('Active', 'Inactive', 'On Hold')
        DEFAULT 'Active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

USE lgd_order_analytics;
SHOW TABLES;
DESCRIBE clients;

CREATE TABLE client_contacts (
    contact_id INT AUTO_INCREMENT PRIMARY KEY,
    client_id INT NOT NULL,
    contact_name VARCHAR(100) NOT NULL,
    designation VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(20),
    is_primary BOOLEAN DEFAULT FALSE,
    CONSTRAINT fk_contact_client
        FOREIGN KEY (client_id)
        REFERENCES clients (client_id)
);

USE lgd_order_analytics;
SHOW TABLES;

USE lgd_order_analytics;
CREATE TABLE skus (
    sku_id INT AUTO_INCREMENT PRIMARY KEY,
    sku_code VARCHAR(30) NOT NULL UNIQUE,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    metal_type VARCHAR(50),
    diamond_shape VARCHAR(50),
    diamond_carat DECIMAL(5,2),
    unit_price DECIMAL(12,2) NOT NULL,
    production_lead_days INT DEFAULT 7,
    sku_status ENUM('Active', 'Discontinued') DEFAULT 'Active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

USE lgd_order_analytics;

CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    order_number VARCHAR(30) NOT NULL UNIQUE,
    client_id INT NOT NULL,
    order_date DATE NOT NULL,
    promised_delivery_date DATE NOT NULL,
    actual_delivery_date DATE,
    order_status ENUM(
        'Pending',
        'In Production',
        'Quality Check',
        'Ready to Dispatch',
        'Dispatched',
        'Delivered',
        'Cancelled'
    ) DEFAULT 'Pending',
    priority ENUM('Low', 'Medium', 'High', 'Urgent')
        DEFAULT 'Medium',
    order_notes VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_order_client
        FOREIGN KEY (client_id)
        REFERENCES clients (client_id)
);
    
USE lgd_order_analytics;

CREATE TABLE order_items (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    sku_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(12,2) NOT NULL,
    item_status ENUM(
        'Pending',
        'In Production',
        'Quality Check',
        'Completed',
        'Cancelled'
    ) DEFAULT 'Pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_item_order
        FOREIGN KEY (order_id)
        REFERENCES orders (order_id),

    CONSTRAINT fk_item_sku
        FOREIGN KEY (sku_id)
        REFERENCES skus (sku_id),

    CONSTRAINT chk_item_quantity
        CHECK (quantity > 0),

    CONSTRAINT chk_item_price
        CHECK (unit_price >= 0)
);

USE lgd_order_analytics;

CREATE TABLE production_stages (
	stage_id INT AUTO_INCREMENT PRIMARY KEY,
    stage_name VARCHAR(100) NOt NULL UNIQUE,
    stage_sequence INT NOT NULL UNIQUE,
    expected_tat_hours INT NOT NULL,
    stage_description VARCHAR(255),
    is_active BOOLEAN DEFAULT TRUE,
    
    CONSTRAINT chk_stage_tat
		CHECK (expected_tat_hours >= 0),
        
	CONSTRAINT chk_stage_sequence
		CHECK (stage_sequence > 0)
);

USE lgd_order_analytics;

CREATE TABLE production_stage_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    order_item_id INT NOT NULL,
    stage_id INT NOT NULL,
    stage_start_time DATETIME NOT NULL,
    stage_end_time DATETIME,
    stage_status ENUM(
        'Not Started',
        'In Progress',
        'Completed',
        'On Hold',
        'Skipped'
    ) DEFAULT 'Not Started',
    assigned_to VARCHAR(100),
    remarks VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_log_order_item
        FOREIGN KEY (order_item_id)
        REFERENCES order_items (order_item_id),

    CONSTRAINT fk_log_stage
        FOREIGN KEY (stage_id)
        REFERENCES production_stages (stage_id)
);

USE lgd_order_analytics;
    
CREATE TABLE tolerance_checks (
    check_id INT AUTO_INCREMENT PRIMARY KEY,
    order_item_id INT NOT NULL,
    check_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    parameter_name VARCHAR(100) NOT NULL,
    expected_value DECIMAL(10,3),
    actual_value DECIMAL(10,3),
    tolerance_limit DECIMAL(10,3),
    check_result ENUM('Pass', 'Fail') NOT NULL,
    checked_by VARCHAR(100),
    remarks VARCHAR(255),

    CONSTRAINT fk_tolerance_order_item
        FOREIGN KEY (order_item_id)
        REFERENCES order_items (order_item_id)
);

SHOW TABLES;
DESCRIBE tolerance_checks;

USE lgd_order_analytics;

CREATE TABLE invoices (
    invoice_id INT AUTO_INCREMENT PRIMARY KEY,
    invoice_number VARCHAR(30) NOT NULL UNIQUE,
    order_id INT NOT NULL,
    invoice_date DATE NOT NULL,
    due_date DATE NOT NULL,
    invoice_amount DECIMAL(12,2) NOT NULL,
    invoice_status ENUM(
        'Draft',
        'Issued',
        'Partially Paid',
        'Paid',
        'Overdue',
        'Cancelled'
    ) DEFAULT 'Issued',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_invoice_order
        FOREIGN KEY (order_id)
        REFERENCES orders (order_id),

    CONSTRAINT chk_invoice_amount
        CHECK (invoice_amount >= 0)
);

SHOW TABLES;
DESCRIBE invoices;

USE lgd_order_analytics;

CREATE TABLE invoice_payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    invoice_id INT NOT NULL,
    payment_date DATE NOT NULL,
    payment_amount DECIMAL(12,2) NOT NULL,
    payment_method ENUM(
        'Bank Transfer',
        'UPI',
        'Cheque',
        'Other'
    ) DEFAULT 'Bank Transfer',
    transaction_reference VARCHAR(100),
    payment_notes VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_payment_invoice
        FOREIGN KEY (invoice_id)
        REFERENCES invoices (invoice_id),

    CONSTRAINT chk_payment_amount
        CHECK (payment_amount > 0)
);

SHOW TABLES;
DESCRIBE clients;
DESCRIBE skus;
DESCRIBE orders;
DESCRIBE order_items;
DESCRIBE production_stages;
DESCRIBE production_stage_log;
DESCRIBE tolerance_checks;
DESCRIBE invoices;
DESCRIBE invoice_payments;


USE lgd_order_analytics;

INSERT INTO clients
    (client_name, client_type, contact_email, contact_phone,
     city, account_manager, onboarding_date, client_status)
VALUES
    ('Aurora Jewels', 'LGD Brand', 'contact@aurorajewels.example',
     '9876501001', 'Mumbai', 'Priya Sharma', '2025-01-15', 'Active'),

    ('Luxe Retail Group', 'LGD Brand', 'buying@luxeretail.example',
     '9876501002', 'Delhi', 'Rahul Mehta', '2025-03-10', 'Active'),

    ('Nova Diamonds', 'LGD Brand', 'orders@novadiamonds.example',
     '9876501003', 'Jaipur', 'Ananya Verma', '2025-05-20', 'Active'),

    ('Elite Ornaments', 'LGD Brand', 'purchase@eliteornaments.example',
     '9876501004', 'Bengaluru', 'Karan Shah', '2025-07-01', 'On Hold');

SELECT *
FROM clients;

USE lgd_order_analytics;

SELECT
    client_id,
    client_name,
    client_type,
    city,
    client_status
FROM clients
ORDER BY client_id;

USE lgd_order_analytics;

SELECT *
FROM orders
WHERE client_id IN (1, 2, 3, 4);

USE lgd_order_analytics;

DELETE FROM clients
WHERE client_id IN (1, 2, 3, 4);

SELECT
    client_id,
    client_name,
    client_type,
    city,
    client_status
FROM clients
ORDER BY client_id;

USE lgd_order_analytics;

INSERT INTO client_contacts
    (client_id, contact_name, designation, email, phone, is_primary)
VALUES
    (5, 'Aarav Mehta', 'Purchase Manager',
     'aarav@aurorajewels.example', '9876502001', TRUE),

    (6, 'Ishita Kapoor', 'Category Manager',
     'ishita@luxeretail.example', '9876502002', TRUE),

    (7, 'Rohan Jain', 'Product Development Manager',
     'rohan@novadiamonds.example', '9876502003', TRUE),

    (8, 'Meera Nair', 'Procurement Manager',
     'meera@eliteornaments.example', '9876502004', TRUE);
     
     SELECT
		contact_id,
        client_id,
        contact_name,
        designation,
        is_Primary
	FROM client_contacts
    ORDER BY client_id;
    
    USE lgd_order_analytics;

INSERT INTO skus
    (sku_code, product_name, category, metal_type,
     diamond_shape, diamond_carat, unit_price, production_lead_days,
     sku_status)
VALUES
    ('RNG-001', 'Classic Solitaire Ring', 'Ring', '14K Gold',
     'Round', 1.00, 25000.00, 7, 'Active'),

    ('RNG-002', 'Oval Halo Ring', 'Ring', '18K Gold',
     'Oval', 1.50, 38000.00, 10, 'Active'),

    ('PDS-001', 'Diamond Pendant Necklace', 'Necklace', '14K Gold',
     'Round', 0.75, 18000.00, 6, 'Active'),

    ('ERS-001', 'Diamond Stud Earrings', 'Earrings', '14K Gold',
     'Round', 0.50, 15000.00, 5, 'Active'),

    ('TBRS-001', 'Tennis Bracelet', 'Bracelet', '18K Gold',
     'Round', 2.00, 45000.00, 12, 'Active'),

    ('RNG-003', 'Emerald Cut Solitaire Ring', 'Ring', '18K Gold',
     'Emerald', 1.25, 32000.00, 9, 'Active'),

    ('ERH-002', 'Pear Drop Earrings', 'Earrings', '14K Gold',
     'Pear', 1.00, 28000.00, 8, 'Active'),

    ('NKS-002', 'Layered Diamond Necklace', 'Necklace', '18K Gold',
     'Round', 2.50, 55000.00, 14, 'Active');
     
     SELECT
		sku_id,
        sku_code,
        product_name,
        category,
        diamond_shape,
        diamond_carat,
        unit_price,
        production_lead_days
	FROM skus
    ORDER BY sku_id;
    
    USE lgd_order_analytics;

INSERT INTO production_stages
    (stage_name, stage_sequence, expected_tat_hours, stage_description)
VALUES
    ('CAD Design', 1, 24,
     'Create and approve the computer-aided jewellery design'),

    ('Casting', 2, 48,
     'Cast the jewellery piece using the selected metal'),

    ('Pre-Polishing', 3, 24,
     'Prepare and smooth the jewellery before stone setting'),

    ('Diamond Setting', 4, 48,
     'Set the diamonds into the jewellery piece'),

    ('Final Polishing', 5, 24,
     'Complete final finishing and polishing'),

    ('Quality Check', 6, 12,
     'Inspect product quality and verify specifications'),

    ('Packaging', 7, 12,
     'Prepare the finished jewellery for dispatch');
    
    SELECT
		stage_id,
        stage_sequence,
        stage_name,
        expected_tat_hours,
        stage_description
	FROM production_stages
    ORDER BY stage_sequence;
    
   USE lgd_order_analytics;

INSERT INTO orders
    (order_number, client_id, order_date,
     promised_delivery_date, actual_delivery_date,
     order_status, priority, order_notes)
VALUES
    ('LGD-2026-001', 5, '2026-09-01', '2026-09-15',
     '2026-09-14', 'Delivered', 'High',
     'Delivered one day before the promised date'),

    ('LGD-2026-002', 6, '2026-09-05', '2026-09-20',
     '2026-09-23', 'Delivered', 'Medium',
     'Delivered three days after the promised date'),

    ('LGD-2026-003', 7, '2026-09-15', '2026-10-25',
     NULL, 'In Production', 'Urgent',
     'Priority order currently in manufacturing'),

    ('LGD-2026-004', 8, '2026-09-20', '2026-10-10',
     NULL, 'Quality Check', 'High',
     'Awaiting final quality approval'),

    ('LGD-2026-005', 5, '2026-10-01', '2026-10-30',
     NULL, 'Pending', 'Medium',
     'Awaiting production allocation'),

    ('LGD-2026-006', 6, '2026-10-03', '2026-10-18',
     NULL, 'In Production', 'Urgent',
     'Urgent order approaching delivery deadline'),

    ('LGD-2026-007', 7, '2026-10-05', '2026-10-22',
     NULL, 'Pending', 'Low',
     'Standard order awaiting production'),

    ('LGD-2026-008', 8, '2026-10-08', '2026-10-28',
     NULL, 'In Production', 'High',
     'High-priority retail replenishment order'); 
     
     SELECT
		order_id,
        order_number,
        client_id,
        order_date,
        promised_delivery_date,
        actual_delivery_date,
        order_status,
        priority
	FROM orders
    ORDER BY order_date;
    
    USE lgd_order_analytics;

INSERT INTO order_items
    (order_id, sku_id, quantity, unit_price, item_status)
VALUES
    -- Order 1: Delivered
    (1, 1, 10, 25000.00, 'Completed'),
    (1, 4, 15, 15000.00, 'Completed'),

    -- Order 2: Delivered
    (2, 2, 5, 38000.00, 'Completed'),
    (2, 3, 10, 18000.00, 'Completed'),

    -- Order 3: In Production
    (3, 5, 4, 45000.00, 'In Production'),
    (3, 6, 6, 32000.00, 'In Production'),

    -- Order 4: Quality Check
    (4, 4, 8, 15000.00, 'Quality Check'),
    (4, 7, 5, 28000.00, 'Quality Check'),

    -- Order 5: Pending
    (5, 1, 6, 25000.00, 'Pending'),
    (5, 3, 8, 18000.00, 'Pending'),

    -- Order 6: In Production
    (6, 8, 3, 55000.00, 'In Production'),
    (6, 2, 4, 38000.00, 'In Production'),

    -- Order 7: Pending
    (7, 6, 5, 32000.00, 'Pending'),
    (7, 4, 10, 15000.00, 'Pending'),

    -- Order 8: In Production
    (8, 7, 6, 28000.00, 'In Production'),
    (8, 3, 10, 18000.00, 'In Production');
    
    SELECT
    order_item_id,
    order_id,
    sku_id,
    quantity,
    unit_price,
    quantity * unit_price AS item_total,
    item_status
FROM order_items
ORDER BY order_id, order_item_id;

USE lgd_order_analytics;

INSERT INTO production_stage_log
    (order_item_id, stage_id, stage_start_time, stage_end_time,
     stage_status, assigned_to, remarks)
VALUES
    -- Order item 1: Completed CAD design
    (1, 1, '2026-09-02 09:00:00', '2026-09-02 17:00:00',
     'Completed', 'Design Team', 'CAD approved by client'),

    -- Order item 1: Completed casting
    (1, 2, '2026-09-03 09:00:00', '2026-09-04 15:00:00',
     'Completed', 'Casting Team', 'Casting completed'),

    -- Order item 1: Completed diamond setting
    (1, 4, '2026-09-05 09:00:00', '2026-09-06 12:00:00',
     'Completed', 'Setting Team', 'Setting completed'),

    -- Order item 3: CAD design completed
    (3, 1, '2026-09-06 10:00:00', '2026-09-07 09:00:00',
     'Completed', 'Design Team', 'Design approved'),

    -- Order item 3: Casting in progress
    (3, 2, '2026-09-08 09:00:00', NULL,
     'In Progress', 'Casting Team', 'Casting underway'),

    -- Order item 5: CAD design completed
    (5, 1, '2026-09-16 09:00:00', '2026-09-17 11:00:00',
     'Completed', 'Design Team', 'CAD approved'),

    -- Order item 5: Casting in progress
    (5, 2, '2026-09-18 09:00:00', NULL,
     'In Progress', 'Casting Team', 'Awaiting casting completion'),

    -- Order item 7: Quality check completed
    (7, 6, '2026-10-05 10:00:00', '2026-10-05 15:00:00',
     'Completed', 'Quality Team', 'Passed final inspection'),

    -- Order item 9: Not started
    (9, 1, '2026-10-02 09:00:00', NULL,
     'Not Started', 'Design Team', 'Awaiting design allocation'),

    -- Order item 11: Diamond setting on hold
    (11, 4, '2026-10-07 09:00:00', NULL,
     'On Hold', 'Setting Team', 'Awaiting production clarification');
    
    SELECT
    log_id,
    order_item_id,
    stage_id,
    stage_start_time,
    stage_end_time,
    stage_status,
    assigned_to
FROM production_stage_log
ORDER BY order_item_id, stage_start_time;

USE lgd_order_analytics;

INSERT INTO tolerance_checks
    (order_item_id, check_date, parameter_name,
     expected_value, actual_value, tolerance_limit,
     check_result, checked_by, remarks)
VALUES
    (1, '2026-09-14 10:00:00', 'Diamond Diameter (mm)',
     6.500, 6.490, 0.050, 'Pass',
     'Quality Team', 'Within permitted tolerance'),

    (1, '2026-09-14 10:15:00', 'Setting Alignment (mm)',
     0.000, 0.020, 0.050, 'Pass',
     'Quality Team', 'Alignment acceptable'),

    (2, '2026-09-18 11:00:00', 'Diamond Diameter (mm)',
     5.000, 5.080, 0.050, 'Fail',
     'Quality Team', 'Outside permitted tolerance'),

    (3, '2026-09-19 14:00:00', 'Metal Thickness (mm)',
     1.200, 1.210, 0.030, 'Pass',
     'Quality Team', 'Thickness within limits'),

    (7, '2026-10-05 12:00:00', 'Setting Alignment (mm)',
     0.000, 0.070, 0.050, 'Fail',
     'Quality Team', 'Requires corrective adjustment'),

    (8, '2026-10-06 15:00:00', 'Polishing Finish (mm)',
     0.000, 0.010, 0.020, 'Pass',
     'Quality Team', 'Final finish accepted'),

    (11, '2026-10-09 11:30:00', 'Diamond Alignment (mm)',
     0.000, 0.015, 0.050, 'Pass',
     'Quality Team', 'Alignment within tolerance'),

    (13, '2026-10-12 10:00:00', 'Metal Thickness (mm)',
     1.500, 1.560, 0.030, 'Fail',
     'Quality Team', 'Requires rework and reinspection');
    
    
    SELECT
    check_id,
    order_item_id,
    parameter_name,
    expected_value,
    actual_value,
    tolerance_limit,
    check_result,
    checked_by
FROM tolerance_checks
ORDER BY check_date;

USE lgd_order_analytics;

INSERT INTO invoices
    (invoice_number, order_id, invoice_date, due_date,
     invoice_amount, invoice_status)
VALUES
    ('INV-2026-001', 1, '2026-09-14', '2026-09-29',
     475000.00, 'Paid'),

    ('INV-2026-002', 2, '2026-09-23', '2026-10-08',
     370000.00, 'Partially Paid'),

    ('INV-2026-003', 3, '2026-10-01', '2026-10-31',
     372000.00, 'Issued'),

    ('INV-2026-004', 4, '2026-10-06', '2026-10-16',
     260000.00, 'Overdue'),

    ('INV-2026-005', 6, '2026-10-10', '2026-10-25',
     317000.00, 'Issued');
     
     SELECT
    invoice_id,
    invoice_number,
    order_id,
    invoice_date,
    due_date,
    invoice_amount,
    invoice_status
FROM invoices
ORDER BY invoice_date;

USE lgd_order_analytics;

INSERT INTO invoice_payments
    (invoice_id, payment_date, payment_amount,
     payment_method, transaction_reference, payment_notes)
VALUES
    -- Invoice 1: Fully paid
    (1, '2026-09-20', 475000.00,
     'Bank Transfer', 'TXN-LGD-001',
     'Full invoice payment received'),

    -- Invoice 2: Partially paid
    (2, '2026-09-28', 200000.00,
     'Bank Transfer', 'TXN-LGD-002',
     'First instalment received'),

    -- Invoice 3: No payment received yet
    -- No payment record is inserted for this invoice

    -- Invoice 4: Overdue invoice with no payment
    -- No payment record is inserted for this invoice

    -- Invoice 5: Partial payment received
    (5, '2026-10-15', 100000.00,
     'UPI', 'TXN-LGD-005',
     'Advance payment received');
     
     SELECT
    payment_id,
    invoice_id,
    payment_date,
    payment_amount,
    payment_method,
    transaction_reference
FROM invoice_payments
ORDER BY payment_date;

-- calculating outstanding balances--
SELECT
    i.invoice_number,
    i.invoice_amount,
    COALESCE(SUM(p.payment_amount), 0) AS amount_paid,
    i.invoice_amount
        - COALESCE(SUM(p.payment_amount), 0) AS outstanding_balance,
    i.invoice_status
FROM invoices i
LEFT JOIN invoice_payments p
    ON i.invoice_id = p.invoice_id
GROUP BY
    i.invoice_id,
    i.invoice_number,
    i.invoice_amount,
    i.invoice_status
ORDER BY i.invoice_id;


USE lgd_order_analytics;

-- Analysis 1: Client-wise order volume and status

SELECT
    c.client_name,
    COUNT(o.order_id) AS total_orders,
    SUM(CASE
        WHEN o.order_status = 'Delivered' THEN 1
        ELSE 0
    END) AS delivered_orders,
    SUM(CASE
        WHEN o.order_status = 'In Production' THEN 1
        ELSE 0
    END) AS orders_in_production,
    SUM(CASE
        WHEN o.order_status = 'Pending' THEN 1
        ELSE 0
    END) AS pending_orders
FROM clients c
LEFT JOIN orders o
    ON c.client_id = o.client_id
GROUP BY
    c.client_id,
    c.client_name
ORDER BY total_orders DESC;


USE lgd_order_analytics;

-- Analysis 2: Order value by client

SELECT
    c.client_name,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.quantity * oi.unit_price) AS total_order_value,
    ROUND(
        SUM(oi.quantity * oi.unit_price)
        / NULLIF(COUNT(DISTINCT o.order_id), 0),
        2
    ) AS average_order_value
FROM clients c
JOIN orders o
    ON c.client_id = o.client_id
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY
    c.client_id,
    c.client_name
ORDER BY total_order_value DESC;


USE lgd_order_analytics;

-- Analysis 3: Product-wise demand and order value

SELECT
    s.sku_code,
    s.product_name,
    s.category,
    SUM(oi.quantity) AS total_units_ordered,
    COUNT(DISTINCT oi.order_id) AS number_of_orders,
    SUM(oi.quantity * oi.unit_price) AS total_order_value
FROM skus s
JOIN order_items oi
    ON s.sku_id = oi.sku_id
GROUP BY
    s.sku_id,
    s.sku_code,
    s.product_name,
    s.category
ORDER BY total_units_ordered DESC;

-- can make a small change by changing the final line to- ORDER BY total_order_value DESC;

USE lgd_order_analytics;

-- Analysis 5: Overall on-time delivery rate

SELECT
    COUNT(*) AS total_delivered_orders,
    SUM(
        CASE
            WHEN actual_delivery_date <= promised_delivery_date
            THEN 1
            ELSE 0
        END
    ) AS on_time_orders,
    ROUND(
        100.0 * SUM(
            CASE
                WHEN actual_delivery_date <= promised_delivery_date
                THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS on_time_delivery_percentage
FROM orders
WHERE actual_delivery_date IS NOT NULL;


USE lgd_order_analytics;

-- Analysis 6: Actual vs expected production turnaround time

SELECT
    ps.stage_name,
    ps.expected_tat_hours,
    COUNT(psl.log_id) AS completed_stage_count,
    ROUND(
        AVG(
            TIMESTAMPDIFF(
                MINUTE,
                psl.stage_start_time,
                psl.stage_end_time
            ) / 60.0
        ),
        2
    ) AS avg_actual_tat_hours,
    ROUND(
        AVG(
            TIMESTAMPDIFF(
                MINUTE,
                psl.stage_start_time,
                psl.stage_end_time
            ) / 60.0
        ) - ps.expected_tat_hours,
        2
    ) AS avg_variance_hours
FROM production_stages ps
JOIN production_stage_log psl
    ON ps.stage_id = psl.stage_id
WHERE psl.stage_status = 'Completed'
  AND psl.stage_end_time IS NOT NULL
GROUP BY
    ps.stage_id,
    ps.stage_name,
    ps.expected_tat_hours
ORDER BY avg_actual_tat_hours DESC;


USE lgd_order_analytics;

-- Analysis 7: Overall quality pass rate

SELECT
    COUNT(*) AS total_quality_checks,
    SUM(
        CASE
            WHEN check_result = 'Pass' THEN 1
            ELSE 0
        END
    ) AS passed_checks,
    SUM(
        CASE
            WHEN check_result = 'Fail' THEN 1
            ELSE 0
        END
    ) AS failed_checks,
    ROUND(
        100.0 * SUM(
            CASE
                WHEN check_result = 'Pass' THEN 1
                ELSE 0
            END
        ) / NULLIF(COUNT(*), 0),
        2
    ) AS quality_pass_percentage
FROM tolerance_checks;


USE lgd_order_analytics;

-- Analysis 9: Invoice-wise outstanding balance

SELECT
    i.invoice_number,
    c.client_name,
    i.invoice_amount,
    COALESCE(SUM(p.payment_amount), 0) AS amount_paid,
    i.invoice_amount
        - COALESCE(SUM(p.payment_amount), 0)
        AS outstanding_balance,
    i.due_date,
    i.invoice_status
FROM invoices i
JOIN orders o
    ON i.order_id = o.order_id
JOIN clients c
    ON o.client_id = c.client_id
LEFT JOIN invoice_payments p
    ON i.invoice_id = p.invoice_id
GROUP BY
    i.invoice_id,
    i.invoice_number,
    c.client_name,
    i.invoice_amount,
    i.due_date,
    i.invoice_status
ORDER BY outstanding_balance DESC;


USE lgd_order_analytics;

-- Analysis 11: Client Performance Ranking

SELECT
    c.client_name,
    COUNT(DISTINCT o.order_id) AS total_orders,

    COALESCE(SUM(oi.quantity * oi.unit_price), 0)
        AS total_order_value,

    COUNT(DISTINCT CASE
        WHEN o.order_status = 'Delivered'
        THEN o.order_id
    END) AS delivered_orders,

    COUNT(DISTINCT CASE
        WHEN o.actual_delivery_date IS NOT NULL
         AND o.actual_delivery_date <= o.promised_delivery_date
        THEN o.order_id
    END) AS on_time_orders,

    ROUND(
        100.0 * COUNT(DISTINCT CASE
            WHEN o.actual_delivery_date IS NOT NULL
             AND o.actual_delivery_date <= o.promised_delivery_date
            THEN o.order_id
        END)
        / NULLIF(COUNT(DISTINCT CASE
            WHEN o.actual_delivery_date IS NOT NULL
            THEN o.order_id
        END), 0),
        2
    ) AS on_time_delivery_percentage

FROM clients c
LEFT JOIN orders o
    ON c.client_id = o.client_id
LEFT JOIN order_items oi
    ON o.order_id = oi.order_id

GROUP BY c.client_id, c.client_name
ORDER BY total_order_value DESC;


USE lgd_order_analytics;

-- Analysis 12: Data Quality Checks

SELECT
    o.order_id,
    o.order_number,
    o.client_id
FROM orders o
LEFT JOIN clients c
    ON o.client_id = c.client_id
WHERE c.client_id IS NULL;


SELECT *
FROM order_items
WHERE quantity <= 0
   OR unit_price < 0
   OR quantity IS NULL
   OR unit_price IS NULL;
   
   
SELECT
    order_number,
    order_status,
    promised_delivery_date,
    actual_delivery_date
FROM orders
WHERE
    (actual_delivery_date IS NOT NULL
     AND actual_delivery_date < order_date)
    OR
    (order_status = 'Delivered'
     AND actual_delivery_date IS NULL);

-- this step is to assess data reliability, which is valuable in data analyst, buusiness analyst and tech operations roles--


USE lgd_order_analytics;

-- Analysis 13: Overall Business KPI Report

SELECT
    (SELECT COUNT(*)
     FROM orders) AS total_orders,

    (SELECT COUNT(*)
     FROM orders
     WHERE order_status = 'Delivered') AS delivered_orders,

    (SELECT COUNT(*)
     FROM orders
     WHERE order_status IN
     ('Pending', 'In Production', 'Quality Check',
      'Ready to Dispatch')) AS open_orders,

    (SELECT ROUND(SUM(quantity * unit_price), 2)
     FROM order_items
     WHERE item_status <> 'Cancelled') AS total_order_value,

    (SELECT ROUND(
        100.0 * SUM(
            CASE
                WHEN actual_delivery_date <= promised_delivery_date
                THEN 1 ELSE 0
            END
        ) / NULLIF(COUNT(*), 0), 2)
     FROM orders
     WHERE actual_delivery_date IS NOT NULL)
        AS on_time_delivery_percentage,

    (SELECT ROUND(
        100.0 * SUM(
            CASE
                WHEN check_result = 'Pass'
                THEN 1 ELSE 0
            END
        ) / NULLIF(COUNT(*), 0), 2)
     FROM tolerance_checks) AS quality_pass_percentage;




