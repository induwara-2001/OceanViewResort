<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.example.oceanviewresort.model.User" %>
<%@ page import="com.example.oceanviewresort.model.Room" %>
<%@ page import="java.util.List" %>
<%
    User loggedUser = (User) session.getAttribute("loggedUser");
    if (loggedUser == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    List<Room> rooms         = (List<Room>) request.getAttribute("rooms");
    int availableCount  = request.getAttribute("availableCount")  != null ? (int) request.getAttribute("availableCount")  : 0;
    int occupiedCount   = request.getAttribute("occupiedCount")   != null ? (int) request.getAttribute("occupiedCount")   : 0;
    int maintenanceCount = request.getAttribute("maintenanceCount") != null ? (int) request.getAttribute("maintenanceCount"): 0;
    String updated = request.getParameter("updated");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Rooms — Ocean View Resort</title>
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

        .container { max-width: 1160px; margin: 36px auto; padding: 0 28px; }
        .page-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 24px; }
        .page-header h1 { font-size: 1.45rem; font-weight: 800; color: #0a2540; letter-spacing: -0.5px; }
        .page-header p  { font-size: 0.84rem; color: #64748b; margin-top: 3px; }

        /* Summary strip */
        .summary-strip { display: flex; gap: 16px; margin-bottom: 24px; flex-wrap: wrap; }
        .summary-card {
            flex: 1; min-width: 140px; background: white;
            border-radius: 16px; padding: 20px 22px;
            box-shadow: 0 2px 12px rgba(0,0,0,0.06);
            text-align: center; border: 1px solid #e2e8f0;
            transition: transform 0.18s, box-shadow 0.18s;
        }
        .summary-card:hover { transform: translateY(-3px); box-shadow: 0 8px 24px rgba(0,0,0,0.1); }
        .summary-card .sc-num  { font-size: 2rem; font-weight: 800; margin-bottom: 4px; }
        .summary-card .sc-label{ font-size: 0.72rem; color: #94a3b8; text-transform: uppercase; letter-spacing: 0.7px; font-weight: 600; }
        .sc-total .sc-num  { color: #0a2540; }
        .sc-avail .sc-num  { color: #059669; }
        .sc-occ   .sc-num  { color: #dc2626; }
        .sc-maint .sc-num  { color: #d97706; }

        .alert-success {
            display: flex; align-items: center; gap: 10px;
            background: #f0fdf4; border: 1.5px solid #86efac;
            color: #166534; padding: 13px 18px; border-radius: 12px;
            margin-bottom: 20px; font-size: 0.88rem; font-weight: 500;
        }

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

        /* Badges */
        .badge { display: inline-block; padding: 4px 11px; border-radius: 20px; font-size: 0.72rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; }
        .badge-available   { background: #f0fdf4; color: #166534; border: 1px solid #86efac; }
        .badge-occupied    { background: #fef2f2; color: #991b1b; border: 1px solid #fca5a5; }
        .badge-maintenance { background: #fffbeb; color: #92400e; border: 1px solid #fde68a; }

        /* Status change form */
        .status-form { display: flex; align-items: center; gap: 8px; justify-content: center; }
        .status-select {
            border: 1.5px solid #e2e8f0; border-radius: 8px; padding: 6px 10px;
            font-size: 0.82rem; background: white; cursor: pointer; color: #334155;
            font-family: 'Inter', sans-serif;
        }
        .btn-update {
            background: linear-gradient(135deg, #0a4d68, #0bb8c4);
            color: white; border: none; padding: 7px 16px;
            border-radius: 8px; font-size: 0.8rem; font-weight: 700;
            cursor: pointer; font-family: 'Inter', sans-serif;
            transition: opacity 0.15s;
        }
        .btn-update:hover { opacity: 0.88; }
        .price-cell { font-weight: 700; color: #0a4d68; }
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
        <a href="<%= request.getContextPath() %>/rooms" class="active">Rooms</a>
        <a href="<%= request.getContextPath() %>/guests">Guests</a>
        <a href="<%= request.getContextPath() %>/payments">Payments</a>
        <a href="<%= request.getContextPath() %>/reports">Reports</a>
        <a href="<%= request.getContextPath() %>/help">Help</a>
        <a href="<%= request.getContextPath() %>/logout" class="btn-logout">Logout</a>
        <a href="<%= request.getContextPath() %>/exit" onclick="return confirm('Exit and end your session?')" class="btn-exit">&#x23FB; Exit</a>
    </div>
</nav>

<div class="container">

    <!-- Page Header -->
    <div class="page-header">
        <div>
            <h1>&#127968; Room Management</h1>
            <p>View availability and update room status</p>
        </div>
    </div>

    <%-- Success alert --%>
    <% if ("1".equals(updated)) { %>
    <div class="alert-success">&#10003; Room status updated successfully.</div>
    <% } %>

    <!-- Summary strip -->
    <div class="summary-strip">
        <div class="summary-card sc-total">
            <div class="sc-num"><%= rooms != null ? rooms.size() : 0 %></div>
            <div class="sc-label">Total Rooms</div>
        </div>
        <div class="summary-card sc-avail">
            <div class="sc-num"><%= availableCount %></div>
            <div class="sc-label">Available</div>
        </div>
        <div class="summary-card sc-occ">
            <div class="sc-num"><%= occupiedCount %></div>
            <div class="sc-label">Occupied</div>
        </div>
        <div class="summary-card sc-maint">
            <div class="sc-num"><%= maintenanceCount %></div>
            <div class="sc-label">Maintenance</div>
        </div>
    </div>

    <!-- Rooms Table -->
    <div class="table-card">
        <% if (rooms == null || rooms.isEmpty()) { %>
        <div class="empty-state">
            <p style="font-size:2.5rem;margin-bottom:12px;">&#127968;</p>
            <p>No rooms found. Please add room records to the database.</p>
        </div>
        <% } else { %>
        <table>
            <thead>
                <tr>
                    <th>Room No.</th>
                    <th>Room Type</th>
                    <th>Floor</th>
                    <th>Capacity</th>
                    <th>Rate / Night</th>
                    <th>Status</th>
                    <th>Description</th>
                    <th>Update Status</th>
                </tr>
            </thead>
            <tbody>
                <% for (Room room : rooms) {
                    String statusClass = "badge-available";
                    if ("Occupied".equals(room.getStatus()))     statusClass = "badge-occupied";
                    if ("Maintenance".equals(room.getStatus()))  statusClass = "badge-maintenance";
                %>
                <tr>
                    <td><strong><%= room.getRoomNumber() %></strong></td>
                    <td><%= room.getRoomType() %></td>
                    <td>Floor <%= room.getFloor() %></td>
                    <td><%= room.getCapacity() %> person<%= room.getCapacity() > 1 ? "s" : "" %></td>
                    <td class="price-cell">$<%= String.format("%.2f", room.getPricePerNight()) %></td>
                    <td><span class="badge <%= statusClass %>"><%= room.getStatus() %></span></td>
                    <td style="font-size:0.82rem;color:#666;"><%= room.getDescription() != null ? room.getDescription() : "-" %></td>
                    <td>
                        <form method="post" action="<%= request.getContextPath() %>/rooms" class="status-form">
                            <input type="hidden" name="action"  value="updateStatus">
                            <input type="hidden" name="roomId"  value="<%= room.getId() %>">
                            <select name="status" class="status-select">
                                <option value="Available"   <%= "Available".equals(room.getStatus())    ? "selected" : "" %>>Available</option>
                                <option value="Occupied"    <%= "Occupied".equals(room.getStatus())     ? "selected" : "" %>>Occupied</option>
                                <option value="Maintenance" <%= "Maintenance".equals(room.getStatus())  ? "selected" : "" %>>Maintenance</option>
                            </select>
                            <button type="submit" class="btn-update">Save</button>
                        </form>
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
