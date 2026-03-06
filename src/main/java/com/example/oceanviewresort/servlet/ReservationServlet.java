package com.example.oceanviewresort.servlet;

import com.example.oceanviewresort.model.Reservation;
import com.example.oceanviewresort.service.ReservationService;
import com.example.oceanviewresort.service.impl.ReservationServiceImpl;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

/**
 * Handles /reservations (list), /reservations/add (form+save), /reservations/view (details).
 */
@WebServlet(name = "ReservationServlet", urlPatterns = {"/reservations", "/reservations/add", "/reservations/view"})
public class ReservationServlet extends HttpServlet {

    private ReservationService reservationService;

    @Override
    public void init() throws ServletException {
        reservationService = new ReservationServiceImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Auth guard
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loggedUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String path = request.getServletPath();

        if ("/reservations/add".equals(path)) {
            // Show the add reservation form
            request.getRequestDispatcher("/add-reservation.jsp").forward(request, response);

        } else if ("/reservations/view".equals(path)) {
            // Show details of a specific reservation
            String idParam = request.getParameter("id");
            if (idParam == null || idParam.isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/reservations");
                return;
            }
            try {
                int id = Integer.parseInt(idParam);
                Reservation reservation = reservationService.getReservationById(id);
                if (reservation == null) {
                    response.sendRedirect(request.getContextPath() + "/reservations?notfound=1");
                    return;
                }
                request.setAttribute("reservation", reservation);
                request.getRequestDispatcher("/reservation-details.jsp").forward(request, response);
            } catch (NumberFormatException e) {
                response.sendRedirect(request.getContextPath() + "/reservations");
            }

        } else {
            // Show the reservations list
            List<Reservation> reservations = reservationService.getAllReservations();
            request.setAttribute("reservations", reservations);
            request.getRequestDispatcher("/reservations.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Auth guard
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loggedUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String guestName      = request.getParameter("guestName");
        String address        = request.getParameter("address");
        String contactNumber  = request.getParameter("contactNumber");
        String guestEmail     = request.getParameter("guestEmail");
        String roomType       = request.getParameter("roomType");
        String checkInDate    = request.getParameter("checkInDate");
        String checkOutDate   = request.getParameter("checkOutDate");

        boolean success = reservationService.addReservation(
                guestName, address, contactNumber, guestEmail, roomType, checkInDate, checkOutDate);

        if (success) {
            // Redirect to reservations list with success message
            response.sendRedirect(request.getContextPath() + "/reservations?success=1");
        } else {
            // Return to form with error
            request.setAttribute("errorMessage", "Failed to save reservation. Please check all fields and ensure check-out is after check-in.");
            request.setAttribute("guestName",     guestName);
            request.setAttribute("address",       address);
            request.setAttribute("contactNumber", contactNumber);
            request.setAttribute("guestEmail",    guestEmail);
            request.setAttribute("roomType",      roomType);
            request.setAttribute("checkInDate",   checkInDate);
            request.setAttribute("checkOutDate",  checkOutDate);
            request.getRequestDispatcher("/add-reservation.jsp").forward(request, response);
        }
    }
}
