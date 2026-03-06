package com.example.oceanviewresort.service;

import com.example.oceanviewresort.model.Guest;
import java.util.List;

public interface GuestService {
    List<Guest> getAllGuests();
    int         countUniqueGuests();
}
