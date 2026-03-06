package com.example.oceanviewresort.service.impl;

import com.example.oceanviewresort.dao.ReservationDAO;
import com.example.oceanviewresort.dao.impl.ReservationDAOImpl;
import com.example.oceanviewresort.model.Reservation;
import com.example.oceanviewresort.service.EmailService;
import com.example.oceanviewresort.service.ReservationService;
import com.example.oceanviewresort.service.impl.EmailServiceImpl;

import java.sql.Date;
import java.time.LocalDate;
import java.time.Year;
import java.util.List;

/**
 * Business logic for reservation operations.
 */
public class ReservationServiceImpl implements ReservationService {

    private final ReservationDAO reservationDAO;
    private final EmailService   emailService;

    public ReservationServiceImpl() {
        this.reservationDAO = new ReservationDAOImpl();
        this.emailService   = new EmailServiceImpl();
    }

    @Override
    public boolean addReservation(String guestName, String address, String contactNumber,
                                  String guestEmail, String roomType,
                                  String checkInDate, String checkOutDate) {

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
                guestEmail != null ? guestEmail.trim() : "",
                roomType,
                checkIn,
                checkOut
        );

        int id = reservationDAO.save(reservation);
        if (id > 0) {
            reservation.setId(id);
            // Send confirmation email (non-blocking background thread)
            emailService.sendReservationConfirmation(reservation);
            return true;
        }
        return false;
    }

    @Override
    public List<Reservation> getAllReservations() {
        return reservationDAO.findAll();
    }

    @Override
    public Reservation getReservationById(int id) {
        return reservationDAO.findById(id);
    }

    @Override
    public List<Reservation> getReservationsByContact(String contactNumber) {
        return reservationDAO.findByContactNumber(contactNumber);
    }

    @Override
    public boolean deleteReservation(int id) {
        return reservationDAO.deleteById(id);
    }

    @Override
    public boolean updateReservation(int id, String guestName, String address, String contactNumber,
                                     String guestEmail, String roomType,
                                     String checkInDate, String checkOutDate, String status) {
        if (guestName == null || guestName.trim().isEmpty()) return false;
        if (contactNumber == null || contactNumber.trim().isEmpty()) return false;
        if (roomType == null || roomType.trim().isEmpty()) return false;
        if (checkInDate == null || checkOutDate == null) return false;

        java.sql.Date checkIn  = java.sql.Date.valueOf(checkInDate);
        java.sql.Date checkOut = java.sql.Date.valueOf(checkOutDate);
        if (!checkOut.after(checkIn)) return false;

        Reservation existing = reservationDAO.findById(id);
        if (existing == null) return false;

        existing.setGuestName(guestName.trim());
        existing.setAddress(address != null ? address.trim() : "");
        existing.setContactNumber(contactNumber.trim());
        existing.setGuestEmail(guestEmail != null ? guestEmail.trim() : "");
        existing.setRoomType(roomType.trim());
        existing.setCheckInDate(checkIn);
        existing.setCheckOutDate(checkOut);
        existing.setStatus(status != null && !status.trim().isEmpty() ? status.trim() : "PENDING");

        return reservationDAO.update(existing);
    }

    // ---- Helper ----

    private String generateReservationNumber() {
        int year  = Year.now().getValue();
        int count = reservationDAO.count() + 1;
        return String.format("RES-%d-%04d", year, count);
    }
}
