package com.example.oceanviewresort.db;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * Singleton pattern for database connection.
 * DB: ocean | user: root | password: "" | host: localhost
 */
public class DBConnection {

    private static final String URL      = "jdbc:mysql://localhost:3306/ocean?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true";
    private static final String USER     = "root";
    private static final String PASSWORD = "";

    private static DBConnection instance;
    private Connection connection;

    private DBConnection() {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            this.connection = DriverManager.getConnection(URL, USER, PASSWORD);
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("MySQL JDBC Driver not found.", e);
        } catch (SQLException e) {
            throw new RuntimeException("Failed to connect to database.", e);
        }
    }

    /**
     * Returns the single instance of DBConnection.
     */
    public static synchronized DBConnection getInstance() {
        if (instance == null || isConnectionClosed()) {
            instance = new DBConnection();
        }
        return instance;
    }

    private static boolean isConnectionClosed() {
        try {
            return instance.connection == null || instance.connection.isClosed();
        } catch (SQLException e) {
            return true;
        }
    }

    /**
     * Returns the active JDBC Connection.
     */
    public Connection getConnection() {
        return connection;
    }
}
