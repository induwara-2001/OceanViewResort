package com.example.oceanviewresort.db;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;
import java.sql.Connection;
import java.sql.Statement;

/**
 * Runs on application startup and creates all required tables
 * (+ sample seed data) if they do not already exist.
 * This means staff never need to run ocean_db.sql manually.
 */
@WebListener
public class DBInitializer implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        try {
            Connection conn = DBConnection.getInstance().getConnection();
            Statement  st   = conn.createStatement();

            // ── users ────────────────────────────────────────────────────
            st.executeUpdate(
                "CREATE TABLE IF NOT EXISTS users (" +
                "  id         INT          AUTO_INCREMENT PRIMARY KEY," +
                "  username   VARCHAR(50)  NOT NULL UNIQUE," +
                "  password   VARCHAR(255) NOT NULL," +
                "  role       VARCHAR(20)  NOT NULL DEFAULT 'staff'," +
                "  email      VARCHAR(100)," +
                "  full_name  VARCHAR(100)," +
                "  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP" +
                ")"
            );

            // ── reservations ─────────────────────────────────────────────
            st.executeUpdate(
                "CREATE TABLE IF NOT EXISTS reservations (" +
                "  id                 INT          AUTO_INCREMENT PRIMARY KEY," +
                "  reservation_number VARCHAR(20)  NOT NULL UNIQUE," +
                "  guest_name         VARCHAR(100) NOT NULL," +
                "  address            VARCHAR(255)," +
                "  contact_number     VARCHAR(20)  NOT NULL," +
                "  guest_email        VARCHAR(150)," +
                "  room_type          VARCHAR(50)  NOT NULL," +
                "  check_in_date      DATE         NOT NULL," +
                "  check_out_date     DATE         NOT NULL," +
                "  status             VARCHAR(20)  NOT NULL DEFAULT 'PENDING'," +
                "  created_at         TIMESTAMP DEFAULT CURRENT_TIMESTAMP" +
                ")"
            );

            // Add guest_email to existing tables that were created before this column existed
            try {
                st.executeUpdate(
                    "ALTER TABLE reservations ADD COLUMN IF NOT EXISTS guest_email VARCHAR(150) AFTER contact_number"
                );
            } catch (Exception ignored) {
                // Older MySQL versions may not support IF NOT EXISTS on ALTER; safe to ignore
            }

            // ── rooms ─────────────────────────────────────────────────────
            st.executeUpdate(
                "CREATE TABLE IF NOT EXISTS rooms (" +
                "  id              INT           AUTO_INCREMENT PRIMARY KEY," +
                "  room_number     VARCHAR(10)   NOT NULL UNIQUE," +
                "  room_type       VARCHAR(50)   NOT NULL," +
                "  floor           INT           NOT NULL DEFAULT 1," +
                "  capacity        INT           NOT NULL DEFAULT 2," +
                "  price_per_night DECIMAL(10,2) NOT NULL," +
                "  status          VARCHAR(20)   NOT NULL DEFAULT 'Available'," +
                "  description     VARCHAR(255)," +
                "  created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP" +
                ")"
            );

            // ── seed users (only if table is empty) ──────────────────────
            st.executeUpdate(
                "INSERT IGNORE INTO users (username, password, role, email, full_name) VALUES " +
                "('admin',   'admin123',   'admin',   'admin@oceanviewresort.com',   'Admin User')," +
                "('manager', 'manager123', 'manager', 'manager@oceanviewresort.com', 'Resort Manager')," +
                "('staff',   'staff123',   'staff',   'staff@oceanviewresort.com',   'Front Desk Staff')"
            );

            // ── seed rooms (only if table is empty) ───────────────────────
            st.executeUpdate(
                "INSERT IGNORE INTO rooms (room_number, room_type, floor, capacity, price_per_night, status, description) VALUES " +
                "('101','Standard',         1,2,  80.00,'Available',   'Comfortable standard room with garden view')," +
                "('102','Standard',         1,2,  80.00,'Occupied',    'Comfortable standard room with garden view')," +
                "('103','Standard',         1,2,  80.00,'Available',   'Comfortable standard room with garden view')," +
                "('104','Deluxe',           1,2, 120.00,'Available',   'Spacious deluxe room with sea view balcony')," +
                "('105','Deluxe',           1,2, 120.00,'Maintenance', 'Spacious deluxe room with sea view balcony')," +
                "('201','Superior',         2,3, 150.00,'Available',   'Superior room with lounge area and ocean view')," +
                "('202','Superior',         2,3, 150.00,'Occupied',    'Superior room with lounge area and ocean view')," +
                "('203','Family',           2,5, 180.00,'Available',   'Family suite with two bedrooms and kitchenette')," +
                "('204','Family',           2,5, 180.00,'Available',   'Family suite with two bedrooms and kitchenette')," +
                "('301','Ocean View Suite', 3,2, 200.00,'Available',   'Luxury suite with panoramic ocean view')," +
                "('302','Ocean View Suite', 3,2, 200.00,'Occupied',    'Luxury suite with panoramic ocean view')," +
                "('401','Presidential',     4,4, 350.00,'Available',   'Presidential suite with private terrace and butler')," +
                "('501','Penthouse',        5,6, 500.00,'Available',   'Entire penthouse floor with private pool and chef')"
            );

            st.close();
            System.out.println("[DBInitializer] All tables verified/created successfully.");

        } catch (Exception e) {
            System.err.println("[DBInitializer] ERROR during table initialization: " + e.getMessage());
            e.printStackTrace();
        }
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        // nothing to clean up
    }
}
