-- ============================================================
--  Ocean View Resort - Database Setup Script
--  DB: ocean | user: root | password: "" | host: localhost
-- ============================================================

CREATE DATABASE IF NOT EXISTS ocean;
USE ocean;

-- Users table (for login & role management)
CREATE TABLE IF NOT EXISTS users (
    id        INT           AUTO_INCREMENT PRIMARY KEY,
    username  VARCHAR(50)   NOT NULL UNIQUE,
    password  VARCHAR(255)  NOT NULL,
    role      VARCHAR(20)   NOT NULL DEFAULT 'staff',
    email     VARCHAR(100),
    full_name VARCHAR(100),
    created_at TIMESTAMP    DEFAULT CURRENT_TIMESTAMP
);

-- Reservations table
CREATE TABLE IF NOT EXISTS reservations (
    id                 INT           AUTO_INCREMENT PRIMARY KEY,
    reservation_number VARCHAR(20)   NOT NULL UNIQUE,
    guest_name         VARCHAR(100)  NOT NULL,
    address            VARCHAR(255),
    contact_number     VARCHAR(20)   NOT NULL,
    room_type          VARCHAR(50)   NOT NULL,
    check_in_date      DATE          NOT NULL,
    check_out_date     DATE          NOT NULL,
    status             VARCHAR(20)   NOT NULL DEFAULT 'PENDING',
    created_at         TIMESTAMP     DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
--  Sample users (password stored as plain text for now)
-- ============================================================
INSERT INTO users (username, password, role, email, full_name) VALUES
('admin',   'admin123',  'admin',   'admin@oceanviewresort.com',   'Admin User'),
('manager', 'manager123','manager', 'manager@oceanviewresort.com', 'Resort Manager'),
('staff',   'staff123',  'staff',   'staff@oceanviewresort.com',   'Front Desk Staff');
