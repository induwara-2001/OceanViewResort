package com.example.oceanviewresort.servlet;

import com.example.oceanviewresort.model.Guest;
import com.example.oceanviewresort.service.GuestService;
import com.example.oceanviewresort.service.impl.GuestServiceImpl;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "GuestServlet", urlPatterns = {"/guests"})
public class GuestServlet extends HttpServlet {

    private GuestService guestService;

    @Override
    public void init() throws ServletException {
        guestService = new GuestServiceImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loggedUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        List<Guest> guests = guestService.getAllGuests();
        int totalGuests    = guestService.countUniqueGuests();

        request.setAttribute("guests",      guests);
        request.setAttribute("totalGuests", totalGuests);
        request.getRequestDispatcher("/guests.jsp").forward(request, response);
    }
}
