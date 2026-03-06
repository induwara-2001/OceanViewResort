package com.example.oceanviewresort.servlet;

import com.example.oceanviewresort.model.Room;
import com.example.oceanviewresort.service.RoomService;
import com.example.oceanviewresort.service.impl.RoomServiceImpl;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "RoomServlet", urlPatterns = {"/rooms"})
public class RoomServlet extends HttpServlet {

    private RoomService roomService;

    @Override
    public void init() throws ServletException {
        roomService = new RoomServiceImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loggedUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        List<Room> rooms = roomService.getAllRooms();
        int available    = roomService.countByStatus("Available");
        int occupied     = roomService.countByStatus("Occupied");
        int maintenance  = roomService.countByStatus("Maintenance");

        request.setAttribute("rooms", rooms);
        request.setAttribute("availableCount",   available);
        request.setAttribute("occupiedCount",    occupied);
        request.setAttribute("maintenanceCount", maintenance);
        request.getRequestDispatcher("/rooms.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loggedUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");

        if ("updateStatus".equals(action)) {
            String idParam = request.getParameter("roomId");
            String status  = request.getParameter("status");
            if (idParam != null && status != null) {
                try {
                    int id = Integer.parseInt(idParam);
                    roomService.updateRoomStatus(id, status);
                } catch (NumberFormatException ignored) {}
            }
        }

        response.sendRedirect(request.getContextPath() + "/rooms?updated=1");
    }
}
