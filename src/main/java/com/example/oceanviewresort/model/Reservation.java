package com.example.oceanviewresort.model;

import java.sql.Date;

/**
 * Reservation model - maps to the 'reservations' table.
 */
public class Reservation {

    private int    id;
    private String reservationNumber;
    private String guestName;
    private String address;
    private String contactNumber;
    private String roomType;
    private Date   checkInDate;
    private Date   checkOutDate;
    private String status;        // PENDING, CONFIRMED, CANCELLED, CHECKED_OUT
    private Date   createdAt;

    public Reservation() {}

    public Reservation(String reservationNumber, String guestName, String address,
                       String contactNumber, String roomType, Date checkInDate, Date checkOutDate) {
        this.reservationNumber = reservationNumber;
        this.guestName         = guestName;
        this.address           = address;
        this.contactNumber     = contactNumber;
        this.roomType          = roomType;
        this.checkInDate       = checkInDate;
        this.checkOutDate      = checkOutDate;
        this.status            = "PENDING";
    }

    // ---- Getters & Setters ----

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getReservationNumber() { return reservationNumber; }
    public void setReservationNumber(String reservationNumber) { this.reservationNumber = reservationNumber; }

    public String getGuestName() { return guestName; }
    public void setGuestName(String guestName) { this.guestName = guestName; }

    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }

    public String getContactNumber() { return contactNumber; }
    public void setContactNumber(String contactNumber) { this.contactNumber = contactNumber; }

    public String getRoomType() { return roomType; }
    public void setRoomType(String roomType) { this.roomType = roomType; }

    public Date getCheckInDate() { return checkInDate; }
    public void setCheckInDate(Date checkInDate) { this.checkInDate = checkInDate; }

    public Date getCheckOutDate() { return checkOutDate; }
    public void setCheckOutDate(Date checkOutDate) { this.checkOutDate = checkOutDate; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Date getCreatedAt() { return createdAt; }
    public void setCreatedAt(Date createdAt) { this.createdAt = createdAt; }
}
