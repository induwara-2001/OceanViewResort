package com.example.oceanviewresort.service;

import com.example.oceanviewresort.model.Bill;

/**
 * Service interface for bill calculation (SOA - Service Layer).
 */
public interface BillService {

    /**
     * Calculate the complete bill for a reservation by its ID.
     * Returns null if the reservation is not found.
     */
    Bill calculateBill(int reservationId);
}
