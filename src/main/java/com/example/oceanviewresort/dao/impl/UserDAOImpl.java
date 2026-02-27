package com.example.oceanviewresort.dao.impl;

import com.example.oceanviewresort.dao.UserDAO;
import com.example.oceanviewresort.db.DBConnection;
import com.example.oceanviewresort.model.User;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * Implementation of UserDAO - handles all SQL for user operations.
 */
public class UserDAOImpl implements UserDAO {

    private final Connection connection;

    public UserDAOImpl() {
        this.connection = DBConnection.getInstance().getConnection();
    }

    @Override
    public User findByUsernameAndPassword(String username, String password) {
        String sql = "SELECT * FROM users WHERE username = ? AND password = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, username);
            ps.setString(2, password);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error finding user by credentials.", e);
        }
        return null;
    }

    @Override
    public User findByUsername(String username) {
        String sql = "SELECT * FROM users WHERE username = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error finding user by username.", e);
        }
        return null;
    }

    // ---- Helper ----

    private User mapRow(ResultSet rs) throws SQLException {
        User user = new User();
        user.setId(rs.getInt("id"));
        user.setUsername(rs.getString("username"));
        user.setPassword(rs.getString("password"));
        user.setRole(rs.getString("role"));
        user.setEmail(rs.getString("email"));
        user.setFullName(rs.getString("full_name"));
        return user;
    }
}
