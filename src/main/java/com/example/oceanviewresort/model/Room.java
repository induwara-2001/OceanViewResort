package com.example.oceanviewresort.model;

/**
 * Room model - maps to the 'rooms' table.
 */
public class Room {

    private int    id;
    private String roomNumber;
    private String roomType;
    private int    floor;
    private int    capacity;
    private double pricePerNight;
    private String status;       // Available, Occupied, Maintenance
    private String description;

    public Room() {}

    public Room(String roomNumber, String roomType, int floor, int capacity,
                double pricePerNight, String status, String description) {
        this.roomNumber    = roomNumber;
        this.roomType      = roomType;
        this.floor         = floor;
        this.capacity      = capacity;
        this.pricePerNight = pricePerNight;
        this.status        = status;
        this.description   = description;
    }

    // ---- Getters & Setters ----

    public int    getId()            { return id; }
    public void   setId(int id)      { this.id = id; }

    public String getRoomNumber()                    { return roomNumber; }
    public void   setRoomNumber(String roomNumber)   { this.roomNumber = roomNumber; }

    public String getRoomType()                  { return roomType; }
    public void   setRoomType(String roomType)   { this.roomType = roomType; }

    public int  getFloor()          { return floor; }
    public void setFloor(int floor) { this.floor = floor; }

    public int  getCapacity()             { return capacity; }
    public void setCapacity(int capacity) { this.capacity = capacity; }

    public double getPricePerNight()                  { return pricePerNight; }
    public void   setPricePerNight(double pricePerNight) { this.pricePerNight = pricePerNight; }

    public String getStatus()              { return status; }
    public void   setStatus(String status) { this.status = status; }

    public String getDescription()                   { return description; }
    public void   setDescription(String description) { this.description = description; }
}
