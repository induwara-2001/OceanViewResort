package com.example.oceanviewresort.dao;

import com.example.oceanviewresort.model.Room;
import java.util.List;

public interface RoomDAO {
    List<Room> findAll();
    Room       findById(int id);
    int        save(Room room);
    boolean    updateStatus(int id, String status);
    int        countByStatus(String status);
}
