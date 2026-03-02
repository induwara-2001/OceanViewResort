package com.example.oceanviewresort.service.impl;

import com.example.oceanviewresort.dao.ReservationDAO;
import com.example.oceanviewresort.dao.impl.ReservationDAOImpl;
import com.example.oceanviewresort.model.Bill;
import com.example.oceanviewresort.model.Reservation;
import com.example.oceanviewresort.model.RoomRates;
import com.example.oceanviewresort.service.BillService;

/**
 * Computes the full bill for a reservation:
 *   subtotal  = ratePerNight × nights
 *   tax       = subtotal × 10%
 *   service   = subtotal × 5%
 *   grandTotal = subtotal + tax + service
 */
public class BillServiceImpl implements BillService {

    private final ReservationDAO reservationDAO;

    public BillServiceImpl() {
        this.reservationDAO = new ReservationDAOImpl();
    }

    @Override
    public Bill calculateBill(int reservationId) {
        Reservation reservation = reservationDAO.findById(reservationId);
        if (reservation == null) return null;

        // Number of nights
        long nights = 0;
        if (reservation.getCheckInDate() != null && reservation.getCheckOutDate() != null) {
            nights = (reservation.getCheckOutDate().getTime() - reservation.getCheckInDate().getTime())
                     / (1000L * 60 * 60 * 24);
        }
        if (nights <= 0) nights = 1; // minimum 1 night

        double ratePerNight       = RoomRates.getRate(reservation.getRoomType());
        double subtotal           = ratePerNight * nights;
        double taxAmount          = subtotal * Bill.TAX_RATE;
        double serviceChargeAmount = subtotal * Bill.SERVICE_RATE;
        double grandTotal         = subtotal + taxAmount + serviceChargeAmount;

        Bill bill = new Bill();
        bill.setReservation(reservation);
        bill.setNights(nights);
        bill.setRatePerNight(ratePerNight);
        bill.setSubtotal(subtotal);
        bill.setTaxRate(Bill.TAX_RATE);
        bill.setTaxAmount(taxAmount);
        bill.setServiceChargeRate(Bill.SERVICE_RATE);
        bill.setServiceChargeAmount(serviceChargeAmount);
        bill.setGrandTotal(grandTotal);

        return bill;
    }
}
