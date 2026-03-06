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
    <title>Reservations — Ocean View Resort</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        *, *::before, *::after { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            font-family: 'Inter', 'Segoe UI', sans-serif;
            background: #f1f5f9;
            color: #1e293b;
        }

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

        /* Page */
        .container { max-width: 1160px; margin: 36px auto; padding: 0 28px; }

        /* Page header */
        .page-header {
            display: flex; align-items: center; justify-content: space-between;
            margin-bottom: 24px;
        }
        .page-header h1 { font-size: 1.45rem; font-weight: 800; color: #0a2540; letter-spacing: -0.5px; }
        .page-header p  { font-size: 0.84rem; color: #64748b; margin-top: 3px; }

        .btn-add {
            display: inline-flex; align-items: center; gap: 7px;
            background: linear-gradient(135deg, #0a4d68, #0bb8c4);
            color: white; text-decoration: none;
            padding: 11px 22px; border-radius: 11px;
            font-size: 0.88rem; font-weight: 700;
            box-shadow: 0 4px 14px rgba(8,131,149,0.35);
            transition: opacity 0.2s, transform 0.15s;
        }
        .btn-add:hover { opacity: 0.9; transform: translateY(-1px); }

        /* Alerts */
        .alert-success {
            display: flex; align-items: center; gap: 10px;
            background: #f0fdf4; border: 1.5px solid #86efac;
            color: #166534; padding: 13px 18px; border-radius: 12px;
            margin-bottom: 20px; font-size: 0.88rem; font-weight: 500;
        }

        /* Table card */
        .table-card {
            background: white; border-radius: 18px;
            box-shadow: 0 4px 24px rgba(0,0,0,0.07); overflow: hidden;
            border: 1px solid #e2e8f0;
        }

        table { width: 100%; border-collapse: collapse; }
        thead { background: linear-gradient(135deg, #0a2540, #0a4d68); color: white; }
        thead th {
            padding: 14px 18px; text-align: left;
            font-size: 0.72rem; font-weight: 700;
            text-transform: uppercase; letter-spacing: 0.9px;
        }
        thead th:last-child { text-align: center; }
        tbody tr { border-bottom: 1px solid #f1f5f9; transition: background 0.12s; }
        tbody tr:hover { background: #f8fbff; }
        tbody tr:last-child { border-bottom: none; }
        td { padding: 14px 18px; font-size: 0.88rem; vertical-align: middle; color: #334155; }
        td.res-number { font-weight: 700; color: #0a4d68; font-family: 'Inter', monospace; }
        td.action-col { text-align: center; white-space: nowrap; min-width: 220px; }

        /* Action buttons */
        .action-group { display: inline-flex; align-items: center; gap: 6px; }
        .action-btn {
            display: inline-flex; align-items: center; gap: 5px;
            padding: 7px 14px; border-radius: 8px; font-size: 0.77rem; font-weight: 600;
            font-family: 'Inter', sans-serif; letter-spacing: 0.2px;
            text-decoration: none; border: none; cursor: pointer;
            transition: transform 0.15s, box-shadow 0.15s, filter 0.15s;
        }
        .action-btn:hover { transform: translateY(-2px); box-shadow: 0 4px 12px rgba(0,0,0,0.18); filter: brightness(1.06); }
        .action-btn:active { transform: translateY(0); box-shadow: none; }
        .action-btn.view { background: linear-gradient(135deg,#0891b2,#06b6d4); color:#fff; }
        .action-btn.edit { background: linear-gradient(135deg,#d97706,#f59e0b); color:#fff; }
        .action-btn.del  { background: linear-gradient(135deg,#dc2626,#ef4444); color:#fff; }

        .alert-danger {
            display: flex; align-items: center; gap: 10px;
            background: #fef2f2; border: 1.5px solid #fca5a5;
            color: #b91c1c; padding: 13px 18px; border-radius: 12px;
            margin-bottom: 20px; font-size: 0.88rem; font-weight: 500;
        }

        /* Badges */
        .badge {
            display: inline-block; padding: 4px 11px; border-radius: 20px;
            font-size: 0.72rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px;
        }
        .badge-pending    { background: #fffbeb; color: #92400e; border: 1px solid #fde68a; }
        .badge-confirmed  { background: #f0fdf4; color: #166534; border: 1px solid #86efac; }
        .badge-cancelled  { background: #fef2f2; color: #991b1b; border: 1px solid #fca5a5; }
        .badge-checked_out { background: #eff6ff; color: #1d4ed8; border: 1px solid #93c5fd; }

        /* Empty state */
        .empty-state { text-align: center; padding: 64px 20px; color: #94a3b8; }
        .empty-state .icon { font-size: 3.5rem; margin-bottom: 14px; }
        .empty-state h3 { font-size: 1.05rem; color: #64748b; margin-bottom: 8px; font-weight: 600; }
        .empty-state p  { font-size: 0.85rem; }
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
        <a href="<%= request.getContextPath() %>/reservations" class="active">Reservations</a>
        <a href="<%= request.getContextPath() %>/rooms">Rooms</a>
        <a href="<%= request.getContextPath() %>/guests">Guests</a>
        <a href="<%= request.getContextPath() %>/payments">Payments</a>
        <a href="<%= request.getContextPath() %>/reports">Reports</a>
        <a href="<%= request.getContextPath() %>/help">Help</a>
        <a href="<%= request.getContextPath() %>/logout" class="btn-logout">Logout</a>
        <a href="javascript:void(0)"
           onclick="if(confirm('Exit the system? Your session will end.')) location.href='<%= request.getContextPath() %>/exit'"
           class="btn-exit">&#x23FB; Exit</a>
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
