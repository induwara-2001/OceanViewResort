package com.example.oceanviewresort.service.impl;

import com.example.oceanviewresort.dao.RoomDAO;
import com.example.oceanviewresort.dao.impl.RoomDAOImpl;
import com.example.oceanviewresort.model.Room;
import com.example.oceanviewresort.service.RoomService;

import java.util.List;

public class RoomServiceImpl implements RoomService {

    private final RoomDAO roomDAO;

    public RoomServiceImpl() {
        this.roomDAO = new RoomDAOImpl();
    }

    @Override
    public List<Room> getAllRooms() {
        return roomDAO.findAll();
    }

    @Override
    public Room getRoomById(int id) {
        return roomDAO.findById(id);
    }

    @Override
    public boolean updateRoomStatus(int id, String status) {
        if (status == null) return false;
        String s = status.trim();
        if (!s.equals("Available") && !s.equals("Occupied") && !s.equals("Maintenance")) return false;
        return roomDAO.updateStatus(id, s);
    }

    @Override
    public int countByStatus(String status) {
        return roomDAO.countByStatus(status);
    }
}
