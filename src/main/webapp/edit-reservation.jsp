<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.example.oceanviewresort.model.User" %>
<%@ page import="com.example.oceanviewresort.model.Reservation" %>
<%
    User loggedUser = (User) session.getAttribute("loggedUser");
    if (loggedUser == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    Reservation r = (Reservation) request.getAttribute("reservation");
    if (r == null) {
        response.sendRedirect(request.getContextPath() + "/reservations");
        return;
    }

    // On validation error, restore attempted values; otherwise fall back to DB values
    String vGuestName     = request.getAttribute("formGuestName")     != null ? (String) request.getAttribute("formGuestName")     : (r.getGuestName()     != null ? r.getGuestName()     : "");
    String vAddress       = request.getAttribute("formAddress")       != null ? (String) request.getAttribute("formAddress")       : (r.getAddress()       != null ? r.getAddress()       : "");
    String vContactNumber = request.getAttribute("formContactNumber") != null ? (String) request.getAttribute("formContactNumber") : (r.getContactNumber() != null ? r.getContactNumber() : "");
    String vGuestEmail    = request.getAttribute("formGuestEmail")    != null ? (String) request.getAttribute("formGuestEmail")    : (r.getGuestEmail()    != null ? r.getGuestEmail()    : "");
    String vRoomType      = request.getAttribute("formRoomType")      != null ? (String) request.getAttribute("formRoomType")      : (r.getRoomType()      != null ? r.getRoomType()      : "");
    String vCheckIn       = request.getAttribute("formCheckInDate")   != null ? (String) request.getAttribute("formCheckInDate")   : (r.getCheckInDate()  != null ? r.getCheckInDate().toString()  : "");
    String vCheckOut      = request.getAttribute("formCheckOutDate")  != null ? (String) request.getAttribute("formCheckOutDate")  : (r.getCheckOutDate() != null ? r.getCheckOutDate().toString() : "");
    String vStatus        = request.getAttribute("formStatus")        != null ? (String) request.getAttribute("formStatus")        : (r.getStatus()        != null ? r.getStatus()        : "PENDING");
    String error          = (String) request.getAttribute("errorMessage");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Reservation — Ocean View Resort</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        *, *::before, *::after { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            font-family: 'Inter', 'Segoe UI', sans-serif;
            background: #f1f5f9;
            color: #1e293b;
        }

        /* Navbar */
        .navbar {
            background: linear-gradient(135deg, #0a2540 0%, #0a4d68 60%, #088395 100%);
            height: 68px; padding: 0 36px;
            display: flex; align-items: center; justify-content: space-between;
            position: sticky; top: 0; z-index: 200;
            box-shadow: 0 2px 20px rgba(10,37,64,0.4);
        }
        .navbar-left { display: flex; align-items: center; gap: 14px; }
        .nav-logo {
            width: 36px; height: 36px; border-radius: 9px;
            background: rgba(255,255,255,0.15); border: 1px solid rgba(255,255,255,0.25);
            display: flex; align-items: center; justify-content: center; font-size: 1.2rem;
        }
        .nav-brand { color: white; font-size: 1rem; font-weight: 700; letter-spacing: -0.3px; }
        .navbar-links { display: flex; align-items: center; gap: 4px; }
        .navbar-links a {
            color: rgba(255,255,255,0.75); text-decoration: none;
            font-size: 0.84rem; font-weight: 500; padding: 6px 12px; border-radius: 8px;
            transition: background 0.15s, color 0.15s;
        }
        .navbar-links a:hover { color: white; background: rgba(255,255,255,0.1); }
        .btn-logout {
            color: white; text-decoration: none;
            background: rgba(255,255,255,0.12); border: 1px solid rgba(255,255,255,0.25);
            font-size: 0.82rem; font-weight: 600; padding: 7px 16px; border-radius: 8px;
        }
        .btn-logout:hover { background: rgba(255,255,255,0.22); }
            font-size: 0.85rem;
        }

        /* Page container */
        .container {
            max-width: 780px;
            margin: 40px auto;
            padding: 0 20px;
        }

        /* Breadcrumb */
        .breadcrumb {
            font-size: 0.85rem;
            color: #888;
            margin-bottom: 20px;
        }
        .breadcrumb a { color: #088395; text-decoration: none; }
        .breadcrumb a:hover { text-decoration: underline; }

        /* Card */
        .card {
            background: white;
            border-radius: 16px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.08);
            overflow: hidden;
        }

        .card-header {
            background: linear-gradient(135deg, #0a5270, #0a9bb0);
            color: white;
            padding: 22px 30px;
            display: flex;
            align-items: center;
            gap: 16px;
        }
        .card-header .res-badge {
            background: rgba(255,255,255,0.18);
            border: 1px solid rgba(255,255,255,0.35);
            padding: 4px 14px;
            border-radius: 20px;
            font-size: 0.82rem;
            font-weight: 600;
            white-space: nowrap;
        }
        .card-header .header-text h2 { font-size: 1.4rem; font-weight: 600; }
        .card-header .header-text p  { font-size: 0.85rem; opacity: 0.85; margin-top: 4px; }

        .card-body { padding: 30px; }

        /* Error */
        .error-box {
            background: #fff0f0;
            border: 1px solid #f5c6c6;
            color: #c0392b;
            padding: 12px 16px;
            border-radius: 8px;
            font-size: 0.88rem;
            margin-bottom: 22px;
        }

        /* Form grid */
        .form-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
        }
        .form-grid .full-width { grid-column: 1 / -1; }

        .form-group { display: flex; flex-direction: column; gap: 6px; }
        .form-group label {
            font-size: 0.85rem;
            font-weight: 600;
            color: #444;
        }
        .form-group input,
        .form-group select,
        .form-group textarea {
            padding: 11px 14px;
            border: 2px solid #e0e0e0;
            border-radius: 10px;
            font-size: 0.93rem;
            color: #333;
            transition: border-color 0.25s;
            font-family: inherit;
            outline: none;
        }
        .form-group input:focus,
        .form-group select:focus,
        .form-group textarea:focus { border-color: #088395; }
        .form-group textarea { resize: vertical; min-height: 80px; }
        .form-group .read-only-field {
            padding: 11px 14px;
            background: #f5f7fa;
            border: 2px solid #e8ecf0;
            border-radius: 10px;
            font-size: 0.93rem;
            color: #666;
            font-weight: 600;
        }

        /* Section divider */
        .section-title {
            font-size: 0.8rem;
            font-weight: 700;
            color: #088395;
            text-transform: uppercase;
            letter-spacing: 1px;
            margin: 10px 0 4px;
            grid-column: 1 / -1;
            border-bottom: 1px solid #e9f5f7;
            padding-bottom: 6px;
        }

        /* Buttons */
        .btn-row {
            display: flex;
            gap: 12px;
            justify-content: flex-end;
            margin-top: 28px;
        }
        .btn-primary {
            background: linear-gradient(135deg, #0a5270, #0a9bb0);
            color: white;
            border: none;
            padding: 12px 28px;
            border-radius: 10px;
            font-size: 0.95rem;
            font-weight: 600;
            cursor: pointer;
            transition: opacity 0.2s, transform 0.1s;
        }
        .btn-primary:hover { opacity: 0.9; transform: translateY(-1px); }
        .btn-secondary {
            background: white;
            color: #555;
            border: 2px solid #ddd;
            padding: 12px 24px;
            border-radius: 10px;
            font-size: 0.95rem;
            cursor: pointer;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
        }
        .btn-secondary:hover { border-color: #aaa; }

        /* Status colours for select */
        select option[value="PENDING"]    { color: #f39c12; }
        select option[value="CONFIRMED"]  { color: #1a7a4a; }
        select option[value="CANCELLED"]  { color: #c0392b; }
        select option[value="CHECKED_OUT"]{ color: #3949ab; }

        @media (max-width: 600px) {
            .form-grid { grid-template-columns: 1fr; }
            .form-grid .full-width { grid-column: 1; }
        }
    </style>
</head>
<body>

<!-- Navbar -->
<nav class="navbar">
    <div class="navbar-left">
        <div class="nav-logo">&#127754;</div>
        <span class="nav-brand">Ocean View Resort</span>
    </div>
    <div class="navbar-links">
        <a href="<%= request.getContextPath() %>/dashboard">Dashboard</a>
        <a href="<%= request.getContextPath() %>/reservations" class="active">Reservations</a>
        <a href="<%= request.getContextPath() %>/rooms">Rooms</a>
        <a href="<%= request.getContextPath() %>/guests">Guests</a>
        <a href="<%= request.getContextPath() %>/payments">Payments</a>
        <a href="<%= request.getContextPath() %>/reports">Reports</a>
        <a href="<%= request.getContextPath() %>/help">Help</a>
        <a href="<%= request.getContextPath() %>/logout" class="btn-logout">Logout</a>
    </div>
</nav>

<!-- Content -->
<div class="container">

    <div class="breadcrumb">
        <a href="<%= request.getContextPath() %>/dashboard">Dashboard</a> &rsaquo;
        <a href="<%= request.getContextPath() %>/reservations">Reservations</a> &rsaquo;
        Edit Reservation
    </div>

    <div class="card">
        <div class="card-header">
            <div class="header-text">
                <h2>&#9998; Edit Reservation</h2>
                <p>Update guest and booking details below</p>
            </div>
            <span class="res-badge"><%= r.getReservationNumber() %></span>
        </div>

        <div class="card-body">

            <% if (error != null) { %>
            <div class="error-box">&#9888; <%= error %></div>
            <% } %>

            <form method="post" action="<%= request.getContextPath() %>/reservations/edit">
                <input type="hidden" name="id" value="<%= r.getId() %>">

                <div class="form-grid">

                    <!-- Guest Information -->
                    <div class="section-title">Guest Information</div>

                    <div class="form-group full-width">
                        <label for="guestName">Guest Full Name *</label>
                        <input type="text" id="guestName" name="guestName"
                               placeholder="e.g. John Doe"
                               value="<%= vGuestName %>" required>
                    </div>

                    <div class="form-group full-width">
                        <label for="address">Address</label>
                        <textarea id="address" name="address"
                                  placeholder="Street, City, Country"><%= vAddress %></textarea>
                    </div>

                    <div class="form-group">
                        <label for="contactNumber">Contact Number *</label>
                        <input type="tel" id="contactNumber" name="contactNumber"
                               placeholder="e.g. +94 77 123 4567"
                               value="<%= vContactNumber %>" required>
                    </div>

                    <div class="form-group">
                        <label for="guestEmail">Email Address
                            <span style="font-weight:400;color:#aaa;font-size:0.78rem;">(optional)</span>
                        </label>
                        <input type="email" id="guestEmail" name="guestEmail"
                               placeholder="e.g. guest@example.com"
                               value="<%= vGuestEmail %>">
                    </div>

                    <!-- Booking Details -->
                    <div class="section-title">Booking Details</div>

                    <div class="form-group">
                        <label>Reservation Number</label>
                        <div class="read-only-field"><%= r.getReservationNumber() %></div>
                    </div>

                    <div class="form-group">
                        <label for="status">Status *</label>
                        <select id="status" name="status" required>
                            <option value="PENDING"    <%= "PENDING".equals(vStatus)     ? "selected" : "" %>>PENDING</option>
                            <option value="CONFIRMED"  <%= "CONFIRMED".equals(vStatus)   ? "selected" : "" %>>CONFIRMED</option>
                            <option value="CANCELLED"  <%= "CANCELLED".equals(vStatus)   ? "selected" : "" %>>CANCELLED</option>
                            <option value="CHECKED_OUT"<%= "CHECKED_OUT".equals(vStatus) ? "selected" : "" %>>CHECKED OUT</option>
                        </select>
                    </div>

                    <div class="form-group full-width">
                        <label for="roomType">Room Type *</label>
                        <select id="roomType" name="roomType" required>
                            <option value="" disabled <%= vRoomType.isEmpty() ? "selected" : "" %>>-- Select Room Type --</option>
                            <option value="Standard Room"      <%= "Standard Room".equals(vRoomType)      ? "selected" : "" %>>Standard Room</option>
                            <option value="Deluxe Room"        <%= "Deluxe Room".equals(vRoomType)        ? "selected" : "" %>>Deluxe Room</option>
                            <option value="Superior Room"      <%= "Superior Room".equals(vRoomType)      ? "selected" : "" %>>Superior Room</option>
                            <option value="Ocean View Suite"   <%= "Ocean View Suite".equals(vRoomType)   ? "selected" : "" %>>Ocean View Suite</option>
                            <option value="Family Room"        <%= "Family Room".equals(vRoomType)        ? "selected" : "" %>>Family Room</option>
                            <option value="Presidential Suite" <%= "Presidential Suite".equals(vRoomType) ? "selected" : "" %>>Presidential Suite</option>
                            <option value="Penthouse Suite"    <%= "Penthouse Suite".equals(vRoomType)    ? "selected" : "" %>>Penthouse Suite</option>
                        </select>
                    </div>

                    <div class="form-group">
                        <label for="checkInDate">Check-In Date *</label>
                        <input type="date" id="checkInDate" name="checkInDate"
                               value="<%= vCheckIn %>" required>
                    </div>

                    <div class="form-group">
                        <label for="checkOutDate">Check-Out Date *</label>
                        <input type="date" id="checkOutDate" name="checkOutDate"
                               value="<%= vCheckOut %>" required>
                    </div>

                </div><!-- /form-grid -->

                <div class="btn-row">
                    <a href="<%= request.getContextPath() %>/reservations" class="btn-secondary">Cancel</a>
                    <button type="submit" class="btn-primary">&#10003; Save Changes</button>
                </div>
            </form>

        </div><!-- /card-body -->
    </div><!-- /card -->

</div><!-- /container -->

<script>
    // Ensure check-out is after check-in
    const checkIn  = document.getElementById('checkInDate');
    const checkOut = document.getElementById('checkOutDate');

    checkIn.addEventListener('change', function () {
        if (checkOut.value && checkOut.value <= checkIn.value) {
            checkOut.value = '';
        }
        checkOut.min = checkIn.value;
    });

    // Set initial min on page load
    if (checkIn.value) {
        checkOut.min = checkIn.value;
    }
</script>

</body>
</html>
