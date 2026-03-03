package com.example.oceanviewresort.servlet;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Handles /exit — safely terminates the user session and shows the exit page.
 * Distinct from /logout: provides a goodbye screen instead of redirecting to login.
 */
@WebServlet(name = "ExitServlet", value = "/exit")
public class ExitServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Capture the user's name before invalidating session
        HttpSession session = request.getSession(false);
        String userName = "Staff";
        if (session != null) {
            Object user = session.getAttribute("loggedUser");
            if (user instanceof com.example.oceanviewresort.model.User) {
                com.example.oceanviewresort.model.User u =
                        (com.example.oceanviewresort.model.User) user;
                userName = u.getFullName() != null ? u.getFullName() : u.getUsername();
            }
            // Invalidate the session — all data is cleared
            session.invalidate();
        }

        // Pass name to exit page
        request.setAttribute("exitUserName", userName);

        // Forward (not redirect) so exit.jsp renders without needing a session
        request.getRequestDispatcher("/exit.jsp").forward(request, response);
    }
}
