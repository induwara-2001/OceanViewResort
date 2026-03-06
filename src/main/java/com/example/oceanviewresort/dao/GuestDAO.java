package com.example.oceanviewresort.dao;

import com.example.oceanviewresort.model.Guest;
import java.util.List;

public interface GuestDAO {
    /** Returns unique guests derived from the reservations table. */
    List<Guest> findAllGuests();
    int         countUniqueGuests();
    /** Returns a single guest summary by contact number. */
    Guest findByContact(String contactNumber);
}
