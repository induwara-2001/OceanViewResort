package com.example.oceanviewresort.service.impl;

import com.example.oceanviewresort.dao.ReservationDAO;
import com.example.oceanviewresort.dao.impl.ReservationDAOImpl;
import com.example.oceanviewresort.model.Reservation;
import com.example.oceanviewresort.service.ReservationService;

import java.sql.Date;
import java.time.LocalDate;
import java.time.Year;
import java.util.List;

/**
 * Business logic for reservation operations.
 */
public class ReservationServiceImpl implements ReservationService {

    private final ReservationDAO reservationDAO;

    public ReservationServiceImpl() {
        this.reservationDAO = new ReservationDAOImpl();
    }

    @Override
    public boolean addReservation(String guestName, String address, String contactNumber,
                                  String roomType, String checkInDate, String checkOutDate) {

        // Basic validation
        if (guestName == null || guestName.trim().isEmpty()) return false;
        if (contactNumber == null || contactNumber.trim().isEmpty()) return false;
        if (roomType == null || roomType.trim().isEmpty()) return false;
        if (checkInDate == null || checkOutDate == null) return false;

        Date checkIn  = Date.valueOf(checkInDate);
        Date checkOut = Date.valueOf(checkOutDate);

        // Check-out must be after check-in
        if (!checkOut.after(checkIn)) return false;

        // Auto-generate reservation number: RES-YYYY-XXXX
        String reservationNumber = generateReservationNumber();

        Reservation reservation = new Reservation(
                reservationNumber,
                guestName.trim(),
                address != null ? address.trim() : "",
                contactNumber.trim(),
                roomType,
                checkIn,
                checkOut
        );

        int id = reservationDAO.save(reservation);
        return id > 0;
    }

    @Override
    public List<Reservation> getAllReservations() {
        return reservationDAO.findAll();
    }

    @Override
    public Reservation getReservationById(int id) {
        return reservationDAO.findById(id);
    }

    // ---- Helper ----

    private String generateReservationNumber() {
        int year  = Year.now().getValue();
        int count = reservationDAO.count() + 1;
        return String.format("RES-%d-%04d", year, count);
    }
}
