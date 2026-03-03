package com.example.oceanviewresort.servlet;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Serves the Help / Staff Guide page at /help.
 */
@WebServlet(name = "HelpServlet", value = "/help")
public class HelpServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Auth guard
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loggedUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Optional: highlight a specific section via ?section=reservations etc.
        String section = request.getParameter("section");
        if (section != null) {
            request.setAttribute("activeSection", section);
        }

        request.getRequestDispatcher("/help.jsp").forward(request, response);
    }
}
