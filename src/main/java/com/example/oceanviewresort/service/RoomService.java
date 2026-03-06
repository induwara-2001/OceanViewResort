package com.example.oceanviewresort.service;

import com.example.oceanviewresort.model.Room;
import java.util.List;

public interface RoomService {
    List<Room> getAllRooms();
    Room       getRoomById(int id);
    boolean    updateRoomStatus(int id, String status);
    int        countByStatus(String status);
}
