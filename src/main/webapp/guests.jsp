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
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Guests - Ocean View Resort</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #f0f4f8; color: #333; }

        .navbar {
            background: linear-gradient(135deg, #0a4d68, #088395);
            color: white; padding: 0 30px; height: 65px;
            display: flex; align-items: center; justify-content: space-between;
            box-shadow: 0 3px 12px rgba(0,0,0,0.2);
        }
        .navbar .brand { font-size: 1.3rem; font-weight: 700; }
        .navbar-links { display: flex; align-items: center; gap: 20px; }
        .navbar-links a { color: rgba(255,255,255,0.85); text-decoration: none; font-size: 0.9rem; }
        .navbar-links a:hover { color: white; }
        .btn-logout { background: rgba(255,255,255,0.2); color: white; border: 1px solid rgba(255,255,255,0.5); padding: 7px 16px; border-radius: 8px; text-decoration: none; font-size: 0.85rem; }
        .btn-exit   { background: rgba(220,53,69,0.25); color: white; border: 1px solid rgba(220,53,69,0.6); padding: 7px 16px; border-radius: 8px; font-size: 0.85rem; font-weight: 600; text-decoration: none; }
        .btn-exit:hover { background: rgba(220,53,69,0.5); }

        .container { max-width: 1100px; margin: 35px auto; padding: 0 20px; }
        .page-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 22px; }
        .page-header h1 { font-size: 1.5rem; color: #0a4d68; }
        .page-header p  { font-size: 0.88rem; color: #888; margin-top: 3px; }

        /* Search bar */
        .search-bar { margin-bottom: 20px; }
        .search-bar input {
            width: 100%; padding: 11px 16px; border: 1px solid #dde2ea;
            border-radius: 10px; font-size: 0.93rem; outline: none;
            background: white; box-shadow: 0 2px 8px rgba(0,0,0,0.04);
        }
        .search-bar input:focus { border-color: #088395; }

        /* Summary */
        .summary-strip { display: flex; gap: 16px; margin-bottom: 24px; }
        .summary-card {
            flex: 1; background: white; border-radius: 14px;
            padding: 18px 20px; box-shadow: 0 4px 16px rgba(0,0,0,0.07); text-align: center;
        }
        .summary-card .sc-num   { font-size: 2rem; font-weight: 700; color: #088395; margin-bottom: 4px; }
        .summary-card .sc-label { font-size: 0.8rem; color: #999; text-transform: uppercase; }

        .table-card { background: white; border-radius: 16px; box-shadow: 0 4px 20px rgba(0,0,0,0.07); overflow: hidden; }
        table { width: 100%; border-collapse: collapse; }
        thead { background: linear-gradient(135deg, #0a4d68, #088395); color: white; }
        thead th { padding: 14px 16px; text-align: left; font-size: 0.82rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.5px; }
        tbody tr { border-bottom: 1px solid #f0f4f8; transition: background 0.15s; }
        tbody tr:last-child { border-bottom: none; }
        tbody tr:hover { background: #f7fbfc; }
        td { padding: 13px 16px; font-size: 0.9rem; vertical-align: middle; }

        .badge { display: inline-block; padding: 4px 12px; border-radius: 20px; font-size: 0.75rem; font-weight: 600; text-transform: uppercase; }
        .badge-confirmed { background: #e6f9ef; color: #1a7a4a; }
        .badge-pending   { background: #fff8e1; color: #856404; }
        .badge-cancelled { background: #fde8e8; color: #c0392b; }
        .badge-checked-out { background: #e8f0ff; color: #3b4fd4; }

        .empty-state { text-align: center; padding: 50px; color: #bbb; font-size: 0.95rem; }

        .avatar {
            width: 38px; height: 38px; border-radius: 50%;
            background: linear-gradient(135deg, #0a4d68, #088395);
            color: white; font-size: 1rem; font-weight: 700;
            display: inline-flex; align-items: center; justify-content: center;
            margin-right: 10px; vertical-align: middle;
        }
        .guest-name { display: flex; align-items: center; }
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
            <h1>&#128101; Guest Records</h1>
            <p>Unique guests derived from booking history</p>
        </div>
    </div>

    <!-- Summary -->
    <div class="summary-strip">
        <div class="summary-card">
            <div class="sc-num"><%= totalGuests %></div>
            <div class="sc-label">Unique Guests</div>
        </div>
        <div class="summary-card">
            <div class="sc-num"><%= guests != null ? guests.stream().mapToInt(com.example.oceanviewresort.model.Guest::getTotalReservations).sum() : 0 %></div>
            <div class="sc-label">Total Bookings</div>
        </div>
    </div>

    <!-- Search -->
    <div class="search-bar">
        <input type="text" id="searchInput" placeholder="&#128269;  Search by guest name or contact number..." onkeyup="filterTable()">
    </div>

    <!-- Table -->
    <div class="table-card">
        <% if (guests == null || guests.isEmpty()) { %>
        <div class="empty-state">
            <p style="font-size:2.5rem;margin-bottom:12px;">&#128101;</p>
            <p>No guests found. Guest records are built from reservations.</p>
        </div>
        <% } else { %>
        <table id="guestTable">
            <thead>
                <tr>
                    <th>#</th>
                    <th>Guest Name</th>
                    <th>Contact</th>
                    <th>Address</th>
                    <th>Total Bookings</th>
                    <th>Last Stay</th>
                    <th>Last Room</th>
                    <th>Last Status</th>
                </tr>
            </thead>
            <tbody>
                <% int rowNum = 0;
                   for (Guest g : guests) {
                       rowNum++;
                       String initial = (g.getGuestName() != null && !g.getGuestName().isEmpty())
                                        ? String.valueOf(g.getGuestName().charAt(0)).toUpperCase() : "?";
                       String statusBadge = "badge-pending";
                       if ("CONFIRMED".equals(g.getLastStatus()))   statusBadge = "badge-confirmed";
                       if ("CANCELLED".equals(g.getLastStatus()))   statusBadge = "badge-cancelled";
                       if ("CHECKED_OUT".equals(g.getLastStatus())) statusBadge = "badge-checked-out";
                %>
                <tr>
                    <td style="color:#999;font-size:0.82rem;"><%= rowNum %></td>
                    <td>
                        <div class="guest-name">
                            <span class="avatar"><%= initial %></span>
                            <strong><%= g.getGuestName() != null ? g.getGuestName() : "-" %></strong>
                        </div>
                    </td>
                    <td><%= g.getContactNumber() != null ? g.getContactNumber() : "-" %></td>
                    <td style="font-size:0.85rem;color:#666;"><%= g.getAddress() != null ? g.getAddress() : "-" %></td>
                    <td style="text-align:center;"><strong><%= g.getTotalReservations() %></strong></td>
                    <td><%= g.getLastVisit() != null ? g.getLastVisit().toString() : "-" %></td>
                    <td><%= g.getLastRoomType() != null ? g.getLastRoomType() : "-" %></td>
                    <td><span class="badge <%= statusBadge %>"><%= g.getLastStatus() != null ? g.getLastStatus() : "-" %></span></td>
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
    rows.forEach(row => {
        const text = row.textContent.toLowerCase();
        row.style.display = text.includes(query) ? '' : 'none';
    });
}
</script>
</body>
</html>
