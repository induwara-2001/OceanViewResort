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
    guest_email        VARCHAR(150),
    room_type          VARCHAR(50)   NOT NULL,
    check_in_date      DATE          NOT NULL,
    check_out_date     DATE          NOT NULL,
    status             VARCHAR(20)   NOT NULL DEFAULT 'PENDING',
    created_at         TIMESTAMP     DEFAULT CURRENT_TIMESTAMP
);

-- Rooms table
CREATE TABLE IF NOT EXISTS rooms (
    id             INT           AUTO_INCREMENT PRIMARY KEY,
    room_number    VARCHAR(10)   NOT NULL UNIQUE,
    room_type      VARCHAR(50)   NOT NULL,
    floor          INT           NOT NULL DEFAULT 1,
    capacity       INT           NOT NULL DEFAULT 2,
    price_per_night DECIMAL(10,2) NOT NULL,
    status         VARCHAR(20)   NOT NULL DEFAULT 'Available',
    description    VARCHAR(255),
    created_at     TIMESTAMP     DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
--  Sample users (password stored as plain text for now)
-- ============================================================
INSERT INTO users (username, password, role, email, full_name) VALUES
('admin',   'admin123',  'admin',   'admin@oceanviewresort.com',   'Admin User'),
('manager', 'manager123','manager', 'manager@oceanviewresort.com', 'Resort Manager'),
('staff',   'staff123',  'staff',   'staff@oceanviewresort.com',   'Front Desk Staff');

-- ============================================================
--  Sample rooms
-- ============================================================
INSERT INTO rooms (room_number, room_type, floor, capacity, price_per_night, status, description) VALUES
('101', 'Standard',         1, 2,  80.00, 'Available',   'Comfortable standard room with garden view'),
('102', 'Standard',         1, 2,  80.00, 'Occupied',    'Comfortable standard room with garden view'),
('103', 'Standard',         1, 2,  80.00, 'Available',   'Comfortable standard room with garden view'),
('104', 'Deluxe',           1, 2, 120.00, 'Available',   'Spacious deluxe room with sea view balcony'),
('105', 'Deluxe',           1, 2, 120.00, 'Maintenance', 'Spacious deluxe room with sea view balcony'),
('201', 'Superior',         2, 3, 150.00, 'Available',   'Superior room with lounge area and ocean view'),
('202', 'Superior',         2, 3, 150.00, 'Occupied',    'Superior room with lounge area and ocean view'),
('203', 'Family',           2, 5, 180.00, 'Available',   'Family suite with two bedrooms and kitchenette'),
('204', 'Family',           2, 5, 180.00, 'Available',   'Family suite with two bedrooms and kitchenette'),
('301', 'Ocean View Suite', 3, 2, 200.00, 'Available',   'Luxury suite with panoramic ocean view'),
('302', 'Ocean View Suite', 3, 2, 200.00, 'Occupied',    'Luxury suite with panoramic ocean view'),
('401', 'Presidential',     4, 4, 350.00, 'Available',   'Presidential suite with private terrace and butler'),
('501', 'Penthouse',        5, 6, 500.00, 'Available',   'Entire penthouse floor with private pool and chef');
