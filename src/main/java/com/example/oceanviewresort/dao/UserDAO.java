package com.example.oceanviewresort.dao;

import com.example.oceanviewresort.model.User;

/**
 * DAO interface for User-related database operations (SOA - Data Access Layer).
 */
public interface UserDAO {

    /**
     * Finds a user by username and password (plain text match against DB).
     * Returns null if no match found.
     */
    User findByUsernameAndPassword(String username, String password);

    /**
     * Finds a user by username only.
     * Returns null if not found.
     */
    User findByUsername(String username);
}
