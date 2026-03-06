package com.example.oceanviewresort.dao.impl;

import com.example.oceanviewresort.dao.GuestDAO;
import com.example.oceanviewresort.db.DBConnection;
import com.example.oceanviewresort.model.Guest;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class GuestDAOImpl implements GuestDAO {

    private final Connection connection;

    public GuestDAOImpl() {
        this.connection = DBConnection.getInstance().getConnection();
    }

    @Override
    public List<Guest> findAllGuests() {
        List<Guest> list = new ArrayList<>();
        // Group reservations by contact number, pick latest entry per guest
        String sql = "SELECT contact_number, guest_name, address, " +
                     "COUNT(*) AS total_reservations, " +
                     "MAX(check_in_date) AS last_visit, " +
                     "SUBSTRING_INDEX(GROUP_CONCAT(room_type ORDER BY check_in_date DESC), ',', 1) AS last_room_type, " +
                     "SUBSTRING_INDEX(GROUP_CONCAT(status ORDER BY check_in_date DESC), ',', 1) AS last_status " +
                     "FROM reservations " +
                     "GROUP BY contact_number, guest_name, address " +
                     "ORDER BY last_visit DESC";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Guest g = new Guest();
                g.setContactNumber(rs.getString("contact_number"));
                g.setGuestName(rs.getString("guest_name"));
                g.setAddress(rs.getString("address"));
                g.setTotalReservations(rs.getInt("total_reservations"));
                g.setLastVisit(rs.getDate("last_visit"));
                g.setLastRoomType(rs.getString("last_room_type"));
                g.setLastStatus(rs.getString("last_status"));
                list.add(g);
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error fetching guests.", e);
        }
        return list;
    }

    @Override
    public int countUniqueGuests() {
        String sql = "SELECT COUNT(DISTINCT contact_number) FROM reservations";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            throw new RuntimeException("Error counting guests.", e);
        }
        return 0;
    }
}
