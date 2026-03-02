package com.example.oceanviewresort.model;

/**
 * Bill model - computed from a Reservation.
 * Holds all financial breakdown for printing.
 */
public class Bill {

    // --- Reference ---
    private Reservation reservation;

    // --- Nightly rate ---
    private double ratePerNight;
    private long   nights;

    // --- Totals ---
    private double subtotal;        // ratePerNight * nights
    private double taxRate;         // e.g. 0.10 = 10%
    private double taxAmount;
    private double serviceChargeRate; // e.g. 0.05 = 5%
    private double serviceChargeAmount;
    private double grandTotal;

    // --- Formatting helpers ---
    public static final double TAX_RATE     = 0.10;  // 10% government tax
    public static final double SERVICE_RATE = 0.05;  // 5% service charge

    public Bill() {}

    // ---- Getters & Setters ----

    public Reservation getReservation()             { return reservation; }
    public void setReservation(Reservation r)       { this.reservation = r; }

    public double getRatePerNight()                 { return ratePerNight; }
    public void setRatePerNight(double v)           { this.ratePerNight = v; }

    public long getNights()                         { return nights; }
    public void setNights(long v)                   { this.nights = v; }

    public double getSubtotal()                     { return subtotal; }
    public void setSubtotal(double v)               { this.subtotal = v; }

    public double getTaxRate()                      { return taxRate; }
    public void setTaxRate(double v)                { this.taxRate = v; }

    public double getTaxAmount()                    { return taxAmount; }
    public void setTaxAmount(double v)              { this.taxAmount = v; }

    public double getServiceChargeRate()            { return serviceChargeRate; }
    public void setServiceChargeRate(double v)      { this.serviceChargeRate = v; }

    public double getServiceChargeAmount()          { return serviceChargeAmount; }
    public void setServiceChargeAmount(double v)    { this.serviceChargeAmount = v; }

    public double getGrandTotal()                   { return grandTotal; }
    public void setGrandTotal(double v)             { this.grandTotal = v; }
}
