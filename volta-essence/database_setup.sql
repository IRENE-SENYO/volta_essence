-- ============================================================
--  VOLTA ESSENCE — Database Setup
--  Business: Volta Essence
--  Location: Accra, Ghana
--  Email:    senyoirene123@gmail.com
--  Phone:    0557202440
-- ============================================================
--  HOW TO USE:
--  1. Go to http://localhost/phpmyadmin
--  2. Click the SQL tab at the top
--  3. Copy everything in this file and paste it in the box
--  4. Click Go
--  5. Done! All tables will be created automatically.
-- ============================================================


-- ============================================================
--  STEP 1: CREATE THE DATABASE
-- ============================================================
CREATE DATABASE IF NOT EXISTS volta_essence
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE volta_essence;


-- ============================================================
--  STEP 2: CUSTOMER ENQUIRIES TABLE
--  Saves every message submitted through the contact form
-- ============================================================
CREATE TABLE IF NOT EXISTS customer_enquiries (

    id            INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    -- Customer name
    first_name    VARCHAR(80)  NOT NULL,
    last_name     VARCHAR(80)  NOT NULL,

    -- Contact details
    email         VARCHAR(180) NOT NULL,
    phone         VARCHAR(30)  DEFAULT NULL,

    -- What they want
    -- Options: personal_order, bulk_order, catering, partnership, general
    interest      VARCHAR(60)  DEFAULT NULL,

    -- Their message / order details
    message       TEXT         DEFAULT NULL,

    -- Their IP address
    ip_address    VARCHAR(45)  DEFAULT NULL,

    -- Track progress of each enquiry
    -- new     = just came in, you haven't seen it yet
    -- read    = you've opened and read it
    -- replied = you've responded to the customer
    -- archived = done, no longer needed
    status        ENUM('new', 'read', 'replied', 'archived') DEFAULT 'new',

    -- Timestamps
    submitted_at  DATETIME     NOT NULL,
    updated_at    TIMESTAMP    DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    -- Indexes for fast searching
    INDEX idx_email     (email),
    INDEX idx_status    (status),
    INDEX idx_submitted (submitted_at)

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- ============================================================
--  STEP 3: ORDERS TABLE
--  For tracking food orders placed through the site
-- ============================================================
CREATE TABLE IF NOT EXISTS orders (

    id            INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,

    -- Customer info
    customer_name VARCHAR(160) NOT NULL,
    email         VARCHAR(180) NOT NULL,
    phone         VARCHAR(30)  DEFAULT NULL,
    location      VARCHAR(255) DEFAULT NULL,   -- Delivery address in Accra

    -- Items ordered (stored as JSON list)
    -- Example: [{"name":"Fufu & Light Soup","qty":2},{"name":"Agbeli Kaklo","qty":3}]
    items         JSON         NOT NULL,

    -- Order progress
    -- pending   = order received, not yet confirmed
    -- confirmed = you have confirmed the order
    -- preparing = food is being prepared
    -- delivered = order has been delivered
    -- cancelled = order was cancelled
    status        ENUM('pending','confirmed','preparing','delivered','cancelled') DEFAULT 'pending',

    -- Special instructions from customer
    notes         TEXT         DEFAULT NULL,

    -- Timestamps
    created_at    DATETIME     DEFAULT CURRENT_TIMESTAMP,
    updated_at    TIMESTAMP    DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- ============================================================
--  STEP 4: MENU ITEMS TABLE
--  All 21 Volta Essence menu items
--  No prices stored (prices removed as requested)
-- ============================================================
CREATE TABLE IF NOT EXISTS menu_items (

    id           INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name         VARCHAR(120) NOT NULL,
    description  TEXT         DEFAULT NULL,

    -- Category: foods, snacks, drinks
    category     ENUM('foods', 'snacks', 'drinks') NOT NULL,

    -- Badge label shown on the card e.g. "Bestseller", "Chef's Pick"
    badge        VARCHAR(40)  DEFAULT NULL,

    -- Image filename stored in the images/ folder
    image_file   VARCHAR(120) DEFAULT NULL,

    -- Whether this item is currently available to order
    is_available TINYINT(1)   DEFAULT 1,

    -- Controls display order on the menu
    sort_order   INT          DEFAULT 0,

    created_at   DATETIME     DEFAULT CURRENT_TIMESTAMP

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- ============================================================
--  STEP 5: INSERT ALL 21 MENU ITEMS
--  Foods, Snacks and Drinks — no prices as requested
-- ============================================================

INSERT INTO menu_items (name, description, category, badge, image_file, sort_order) VALUES

-- ── FOODS ────────────────────────────────────────────────
('Fufu & Light Soup',
 'Hand-pounded fufu in rich aromatic light soup with assorted meat, fish and garden egg. Soul food at its finest.',
 'foods', 'Bestseller', 'FUFU.jfif', 1),

('Volta Fried Tilapia',
 'Whole Volta River tilapia marinated in Ewe spices and fried golden crisp. Served with shito or pepper sauce.',
 'foods', 'Chef\'s Pick', 'tilapia_fish.jfif', 2),

('Dzenkle',
 'Bold Ewe speciality — rich, deeply spiced and slow-cooked with crab and fish. An unforgettable taste of the Volta.',
 'foods', 'Traditional', 'DZenkle.jfif', 3),

('Ghanaian Jollof Rice',
 'Smoky fire-kissed party jollof in rich tomato base. Served with grilled chicken and fried plantain.',
 'foods', 'Party Favourite', 'JOLLOF.jfif', 4),

('Abobi Tadi & Akple',
 'Smooth firm akple with spicy abobi tadi sauce — a true Ewe classic loaded with smoked fish and sardines.',
 'foods', NULL, 'ABOBI_TADI_AND_AKPLE.jfif', 5),

('Beans & Fried Plantain',
 'Slow-cooked cowpeas in rich palm oil stew with golden fried plantain. Hearty, bold, deeply satisfying.',
 'foods', NULL, 'BEANS_AND_KOKO.jfif', 6),

('Kenkey & Fried Fish',
 'Fermented corn kenkey with crispy fried fish, shito and fresh tomato salsa. A Ghanaian street legend.',
 'foods', NULL, 'KENKEY.jfif', 7),

-- ── SNACKS ───────────────────────────────────────────────
('Agbeli Kaklo',
 'Golden cassava fritters fried crisp and served with fresh coconut. The ultimate Ewe street snack.',
 'snacks', 'Fan Favourite', 'AGBELIKAKLO2.jfif', 8),

('Agbeli Kaklo (Mini)',
 'Bite-sized crispy cassava balls with coconut — perfect for sharing or snacking on the go.',
 'snacks', NULL, 'agbelikaklo.jfif', 9),

('Roasted Plantain',
 'Char-grilled ripe plantain straight off the fire. Smoky, sweet, and irresistibly simple.',
 'snacks', NULL, 'ROASTED_PLANTAIN.jfif', 10),

('Plantain Chips',
 'Thin-sliced unripe plantain fried to a satisfying crunch. Lightly salted or spiced — your choice.',
 'snacks', 'Bestseller', 'plantain_chips.jfif', 11),

('Bofrot (Puff Puff)',
 'Fluffy deep-fried dough balls, warm and slightly sweet. A Ghanaian favourite at any time of day.',
 'snacks', NULL, 'BROFROT.jfif', 12),

('Spring Rolls & Samosa',
 'Crispy spring rolls and samosas stuffed with spiced vegetables or meat. Perfect for gatherings.',
 'snacks', 'Party Pack', 'springrolls_and_samosa.jfif', 13),

('Nkate Cake',
 'Traditional groundnut bars — crunchy, sweet and nutty. Made with roasted peanuts and palm sugar.',
 'snacks', NULL, 'nkatecake.jfif', 14),

('Coconut Toffee',
 'Chewy coconut caramel toffee bars made with fresh Volta coconut. Sweet, sticky and addictive.',
 'snacks', NULL, 'COCONUT_TOFEE.jfif', 15),

('Coconut Chips',
 'Light crispy coconut bites — subtly sweet with a satisfying crunch. A wholesome local snack.',
 'snacks', NULL, 'CHIPS.jfif', 16),

('Polo Mints',
 'Locally made peppermint sweets with a satisfying hard bite and cooling finish.',
 'snacks', NULL, 'polo.jfif', 17),

('Dzowe',
 'Smooth dense groundnut paste balls — a beloved Ewe confection full of roasted peanut flavour.',
 'snacks', 'Traditional', 'DZOWE.jfif', 18),

-- ── DRINKS ───────────────────────────────────────────────
('Asana',
 'Chilled fermented corn drink, naturally sweet and cooling. A beloved Volta classic enjoyed daily.',
 'drinks', 'Refreshing', 'ASANA.jfif', 19),

('Brukina',
 'Chilled millet porridge drink blended smooth and lightly sweetened. Nourishing and utterly Ghanaian.',
 'drinks', NULL, 'brukina.jfif', 20),

('Dzowe Drink',
 'A warming traditional local brew — rich, spiced and full of character from the Volta region.',
 'drinks', NULL, 'DZOWE.jfif', 21);


-- ============================================================
--  STEP 6: USEFUL VIEWS
--  Shortcuts to see your data quickly in phpMyAdmin
-- ============================================================

-- See only NEW unread enquiries
CREATE OR REPLACE VIEW new_enquiries AS
SELECT
    id,
    CONCAT(first_name, ' ', last_name) AS full_name,
    email,
    phone,
    interest,
    LEFT(message, 100)                 AS message_preview,
    submitted_at
FROM customer_enquiries
WHERE status = 'new'
ORDER BY submitted_at DESC;


-- See ALL enquiries regardless of status
CREATE OR REPLACE VIEW all_enquiries AS
SELECT
    id,
    CONCAT(first_name, ' ', last_name) AS full_name,
    email,
    phone,
    interest,
    LEFT(message, 100)                 AS message_preview,
    status,
    submitted_at
FROM customer_enquiries
ORDER BY submitted_at DESC;


-- See pending orders that need attention
CREATE OR REPLACE VIEW pending_orders AS
SELECT
    id,
    customer_name,
    phone,
    email,
    location,
    status,
    created_at
FROM orders
WHERE status IN ('pending', 'confirmed', 'preparing')
ORDER BY created_at ASC;


-- Summary of enquiries by type
CREATE OR REPLACE VIEW enquiry_summary AS
SELECT
    interest,
    COUNT(*)               AS total,
    SUM(status = 'new')    AS unread,
    SUM(status = 'replied') AS replied,
    MAX(submitted_at)      AS latest
FROM customer_enquiries
GROUP BY interest
ORDER BY total DESC;


-- ============================================================
--  STEP 7: HELPFUL QUERIES
--  Copy and paste any of these into phpMyAdmin SQL tab
-- ============================================================

-- View all new (unread) enquiries:
-- SELECT * FROM new_enquiries;

-- View all enquiries ever:
-- SELECT * FROM all_enquiries;

-- Mark an enquiry as read (change 1 to the actual ID):
-- UPDATE customer_enquiries SET status = 'read' WHERE id = 1;

-- Mark as replied:
-- UPDATE customer_enquiries SET status = 'replied' WHERE id = 1;

-- Search by customer email:
-- SELECT * FROM customer_enquiries WHERE email = 'someone@gmail.com';

-- Search by customer phone:
-- SELECT * FROM customer_enquiries WHERE phone LIKE '%0557%';

-- Count total enquiries:
-- SELECT COUNT(*) AS total_enquiries FROM customer_enquiries;

-- Count unread enquiries:
-- SELECT COUNT(*) AS unread FROM customer_enquiries WHERE status = 'new';

-- See breakdown by interest type:
-- SELECT * FROM enquiry_summary;

-- See all pending orders:
-- SELECT * FROM pending_orders;

-- See full menu (foods only):
-- SELECT * FROM menu_items WHERE category = 'foods' ORDER BY sort_order;

-- See full menu (snacks only):
-- SELECT * FROM menu_items WHERE category = 'snacks' ORDER BY sort_order;

-- See full menu (drinks only):
-- SELECT * FROM menu_items WHERE category = 'drinks' ORDER BY sort_order;

-- ============================================================
--  ALL DONE!
--
--  Your Volta Essence database is ready.
--
--  Business Info stored in this setup:
--  Name     : Volta Essence
--  Location : Accra, Ghana
--  Email    : senyoirene123@gmail.com
--  Phone    : 0557202440
--
--  Go to http://localhost/phpmyadmin to manage everything.
-- ============================================================
