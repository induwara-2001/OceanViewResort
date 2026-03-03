<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.example.oceanviewresort.model.User" %>
<%
    User loggedUser = (User) session.getAttribute("loggedUser");
    if (loggedUser == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    // Helper to keep form values on error
    String vGuestName     = request.getAttribute("guestName")     != null ? (String) request.getAttribute("guestName")     : "";
    String vAddress       = request.getAttribute("address")       != null ? (String) request.getAttribute("address")       : "";
    String vContactNumber = request.getAttribute("contactNumber") != null ? (String) request.getAttribute("contactNumber") : "";
    String vRoomType      = request.getAttribute("roomType")      != null ? (String) request.getAttribute("roomType")      : "";
    String vCheckIn       = request.getAttribute("checkInDate")   != null ? (String) request.getAttribute("checkInDate")   : "";
    String vCheckOut      = request.getAttribute("checkOutDate")  != null ? (String) request.getAttribute("checkOutDate")  : "";
    String error          = (String) request.getAttribute("errorMessage");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Add Reservation - Ocean View Resort</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: #f0f4f8;
            color: #333;
        }

        /* Navbar */
        .navbar {
            background: linear-gradient(135deg, #0a4d68, #088395);
            color: white;
            padding: 0 30px;
            height: 65px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            box-shadow: 0 3px 12px rgba(0,0,0,0.2);
        }
        .navbar .brand { font-size: 1.3rem; font-weight: 700; }
        .navbar-links { display: flex; align-items: center; gap: 20px; }
        .navbar-links a {
            color: rgba(255,255,255,0.85);
            text-decoration: none;
            font-size: 0.9rem;
            transition: color 0.2s;
        }
        .navbar-links a:hover { color: white; }
        .btn-logout {
            background: rgba(255,255,255,0.2);
            color: white;
            border: 1px solid rgba(255,255,255,0.5);
            padding: 7px 16px;
            border-radius: 8px;
            cursor: pointer;
            text-decoration: none;
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
            background: linear-gradient(135deg, #0a4d68, #088395);
            color: white;
            padding: 22px 30px;
        }
        .card-header h2 { font-size: 1.4rem; font-weight: 600; }
        .card-header p  { font-size: 0.85rem; opacity: 0.85; margin-top: 4px; }

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
        .form-group textarea:focus {
            border-color: #088395;
        }
        .form-group textarea { resize: vertical; min-height: 80px; }

        /* Divider */
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
            background: linear-gradient(135deg, #0a4d68, #088395);
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

        @media (max-width: 600px) {
            .form-grid { grid-template-columns: 1fr; }
            .form-grid .full-width { grid-column: 1; }
        }
    </style>
</head>
<body>

<!-- Navbar -->
<nav class="navbar">
    <div class="brand">&#127754; Ocean View Resort</div>
    <div class="navbar-links">
        <a href="<%= request.getContextPath() %>/dashboard">Dashboard</a>
        <a href="<%= request.getContextPath() %>/reservations">Reservations</a>
        <a href="<%= request.getContextPath() %>/help">Help</a>
        <a href="<%= request.getContextPath() %>/logout" class="btn-logout">Logout</a>
        <a href="javascript:void(0)"
           onclick="if(confirm('Exit the system? Your session will end.')) location.href='<%= request.getContextPath() %>/exit'"
           style="background:rgba(220,53,69,0.25);color:white;border:1px solid rgba(220,53,69,0.6);
                  padding:7px 16px;border-radius:8px;cursor:pointer;font-size:0.85rem;
                  font-weight:600;text-decoration:none;">
            &#x23FB; Exit System
        </a>
    </div>
</nav>

<!-- Content -->
<div class="container">

    <div class="breadcrumb">
        <a href="<%= request.getContextPath() %>/dashboard">Dashboard</a> &rsaquo;
        <a href="<%= request.getContextPath() %>/reservations">Reservations</a> &rsaquo;
        Add New Reservation
    </div>

    <div class="card">
        <div class="card-header">
            <h2>&#128203; Add New Reservation</h2>
            <p>Fill in the guest and booking details below</p>
        </div>

        <div class="card-body">

            <% if (error != null) { %>
            <div class="error-box"><%= error %></div>
            <% } %>

            <form method="post" action="<%= request.getContextPath() %>/reservations/add">
                <div class="form-grid">

                    <!-- Guest Details section -->
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

                    <!-- Booking Details section -->
                    <div class="section-title">Booking Details</div>

                    <div class="form-group full-width">
                        <label for="roomType">Room Type *</label>
                        <select id="roomType" name="roomType" required>
                            <option value="" disabled <%= vRoomType.isEmpty() ? "selected" : "" %>>-- Select Room Type --</option>
                            <option value="Standard Room"           <%= "Standard Room".equals(vRoomType)           ? "selected" : "" %>>Standard Room</option>
                            <option value="Deluxe Room"             <%= "Deluxe Room".equals(vRoomType)             ? "selected" : "" %>>Deluxe Room</option>
                            <option value="Superior Room"           <%= "Superior Room".equals(vRoomType)           ? "selected" : "" %>>Superior Room</option>
                            <option value="Ocean View Suite"        <%= "Ocean View Suite".equals(vRoomType)        ? "selected" : "" %>>Ocean View Suite</option>
                            <option value="Family Room"             <%= "Family Room".equals(vRoomType)             ? "selected" : "" %>>Family Room</option>
                            <option value="Presidential Suite"      <%= "Presidential Suite".equals(vRoomType)      ? "selected" : "" %>>Presidential Suite</option>
                            <option value="Penthouse Suite"         <%= "Penthouse Suite".equals(vRoomType)         ? "selected" : "" %>>Penthouse Suite</option>
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
                    <button type="submit" class="btn-primary">&#10003; Save Reservation</button>
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
</script>

</body>
</html>
