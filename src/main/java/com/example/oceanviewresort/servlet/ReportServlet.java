package com.example.oceanviewresort.servlet;

import com.example.oceanviewresort.service.ReportService;
import com.example.oceanviewresort.service.impl.ReportServiceImpl;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Map;

@WebServlet(name = "ReportServlet", urlPatterns = {"/reports"})
public class ReportServlet extends HttpServlet {

    private ReportService reportService;

    @Override
    public void init() throws ServletException {
        reportService = new ReportServiceImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loggedUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        int    totalReservations    = reportService.totalReservations();
        double totalRevenue         = reportService.totalRevenue();
        int    totalGuests          = reportService.totalGuests();
        int    totalRooms           = reportService.totalRooms();
        int    availableRooms       = reportService.availableRooms();

        Map<String, Long>   byStatus   = reportService.reservationsByStatus();
        Map<String, Long>   byRoomType = reportService.reservationsByRoomType();
        Map<String, Double> revenue    = reportService.revenueByRoomType();

        request.setAttribute("totalReservations", totalReservations);
        request.setAttribute("totalRevenue",      totalRevenue);
        request.setAttribute("totalGuests",       totalGuests);
        request.setAttribute("totalRooms",        totalRooms);
        request.setAttribute("availableRooms",    availableRooms);
        request.setAttribute("byStatus",          byStatus);
        request.setAttribute("byRoomType",        byRoomType);
        request.setAttribute("revenueByRoomType", revenue);

        request.getRequestDispatcher("/reports.jsp").forward(request, response);
    }
}
