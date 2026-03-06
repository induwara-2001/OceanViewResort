<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.example.oceanviewresort.model.User" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%
    User loggedUser = (User) session.getAttribute("loggedUser");
    if (loggedUser == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    int    totalReservations = request.getAttribute("totalReservations") != null ? (int)    request.getAttribute("totalReservations") : 0;
    double totalRevenue      = request.getAttribute("totalRevenue")      != null ? (double) request.getAttribute("totalRevenue")      : 0.0;
    int    totalGuests       = request.getAttribute("totalGuests")       != null ? (int)    request.getAttribute("totalGuests")       : 0;
    int    totalRooms        = request.getAttribute("totalRooms")        != null ? (int)    request.getAttribute("totalRooms")        : 0;
    int    availableRooms    = request.getAttribute("availableRooms")    != null ? (int)    request.getAttribute("availableRooms")    : 0;

    @SuppressWarnings("unchecked")
    Map<String, Long>   byStatus   = (Map<String, Long>)   request.getAttribute("byStatus");
    @SuppressWarnings("unchecked")
    Map<String, Long>   byRoomType = (Map<String, Long>)   request.getAttribute("byRoomType");
    @SuppressWarnings("unchecked")
    Map<String, Double> revenueMap = (Map<String, Double>) request.getAttribute("revenueByRoomType");

    // Convert to JSON strings for chart rendering
    StringBuilder statusLabels = new StringBuilder();
    StringBuilder statusData   = new StringBuilder();
    if (byStatus != null) {
        for (Map.Entry<String, Long> e : byStatus.entrySet()) {
            if (statusLabels.length() > 0) { statusLabels.append(","); statusData.append(","); }
            statusLabels.append("'").append(e.getKey()).append("'");
            statusData.append(e.getValue());
        }
    }
    StringBuilder roomLabels = new StringBuilder();
    StringBuilder roomData   = new StringBuilder();
    if (byRoomType != null) {
        for (Map.Entry<String, Long> e : byRoomType.entrySet()) {
            if (roomLabels.length() > 0) { roomLabels.append(","); roomData.append(","); }
            roomLabels.append("'").append(e.getKey()).append("'");
            roomData.append(e.getValue());
        }
    }
    StringBuilder revLabels = new StringBuilder();
    StringBuilder revData   = new StringBuilder();
    if (revenueMap != null) {
        for (Map.Entry<String, Double> e : revenueMap.entrySet()) {
            if (revLabels.length() > 0) { revLabels.append(","); revData.append(","); }
            revLabels.append("'").append(e.getKey()).append("'");
            revData.append(e.getValue());
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reports - Ocean View Resort</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
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
        }
        .btn-logout:hover { background: rgba(255,255,255,0.22); }
        .btn-exit {
            color: white; text-decoration: none;
            background: rgba(239,68,68,0.2); border: 1px solid rgba(239,68,68,0.45);
            font-size: 0.82rem; font-weight: 600; padding: 7px 16px; border-radius: 8px;
        }
        .btn-exit:hover { background: rgba(239,68,68,0.4); }

        .container { max-width: 1200px; margin: 36px auto; padding: 0 28px; }
        .page-header { margin-bottom: 28px; }
        .page-header h1 { font-size: 1.45rem; font-weight: 800; color: #0a2540; letter-spacing: -0.5px; }
        .page-header p  { font-size: 0.84rem; color: #64748b; margin-top: 3px; }

        /* KPI cards */
        .kpi-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(190px, 1fr)); gap: 16px; margin-bottom: 28px; }
        .kpi-card {
            background: white; border-radius: 16px; padding: 22px 20px;
            box-shadow: 0 2px 12px rgba(0,0,0,0.06); text-align: center;
            border: 1px solid #e2e8f0;
            transition: transform 0.18s, box-shadow 0.18s;
        }
        .kpi-card:hover { transform: translateY(-3px); box-shadow: 0 8px 24px rgba(0,0,0,0.1); }
        .kpi-card .kpi-icon  { font-size: 2rem; margin-bottom: 8px; }
        .kpi-card .kpi-value { font-size: 2rem; font-weight: 800; color: #0a2540; margin-bottom: 4px; letter-spacing: -0.5px; }
        .kpi-card .kpi-label { font-size: 0.72rem; color: #94a3b8; text-transform: uppercase; letter-spacing: 0.7px; font-weight: 600; }
        .kpi-card.revenue .kpi-value { color: #059669; font-size: 1.6rem; }

        /* Chart grid */
        .charts-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-bottom: 28px; }
        .chart-card {
            background: white; border-radius: 18px; padding: 26px;
            box-shadow: 0 4px 24px rgba(0,0,0,0.07); border: 1px solid #e2e8f0;
        }
        .chart-card h3 { font-size: 0.9rem; font-weight: 700; color: #0a2540; margin-bottom: 18px; letter-spacing: -0.2px; }
        .chart-wrapper { position: relative; height: 260px; }

        /* Revenue table */
        .section-card {
            background: white; border-radius: 18px; padding: 26px;
            box-shadow: 0 4px 24px rgba(0,0,0,0.07); border: 1px solid #e2e8f0;
        }
        .section-card h3 { font-size: 0.9rem; font-weight: 700; color: #0a2540; margin-bottom: 18px; }
        table { width: 100%; border-collapse: collapse; }
        thead { background: linear-gradient(135deg, #0a2540, #0a4d68); color: white; }
        thead th { padding: 13px 18px; text-align: left; font-size: 0.72rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.9px; }
        tbody tr { border-bottom: 1px solid #f1f5f9; }
        tbody tr:last-child { border-bottom: none; }
        tbody tr:hover { background: #f8fbff; }
        td { padding: 13px 18px; font-size: 0.88rem; color: #334155; }
        .amount-cell { font-weight: 700; color: #059669; }

        @media (max-width: 700px) { .charts-grid { grid-template-columns: 1fr; } }
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
        <a href="<%= request.getContextPath() %>/payments">Payments</a>
        <a href="<%= request.getContextPath() %>/reports" class="active">Reports</a>
        <a href="<%= request.getContextPath() %>/help">Help</a>
        <a href="<%= request.getContextPath() %>/logout" class="btn-logout">Logout</a>
        <a href="<%= request.getContextPath() %>/exit" onclick="return confirm('Exit and end your session?')" class="btn-exit">&#x23FB; Exit</a>
    </div>
</nav>

<div class="container">

    <div class="page-header">
        <h1>&#128202; Analytics &amp; Reports</h1>
        <p>Overview of resort performance and booking statistics</p>
    </div>

    <!-- KPI Cards -->
    <div class="kpi-grid">
        <div class="kpi-card">
            <div class="kpi-icon">&#128203;</div>
            <div class="kpi-value"><%= totalReservations %></div>
            <div class="kpi-label">Total Reservations</div>
        </div>
        <div class="kpi-card revenue">
            <div class="kpi-icon">&#128184;</div>
            <div class="kpi-value">$<%= String.format("%,.0f", totalRevenue) %></div>
            <div class="kpi-label">Total Revenue</div>
        </div>
        <div class="kpi-card">
            <div class="kpi-icon">&#128101;</div>
            <div class="kpi-value"><%= totalGuests %></div>
            <div class="kpi-label">Unique Guests</div>
        </div>
        <div class="kpi-card">
            <div class="kpi-icon">&#127968;</div>
            <div class="kpi-value"><%= totalRooms %></div>
            <div class="kpi-label">Total Rooms</div>
        </div>
        <div class="kpi-card">
            <div class="kpi-icon">&#9989;</div>
            <div class="kpi-value"><%= availableRooms %></div>
            <div class="kpi-label">Rooms Available</div>
        </div>
    </div>

    <!-- Charts -->
    <div class="charts-grid">
        <div class="chart-card">
            <h3>&#128202; Reservations by Status</h3>
            <div class="chart-wrapper">
                <canvas id="statusChart"></canvas>
            </div>
        </div>
        <div class="chart-card">
            <h3>&#127968; Bookings by Room Type</h3>
            <div class="chart-wrapper">
                <canvas id="roomChart"></canvas>
            </div>
        </div>
    </div>

    <!-- Revenue breakdown table -->
    <div class="section-card">
        <h3>&#128184; Revenue by Room Type (incl. taxes &amp; charges)</h3>
        <% if (revenueMap == null || revenueMap.isEmpty()) { %>
        <p style="color:#bbb;text-align:center;padding:30px;">No revenue data available yet.</p>
        <% } else { %>
        <table>
            <thead>
                <tr>
                    <th>Room Type</th>
                    <th>Bookings</th>
                    <th>Estimated Revenue</th>
                </tr>
            </thead>
            <tbody>
                <% for (Map.Entry<String, Double> e : revenueMap.entrySet()) {
                       Long bookings = byRoomType != null ? byRoomType.get(e.getKey()) : null; %>
                <tr>
                    <td><%= e.getKey() %></td>
                    <td><%= bookings != null ? bookings : 0 %></td>
                    <td class="amount-cell">$<%= String.format("%,.2f", e.getValue()) %></td>
                </tr>
                <% } %>
            </tbody>
        </table>
        <% } %>
    </div>

</div>

<script>
// Doughnut: reservations by status
const statusCtx = document.getElementById('statusChart').getContext('2d');
new Chart(statusCtx, {
    type: 'doughnut',
    data: {
        labels: [<%= statusLabels %>],
        datasets: [{
            data: [<%= statusData %>],
            backgroundColor: ['#4CAF50','#FFC107','#F44336','#2196F3','#9C27B0'],
            borderWidth: 2
        }]
    },
    options: {
        responsive: true, maintainAspectRatio: false,
        plugins: { legend: { position: 'bottom', labels: { font: { size: 11 }, padding: 12 } } }
    }
});

// Bar: bookings by room type
const roomCtx = document.getElementById('roomChart').getContext('2d');
new Chart(roomCtx, {
    type: 'bar',
    data: {
        labels: [<%= roomLabels %>],
        datasets: [{
            label: 'Bookings',
            data: [<%= roomData %>],
            backgroundColor: 'rgba(8, 131, 149, 0.75)',
            borderColor: '#088395',
            borderWidth: 1,
            borderRadius: 6
        }]
    },
    options: {
        responsive: true, maintainAspectRatio: false,
        plugins: { legend: { display: false } },
        scales: {
            y: { beginAtZero: true, ticks: { stepSize: 1 } },
            x: { ticks: { font: { size: 10 } } }
        }
    }
});
</script>
</body>
</html>
