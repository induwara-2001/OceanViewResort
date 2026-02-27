package com.example.oceanviewresort.service.impl;

import com.example.oceanviewresort.dao.UserDAO;
import com.example.oceanviewresort.dao.impl.UserDAOImpl;
import com.example.oceanviewresort.model.User;
import com.example.oceanviewresort.service.UserService;

/**
 * Implementation of UserService - contains business logic for user operations.
 */
public class UserServiceImpl implements UserService {

    private final UserDAO userDAO;

    public UserServiceImpl() {
        this.userDAO = new UserDAOImpl();
    }

    @Override
    public User login(String username, String password) {
        if (username == null || username.trim().isEmpty()) {
            return null;
        }
        if (password == null || password.trim().isEmpty()) {
            return null;
        }
        return userDAO.findByUsernameAndPassword(username.trim(), password);
    }
}
