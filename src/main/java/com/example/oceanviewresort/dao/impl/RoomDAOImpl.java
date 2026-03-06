package com.example.oceanviewresort.dao.impl;

import com.example.oceanviewresort.dao.RoomDAO;
import com.example.oceanviewresort.db.DBConnection;
import com.example.oceanviewresort.model.Room;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class RoomDAOImpl implements RoomDAO {

    private final Connection connection;

    public RoomDAOImpl() {
        this.connection = DBConnection.getInstance().getConnection();
    }

    @Override
    public List<Room> findAll() {
        List<Room> list = new ArrayList<>();
        String sql = "SELECT * FROM rooms ORDER BY room_number";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) {
            throw new RuntimeException("Error fetching rooms.", e);
        }
        return list;
    }

    @Override
    public Room findById(int id) {
        String sql = "SELECT * FROM rooms WHERE id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error finding room.", e);
        }
        return null;
    }

    @Override
    public int save(Room room) {
        String sql = "INSERT INTO rooms (room_number, room_type, floor, capacity, price_per_night, status, description) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, room.getRoomNumber());
            ps.setString(2, room.getRoomType());
            ps.setInt(3, room.getFloor());
            ps.setInt(4, room.getCapacity());
            ps.setDouble(5, room.getPricePerNight());
            ps.setString(6, room.getStatus() != null ? room.getStatus() : "Available");
            ps.setString(7, room.getDescription());
            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet keys = ps.getGeneratedKeys()) {
                    if (keys.next()) return keys.getInt(1);
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error saving room.", e);
        }
        return -1;
    }

    @Override
    public boolean updateStatus(int id, String status) {
        String sql = "UPDATE rooms SET status = ? WHERE id = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("Error updating room status.", e);
        }
    }

    @Override
    public int countByStatus(String status) {
        String sql = "SELECT COUNT(*) FROM rooms WHERE status = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, status);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error counting rooms.", e);
        }
        return 0;
    }

    private Room mapRow(ResultSet rs) throws SQLException {
        Room r = new Room();
        r.setId(rs.getInt("id"));
        r.setRoomNumber(rs.getString("room_number"));
        r.setRoomType(rs.getString("room_type"));
        r.setFloor(rs.getInt("floor"));
        r.setCapacity(rs.getInt("capacity"));
        r.setPricePerNight(rs.getDouble("price_per_night"));
        r.setStatus(rs.getString("status"));
        r.setDescription(rs.getString("description"));
        return r;
    }
}
