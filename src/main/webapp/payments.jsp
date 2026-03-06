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
    <title>Payments — Ocean View Resort</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        *, *::before, *::after { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Inter', 'Segoe UI', sans-serif; background: #f1f5f9; color: #1e293b; }

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
        .navbar-links a.active { color: white; background: rgba(255,255,255,0.15); font-weight: 600; }
        .btn-logout {
            color: white; text-decoration: none;
            background: rgba(255,255,255,0.12); border: 1px solid rgba(255,255,255,0.25);
            font-size: 0.82rem; font-weight: 600; padding: 7px 16px; border-radius: 8px;
            transition: background 0.15s;
        }
        .btn-logout:hover { background: rgba(255,255,255,0.22); }
        .btn-exit {
            color: white; text-decoration: none;
            background: rgba(239,68,68,0.2); border: 1px solid rgba(239,68,68,0.45);
            font-size: 0.82rem; font-weight: 600; padding: 7px 16px; border-radius: 8px;
            transition: background 0.15s;
        }
        .btn-exit:hover { background: rgba(239,68,68,0.4); }

        .container { max-width: 1200px; margin: 36px auto; padding: 0 28px; }
        .page-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 24px; }
        .page-header h1 { font-size: 1.45rem; font-weight: 800; color: #0a2540; letter-spacing: -0.5px; }
        .page-header p  { font-size: 0.84rem; color: #64748b; margin-top: 3px; }

        /* Revenue banner */
        .revenue-banner {
            background: linear-gradient(135deg, #0a2540 0%, #0a4d68 50%, #0bb8c4 100%);
            color: white; border-radius: 18px; padding: 28px 36px;
            margin-bottom: 26px; display: flex; align-items: center; justify-content: space-between;
            box-shadow: 0 8px 32px rgba(10,37,64,0.25); position: relative; overflow: hidden;
        }
        .revenue-banner::before {
            content: ''; position: absolute; top: -40px; right: -40px;
            width: 200px; height: 200px; border-radius: 50%;
            background: rgba(255,255,255,0.06); pointer-events: none;
        }
        .revenue-banner .rb-left { position: relative; z-index: 1; }
        .revenue-banner .label { font-size: 0.72rem; opacity: 0.7; margin-bottom: 4px; letter-spacing: 1px; text-transform: uppercase; font-weight: 600; }
        .revenue-banner .amount { font-size: 2.4rem; font-weight: 900; letter-spacing: -1px; }
        .revenue-banner .sub    { font-size: 0.8rem; opacity: 0.65; margin-top: 4px; }
        .revenue-banner .rb-right { position: relative; z-index: 1; font-size: 3.5rem; }

        .table-card { background: white; border-radius: 18px; box-shadow: 0 4px 24px rgba(0,0,0,0.07); overflow: hidden; border: 1px solid #e2e8f0; }
        table { width: 100%; border-collapse: collapse; }
        thead { background: linear-gradient(135deg, #0a2540, #0a4d68); color: white; }
        thead th { padding: 14px 18px; text-align: left; font-size: 0.72rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.9px; }
        thead th:last-child { text-align: center; }
        tbody tr { border-bottom: 1px solid #f1f5f9; transition: background 0.12s; }
        tbody tr:hover { background: #f8fbff; }
        tbody tr:last-child { border-bottom: none; }
        td { padding: 14px 18px; font-size: 0.88rem; vertical-align: middle; color: #334155; }
        td:last-child { text-align: center; }
        .empty-state { text-align: center; padding: 64px 20px; color: #94a3b8; font-size: 0.9rem; }

        .badge { display: inline-block; padding: 4px 11px; border-radius: 20px; font-size: 0.72rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; }
        .badge-confirmed   { background: #f0fdf4; color: #166534; border: 1px solid #86efac; }
        .badge-pending     { background: #fffbeb; color: #92400e; border: 1px solid #fde68a; }
        .badge-cancelled   { background: #fef2f2; color: #991b1b; border: 1px solid #fca5a5; }
        .badge-checked-out { background: #eff6ff; color: #1d4ed8; border: 1px solid #93c5fd; }

        .amount-cell { font-weight: 700; color: #0a2540; }
        .cancelled-amount { color: #dc2626; text-decoration: line-through; opacity: 0.6; }

        .btn-invoice {
            display: inline-flex; align-items: center; gap: 5px;
            background: linear-gradient(135deg, #0a4d68, #0bb8c4);
            color: white; text-decoration: none; padding: 7px 16px;
            border-radius: 8px; font-size: 0.8rem; font-weight: 700;
            font-family: 'Inter', sans-serif; white-space: nowrap;
            transition: opacity 0.15s, transform 0.15s;
        }
        .btn-invoice:hover { opacity: 0.9; transform: translateY(-1px); }
    </style>
</head>
<body>

<nav class="navbar">
    <div class="navbar-left">
        <div class="nav-logo">&#127754;</div>
        <span class="nav-brand">Ocean View Resort</span>
    </div>
    <div class="navbar-links">
        <a href="<%= request.getContextPath() %>/dashboard">Dashboard</a>
        <a href="<%= request.getContextPath() %>/reservations">Reservations</a>
        <a href="<%= request.getContextPath() %>/rooms">Rooms</a>
        <a href="<%= request.getContextPath() %>/guests">Guests</a>
        <a href="<%= request.getContextPath() %>/payments" class="active">Payments</a>
        <a href="<%= request.getContextPath() %>/reports">Reports</a>
        <a href="<%= request.getContextPath() %>/help">Help</a>
        <a href="<%= request.getContextPath() %>/logout" class="btn-logout">Logout</a>
        <a href="<%= request.getContextPath() %>/exit" onclick="return confirm('Exit and end your session?')" class="btn-exit">&#x23FB; Exit</a>
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
