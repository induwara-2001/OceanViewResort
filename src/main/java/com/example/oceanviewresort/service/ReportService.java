package com.example.oceanviewresort.service;

import com.example.oceanviewresort.model.Bill;
import java.util.List;
import java.util.Map;

public interface ReportService {
    int                 totalReservations();
    Map<String, Long>   reservationsByStatus();
    Map<String, Double> revenueByRoomType();
    Map<String, Long>   reservationsByRoomType();
    double              totalRevenue();
    int                 totalGuests();
    int                 totalRooms();
    int                 availableRooms();
}
