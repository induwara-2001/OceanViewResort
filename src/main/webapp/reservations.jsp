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
    String deleted = request.getParameter("deleted");
    String updated = request.getParameter("updated");
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
        thead th:last-child { text-align: center; }
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
        td.action-col { text-align: center; white-space: nowrap; min-width: 200px; }

        /* ── Modern action button group ── */
        .action-group {
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }
        .action-btn {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            padding: 6px 14px;
            border-radius: 8px;
            font-size: 0.78rem;
            font-weight: 600;
            letter-spacing: 0.2px;
            text-decoration: none;
            border: none;
            cursor: pointer;
            transition: transform 0.15s, box-shadow 0.15s, filter 0.15s;
            line-height: 1;
        }
        .action-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
            filter: brightness(1.06);
        }
        .action-btn:active { transform: translateY(0); box-shadow: none; }
        .action-btn svg { flex-shrink: 0; }

        /* View — teal */
        .action-btn.view {
            background: linear-gradient(135deg, #0891b2, #06b6d4);
            color: #fff;
        }
        /* Edit — amber */
        .action-btn.edit {
            background: linear-gradient(135deg, #d97706, #f59e0b);
            color: #fff;
        }
        /* Delete — red */
        .action-btn.del {
            background: linear-gradient(135deg, #dc2626, #ef4444);
            color: #fff;
        }
        .alert-danger {
            background: #fdecea;
            border: 1px solid #f5c6cb;
            color: #c0392b;
            padding: 12px 18px;
            border-radius: 10px;
            margin-bottom: 20px;
            font-size: 0.9rem;
        }

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
    <% if ("1".equals(deleted)) { %>
    <div class="alert-danger">
        &#128465; Reservation deleted successfully.
    </div>
    <% } %>
    <% if ("1".equals(updated)) { %>
    <div class="alert-success">
        &#10003; Reservation updated successfully!
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
                    <th>Actions</th>
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
                    <td class="action-col">
                        <div class="action-group">
                            <a href="<%= request.getContextPath() %>/reservations/view?id=<%= r.getId() %>" class="action-btn view">
                                <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
                                View
                            </a>
                            <a href="<%= request.getContextPath() %>/reservations/edit?id=<%= r.getId() %>" class="action-btn edit">
                                <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
                                Edit
                            </a>
                            <form method="post" action="<%= request.getContextPath() %>/reservations/delete" style="display:contents;">
                                <input type="hidden" name="id" value="<%= r.getId() %>">
                                <button type="button" class="action-btn del"
                                    onclick="confirmDelete(this, '<%= r.getReservationNumber() %>', '<%= r.getGuestName().replace("'", "\\'" ) %>')">
                                    <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14a2 2 0 0 1-2 2H8a2 2 0 0 1-2-2L5 6"/><path d="M10 11v6"/><path d="M14 11v6"/><path d="M9 6V4a1 1 0 0 1 1-1h4a1 1 0 0 1 1 1v2"/></svg>
                                    Delete
                                </button>
                            </form>
                        </div>
                    </td>
                </tr>
                <% } %>
            </tbody>
        </table>
        <% } %>
    </div>

</div>

<script>
function confirmDelete(btn, resNum, guestName) {
    if (confirm('Delete reservation ' + resNum + ' for ' + guestName + '?\nThis action cannot be undone.')) {
        btn.closest('form').submit();
    }
}
</script>
</body>
</html>
