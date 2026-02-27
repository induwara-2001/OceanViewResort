package com.example.oceanviewresort.dao.impl;

import com.example.oceanviewresort.dao.ReservationDAO;
import com.example.oceanviewresort.db.DBConnection;
import com.example.oceanviewresort.model.Reservation;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * SQL implementation of ReservationDAO.
 */
public class ReservationDAOImpl implements ReservationDAO {

    private final Connection connection;

    public ReservationDAOImpl() {
        this.connection = DBConnection.getInstance().getConnection();
    }

    @Override
    public int save(Reservation r) {
        String sql = "INSERT INTO reservations " +
                     "(reservation_number, guest_name, address, contact_number, room_type, check_in_date, check_out_date, status) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, r.getReservationNumber());
            ps.setString(2, r.getGuestName());
            ps.setString(3, r.getAddress());
            ps.setString(4, r.getContactNumber());
            ps.setString(5, r.getRoomType());
            ps.setDate(6, r.getCheckInDate());
            ps.setDate(7, r.getCheckOutDate());
            ps.setString(8, r.getStatus() != null ? r.getStatus() : "PENDING");

            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) return keys.getInt(1);
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error saving reservation.", e);
        }
        return -1;
    }

    @Override
    public List<Reservation> findAll() {
        List<Reservation> list = new ArrayList<>();
        String sql = "SELECT * FROM reservations ORDER BY created_at DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error fetching reservations.", e);
        }
        return list;
    }

    @Override
    public Reservation findById(int id) {
        String sql = "SELECT * FROM reservations WHERE id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error finding reservation by ID.", e);
        }
        return null;
    }

    @Override
    public Reservation findByReservationNumber(String reservationNumber) {
        String sql = "SELECT * FROM reservations WHERE reservation_number = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, reservationNumber);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error finding reservation by number.", e);
        }
        return null;
    }

    @Override
    public int count() {
        String sql = "SELECT COUNT(*) FROM reservations";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            throw new RuntimeException("Error counting reservations.", e);
        }
        return 0;
    }

    // ---- Helper ----

    private Reservation mapRow(ResultSet rs) throws SQLException {
        Reservation r = new Reservation();
        r.setId(rs.getInt("id"));
        r.setReservationNumber(rs.getString("reservation_number"));
        r.setGuestName(rs.getString("guest_name"));
        r.setAddress(rs.getString("address"));
        r.setContactNumber(rs.getString("contact_number"));
        r.setRoomType(rs.getString("room_type"));
        r.setCheckInDate(rs.getDate("check_in_date"));
        r.setCheckOutDate(rs.getDate("check_out_date"));
        r.setStatus(rs.getString("status"));
        r.setCreatedAt(rs.getDate("created_at"));
        return r;
    }
}
