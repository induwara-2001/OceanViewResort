package com.example.oceanviewresort.service;

import com.example.oceanviewresort.model.Reservation;

import java.util.List;

/**
 * Service interface for reservation business logic (SOA - Service Layer).
 */
public interface ReservationService {

    /**
     * Creates and stores a new reservation.
     * Generates the reservation number automatically.
     * Sends an HTML confirmation email to guestEmail if provided.
     * Returns true on success.
     */
    boolean addReservation(String guestName, String address, String contactNumber,
                           String guestEmail, String roomType,
                           String checkInDate, String checkOutDate);

    /** Returns all reservations. */
    List<Reservation> getAllReservations();

    /** Finds a reservation by its ID. */
    Reservation getReservationById(int id);

    /** Delete a reservation by ID. Returns true on success. */
    boolean deleteReservation(int id);
}
