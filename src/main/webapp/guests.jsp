<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.example.oceanviewresort.model.User" %>
<%@ page import="com.example.oceanviewresort.model.Guest" %>
<%@ page import="java.util.List" %>
<%
    User loggedUser = (User) session.getAttribute("loggedUser");
    if (loggedUser == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    List<Guest> guests  = (List<Guest>) request.getAttribute("guests");
    int totalGuests     = request.getAttribute("totalGuests") != null ? (int) request.getAttribute("totalGuests") : 0;
    int totalBookings   = 0;
    if (guests != null) for (Guest g : guests) totalBookings += g.getTotalReservations();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Guests — Ocean View Resort</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        *, *::before, *::after { margin: 0; padding: 0; box-sizing: border-box; }
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
        .container { max-width: 1150px; margin: 36px auto; padding: 0 24px; }

        /* ── Page title ── */
        .page-title { margin-bottom: 24px; }
        .page-title h1 { font-size: 1.55rem; font-weight: 700; color: #0a4d68; display: flex; align-items: center; gap: 10px; }
        .page-title p  { font-size: 0.87rem; color: #9aacba; margin-top: 4px; }

        /* ── KPI strip ── */
        .kpi-strip { display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px; margin-bottom: 26px; }
        .kpi-card {
            background: white; border-radius: 16px;
            padding: 20px 24px; box-shadow: 0 2px 14px rgba(0,0,0,0.06);
            display: flex; align-items: center; gap: 16px;
        }
        .kpi-icon {
            width: 50px; height: 50px; border-radius: 14px;
            display: flex; align-items: center; justify-content: center;
            font-size: 1.4rem; flex-shrink: 0;
        }
        .kpi-icon.blue   { background: linear-gradient(135deg,#0891b2,#06b6d4); }
        .kpi-icon.green  { background: linear-gradient(135deg,#059669,#10b981); }
        .kpi-icon.purple { background: linear-gradient(135deg,#7c3aed,#a78bfa); }
        .kpi-text .num   { font-size: 1.8rem; font-weight: 800; color: #0a4d68; line-height: 1; }
        .kpi-text .lbl   { font-size: 0.78rem; color: #9aacba; text-transform: uppercase; letter-spacing: 0.6px; margin-top: 3px; }

        /* ── Toolbar ── */
        .toolbar { display: flex; align-items: center; gap: 14px; margin-bottom: 18px; }
        .search-wrap { flex: 1; position: relative; }
        .search-wrap svg { position: absolute; left: 14px; top: 50%; transform: translateY(-50%); color: #9aacba; pointer-events: none; }
        .search-wrap input {
            width: 100%; padding: 11px 16px 11px 42px;
            border: 1.5px solid #dde4ea; border-radius: 12px;
            font-size: 0.9rem; background: white; outline: none;
            box-shadow: 0 2px 8px rgba(0,0,0,0.04);
            transition: border-color 0.2s, box-shadow 0.2s;
        }
        .search-wrap input:focus { border-color: #088395; box-shadow: 0 0 0 3px rgba(8,131,149,0.12); }
        .count-badge {
            background: linear-gradient(135deg, #0a4d68, #088395);
            color: white; padding: 10px 20px; border-radius: 12px;
            font-size: 0.83rem; font-weight: 600; white-space: nowrap;
        }

        /* ── Table card ── */
        .table-card { background: white; border-radius: 18px; box-shadow: 0 4px 22px rgba(0,0,0,0.07); overflow: hidden; }
        table { width: 100%; border-collapse: collapse; }
        thead { background: linear-gradient(135deg, #0a4d68, #088395); color: white; }
        thead th { padding: 14px 18px; text-align: left; font-size: 0.78rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.7px; }
        thead th:last-child { text-align: center; }
        tbody tr { border-bottom: 1px solid #f2f6fa; transition: background 0.14s; }
        tbody tr:last-child { border-bottom: none; }
        tbody tr:hover { background: #f6fbfc; }
        td { padding: 14px 18px; font-size: 0.9rem; vertical-align: middle; }

        /* Avatar */
        .avatar-circle {
            width: 40px; height: 40px; border-radius: 50%;
            background: linear-gradient(135deg, #0891b2, #06b6d4);
            color: white; font-size: 1rem; font-weight: 700;
            display: inline-flex; align-items: center; justify-content: center;
            flex-shrink: 0; box-shadow: 0 2px 8px rgba(8,131,149,0.25);
        }
        .guest-cell { display: flex; align-items: center; gap: 12px; }
        .guest-cell .gname { font-weight: 600; color: #1a2e3b; font-size: 0.92rem; }

        /* Booking count pill */
        .bookings-pill {
            display: inline-flex; align-items: center; justify-content: center;
            width: 32px; height: 32px; border-radius: 50%;
            background: #e0f7fa; color: #0a4d68;
            font-weight: 700; font-size: 0.88rem;
        }

        /* Status badge */
        .badge { display: inline-block; padding: 4px 12px; border-radius: 20px; font-size: 0.73rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.4px; }
        .badge-confirmed   { background: #dcfce7; color: #15803d; }
        .badge-pending     { background: #fef9c3; color: #854d0e; }
        .badge-cancelled   { background: #fee2e2; color: #b91c1c; }
        .badge-checked_out { background: #ede9fe; color: #6d28d9; }

        /* View Profile button */
        .btn-profile {
            display: inline-flex; align-items: center; gap: 6px;
            background: linear-gradient(135deg, #0891b2, #06b6d4);
            color: white; border: none; padding: 7px 16px;
            border-radius: 8px; font-size: 0.78rem; font-weight: 600;
            text-decoration: none; cursor: pointer; letter-spacing: 0.2px;
            transition: transform 0.15s, box-shadow 0.15s, filter 0.15s;
        }
        .btn-profile:hover { transform: translateY(-2px); box-shadow: 0 4px 14px rgba(8,131,149,0.35); filter: brightness(1.06); }
        .btn-profile:active { transform: translateY(0); box-shadow: none; }

        /* Empty state */
        .empty-state { text-align: center; padding: 64px 20px; color: #bbb; }
        .empty-state .icon { font-size: 3.5rem; margin-bottom: 14px; }
        .empty-state h3 { font-size: 1.05rem; color: #999; margin-bottom: 6px; }
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
        <a href="<%= request.getContextPath() %>/guests" class="active">Guests</a>
        <a href="<%= request.getContextPath() %>/payments">Payments</a>
        <a href="<%= request.getContextPath() %>/reports">Reports</a>
        <a href="<%= request.getContextPath() %>/help">Help</a>
        <a href="<%= request.getContextPath() %>/logout" class="btn-logout">Logout</a>
    </div>
</nav>

<div class="container">

    <!-- Title -->
    <div class="page-title">
        <h1>
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#0a4d68" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
            Guest Records
        </h1>
        <p>Unique guest profiles derived from reservation history</p>
    </div>

    <!-- KPI strip -->
    <div class="kpi-strip">
        <div class="kpi-card">
            <div class="kpi-icon blue">&#128101;</div>
            <div class="kpi-text">
                <div class="num"><%= totalGuests %></div>
                <div class="lbl">Unique Guests</div>
            </div>
        </div>
        <div class="kpi-card">
            <div class="kpi-icon green">&#128203;</div>
            <div class="kpi-text">
                <div class="num"><%= totalBookings %></div>
                <div class="lbl">Total Bookings</div>
            </div>
        </div>
        <div class="kpi-card">
            <div class="kpi-icon purple">&#11088;</div>
            <div class="kpi-text">
                <div class="num"><%= totalGuests > 0 ? String.format("%.1f", (double) totalBookings / totalGuests) : "0.0" %></div>
                <div class="lbl">Avg Stays / Guest</div>
            </div>
        </div>
    </div>

    <!-- Toolbar -->
    <div class="toolbar">
        <div class="search-wrap">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
            <input type="text" id="searchInput" placeholder="Search by guest name or contact number..." onkeyup="filterTable()">
        </div>
        <div class="count-badge">
            <span id="visibleCount"><%= guests != null ? guests.size() : 0 %></span> guests
        </div>
    </div>

    <!-- Table -->
    <div class="table-card">
        <% if (guests == null || guests.isEmpty()) { %>
        <div class="empty-state">
            <div class="icon">&#128101;</div>
            <h3>No guests yet</h3>
            <p>Guest profiles are automatically created from reservations.</p>
        </div>
        <% } else { %>
        <table id="guestTable">
            <thead>
                <tr>
                    <th>#</th>
                    <th>Guest</th>
                    <th>Contact</th>
                    <th>Address</th>
                    <th style="text-align:center;">Bookings</th>
                    <th>Last Stay</th>
                    <th>Last Room</th>
                    <th>Last Status</th>
                    <th style="text-align:center;">Action</th>
                </tr>
            </thead>
            <tbody>
                <%
                    int rowNum = 0;
                    for (Guest g : guests) {
                        rowNum++;
                        String initial = (g.getGuestName() != null && !g.getGuestName().isEmpty())
                                         ? String.valueOf(g.getGuestName().charAt(0)).toUpperCase() : "?";
                        String st = g.getLastStatus() != null ? g.getLastStatus() : "";
                        String badgeCls = "badge-pending";
                        if ("CONFIRMED".equalsIgnoreCase(st))   badgeCls = "badge-confirmed";
                        if ("CANCELLED".equalsIgnoreCase(st))   badgeCls = "badge-cancelled";
                        if ("CHECKED_OUT".equalsIgnoreCase(st)) badgeCls = "badge-checked_out";
                        String encodedContact = java.net.URLEncoder.encode(
                                g.getContactNumber() != null ? g.getContactNumber() : "", "UTF-8");
                %>
                <tr>
                    <td style="color:#b0bec5;font-size:0.82rem;font-weight:600;"><%= rowNum %></td>
                    <td>
                        <div class="guest-cell">
                            <div class="avatar-circle"><%= initial %></div>
                            <div class="gname"><%= g.getGuestName() != null ? g.getGuestName() : "-" %></div>
                        </div>
                    </td>
                    <td style="font-size:0.87rem;">
                        <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#9aacba" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="vertical-align:-2px;margin-right:4px;"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07A19.5 19.5 0 0 1 4.69 12 19.79 19.79 0 0 1 1.61 3.38 2 2 0 0 1 3.58 1h3a2 2 0 0 1 2 1.72c.127.96.361 1.903.7 2.81a2 2 0 0 1-.45 2.11L7.91 8.46a16 16 0 0 0 6.29 6.29l1.52-1.52a2 2 0 0 1 2.11-.45c.907.339 1.85.573 2.81.7A2 2 0 0 1 22 16.92z"/></svg>
                        <%= g.getContactNumber() != null ? g.getContactNumber() : "-" %>
                    </td>
                    <td style="font-size:0.83rem;color:#78909c;max-width:160px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">
                        <%= g.getAddress() != null && !g.getAddress().isEmpty() ? g.getAddress() : "&mdash;" %>
                    </td>
                    <td style="text-align:center;">
                        <span class="bookings-pill"><%= g.getTotalReservations() %></span>
                    </td>
                    <td style="font-size:0.87rem;color:#546e7a;">
                        <%= g.getLastVisit() != null ? g.getLastVisit().toString() : "&mdash;" %>
                    </td>
                    <td style="font-size:0.87rem;color:#546e7a;">
                        <%= g.getLastRoomType() != null ? g.getLastRoomType() : "&mdash;" %>
                    </td>
                    <td>
                        <% if (!st.isEmpty()) { %>
                        <span class="badge <%= badgeCls %>"><%= st %></span>
                        <% } else { %>&mdash;<% } %>
                    </td>
                    <td style="text-align:center;">
                        <a href="<%= request.getContextPath() %>/guests/profile?contact=<%= encodedContact %>" class="btn-profile">
                            <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                            View Profile
                        </a>
                    </td>
                </tr>
                <% } %>
            </tbody>
        </table>
        <% } %>
    </div>

</div>

<script>
function filterTable() {
    const query = document.getElementById('searchInput').value.toLowerCase();
    const rows  = document.querySelectorAll('#guestTable tbody tr');
    let visible = 0;
    rows.forEach(row => {
        const show = row.textContent.toLowerCase().includes(query);
        row.style.display = show ? '' : 'none';
        if (show) visible++;
    });
    document.getElementById('visibleCount').textContent = visible;
}
</script>
</body>
</html>
