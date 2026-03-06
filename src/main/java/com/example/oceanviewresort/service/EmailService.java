package com.example.oceanviewresort.service;

import com.example.oceanviewresort.model.Reservation;

/**
 * Service interface for sending email notifications.
 */
public interface EmailService {

    /**
     * Sends an HTML reservation confirmation email to the guest.
     * The call is non-blocking (fires in a background thread).
     *
     * @param reservation the newly created reservation
     */
    void sendReservationConfirmation(Reservation reservation);
}
