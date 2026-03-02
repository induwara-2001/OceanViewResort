package com.example.oceanviewresort.servlet;

import com.example.oceanviewresort.model.Bill;
import com.example.oceanviewresort.service.BillService;
import com.example.oceanviewresort.service.impl.BillServiceImpl;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Handles GET /reservations/bill?id=X
 * Calculates and forwards bill data to bill.jsp for display/printing.
 */
@WebServlet(name = "BillServlet", value = "/reservations/bill")
public class BillServlet extends HttpServlet {

    private BillService billService;

    @Override
    public void init() throws ServletException {
        billService = new BillServiceImpl();
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

        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/reservations");
            return;
        }

        try {
            int  id   = Integer.parseInt(idParam);
            Bill bill = billService.calculateBill(id);

            if (bill == null) {
                response.sendRedirect(request.getContextPath() + "/reservations?notfound=1");
                return;
            }

            request.setAttribute("bill", bill);
            request.getRequestDispatcher("/bill.jsp").forward(request, response);

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/reservations");
        }
    }
}
