<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.example.oceanviewresort.model.User" %>
<%@ page import="com.example.oceanviewresort.model.Reservation" %>
<%@ page import="com.example.oceanviewresort.model.Bill" %>
<%@ page import="java.util.List" %>
<%
    User loggedUser = (User) session.getAttribute("loggedUser");
    if (loggedUser == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    List<Reservation> reservations = (List<Reservation>) request.getAttribute("reservations");
    List<Bill>        bills        = (List<Bill>)        request.getAttribute("bills");
    double totalRevenue = request.getAttribute("totalRevenue") != null ? (double) request.getAttribute("totalRevenue") : 0;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Payments - Ocean View Resort</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #f0f4f8; color: #333; }

        .navbar { background: linear-gradient(135deg, #0a4d68, #088395); color: white; padding: 0 30px; height: 65px;
            display: flex; align-items: center; justify-content: space-between; box-shadow: 0 3px 12px rgba(0,0,0,0.2); }
        .navbar .brand { font-size: 1.3rem; font-weight: 700; }
        .navbar-links { display: flex; align-items: center; gap: 20px; }
        .navbar-links a { color: rgba(255,255,255,0.85); text-decoration: none; font-size: 0.9rem; }
        .navbar-links a:hover { color: white; }
        .btn-logout { background: rgba(255,255,255,0.2); color: white; border: 1px solid rgba(255,255,255,0.5); padding: 7px 16px; border-radius: 8px; text-decoration: none; font-size: 0.85rem; }
        .btn-exit   { background: rgba(220,53,69,0.25); color: white; border: 1px solid rgba(220,53,69,0.6); padding: 7px 16px; border-radius: 8px; font-size: 0.85rem; font-weight: 600; text-decoration: none; }
        .btn-exit:hover { background: rgba(220,53,69,0.5); }

        .container { max-width: 1150px; margin: 35px auto; padding: 0 20px; }
        .page-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 22px; }
        .page-header h1 { font-size: 1.5rem; color: #0a4d68; }
        .page-header p  { font-size: 0.88rem; color: #888; margin-top: 3px; }

        /* Revenue banner */
        .revenue-banner {
            background: linear-gradient(135deg, #0a4d68, #088395);
            color: white; border-radius: 16px; padding: 24px 30px;
            margin-bottom: 24px; display: flex; align-items: center; justify-content: space-between;
        }
        .revenue-banner .label { font-size: 0.88rem; opacity: 0.8; margin-bottom: 4px; }
        .revenue-banner .amount { font-size: 2.2rem; font-weight: 700; }
        .revenue-banner .sub { font-size: 0.82rem; opacity: 0.7; }

        .table-card { background: white; border-radius: 16px; box-shadow: 0 4px 20px rgba(0,0,0,0.07); overflow: hidden; }
        table { width: 100%; border-collapse: collapse; }
        thead { background: linear-gradient(135deg, #0a4d68, #088395); color: white; }
        thead th { padding: 14px 16px; text-align: left; font-size: 0.82rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.5px; }
        thead th:last-child { text-align: center; }
        tbody tr { border-bottom: 1px solid #f0f4f8; transition: background 0.15s; }
        tbody tr:last-child { border-bottom: none; }
        tbody tr:hover { background: #f7fbfc; }
        td { padding: 13px 16px; font-size: 0.9rem; vertical-align: middle; }
        td:last-child { text-align: center; }
        .empty-state { text-align: center; padding: 50px; color: #bbb; font-size: 0.95rem; }

        .badge { display: inline-block; padding: 4px 12px; border-radius: 20px; font-size: 0.75rem; font-weight: 600; text-transform: uppercase; }
        .badge-confirmed    { background: #e6f9ef; color: #1a7a4a; }
        .badge-pending      { background: #fff8e1; color: #856404; }
        .badge-cancelled    { background: #fde8e8; color: #c0392b; }
        .badge-checked-out  { background: #e8f0ff; color: #3b4fd4; }

        .amount-cell { font-weight: 700; color: #0a4d68; }
        .cancelled-amount { color: #c0392b; text-decoration: line-through; opacity: 0.6; }

        .btn-invoice {
            background: linear-gradient(135deg, #0a4d68, #088395);
            color: white; text-decoration: none; padding: 6px 14px;
            border-radius: 7px; font-size: 0.8rem; font-weight: 600; white-space: nowrap;
        }
        .btn-invoice:hover { opacity: 0.88; }
    </style>
</head>
<body>

<nav class="navbar">
    <div class="brand">&#127754; Ocean View Resort</div>
    <div class="navbar-links">
        <a href="<%= request.getContextPath() %>/dashboard">Dashboard</a>
        <a href="<%= request.getContextPath() %>/reservations">Reservations</a>
        <a href="<%= request.getContextPath() %>/help">Help</a>
        <a href="<%= request.getContextPath() %>/logout" class="btn-logout">Logout</a>
        <a href="<%= request.getContextPath() %>/exit" onclick="return confirm('Exit and end your session?')" class="btn-exit">&#x23FB; Exit System</a>
    </div>
</nav>

<div class="container">

    <div class="page-header">
        <div>
            <h1>&#128184; Payments &amp; Billing</h1>
            <p>Computed bill totals for all reservations (incl. 10% tax + 5% service charge)</p>
        </div>
    </div>

    <!-- Revenue summary -->
    <div class="revenue-banner">
        <div>
            <div class="label">Total Estimated Revenue</div>
            <div class="amount">$<%= String.format("%,.2f", totalRevenue) %></div>
            <div class="sub">Active reservations only (excluding cancellations)</div>
        </div>
        <div style="font-size:3rem;opacity:0.3;">&#128184;</div>
    </div>

    <!-- Table -->
    <div class="table-card">
        <% if (reservations == null || reservations.isEmpty()) { %>
        <div class="empty-state">
            <p style="font-size:2.5rem;margin-bottom:12px;">&#128184;</p>
            <p>No payment records yet. Add reservations to see billing info.</p>
        </div>
        <% } else { %>
        <table>
            <thead>
                <tr>
                    <th>Res. Number</th>
                    <th>Guest Name</th>
                    <th>Room Type</th>
                    <th>Check-In</th>
                    <th>Check-Out</th>
                    <th>Nights</th>
                    <th>Rate/Night</th>
                    <th>Grand Total</th>
                    <th>Status</th>
                    <th>Invoice</th>
                </tr>
            </thead>
            <tbody>
                <% for (int i = 0; i < reservations.size(); i++) {
                       Reservation r = reservations.get(i);
                       Bill b = (bills != null && i < bills.size()) ? bills.get(i) : null;
                       boolean cancelled = "CANCELLED".equals(r.getStatus());
                       String statusBadge = "badge-pending";
                       if ("CONFIRMED".equals(r.getStatus()))   statusBadge = "badge-confirmed";
                       if ("CANCELLED".equals(r.getStatus()))   statusBadge = "badge-cancelled";
                       if ("CHECKED_OUT".equals(r.getStatus())) statusBadge = "badge-checked-out";
                %>
                <tr>
                    <td><strong><%= r.getReservationNumber() %></strong></td>
                    <td><%= r.getGuestName() %></td>
                    <td><%= r.getRoomType() %></td>
                    <td><%= r.getCheckInDate() %></td>
                    <td><%= r.getCheckOutDate() %></td>
                    <td style="text-align:center;"><%= b != null ? b.getNights() : "-" %></td>
                    <td><%= b != null ? "$" + String.format("%.2f", b.getRatePerNight()) : "-" %></td>
                    <td class="<%= cancelled ? "cancelled-amount" : "amount-cell" %>">
                        <%= b != null ? "$" + String.format("%,.2f", b.getGrandTotal()) : "-" %>
                    </td>
                    <td><span class="badge <%= statusBadge %>"><%= r.getStatus() %></span></td>
                    <td>
                        <a href="<%= request.getContextPath() %>/reservations/bill?id=<%= r.getId() %>" class="btn-invoice">
                            &#128203; Invoice
                        </a>
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
