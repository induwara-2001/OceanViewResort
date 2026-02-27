package com.example.oceanviewresort.servlet;

import com.example.oceanviewresort.model.User;
import com.example.oceanviewresort.service.UserService;
import com.example.oceanviewresort.service.impl.UserServiceImpl;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import java.io.IOException;

/**
 * Servlet that handles user login (GET shows form, POST processes credentials).
 */
@WebServlet(name = "LoginServlet", value = "/login")
public class LoginServlet extends HttpServlet {

    private UserService userService;

    @Override
    public void init() throws ServletException {
        userService = new UserServiceImpl();
    }

    /** Show the login page. */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // If already logged in, redirect to dashboard
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("loggedUser") != null) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }

        request.getRequestDispatcher("/login.jsp").forward(request, response);
    }

    /** Process login credentials. */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username");
        String password = request.getParameter("password");

        User user = userService.login(username, password);

        if (user != null) {
            // Valid credentials - create session
            HttpSession session = request.getSession(true);
            session.setAttribute("loggedUser", user);
            session.setMaxInactiveInterval(30 * 60); // 30 minutes

            response.sendRedirect(request.getContextPath() + "/dashboard");
        } else {
            // Invalid credentials - return to login with error
            request.setAttribute("errorMessage", "Invalid username or password. Please try again.");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
        }
    }
}
