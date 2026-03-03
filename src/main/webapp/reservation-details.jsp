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

    // Calculate nights
    long nights = 0;
    if (r.getCheckInDate() != null && r.getCheckOutDate() != null) {
        nights = (r.getCheckOutDate().getTime() - r.getCheckInDate().getTime()) / (1000L * 60 * 60 * 24);
    }

    String status = r.getStatus() != null ? r.getStatus() : "PENDING";
    String badgeClass = "badge-pending";
    if ("CONFIRMED".equalsIgnoreCase(status))    badgeClass = "badge-confirmed";
    if ("CANCELLED".equalsIgnoreCase(status))    badgeClass = "badge-cancelled";
    if ("CHECKED_OUT".equalsIgnoreCase(status))  badgeClass = "badge-checked_out";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reservation Details - Ocean View Resort</title>
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
        .navbar-links  { display: flex; align-items: center; gap: 20px; }
        .navbar-links a { color: rgba(255,255,255,0.85); text-decoration: none; font-size: 0.9rem; }
        .navbar-links a:hover { color: white; }
        .btn-logout {
            background: rgba(255,255,255,0.2);
            color: white;
            border: 1px solid rgba(255,255,255,0.5);
            padding: 7px 16px;
            border-radius: 8px;
            text-decoration: none;
            font-size: 0.85rem;
        }

        /* Page */
        .container {
            max-width: 820px;
            margin: 38px auto;
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

        /* Top action bar */
        .action-bar {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 22px;
        }
        .action-bar h1 { font-size: 1.45rem; color: #0a4d68; }

        .btn-back {
            color: #088395;
            text-decoration: none;
            font-size: 0.9rem;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 5px;
        }
        .btn-back:hover { text-decoration: underline; }

        /* Status badge */
        .badge {
            display: inline-block;
            padding: 5px 14px;
            border-radius: 20px;
            font-size: 0.8rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        .badge-pending    { background: #fff8e1; color: #f39c12; }
        .badge-confirmed  { background: #e8f8f0; color: #1a7a4a; }
        .badge-cancelled  { background: #fdecea; color: #c0392b; }
        .badge-checked_out { background: #e8eaf6; color: #3949ab; }

        /* Card */
        .card {
            background: white;
            border-radius: 16px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.08);
            overflow: hidden;
            margin-bottom: 20px;
        }

        /* Card header bar */
        .card-header {
            background: linear-gradient(135deg, #0a4d68, #088395);
            color: white;
            padding: 20px 28px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 12px;
        }
        .card-header-left h2 { font-size: 1.15rem; font-weight: 700; }
        .card-header-left .res-num {
            font-size: 1.5rem;
            font-weight: 800;
            letter-spacing: 1px;
            margin-top: 2px;
        }

        /* Info grid */
        .info-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 0;
        }
        .info-section {
            padding: 24px 28px;
            border-bottom: 1px solid #f0f4f8;
        }
        .info-section:nth-child(odd) {
            border-right: 1px solid #f0f4f8;
        }
        .info-section.full-width {
            grid-column: 1 / -1;
            border-right: none;
        }
        .section-label {
            font-size: 0.72rem;
            font-weight: 700;
            color: #088395;
            text-transform: uppercase;
            letter-spacing: 1px;
            margin-bottom: 14px;
            display: flex;
            align-items: center;
            gap: 6px;
        }

        /* Field row */
        .field { margin-bottom: 12px; }
        .field:last-child { margin-bottom: 0; }
        .field-label {
            font-size: 0.78rem;
            color: #999;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 3px;
        }
        .field-value {
            font-size: 0.97rem;
            color: #222;
            font-weight: 500;
        }
        .field-value.large {
            font-size: 1.1rem;
            font-weight: 700;
            color: #0a4d68;
        }

        /* Stay summary strip */
        .stay-strip {
            background: linear-gradient(135deg, #e0f7fa, #e8f5e9);
            border-radius: 12px;
            padding: 18px 22px;
            display: flex;
            align-items: center;
            gap: 30px;
            flex-wrap: wrap;
            margin: 22px 28px;
        }
        .stay-item { text-align: center; }
        .stay-item .stay-val {
            font-size: 1.6rem;
            font-weight: 800;
            color: #0a4d68;
            line-height: 1;
        }
        .stay-item .stay-lbl {
            font-size: 0.75rem;
            color: #666;
            margin-top: 4px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        .stay-divider {
            width: 1px;
            height: 40px;
            background: #b2dfdb;
        }

        /* Print button */
        .btn-print {
            background: white;
            color: #0a4d68;
            border: 2px solid #0a4d68;
            padding: 10px 22px;
            border-radius: 10px;
            font-size: 0.9rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s;
        }
        .btn-print:hover {
            background: #0a4d68;
            color: white;
        }

        @media (max-width: 600px) {
            .info-grid { grid-template-columns: 1fr; }
            .info-section:nth-child(odd) { border-right: none; }
            .info-section.full-width { grid-column: 1; }
            .stay-strip { justify-content: center; }
        }

        @media print {
            .navbar, .breadcrumb, .action-bar, .btn-print { display: none; }
            body { background: white; }
            .container { margin: 0; max-width: 100%; }
            .card { box-shadow: none; border: 1px solid #ddd; }
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

    <!-- Breadcrumb -->
    <div class="breadcrumb">
        <a href="<%= request.getContextPath() %>/dashboard">Dashboard</a> &rsaquo;
        <a href="<%= request.getContextPath() %>/reservations">Reservations</a> &rsaquo;
        <%= r.getReservationNumber() %>
    </div>

    <!-- Action bar -->
    <div class="action-bar">
        <h1>Reservation Details</h1>
        <div style="display:flex; gap:12px; align-items:center;">
            <a href="<%= request.getContextPath() %>/reservations/bill?id=<%= r.getId() %>"
               style="background:linear-gradient(135deg,#0a4d68,#088395);color:white;text-decoration:none;
                      padding:10px 22px;border-radius:10px;font-size:0.9rem;font-weight:600;">
                &#128184; Calculate &amp; Print Bill
            </a>
            <button class="btn-print" onclick="window.print()">&#128424; Print</button>
            <a href="<%= request.getContextPath() %>/reservations" class="btn-back">&#8592; Back to List</a>
        </div>
    </div>

    <!-- Main card -->
    <div class="card">

        <!-- Card header -->
        <div class="card-header">
            <div class="card-header-left">
                <h2>Booking Reference</h2>
                <div class="res-num"><%= r.getReservationNumber() %></div>
            </div>
            <span class="badge <%= badgeClass %>"><%= status %></span>
        </div>

        <!-- Stay summary -->
        <div class="stay-strip">
            <div class="stay-item">
                <div class="stay-val"><%= r.getCheckInDate() %></div>
                <div class="stay-lbl">&#128197; Check-In</div>
            </div>
            <div class="stay-divider"></div>
            <div class="stay-item">
                <div class="stay-val"><%= nights %></div>
                <div class="stay-lbl">&#127769; Night<%= nights != 1 ? "s" : "" %></div>
            </div>
            <div class="stay-divider"></div>
            <div class="stay-item">
                <div class="stay-val"><%= r.getCheckOutDate() %></div>
                <div class="stay-lbl">&#128197; Check-Out</div>
            </div>
        </div>

        <!-- Detail sections -->
        <div class="info-grid">

            <!-- Guest Info -->
            <div class="info-section">
                <div class="section-label">&#128101; Guest Information</div>

                <div class="field">
                    <div class="field-label">Full Name</div>
                    <div class="field-value large"><%= r.getGuestName() %></div>
                </div>

                <div class="field">
                    <div class="field-label">Contact Number</div>
                    <div class="field-value"><%= r.getContactNumber() %></div>
                </div>

                <div class="field">
                    <div class="field-label">Address</div>
                    <div class="field-value">
                        <%= (r.getAddress() != null && !r.getAddress().isEmpty()) ? r.getAddress() : "—" %>
                    </div>
                </div>
            </div>

            <!-- Booking Info -->
            <div class="info-section">
                <div class="section-label">&#127968; Booking Details</div>

                <div class="field">
                    <div class="field-label">Room Type</div>
                    <div class="field-value large"><%= r.getRoomType() %></div>
                </div>

                <div class="field">
                    <div class="field-label">Check-In Date</div>
                    <div class="field-value"><%= r.getCheckInDate() %></div>
                </div>

                <div class="field">
                    <div class="field-label">Check-Out Date</div>
                    <div class="field-value"><%= r.getCheckOutDate() %></div>
                </div>

                <div class="field">
                    <div class="field-label">Duration</div>
                    <div class="field-value"><%= nights %> night<%= nights != 1 ? "s" : "" %></div>
                </div>
            </div>

            <!-- System Info -->
            <div class="info-section full-width" style="border-bottom:none;">
                <div class="section-label">&#128203; System Information</div>
                <div style="display:flex; gap:40px; flex-wrap:wrap;">
                    <div class="field">
                        <div class="field-label">Reservation ID</div>
                        <div class="field-value">#<%= r.getId() %></div>
                    </div>
                    <div class="field">
                        <div class="field-label">Reservation Number</div>
                        <div class="field-value"><%= r.getReservationNumber() %></div>
                    </div>
                    <div class="field">
                        <div class="field-label">Status</div>
                        <div class="field-value"><%= status %></div>
                    </div>
                    <div class="field">
                        <div class="field-label">Created On</div>
                        <div class="field-value">
                            <%= r.getCreatedAt() != null ? r.getCreatedAt().toString() : "—" %>
                        </div>
                    </div>
                </div>
            </div>

        </div><!-- /info-grid -->
    </div><!-- /card -->

</div><!-- /container -->

</body>
</html>
