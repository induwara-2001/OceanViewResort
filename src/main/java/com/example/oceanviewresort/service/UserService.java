package com.example.oceanviewresort.service;

import com.example.oceanviewresort.model.User;

/**
 * Service interface for user-related business logic (SOA - Service Layer).
 */
public interface UserService {

    /**
     * Authenticates a user with username and password.
     * Returns the User object on success, null on failure.
     */
    User login(String username, String password);
}
