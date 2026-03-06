package com.example.oceanviewresort.service.impl;

import com.example.oceanviewresort.dao.GuestDAO;
import com.example.oceanviewresort.dao.RoomDAO;
import com.example.oceanviewresort.dao.impl.GuestDAOImpl;
import com.example.oceanviewresort.dao.impl.RoomDAOImpl;
import com.example.oceanviewresort.db.DBConnection;
import com.example.oceanviewresort.model.RoomRates;
import com.example.oceanviewresort.model.Bill;
import com.example.oceanviewresort.service.ReportService;

import java.sql.*;
import java.util.*;

public class ReportServiceImpl implements ReportService {

    private final Connection connection;
    private final GuestDAO   guestDAO;
    private final RoomDAO    roomDAO;

    public ReportServiceImpl() {
        this.connection = DBConnection.getInstance().getConnection();
        this.guestDAO   = new GuestDAOImpl();
        this.roomDAO    = new RoomDAOImpl();
    }

    @Override
    public int totalReservations() {
        String sql = "SELECT COUNT(*) FROM reservations";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            throw new RuntimeException("Error counting reservations.", e);
        }
        return 0;
    }

    @Override
    public Map<String, Long> reservationsByStatus() {
        Map<String, Long> map = new LinkedHashMap<>();
        String sql = "SELECT status, COUNT(*) AS cnt FROM reservations GROUP BY status ORDER BY cnt DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                map.put(rs.getString("status"), rs.getLong("cnt"));
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error grouping by status.", e);
        }
        return map;
    }

    @Override
    public Map<String, Long> reservationsByRoomType() {
        Map<String, Long> map = new LinkedHashMap<>();
        String sql = "SELECT room_type, COUNT(*) AS cnt FROM reservations GROUP BY room_type ORDER BY cnt DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                map.put(rs.getString("room_type"), rs.getLong("cnt"));
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error grouping reservations by room type.", e);
        }
        return map;
    }

    @Override
    public Map<String, Double> revenueByRoomType() {
        // Compute revenue = rate * nights per reservation, grouped by room type
        Map<String, Double> map = new LinkedHashMap<>();
        String sql = "SELECT room_type, SUM(DATEDIFF(check_out_date, check_in_date)) AS total_nights " +
                     "FROM reservations WHERE status != 'CANCELLED' GROUP BY room_type ORDER BY total_nights DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                String type  = rs.getString("room_type");
                long   nights = rs.getLong("total_nights");
                if (nights <= 0) nights = 1;
                double rate   = RoomRates.getRate(type);
                double revenue = rate * nights * (1 + Bill.TAX_RATE + Bill.SERVICE_RATE);
                map.put(type, Math.round(revenue * 100.0) / 100.0);
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error computing revenue by room type.", e);
        }
        return map;
    }

    @Override
    public double totalRevenue() {
        String sql = "SELECT room_type, SUM(DATEDIFF(check_out_date, check_in_date)) AS total_nights " +
                     "FROM reservations WHERE status != 'CANCELLED' GROUP BY room_type";
        double total = 0;
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                String type  = rs.getString("room_type");
                long   nights = rs.getLong("total_nights");
                if (nights <= 0) nights = 1;
                double rate = RoomRates.getRate(type);
                total += rate * nights * (1 + Bill.TAX_RATE + Bill.SERVICE_RATE);
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error computing total revenue.", e);
        }
        return Math.round(total * 100.0) / 100.0;
    }

    @Override
    public int totalGuests() {
        return guestDAO.countUniqueGuests();
    }

    @Override
    public int totalRooms() {
        List<com.example.oceanviewresort.model.Room> rooms = roomDAO.findAll();
        return rooms.size();
    }

    @Override
    public int availableRooms() {
        return roomDAO.countByStatus("Available");
    }
}
