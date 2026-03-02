package com.example.oceanviewresort.model;

import java.util.HashMap;
import java.util.Map;

/**
 * Static room rates (per night, in USD).
 * Used by BillService to calculate the total stay cost.
 */
public class RoomRates {

    private static final Map<String, Double> RATES = new HashMap<>();

    static {
        RATES.put("Standard Room",      80.00);
        RATES.put("Deluxe Room",       120.00);
        RATES.put("Superior Room",     150.00);
        RATES.put("Ocean View Suite",  200.00);
        RATES.put("Family Room",       180.00);
        RATES.put("Presidential Suite",350.00);
        RATES.put("Penthouse Suite",   500.00);
    }

    public static double getRate(String roomType) {
        return RATES.getOrDefault(roomType, 100.00); // default fallback
    }

    public static Map<String, Double> getAllRates() {
        return RATES;
    }

    private RoomRates() {}
}
