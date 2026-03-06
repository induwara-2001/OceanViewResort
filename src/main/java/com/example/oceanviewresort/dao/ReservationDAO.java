package com.example.oceanviewresort.dao;

import com.example.oceanviewresort.model.Reservation;

import java.util.List;

/**
 * DAO interface for Reservation operations (SOA - Data Access Layer).
 */
public interface ReservationDAO {

    /** Insert a new reservation. Returns generated ID, or -1 on failure. */
    int save(Reservation reservation);

    /** Retrieve all reservations ordered by created date desc. */
    List<Reservation> findAll();

    /** Find a single reservation by its ID. */
    Reservation findById(int id);

    /** Find a reservation by its reservation number. */
    Reservation findByReservationNumber(String reservationNumber);

    /** Get the count of reservations to help generate reservation numbers. */
    int count();

    /** Delete a reservation by its ID. Returns true if a row was deleted. */
    boolean deleteById(int id);

    /** Update an existing reservation record. Returns true if a row was updated. */
    boolean update(Reservation reservation);

    /** Find all reservations for a given contact number ordered by check-in desc. */
    List<Reservation> findByContactNumber(String contactNumber);
}
