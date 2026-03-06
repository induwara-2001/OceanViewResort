package com.example.oceanviewresort.servlet;

import com.example.oceanviewresort.model.Guest;
import com.example.oceanviewresort.model.Reservation;
import com.example.oceanviewresort.service.GuestService;
import com.example.oceanviewresort.service.ReservationService;
import com.example.oceanviewresort.service.impl.GuestServiceImpl;
import com.example.oceanviewresort.service.impl.ReservationServiceImpl;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "GuestServlet", urlPatterns = {"/guests", "/guests/profile"})
public class GuestServlet extends HttpServlet {

    private GuestService       guestService;
    private ReservationService reservationService;

    @Override
    public void init() throws ServletException {
        guestService       = new GuestServiceImpl();
        reservationService = new ReservationServiceImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loggedUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String path = request.getServletPath();

        if ("/guests/profile".equals(path)) {
            String contact = request.getParameter("contact");
            if (contact == null || contact.isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/guests");
                return;
            }
            Guest guest = guestService.getGuestByContact(contact);
            if (guest == null) {
                response.sendRedirect(request.getContextPath() + "/guests");
                return;
            }
            List<Reservation> history = reservationService.getReservationsByContact(contact);
            request.setAttribute("guest",   guest);
            request.setAttribute("history", history);
            request.getRequestDispatcher("/guest-profile.jsp").forward(request, response);
        } else {
            List<Guest> guests = guestService.getAllGuests();
            int totalGuests    = guestService.countUniqueGuests();
            request.setAttribute("guests",      guests);
            request.setAttribute("totalGuests", totalGuests);
            request.getRequestDispatcher("/guests.jsp").forward(request, response);
        }
    }
}
