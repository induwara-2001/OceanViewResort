package com.example.oceanviewresort.model;

import java.sql.Date;

/**
 * Guest summary derived from the reservations table.
 * (No separate guests table — guests are identified by name + contact.)
 */
public class Guest {

    private String guestName;
    private String contactNumber;
    private String address;
    private int    totalReservations;
    private Date   lastVisit;
    private String lastRoomType;
    private String lastStatus;

    public Guest() {}

    // ---- Getters & Setters ----

    public String getGuestName()                   { return guestName; }
    public void   setGuestName(String guestName)   { this.guestName = guestName; }

    public String getContactNumber()                       { return contactNumber; }
    public void   setContactNumber(String contactNumber)   { this.contactNumber = contactNumber; }

    public String getAddress()               { return address; }
    public void   setAddress(String address) { this.address = address; }

    public int  getTotalReservations()                    { return totalReservations; }
    public void setTotalReservations(int totalReservations) { this.totalReservations = totalReservations; }

    public Date getLastVisit()               { return lastVisit; }
    public void setLastVisit(Date lastVisit) { this.lastVisit = lastVisit; }

    public String getLastRoomType()                    { return lastRoomType; }
    public void   setLastRoomType(String lastRoomType) { this.lastRoomType = lastRoomType; }

    public String getLastStatus()                { return lastStatus; }
    public void   setLastStatus(String lastStatus) { this.lastStatus = lastStatus; }
}
