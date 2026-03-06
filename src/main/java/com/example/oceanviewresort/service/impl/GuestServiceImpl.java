package com.example.oceanviewresort.service.impl;

import com.example.oceanviewresort.dao.GuestDAO;
import com.example.oceanviewresort.dao.impl.GuestDAOImpl;
import com.example.oceanviewresort.model.Guest;
import com.example.oceanviewresort.service.GuestService;

import java.util.List;

public class GuestServiceImpl implements GuestService {

    private final GuestDAO guestDAO;

    public GuestServiceImpl() {
        this.guestDAO = new GuestDAOImpl();
    }

    @Override
    public List<Guest> getAllGuests() {
        return guestDAO.findAllGuests();
    }

    @Override
    public int countUniqueGuests() {
        return guestDAO.countUniqueGuests();
    }

    @Override
    public Guest getGuestByContact(String contactNumber) {
        return guestDAO.findByContact(contactNumber);
    }
}
