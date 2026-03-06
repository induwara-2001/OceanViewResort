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
    <title>Rooms - Ocean View Resort</title>
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
        .btn-logout {
            background: rgba(255,255,255,0.2); color: white;
            border: 1px solid rgba(255,255,255,0.5);
            padding: 7px 16px; border-radius: 8px; text-decoration: none; font-size: 0.85rem;
        }
        .btn-exit {
            background: rgba(220,53,69,0.25); color: white;
            border: 1px solid rgba(220,53,69,0.6);
            padding: 7px 16px; border-radius: 8px; cursor: pointer;
            font-size: 0.85rem; font-weight: 600; text-decoration: none;
        }
        .btn-exit:hover { background: rgba(220,53,69,0.5); }

        .container { max-width: 1100px; margin: 35px auto; padding: 0 20px; }

        .page-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 22px; }
        .page-header h1 { font-size: 1.5rem; color: #0a4d68; }
        .page-header p  { font-size: 0.88rem; color: #888; margin-top: 3px; }

        /* Summary strip */
        .summary-strip { display: flex; gap: 16px; margin-bottom: 24px; flex-wrap: wrap; }
        .summary-card {
            flex: 1; min-width: 140px; background: white;
            border-radius: 14px; padding: 18px 20px;
            box-shadow: 0 4px 16px rgba(0,0,0,0.07); text-align: center;
        }
        .summary-card .sc-num  { font-size: 2rem; font-weight: 700; margin-bottom: 4px; }
        .summary-card .sc-label{ font-size: 0.8rem; color: #999; text-transform: uppercase; letter-spacing: 0.5px; }
        .sc-total   .sc-num { color: #0a4d68; }
        .sc-avail   .sc-num { color: #1a7a4a; }
        .sc-occ     .sc-num { color: #c0392b; }
        .sc-maint   .sc-num { color: #d97706; }

        .alert-success {
            background: #e8f8f0; border: 1px solid #a3e4c0; color: #1a7a4a;
            padding: 12px 18px; border-radius: 10px; margin-bottom: 20px; font-size: 0.9rem;
        }

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

        /* Badges */
        .badge {
            display: inline-block; padding: 4px 12px; border-radius: 20px;
            font-size: 0.75rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.4px;
        }
        .badge-available  { background: #e6f9ef; color: #1a7a4a; }
        .badge-occupied   { background: #fde8e8; color: #c0392b; }
        .badge-maintenance{ background: #fef3cd; color: #856404; }

        /* Status change form */
        .status-form { display: flex; align-items: center; gap: 8px; justify-content: center; }
        .status-select {
            border: 1px solid #dee2e6; border-radius: 7px; padding: 5px 10px;
            font-size: 0.82rem; background: white; cursor: pointer; color: #333;
        }
        .btn-update {
            background: linear-gradient(135deg, #0a4d68, #088395);
            color: white; border: none; padding: 6px 14px;
            border-radius: 7px; font-size: 0.8rem; font-weight: 600; cursor: pointer;
        }
        .btn-update:hover { opacity: 0.88; }

        .price-cell { font-weight: 600; color: #0a4d68; }
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
        <a href="<%= request.getContextPath() %>/exit" onclick="return confirm('Exit and end your session?')" class="btn-exit">&#x23FB; Exit System</a>
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
