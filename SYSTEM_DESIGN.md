# Ocean View Resort – System Design Document

> **Stack:** Java 11 · Jakarta Servlet 4.0 (javax) · JSP · MySQL 8 · Apache Tomcat 9  
> **Build:** Apache Maven (WAR packaging)  
> **Architecture:** Service-Oriented Architecture (SOA) with Singleton DB connection

---

## Table of Contents

1. [System Overview](#1-system-overview)
2. [Architecture Overview](#2-architecture-overview)
3. [Actors & System Roles](#3-actors--system-roles)
4. [Use Case Diagram](#4-use-case-diagram)
5. [Class Diagram](#5-class-diagram)
6. [Sequence Diagrams](#6-sequence-diagrams)
   - 6.1 Login
   - 6.2 Add Reservation
   - 6.3 View Reservation Details
   - 6.4 Calculate & Print Bill
   - 6.5 Update Room Status
   - 6.6 View Reports
   - 6.7 Exit System
7. [Design Patterns Used](#7-design-patterns-used)
8. [Database Schema](#8-database-schema)
9. [Assumptions](#9-assumptions)

---

## 1. System Overview

The **Ocean View Resort Management System** is a web-based application for managing hotel operations by resort staff. It handles:

| Module        | Feature Summary                                                      |
|---------------|----------------------------------------------------------------------|
| Authentication| Login / logout / session management with role display                |
| Reservations  | Create, list, and view detailed guest bookings                       |
| Rooms         | View all rooms, availability summary, update room status             |
| Guests        | Auto-derived guest profiles from booking history                     |
| Payments      | List all reservations with computed bill totals and invoice links     |
| Reports       | KPI dashboard with interactive charts (Chart.js)                     |
| Billing       | Detailed printable invoice (room charge + 10% tax + 5% service)      |
| Help          | Staff user guide (9 collapsible sections)                            |
| Exit          | Safe session termination with goodbye screen                         |

---

## 2. Architecture Overview

The application follows a **4-tier SOA layered architecture**:

```
Browser (JSP Views)
       │  HTTP Request/Response
       ▼
Servlet Layer  (Controller)     – javax.servlet.HttpServlet subclasses
       │  delegates business logic
       ▼
Service Layer  (Business Logic) – interfaces + implementation classes
       │  delegates data access
       ▼
DAO Layer      (Data Access)    – interfaces + implementation classes
       │  JDBC SQL
       ▼
Database       (MySQL)          – ocean database (users, reservations, rooms)
       │
DBConnection (Singleton)        – single shared JDBC Connection
```

**Request flow:**  
`Browser → Servlet → Service → DAO → DBConnection (Singleton) → MySQL`  
Response: `DAO → Service → Servlet → JSP → Browser`

---

## 3. Actors & System Roles

| Actor             | Description                                                                                                       |
|-------------------|-------------------------------------------------------------------------------------------------------------------|
| **Front Desk Staff**  | Logs in, adds/views reservations, views guests, calculates bills, manages room status. Default role: `staff`  |
| **Manager**           | Same access as Staff plus can view full financial reports and analytics. Role: `manager`                      |
| **Admin**             | Full system access, manages users and all modules. Role: `admin`                                              |
| **MySQL Database**    | External system actor — stores and retrieves all persistent data via JDBC                                     |
| **Tomcat Container**  | External system actor — hosts the WAR, manages servlet lifecycle, fires `DBInitializer` on startup            |

> **Assumption:** All three human actors (Staff, Manager, Admin) share the same login page and the same set of screens. Role differentiation is stored in the `users.role` column but UI-level role-based access control (hiding/showing features per role) is not yet enforced — all authenticated users see all modules.

---

## 4. Use Case Diagram

```mermaid
%%{init: {"theme": "default", "flowchart": {"curve": "linear"}}}%%
flowchart LR
    %% Actors
    Staff(["👤 Front Desk Staff"])
    Manager(["👤 Manager"])
    Admin(["👤 Admin"])
    DB(["🗄️ MySQL Database"])
    Tomcat(["⚙️ Tomcat Container"])

    %% ── Authentication ──────────────────────────────
    subgraph AUTH["🔐 Authentication"]
        UC1["Login"]
        UC2["Logout"]
        UC3["Exit System"]
    end

    %% ── Reservations ─────────────────────────────────
    subgraph RES["📋 Reservations"]
        UC4["View Reservation List"]
        UC5["Add New Reservation"]
        UC6["View Reservation Details"]
    end

    %% ── Billing ──────────────────────────────────────
    subgraph BILL["💳 Billing"]
        UC7["Calculate Bill"]
        UC8["Print Invoice"]
    end

    %% ── Room Management ──────────────────────────────
    subgraph ROOM["🏨 Room Management"]
        UC9["View Room Availability"]
        UC10["Update Room Status"]
    end

    %% ── Guests ───────────────────────────────────────
    subgraph GUEST["👥 Guests"]
        UC11["View Guest Profiles"]
        UC12["Search Guests"]
    end

    %% ── Payments ─────────────────────────────────────
    subgraph PAY["💰 Payments"]
        UC13["View Payment Summary"]
        UC14["View Invoice Link"]
    end

    %% ── Reports ──────────────────────────────────────
    subgraph RPT["📊 Reports"]
        UC15["View KPI Dashboard"]
        UC16["View Revenue by Room Type"]
        UC17["View Bookings by Status"]
    end

    %% ── Help ─────────────────────────────────────────
    subgraph HLP["❓ Help"]
        UC18["View Staff Help Guide"]
    end

    %% ── System Init ──────────────────────────────────
    subgraph SYS["⚙️ System"]
        UC19["Initialize DB Tables"]
        UC20["Seed Sample Data"]
    end

    %% ── Staff associations
    Staff --> UC1
    Staff --> UC2
    Staff --> UC3
    Staff --> UC4
    Staff --> UC5
    Staff --> UC6
    Staff --> UC7
    Staff --> UC8
    Staff --> UC9
    Staff --> UC10
    Staff --> UC11
    Staff --> UC12
    Staff --> UC13
    Staff --> UC14
    Staff --> UC18

    %% ── Manager extends Staff
    Manager --> UC1
    Manager --> UC15
    Manager --> UC16
    Manager --> UC17
    Manager --> UC4
    Manager --> UC5
    Manager --> UC6
    Manager --> UC7
    Manager --> UC8
    Manager --> UC9
    Manager --> UC10
    Manager --> UC11
    Manager --> UC13

    %% ── Admin extends Manager
    Admin --> UC1
    Admin --> UC15
    Admin --> UC16
    Admin --> UC17
    Admin --> UC19
    Admin --> UC20

    %% ── System actors
    Tomcat --> UC19
    Tomcat --> UC20
    UC19 --> DB
    UC20 --> DB
    UC1  --> DB
    UC4  --> DB
    UC5  --> DB
    UC6  --> DB
    UC7  --> DB
    UC9  --> DB
    UC10 --> DB
    UC11 --> DB
    UC13 --> DB
    UC15 --> DB
```

---

## 5. Class Diagram

```mermaid
classDiagram
    direction TB

    %% ═══════════════════════════════════
    %%  DB Layer
    %% ═══════════════════════════════════
    class DBConnection {
        -String URL
        -String USER
        -String PASSWORD
        -static DBConnection instance
        -Connection connection
        -DBConnection()
        +static synchronized getInstance() DBConnection
        -static isConnectionClosed() boolean
        +getConnection() Connection
    }

    class DBInitializer {
        +contextInitialized(ServletContextEvent) void
        +contextDestroyed(ServletContextEvent) void
    }

    %% ═══════════════════════════════════
    %%  Model Layer
    %% ═══════════════════════════════════
    class User {
        -int id
        -String username
        -String password
        -String role
        -String email
        -String fullName
        +getId() int
        +getUsername() String
        +getRole() String
        +getFullName() String
    }

    class Reservation {
        -int id
        -String reservationNumber
        -String guestName
        -String address
        -String contactNumber
        -String roomType
        -Date checkInDate
        -Date checkOutDate
        -String status
        -Date createdAt
        +getReservationNumber() String
        +getGuestName() String
        +getRoomType() String
        +getStatus() String
    }

    class Room {
        -int id
        -String roomNumber
        -String roomType
        -int floor
        -int capacity
        -double pricePerNight
        -String status
        -String description
        +getRoomNumber() String
        +getStatus() String
        +getPricePerNight() double
    }

    class Guest {
        -String guestName
        -String contactNumber
        -String address
        -int totalReservations
        -Date lastVisit
        -String lastRoomType
        -String lastStatus
        +getGuestName() String
        +getTotalReservations() int
    }

    class Bill {
        +double TAX_RATE = 0.10
        +double SERVICE_RATE = 0.05
        -Reservation reservation
        -double ratePerNight
        -long nights
        -double subtotal
        -double taxAmount
        -double serviceChargeAmount
        -double grandTotal
        +getGrandTotal() double
        +getNights() long
    }

    class RoomRates {
        -static Map~String,Double~ RATES
        +static getRate(String roomType) double
    }

    %% ═══════════════════════════════════
    %%  DAO Interfaces
    %% ═══════════════════════════════════
    class UserDAO {
        <<interface>>
        +findByUsernameAndPassword(String, String) User
        +findByUsername(String) User
    }

    class ReservationDAO {
        <<interface>>
        +save(Reservation) int
        +findAll() List~Reservation~
        +findById(int) Reservation
        +findByReservationNumber(String) Reservation
        +count() int
    }

    class RoomDAO {
        <<interface>>
        +findAll() List~Room~
        +findById(int) Room
        +save(Room) int
        +updateStatus(int, String) boolean
        +countByStatus(String) int
    }

    class GuestDAO {
        <<interface>>
        +findAllGuests() List~Guest~
        +countUniqueGuests() int
    }

    %% ═══════════════════════════════════
    %%  DAO Implementations
    %% ═══════════════════════════════════
    class UserDAOImpl {
        -Connection connection
        +findByUsernameAndPassword(String, String) User
        +findByUsername(String) User
    }

    class ReservationDAOImpl {
        -Connection connection
        +save(Reservation) int
        +findAll() List~Reservation~
        +findById(int) Reservation
        +findByReservationNumber(String) Reservation
        +count() int
    }

    class RoomDAOImpl {
        -Connection connection
        +findAll() List~Room~
        +findById(int) Room
        +save(Room) int
        +updateStatus(int, String) boolean
        +countByStatus(String) int
    }

    class GuestDAOImpl {
        -Connection connection
        +findAllGuests() List~Guest~
        +countUniqueGuests() int
    }

    %% ═══════════════════════════════════
    %%  Service Interfaces
    %% ═══════════════════════════════════
    class UserService {
        <<interface>>
        +login(String, String) User
    }

    class ReservationService {
        <<interface>>
        +addReservation(String, String, String, String, String, String) boolean
        +getAllReservations() List~Reservation~
        +getReservationById(int) Reservation
    }

    class RoomService {
        <<interface>>
        +getAllRooms() List~Room~
        +getRoomById(int) Room
        +updateRoomStatus(int, String) boolean
        +countByStatus(String) int
    }

    class GuestService {
        <<interface>>
        +getAllGuests() List~Guest~
        +countUniqueGuests() int
    }

    class BillService {
        <<interface>>
        +calculateBill(int) Bill
    }

    class ReportService {
        <<interface>>
        +totalReservations() int
        +reservationsByStatus() Map
        +revenueByRoomType() Map
        +reservationsByRoomType() Map
        +totalRevenue() double
        +totalGuests() int
        +totalRooms() int
        +availableRooms() int
    }

    %% ═══════════════════════════════════
    %%  Service Implementations
    %% ═══════════════════════════════════
    class UserServiceImpl {
        -UserDAO userDAO
        +login(String, String) User
    }

    class ReservationServiceImpl {
        -ReservationDAO reservationDAO
        +addReservation(...) boolean
        +getAllReservations() List~Reservation~
        +getReservationById(int) Reservation
    }

    class RoomServiceImpl {
        -RoomDAO roomDAO
        +getAllRooms() List~Room~
        +updateRoomStatus(int, String) boolean
        +countByStatus(String) int
    }

    class GuestServiceImpl {
        -GuestDAO guestDAO
        +getAllGuests() List~Guest~
        +countUniqueGuests() int
    }

    class BillServiceImpl {
        -ReservationDAO reservationDAO
        +calculateBill(int) Bill
    }

    class ReportServiceImpl {
        -Connection connection
        -GuestDAO guestDAO
        -RoomDAO roomDAO
        +totalReservations() int
        +totalRevenue() double
        +revenueByRoomType() Map
        +reservationsByStatus() Map
    }

    %% ═══════════════════════════════════
    %%  Servlet Layer
    %% ═══════════════════════════════════
    class LoginServlet {
        +doGet(req, res) void
        +doPost(req, res) void
    }

    class DashboardServlet {
        +doGet(req, res) void
    }

    class ReservationServlet {
        -ReservationService reservationService
        +doGet(req, res) void
        +doPost(req, res) void
    }

    class RoomServlet {
        -RoomService roomService
        +doGet(req, res) void
        +doPost(req, res) void
    }

    class GuestServlet {
        -GuestService guestService
        +doGet(req, res) void
    }

    class PaymentServlet {
        -ReservationService reservationService
        -BillService billService
        +doGet(req, res) void
    }

    class BillServlet {
        -BillService billService
        +doGet(req, res) void
    }

    class ReportServlet {
        -ReportService reportService
        +doGet(req, res) void
    }

    class HelpServlet {
        +doGet(req, res) void
    }

    class LogoutServlet {
        +doGet(req, res) void
    }

    class ExitServlet {
        +doGet(req, res) void
    }

    %% ═══════════════════════════════════
    %%  Relationships
    %% ═══════════════════════════════════

    %% Singleton
    DBInitializer ..> DBConnection : uses

    %% DAO impl → DBConnection
    UserDAOImpl       ..> DBConnection : uses
    ReservationDAOImpl ..> DBConnection : uses
    RoomDAOImpl       ..> DBConnection : uses
    GuestDAOImpl      ..> DBConnection : uses
    ReportServiceImpl ..> DBConnection : uses

    %% DAO impl → interface
    UserDAOImpl        ..|> UserDAO
    ReservationDAOImpl ..|> ReservationDAO
    RoomDAOImpl        ..|> RoomDAO
    GuestDAOImpl       ..|> GuestDAO

    %% Service impl → interface
    UserServiceImpl       ..|> UserService
    ReservationServiceImpl ..|> ReservationService
    RoomServiceImpl        ..|> RoomService
    GuestServiceImpl       ..|> GuestService
    BillServiceImpl        ..|> BillService
    ReportServiceImpl      ..|> ReportService

    %% Service → DAO
    UserServiceImpl       --> UserDAO
    ReservationServiceImpl --> ReservationDAO
    RoomServiceImpl        --> RoomDAO
    GuestServiceImpl       --> GuestDAO
    BillServiceImpl        --> ReservationDAO
    ReportServiceImpl      --> GuestDAO
    ReportServiceImpl      --> RoomDAO

    %% Servlet → Service
    LoginServlet      --> UserService
    ReservationServlet --> ReservationService
    RoomServlet        --> RoomService
    GuestServlet       --> GuestService
    PaymentServlet     --> ReservationService
    PaymentServlet     --> BillService
    BillServlet        --> BillService
    ReportServlet      --> ReportService

    %% Bill → Reservation
    Bill --> Reservation : contains
    Bill ..> RoomRates   : uses

    %% Guest derived from Reservation (conceptual)
    GuestDAOImpl ..> Reservation : queries
```

---

## 6. Sequence Diagrams

### 6.1 Login

```mermaid
sequenceDiagram
    actor User as Staff / Manager / Admin
    participant B  as Browser
    participant LS as LoginServlet
    participant US as UserServiceImpl
    participant UD as UserDAOImpl
    participant DB as MySQL (ocean)

    User ->> B  : Navigate to /login
    B    ->> LS : GET /login
    LS   ->> B  : Forward → login.jsp (empty form)

    User ->> B  : Enter username + password → Submit
    B    ->> LS : POST /login (username, password)
    LS   ->> US : login(username, password)
    US   ->> UD : findByUsernameAndPassword(username, password)
    UD   ->> DB : SELECT * FROM users WHERE username=? AND password=?
    DB   -->> UD : ResultSet (User row or empty)

    alt Credentials valid
        UD  -->> US : User object
        US  -->> LS : User object
        LS  ->> LS  : session.setAttribute("loggedUser", user)
        LS  ->> B   : Redirect → /dashboard
        B   ->> B   : Display dashboard
    else Credentials invalid
        UD  -->> US : null
        US  -->> LS : null
        LS  ->> LS  : request.setAttribute("errorMessage", ...)
        LS  ->> B   : Forward → login.jsp (with error)
        B   ->> User: Show "Invalid credentials" message
    end
```

---

### 6.2 Add New Reservation

```mermaid
sequenceDiagram
    actor Staff
    participant B   as Browser
    participant RS  as ReservationServlet
    participant RSS as ReservationServiceImpl
    participant RD  as ReservationDAOImpl
    participant DB  as MySQL (ocean)

    Staff ->> B  : Click "Add Reservation" on dashboard
    B     ->> RS : GET /reservations/add
    RS    ->> RS : Auth guard – check session
    RS    ->> B  : Forward → add-reservation.jsp (blank form)

    Staff ->> B  : Fill form + Submit
    B     ->> RS : POST /reservations/add (guestName, address, contactNumber, roomType, checkIn, checkOut)

    RS    ->> RSS : addReservation(...)
    RSS   ->> RD  : count()
    RD    ->> DB  : SELECT COUNT(*) FROM reservations
    DB   -->> RD  : count (e.g. 5)
    RD   -->> RSS : 5

    RSS   ->> RSS : Generate resNumber = "RES-2026-0006"
    RSS   ->> RSS : Validate checkOut > checkIn

    alt Validation passes
        RSS  ->> RD  : save(Reservation)
        RD   ->> DB  : INSERT INTO reservations (...)
        DB  -->> RD  : Generated key
        RD  -->> RSS : newId
        RSS -->> RS  : true
        RS   ->> B   : Redirect → /reservations?success=1
        B    ->> Staff: Show success banner on reservations list
    else Validation fails
        RSS -->> RS  : false
        RS   ->> B   : Forward → add-reservation.jsp (errorMessage)
        B   ->> Staff: Show error under form
    end
```

---

### 6.3 View Reservation Details

```mermaid
sequenceDiagram
    actor Staff
    participant B   as Browser
    participant RS  as ReservationServlet
    participant RSS as ReservationServiceImpl
    participant RD  as ReservationDAOImpl
    participant DB  as MySQL (ocean)

    Staff ->> B  : Click "View" on reservations table
    B     ->> RS : GET /reservations/view?id=7
    RS    ->> RS : Auth guard
    RS    ->> RSS : getReservationById(7)
    RSS   ->> RD  : findById(7)
    RD    ->> DB  : SELECT * FROM reservations WHERE id=7
    DB   -->> RD  : Reservation row
    RD   -->> RSS : Reservation object
    RSS  -->> RS  : Reservation object

    alt Found
        RS   ->> RS  : request.setAttribute("reservation", r)
        RS   ->> B   : Forward → reservation-details.jsp
        B   ->> Staff : Display full details + action buttons
    else Not found
        RS   ->> B   : Redirect → /reservations?notfound=1
    end
```

---

### 6.4 Calculate & Print Bill

```mermaid
sequenceDiagram
    actor Staff
    participant B   as Browser
    participant BS  as BillServlet
    participant BSI as BillServiceImpl
    participant RD  as ReservationDAOImpl
    participant DB  as MySQL (ocean)

    Staff ->> B  : Click "Calculate & Print Bill" on reservation-details.jsp
    B     ->> BS : GET /reservations/bill?id=7
    BS    ->> BSI : calculateBill(7)
    BSI   ->> RD  : findById(7)
    RD    ->> DB  : SELECT * FROM reservations WHERE id=7
    DB   -->> RD  : Reservation row
    RD   -->> BSI : Reservation object

    BSI   ->> BSI : nights = checkOutDate – checkInDate
    BSI   ->> BSI : rate = RoomRates.getRate(roomType)
    BSI   ->> BSI : subtotal = rate × nights
    BSI   ->> BSI : tax = subtotal × 10%
    BSI   ->> BSI : service = subtotal × 5%
    BSI   ->> BSI : grandTotal = subtotal + tax + service
    BSI  -->> BS  : Bill object

    BS    ->> BS  : request.setAttribute("bill", bill)
    BS    ->> B   : Forward → bill.jsp
    B    ->> Staff : Display printable invoice

    Staff ->> B  : Click "Print"
    B    ->> B   : window.print() → browser print dialog
```

---

### 6.5 Update Room Status

```mermaid
sequenceDiagram
    actor Staff
    participant B   as Browser
    participant RmS as RoomServlet
    participant RmSI as RoomServiceImpl
    participant RmD as RoomDAOImpl
    participant DB  as MySQL (ocean)

    Staff ->> B    : GET /rooms
    B     ->> RmS  : GET /rooms
    RmS   ->> RmSI : getAllRooms()
    RmSI  ->> RmD  : findAll()
    RmD   ->> DB   : SELECT * FROM rooms ORDER BY room_number
    DB   -->> RmD  : Room rows
    RmD  -->> RmSI : List~Room~
    RmSI -->> RmS  : List~Room~
    RmS   ->> B    : Forward → rooms.jsp (shows table with status dropdowns)

    Staff ->> B    : Change dropdown → Click "Save"
    B     ->> RmS  : POST /rooms (action=updateStatus, roomId=5, status=Occupied)
    RmS   ->> RmSI : updateRoomStatus(5, "Occupied")
    RmSI  ->> RmSI : Validate status in [Available, Occupied, Maintenance]
    RmSI  ->> RmD  : updateStatus(5, "Occupied")
    RmD   ->> DB   : UPDATE rooms SET status='Occupied' WHERE id=5
    DB   -->> RmD  : 1 row affected
    RmD  -->> RmSI : true
    RmSI -->> RmS  : true
    RmS   ->> B    : Redirect → /rooms?updated=1
    B    ->> Staff : Show "Room status updated" success alert
```

---

### 6.6 View Reports (Analytics Dashboard)

```mermaid
sequenceDiagram
    actor Manager
    participant B    as Browser
    participant RpS  as ReportServlet
    participant RpSI as ReportServiceImpl
    participant DB   as MySQL (ocean)

    Manager ->> B    : Click "Reports" on dashboard
    B       ->> RpS  : GET /reports
    RpS     ->> RpSI : totalReservations()
    RpSI    ->> DB   : SELECT COUNT(*) FROM reservations
    DB     -->> RpSI : count

    RpS     ->> RpSI : totalRevenue()
    RpSI    ->> DB   : SELECT room_type, SUM(DATEDIFF(...)) … GROUP BY room_type
    DB     -->> RpSI : rows → compute rate × nights × 1.15

    RpS     ->> RpSI : reservationsByStatus()
    RpSI    ->> DB   : SELECT status, COUNT(*) … GROUP BY status
    DB     -->> RpSI : Map~String, Long~

    RpS     ->> RpSI : reservationsByRoomType()
    RpSI    ->> DB   : SELECT room_type, COUNT(*) … GROUP BY room_type
    DB     -->> RpSI : Map~String, Long~

    RpS     ->> RpSI : totalGuests() / totalRooms() / availableRooms()
    RpSI    ->> DB   : COUNT(DISTINCT contact_number) + rooms queries
    DB     -->> RpSI : numeric values

    RpS     ->> B    : Forward → reports.jsp (KPI cards + Chart.js data)
    B       ->> B    : Render doughnut + bar charts via Chart.js CDN
    B      ->> Manager : Display analytics dashboard
```

---

### 6.7 Exit System

```mermaid
sequenceDiagram
    actor Staff
    participant B   as Browser
    participant ES  as ExitServlet

    Staff ->> B  : Click "Exit System" → confirm() dialog
    B    ->> B   : Browser confirm dialog: "Exit and end your session?"

    alt Confirmed
        B    ->> ES : GET /exit
        ES   ->> ES : Capture session.getAttribute("loggedUser").fullName
        ES   ->> ES : session.invalidate()
        ES   ->> ES : request.setAttribute("exitUserName", name)
        ES   ->> B  : Forward → exit.jsp
        B   ->> Staff : Goodbye screen (username, timestamp, "Log In Again")
    else Cancelled
        B   ->> Staff : Stay on current page
    end
```

---

## 7. Design Patterns Used

### 7.1 Singleton – `DBConnection`

```
Problem:  Creating a new JDBC connection per request is expensive and
          leads to connection pool exhaustion.
Solution: DBConnection holds ONE static instance with a synchronized
          getInstance() factory method. A closed-connection check
          (isConnectionClosed()) allows automatic reconnection.
```

```mermaid
classDiagram
    class DBConnection {
        -static DBConnection instance
        -Connection connection
        -DBConnection()
        +static synchronized getInstance() DBConnection
        -static isConnectionClosed() boolean
        +getConnection() Connection
    }
    DBConnection --> DBConnection : self-reference (singleton)
```

---

### 7.2 Service-Oriented Architecture (SOA) Layering

Each functional module is split into three clear layers:

| Layer            | Responsibility                                   | Example                          |
|------------------|--------------------------------------------------|----------------------------------|
| **Servlet**      | HTTP request handling, session auth guard        | `ReservationServlet`             |
| **Service**      | Business logic, validation, number generation    | `ReservationServiceImpl`         |
| **DAO**          | SQL queries, result mapping                      | `ReservationDAOImpl`             |

Each layer communicates **only with the layer directly below it** — a Servlet never calls a DAO directly.

---

### 7.3 MVC (Model-View-Controller) via Servlet + JSP

| MVC Role       | Technology                    |
|----------------|-------------------------------|
| **Model**      | POJOs: `User`, `Reservation`, `Room`, `Guest`, `Bill` |
| **View**       | JSP pages (login.jsp, dashboard.jsp, reservations.jsp, …) |
| **Controller** | HttpServlet subclasses        |

---

### 7.4 Strategy Pattern (implicit) – `RoomRates`

`RoomRates` uses a static `Map<String, Double>` to decouple room-type pricing from the billing algorithm. Adding or changing a rate requires modifying only `RoomRates.java`, not `BillServiceImpl`.

---

### 7.5 Listener / Init Pattern – `DBInitializer`

`DBInitializer` implements `ServletContextListener` annotated with `@WebListener`. Tomcat fires `contextInitialized()` on deployment before any HTTP request arrives, executing `CREATE TABLE IF NOT EXISTS` plus seed data — decoupling schema management from runtime request handling.

---

## 8. Database Schema

```mermaid
erDiagram
    users {
        INT        id           PK  "AUTO_INCREMENT"
        VARCHAR50  username         "UNIQUE NOT NULL"
        VARCHAR255 password         "NOT NULL"
        VARCHAR20  role             "default: staff"
        VARCHAR100 email
        VARCHAR100 full_name
        TIMESTAMP  created_at       "DEFAULT CURRENT_TIMESTAMP"
    }

    reservations {
        INT        id           PK  "AUTO_INCREMENT"
        VARCHAR20  reservation_number "UNIQUE NOT NULL"
        VARCHAR100 guest_name       "NOT NULL"
        VARCHAR255 address
        VARCHAR20  contact_number   "NOT NULL"
        VARCHAR50  room_type        "NOT NULL"
        DATE       check_in_date    "NOT NULL"
        DATE       check_out_date   "NOT NULL"
        VARCHAR20  status           "PENDING|CONFIRMED|CANCELLED|CHECKED_OUT"
        TIMESTAMP  created_at
    }

    rooms {
        INT         id           PK  "AUTO_INCREMENT"
        VARCHAR10   room_number      "UNIQUE NOT NULL"
        VARCHAR50   room_type        "NOT NULL"
        INT         floor
        INT         capacity
        DECIMAL1002 price_per_night  "NOT NULL"
        VARCHAR20   status           "Available|Occupied|Maintenance"
        VARCHAR255  description
        TIMESTAMP   created_at
    }

    users       ||--o{ reservations : "staff manages"
    rooms       ||--o{ reservations : "booked as room_type"
```

> **Note:** `reservations.room_type` stores the type name (e.g. `"Deluxe"`) rather than a foreign key to `rooms.id`. This is intentional — a guest books a room *type*, not a specific physical room. The `rooms` table tracks physical inventory separately.

---

## 9. Assumptions

| # | Assumption |
|---|------------|
| 1 | **No password hashing** — passwords are stored and compared as plain text. This is acceptable for a prototype/internal tool but must be upgraded (e.g., BCrypt) before production. |
| 2 | **Single shared DB connection** — the Singleton pattern reuses one JDBC connection. This is not thread-safe under concurrent load. In production, a JNDI connection pool (e.g., HikariCP, Tomcat DBCP) should replace it. |
| 3 | **Role-based access is display-only** — all three roles (admin, manager, staff) see identical screens. The `role` field is stored but no servlet enforces route-level restrictions. |
| 4 | **Guest is derived, not stored** — there is no dedicated `guests` table. `GuestDAOImpl` aggregates rows from the `reservations` table, grouping by `contact_number`. A guest's "profile" exists only if they have at least one reservation. |
| 5 | **Room type, not room number, is booked** — reservations reference a room category (e.g., "Ocean View Suite") rather than a specific room number. Physical room assignment happens offline. |
| 6 | **Bill rates are hard-coded** in `RoomRates.java`. Changing a rate requires a redeployment. A future enhancement would move rates to the `rooms` table. |
| 7 | **Billing is always computed on-the-fly** — no `payments` or `bills` table exists. All financial figures are calculated from `reservations` + `RoomRates` on every request. |
| 8 | **Session timeout is 30 minutes** — configured in `web.xml`. Expired sessions redirect automatically to `/login` via the auth guard in each servlet. |
| 9 | **DBInitializer seeds 13 rooms** on first deployment using `INSERT IGNORE`. If sample rooms are deleted, re-seeding does not occur unless the Tomcat process is restarted. |
| 10 | **Chart.js is loaded from CDN** — `reports.jsp` requires an internet connection to render charts. An offline installation would need the library bundled locally. |
