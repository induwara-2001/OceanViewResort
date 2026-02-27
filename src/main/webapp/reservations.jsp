<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.example.oceanviewresort.model.User" %>
<%@ page import="com.example.oceanviewresort.model.Reservation" %>
<%@ page import="java.util.List" %>
<%
    User loggedUser = (User) session.getAttribute("loggedUser");
    if (loggedUser == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    List<Reservation> reservations = (List<Reservation>) request.getAttribute("reservations");
    String success = request.getParameter("success");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reservations - Ocean View Resort</title>
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
            max-width: 1100px;
            margin: 35px auto;
            padding: 0 20px;
        }

        /* Page header */
        .page-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 22px;
        }
        .page-header h1 { font-size: 1.5rem; color: #0a4d68; }
        .page-header p  { font-size: 0.88rem; color: #888; margin-top: 3px; }

        .btn-add {
            background: linear-gradient(135deg, #0a4d68, #088395);
            color: white;
            text-decoration: none;
            padding: 11px 22px;
            border-radius: 10px;
            font-size: 0.92rem;
            font-weight: 600;
            white-space: nowrap;
            transition: opacity 0.2s;
        }
        .btn-add:hover { opacity: 0.88; }

        /* Success alert */
        .alert-success {
            background: #e8f8f0;
            border: 1px solid #a3e4c0;
            color: #1a7a4a;
            padding: 12px 18px;
            border-radius: 10px;
            margin-bottom: 20px;
            font-size: 0.9rem;
        }

        /* Table card */
        .table-card {
            background: white;
            border-radius: 16px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.07);
            overflow: hidden;
        }

        table {
            width: 100%;
            border-collapse: collapse;
        }
        thead {
            background: linear-gradient(135deg, #0a4d68, #088395);
            color: white;
        }
        thead th {
            padding: 14px 16px;
            text-align: left;
            font-size: 0.82rem;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        tbody tr {
            border-bottom: 1px solid #f0f4f8;
            transition: background 0.15s;
        }
        tbody tr:hover { background: #f7fbfc; }
        tbody tr:last-child { border-bottom: none; }
        td {
            padding: 13px 16px;
            font-size: 0.9rem;
            vertical-align: middle;
        }
        td.res-number { font-weight: 600; color: #088395; }

        /* Status badge */
        .badge {
            display: inline-block;
            padding: 3px 10px;
            border-radius: 20px;
            font-size: 0.75rem;
            font-weight: 600;
            text-transform: uppercase;
        }
        .badge-pending    { background: #fff8e1; color: #f39c12; }
        .badge-confirmed  { background: #e8f8f0; color: #1a7a4a; }
        .badge-cancelled  { background: #fdecea; color: #c0392b; }
        .badge-checked_out { background: #e8eaf6; color: #3949ab; }

        /* Empty state */
        .empty-state {
            text-align: center;
            padding: 60px 20px;
            color: #aaa;
        }
        .empty-state .icon { font-size: 3.5rem; margin-bottom: 14px; }
        .empty-state h3 { font-size: 1.1rem; color: #888; margin-bottom: 8px; }
        .empty-state p  { font-size: 0.88rem; }
    </style>
</head>
<body>

<!-- Navbar -->
<nav class="navbar">
    <div class="brand">&#127754; Ocean View Resort</div>
    <div class="navbar-links">
        <a href="<%= request.getContextPath() %>/dashboard">Dashboard</a>
        <a href="<%= request.getContextPath() %>/reservations">Reservations</a>
        <a href="<%= request.getContextPath() %>/logout" class="btn-logout">Logout</a>
    </div>
</nav>

<!-- Content -->
<div class="container">

    <div class="page-header">
        <div>
            <h1>&#128203; Reservations</h1>
            <p>Manage all guest reservations</p>
        </div>
        <a href="<%= request.getContextPath() %>/reservations/add" class="btn-add">+ Add Reservation</a>
    </div>

    <% if ("1".equals(success)) { %>
    <div class="alert-success">
        &#10003; Reservation saved successfully!
    </div>
    <% } %>

    <div class="table-card">
        <% if (reservations == null || reservations.isEmpty()) { %>
        <div class="empty-state">
            <div class="icon">&#128203;</div>
            <h3>No reservations yet</h3>
            <p>Click "Add Reservation" to create the first booking.</p>
        </div>
        <% } else { %>
        <table>
            <thead>
                <tr>
                    <th>Res. Number</th>
                    <th>Guest Name</th>
                    <th>Contact</th>
                    <th>Room Type</th>
                    <th>Check-In</th>
                    <th>Check-Out</th>
                    <th>Status</th>
                </tr>
            </thead>
            <tbody>
                <% for (Reservation r : reservations) { %>
                <tr>
                    <td class="res-number"><%= r.getReservationNumber() %></td>
                    <td><%= r.getGuestName() %></td>
                    <td><%= r.getContactNumber() %></td>
                    <td><%= r.getRoomType() %></td>
                    <td><%= r.getCheckInDate() %></td>
                    <td><%= r.getCheckOutDate() %></td>
                    <td>
                        <%
                            String status = r.getStatus() != null ? r.getStatus() : "PENDING";
                            String badgeClass = "badge-pending";
                            if ("CONFIRMED".equalsIgnoreCase(status))   badgeClass = "badge-confirmed";
                            if ("CANCELLED".equalsIgnoreCase(status))   badgeClass = "badge-cancelled";
                            if ("CHECKED_OUT".equalsIgnoreCase(status)) badgeClass = "badge-checked_out";
                        %>
                        <span class="badge <%= badgeClass %>"><%= status %></span>
                    </td>
                </tr>
                <% } %>
            </tbody>
        </table>
        <% } %>
    </div>

</div>

</body>
</html>
