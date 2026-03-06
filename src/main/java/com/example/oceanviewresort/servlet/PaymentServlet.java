package com.example.oceanviewresort.servlet;

import com.example.oceanviewresort.model.Bill;
import com.example.oceanviewresort.model.Reservation;
import com.example.oceanviewresort.service.BillService;
import com.example.oceanviewresort.service.ReservationService;
import com.example.oceanviewresort.service.impl.BillServiceImpl;
import com.example.oceanviewresort.service.impl.ReservationServiceImpl;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

/**
 * /payments – lists all reservations enriched with their computed bill totals.
 */
@WebServlet(name = "PaymentServlet", urlPatterns = {"/payments"})
public class PaymentServlet extends HttpServlet {

    private ReservationService reservationService;
    private BillService        billService;

    @Override
    public void init() throws ServletException {
        reservationService = new ReservationServiceImpl();
        billService        = new BillServiceImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loggedUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        List<Reservation> reservations = reservationService.getAllReservations();
        List<Bill>        bills        = new ArrayList<>();
        double            totalRevenue = 0;

        for (Reservation r : reservations) {
            Bill bill = billService.calculateBill(r.getId());
            bills.add(bill);
            if (!"CANCELLED".equals(r.getStatus()) && bill != null) {
                totalRevenue += bill.getGrandTotal();
            }
        }

        // Round to 2 decimal places
        totalRevenue = Math.round(totalRevenue * 100.0) / 100.0;

        request.setAttribute("reservations", reservations);
        request.setAttribute("bills",        bills);
        request.setAttribute("totalRevenue", totalRevenue);
        request.getRequestDispatcher("/payments.jsp").forward(request, response);
    }
}
