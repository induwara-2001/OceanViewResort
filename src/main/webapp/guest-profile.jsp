<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.example.oceanviewresort.model.User" %>
<%@ page import="com.example.oceanviewresort.model.Guest" %>
<%@ page import="com.example.oceanviewresort.model.Reservation" %>
<%@ page import="java.util.List" %>
<%
    User loggedUser = (User) session.getAttribute("loggedUser");
    if (loggedUser == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    Guest g = (Guest) request.getAttribute("guest");
    if (g == null) {
        response.sendRedirect(request.getContextPath() + "/guests");
        return;
    }
    List<Reservation> history = (List<Reservation>) request.getAttribute("history");

    String initial = (g.getGuestName() != null && !g.getGuestName().isEmpty())
                     ? String.valueOf(g.getGuestName().charAt(0)).toUpperCase() : "?";
    String lastSt = g.getLastStatus() != null ? g.getLastStatus() : "";
    String lastBadge = "badge-pending";
    if ("CONFIRMED".equalsIgnoreCase(lastSt))   lastBadge = "badge-confirmed";
    if ("CANCELLED".equalsIgnoreCase(lastSt))   lastBadge = "badge-cancelled";
    if ("CHECKED_OUT".equalsIgnoreCase(lastSt)) lastBadge = "badge-checked_out";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= g.getGuestName() != null ? g.getGuestName() : "Guest" %> — Profile</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Inter', 'Segoe UI', sans-serif; background: #f1f5f9; color: #1e293b; }

        /* ── Navbar ── */
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
        }
        .btn-logout:hover { background: rgba(255,255,255,0.22); }

        /* ── Layout ── */
        .container { max-width: 980px; margin: 36px auto; padding: 0 24px; }

        /* ── Breadcrumb ── */
        .breadcrumb { font-size: 0.84rem; color: #9aacba; margin-bottom: 22px; }
        .breadcrumb a { color: #088395; text-decoration: none; }
        .breadcrumb a:hover { text-decoration: underline; }

        /* ── Hero card ── */
        .hero-card {
            background: white; border-radius: 20px;
            box-shadow: 0 4px 28px rgba(0,0,0,0.09);
            overflow: hidden; margin-bottom: 22px;
        }

        /* Banner with avatar + name embedded inside */
        .hero-banner {
            background: linear-gradient(135deg, #053f56 0%, #0a6d82 45%, #0bb8c4 100%);
            padding: 32px 34px 28px;
            position: relative; overflow: hidden;
            display: flex; align-items: center; gap: 26px;
        }
        /* Decorative blobs */
        .hero-banner::before {
            content: '';
            position: absolute; top: -40px; right: -40px;
            width: 220px; height: 220px; border-radius: 50%;
            background: rgba(255,255,255,0.07);
            pointer-events: none;
        }
        .hero-banner::after {
            content: '';
            position: absolute; bottom: -60px; right: 120px;
            width: 160px; height: 160px; border-radius: 50%;
            background: rgba(255,255,255,0.05);
            pointer-events: none;
        }
        .blob3 {
            position: absolute; top: 10px; right: 180px;
            width: 80px; height: 80px; border-radius: 50%;
            background: rgba(255,255,255,0.06);
            pointer-events: none;
        }
        /* Avatar */
        .avatar-lg {
            width: 90px; height: 90px; border-radius: 50%;
            background: rgba(255,255,255,0.18);
            backdrop-filter: blur(4px);
            color: white; font-size: 2.4rem; font-weight: 800;
            display: flex; align-items: center; justify-content: center;
            border: 3px solid rgba(255,255,255,0.45);
            box-shadow: 0 6px 20px rgba(0,0,0,0.2);
            flex-shrink: 0; position: relative; z-index: 1;
        }
        /* Name / contact inside banner */
        .hero-meta { position: relative; z-index: 1; flex: 1; }
        .hero-meta h2 {
            font-size: 1.65rem; font-weight: 800;
            color: white; letter-spacing: -0.3px; margin-bottom: 6px;
        }
        .hero-meta .contact-line {
            display: flex; align-items: center; gap: 10px;
            flex-wrap: wrap;
        }
        .hero-meta .contact-chip {
            display: inline-flex; align-items: center; gap: 6px;
            background: rgba(255,255,255,0.15); border: 1px solid rgba(255,255,255,0.25);
            color: rgba(255,255,255,0.95); padding: 5px 14px; border-radius: 30px;
            font-size: 0.85rem; font-weight: 500; backdrop-filter: blur(4px);
        }
        .hero-meta .tier-chip {
            display: inline-flex; align-items: center; gap: 5px;
            background: rgba(255,215,0,0.2); border: 1px solid rgba(255,215,0,0.4);
            color: #ffe566; padding: 5px 14px; border-radius: 30px;
            font-size: 0.82rem; font-weight: 700;
        }

        /* Info pills row below banner */
        .info-pills {
            display: grid; grid-template-columns: repeat(3, 1fr);
            border-top: 1px solid #f0f6f8;
        }
        .info-pill {
            display: flex; align-items: center; gap: 14px;
            padding: 20px 24px;
            border-right: 1px solid #f0f6f8;
        }
        .info-pill:last-child { border-right: none; }
        .info-pill .pill-icon {
            width: 42px; height: 42px; border-radius: 12px; flex-shrink: 0;
            display: flex; align-items: center; justify-content: center;
        }
        .pill-icon.addr  { background: #e0f7fa; }
        .pill-icon.date  { background: #e8f5e9; }
        .pill-icon.room  { background: #ede7f6; }
        .info-pill .pill-lbl { font-size: 0.72rem; font-weight: 700; color: #9aacba; text-transform: uppercase; letter-spacing: 0.6px; margin-bottom: 3px; }
        .info-pill .pill-val { font-size: 0.93rem; font-weight: 600; color: #1a2e3b; }

        /* ── Stats row ── */
        .stats-row { display: grid; grid-template-columns: repeat(4, 1fr); gap: 14px; margin-bottom: 22px; }
        .stat-card {
            background: white; border-radius: 16px;
            padding: 18px 20px; box-shadow: 0 2px 14px rgba(0,0,0,0.06);
            display: flex; flex-direction: column; align-items: center; gap: 6px;
        }
        .stat-card .snum { font-size: 1.7rem; font-weight: 800; color: #0a4d68; }
        .stat-card .slbl { font-size: 0.73rem; color: #9aacba; text-transform: uppercase; letter-spacing: 0.5px; text-align: center; }
        .stat-card .sico { font-size: 1.25rem; margin-bottom: 2px; }

        /* ── Section heading ── */
        .section-head {
            display: flex; align-items: center; gap: 10px;
            margin-bottom: 14px;
        }
        .section-head h3 { font-size: 1.05rem; font-weight: 700; color: #0a4d68; }
        .section-head .line { flex: 1; height: 1px; background: #e8f0f4; }

        /* ── History table ── */
        .table-card { background: white; border-radius: 18px; box-shadow: 0 4px 22px rgba(0,0,0,0.07); overflow: hidden; }
        table { width: 100%; border-collapse: collapse; }
        thead { background: linear-gradient(135deg, #0a4d68, #088395); color: white; }
        thead th { padding: 13px 18px; text-align: left; font-size: 0.77rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.7px; }
        tbody tr { border-bottom: 1px solid #f2f6fa; transition: background 0.14s; }
        tbody tr:last-child { border-bottom: none; }
        tbody tr:hover { background: #f6fbfc; }
        td { padding: 13px 18px; font-size: 0.89rem; vertical-align: middle; }
        td.res-num { font-weight: 700; color: #088395; font-size: 0.86rem; }

        /* Status badge */
        .badge { display: inline-block; padding: 4px 12px; border-radius: 20px; font-size: 0.73rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.4px; }
        .badge-confirmed   { background: #dcfce7; color: #15803d; }
        .badge-pending     { background: #fef9c3; color: #854d0e; }
        .badge-cancelled   { background: #fee2e2; color: #b91c1c; }
        .badge-checked_out { background: #ede9fe; color: #6d28d9; }

        /* Action link */
        .btn-view-res {
            display: inline-flex; align-items: center; gap: 5px;
            background: linear-gradient(135deg, #0891b2, #06b6d4);
            color: white; border: none; padding: 6px 14px;
            border-radius: 7px; font-size: 0.77rem; font-weight: 600;
            text-decoration: none;
            transition: transform 0.15s, box-shadow 0.15s;
        }
        .btn-view-res:hover { transform: translateY(-2px); box-shadow: 0 4px 10px rgba(8,131,149,0.3); }

        /* Back button */
        .btn-back {
            display: inline-flex; align-items: center; gap: 7px;
            background: white; color: #0a4d68;
            border: 1.5px solid #d4e6ed; padding: 9px 20px;
            border-radius: 10px; font-size: 0.88rem; font-weight: 600;
            text-decoration: none; margin-bottom: 20px;
            transition: border-color 0.2s, box-shadow 0.2s;
        }
        .btn-back:hover { border-color: #088395; box-shadow: 0 2px 10px rgba(8,131,149,0.12); }

        /* Empty history */
        .empty-hist { text-align: center; padding: 40px; color: #bbb; font-size: 0.9rem; }

        @media(max-width:700px){
            .info-pills { grid-template-columns: 1fr; }
            .info-pill { border-right: none; border-bottom: 1px solid #f0f6f8; }
            .stats-row { grid-template-columns: 1fr 1fr; }
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
        <a href="<%= request.getContextPath() %>/reservations">Reservations</a>
        <a href="<%= request.getContextPath() %>/rooms">Rooms</a>
        <a href="<%= request.getContextPath() %>/guests" class="active">Guests</a>
        <a href="<%= request.getContextPath() %>/payments">Payments</a>
        <a href="<%= request.getContextPath() %>/reports">Reports</a>
        <a href="<%= request.getContextPath() %>/help">Help</a>
        <a href="<%= request.getContextPath() %>/logout" class="btn-logout">Logout</a>
    </div>
</nav>

<div class="container">

    <!-- Breadcrumb -->
    <div class="breadcrumb">
        <a href="<%= request.getContextPath() %>/dashboard">Dashboard</a> &rsaquo;
        <a href="<%= request.getContextPath() %>/guests">Guests</a> &rsaquo;
        <%= g.getGuestName() != null ? g.getGuestName() : "Profile" %>
    </div>

    <!-- Back button -->
    <a href="<%= request.getContextPath() %>/guests" class="btn-back">
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.3" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"/></svg>
        Back to Guests
    </a>

    <!-- Hero card -->
    <div class="hero-card">
        <div class="hero-banner">
            <div class="blob3"></div>
            <div class="avatar-lg"><%= initial %></div>
            <div class="hero-meta">
                <h2><%= g.getGuestName() != null ? g.getGuestName() : "Unknown Guest" %></h2>
                <div class="contact-line">
                    <span class="contact-chip">
                        <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07A19.5 19.5 0 0 1 4.69 12 19.79 19.79 0 0 1 1.61 3.38 2 2 0 0 1 3.58 1h3a2 2 0 0 1 2 1.72c.127.96.361 1.903.7 2.81a2 2 0 0 1-.45 2.11L7.91 8.46a16 16 0 0 0 6.29 6.29l1.52-1.52a2 2 0 0 1 2.11-.45c.907.339 1.85.573 2.81.7A2 2 0 0 1 22 16.92z"/></svg>
                        <%= g.getContactNumber() != null ? g.getContactNumber() : "—" %>
                    </span>
                    <% if (!lastSt.isEmpty()) { %>
                    <span class="badge <%= lastBadge %>" style="font-size:0.72rem;"><%= lastSt %></span>
                    <% } %>
                    <span class="tier-chip">
                        &#11088;
                        <%= g.getTotalReservations() >= 5 ? "VIP Guest" : g.getTotalReservations() >= 2 ? "Regular Guest" : "New Guest" %>
                    </span>
                </div>
            </div>
        </div>

        <div class="info-pills">
            <div class="info-pill">
                <div class="pill-icon addr">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#088395" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/><circle cx="12" cy="10" r="3"/></svg>
                </div>
                <div>
                    <div class="pill-lbl">Address</div>
                    <div class="pill-val"><%= g.getAddress() != null && !g.getAddress().isEmpty() ? g.getAddress() : "—" %></div>
                </div>
            </div>
            <div class="info-pill">
                <div class="pill-icon date">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#2e7d32" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
                </div>
                <div>
                    <div class="pill-lbl">Last Visit</div>
                    <div class="pill-val"><%= g.getLastVisit() != null ? g.getLastVisit().toString() : "—" %></div>
                </div>
            </div>
            <div class="info-pill">
                <div class="pill-icon room">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#6d28d9" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg>
                </div>
                <div>
                    <div class="pill-lbl">Preferred Room</div>
                    <div class="pill-val"><%= g.getLastRoomType() != null ? g.getLastRoomType() : "—" %></div>
                </div>
            </div>
        </div>
    </div>

    <!-- Stats row -->
    <div class="stats-row">
        <div class="stat-card">
            <div class="sico">&#128203;</div>
            <div class="snum"><%= g.getTotalReservations() %></div>
            <div class="slbl">Total Stays</div>
        </div>
        <div class="stat-card">
            <div class="sico">&#127965;</div>
            <div class="snum"><%= g.getLastRoomType() != null ? g.getLastRoomType().split(" ")[0] : "—" %></div>
            <div class="slbl">Last Room Type</div>
        </div>
        <div class="stat-card">
            <div class="sico">&#128337;</div>
            <div class="snum"><%= g.getLastVisit() != null ? g.getLastVisit().toString().substring(0,4) : "—" %></div>
            <div class="slbl">Last Year Visited</div>
        </div>
        <div class="stat-card">
            <div class="sico">&#127775;</div>
            <div class="snum"><%= g.getTotalReservations() >= 5 ? "VIP" : g.getTotalReservations() >= 2 ? "Regular" : "New" %></div>
            <div class="slbl">Guest Tier</div>
        </div>
    </div>

    <!-- Reservation history -->
    <div class="section-head">
        <h3>&#128203; Reservation History</h3>
        <div class="line"></div>
        <span style="font-size:0.82rem;color:#9aacba;font-weight:600;white-space:nowrap;">
            <%= history != null ? history.size() : 0 %> reservation<%= (history == null || history.size() != 1) ? "s" : "" %>
        </span>
    </div>

    <div class="table-card">
        <% if (history == null || history.isEmpty()) { %>
        <div class="empty-hist">No reservation records found for this guest.</div>
        <% } else { %>
        <table>
            <thead>
                <tr>
                    <th>Res. Number</th>
                    <th>Room Type</th>
                    <th>Check-In</th>
                    <th>Check-Out</th>
                    <th>Status</th>
                    <th style="text-align:center;">Details</th>
                </tr>
            </thead>
            <tbody>
                <% for (Reservation r : history) {
                    String rs = r.getStatus() != null ? r.getStatus() : "PENDING";
                    String rb = "badge-pending";
                    if ("CONFIRMED".equalsIgnoreCase(rs))   rb = "badge-confirmed";
                    if ("CANCELLED".equalsIgnoreCase(rs))   rb = "badge-cancelled";
                    if ("CHECKED_OUT".equalsIgnoreCase(rs)) rb = "badge-checked_out";
                %>
                <tr>
                    <td class="res-num"><%= r.getReservationNumber() %></td>
                    <td style="font-size:0.87rem;"><%= r.getRoomType() != null ? r.getRoomType() : "—" %></td>
                    <td style="font-size:0.87rem;color:#546e7a;"><%= r.getCheckInDate() != null ? r.getCheckInDate().toString() : "—" %></td>
                    <td style="font-size:0.87rem;color:#546e7a;"><%= r.getCheckOutDate() != null ? r.getCheckOutDate().toString() : "—" %></td>
                    <td><span class="badge <%= rb %>"><%= rs %></span></td>
                    <td style="text-align:center;">
                        <a href="<%= request.getContextPath() %>/reservations/view?id=<%= r.getId() %>" class="btn-view-res">
                            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
                            View
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
