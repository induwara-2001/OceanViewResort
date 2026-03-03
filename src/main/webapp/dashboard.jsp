<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.example.oceanviewresort.model.User" %>
<%
    // Guard: redirect if not logged in
    User loggedUser = (User) session.getAttribute("loggedUser");
    if (loggedUser == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Ocean View Resort - Dashboard</title>
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

        .navbar .brand {
            font-size: 1.4rem;
            font-weight: 700;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .navbar .user-info {
            display: flex;
            align-items: center;
            gap: 16px;
            font-size: 0.9rem;
        }

        .btn-logout {
            background: rgba(255,255,255,0.2);
            color: white;
            border: 1px solid rgba(255,255,255,0.5);
            padding: 7px 16px;
            border-radius: 8px;
            cursor: pointer;
            text-decoration: none;
            font-size: 0.87rem;
            transition: background 0.2s;
        }

        .btn-logout:hover {
            background: rgba(255,255,255,0.35);
        }

        .btn-exit {
            background: rgba(220,53,69,0.25);
            color: white;
            border: 1px solid rgba(220,53,69,0.6);
            padding: 7px 16px;
            border-radius: 8px;
            cursor: pointer;
            font-size: 0.87rem;
            font-weight: 600;
            transition: background 0.2s;
            text-decoration: none;
        }
        .btn-exit:hover { background: rgba(220,53,69,0.5); }

        /* Exit confirm overlay */
        .overlay {
            display: none;
            position: fixed;
            inset: 0;
            background: rgba(0,0,0,0.55);
            z-index: 999;
            align-items: center;
            justify-content: center;
        }
        .overlay.show { display: flex; }
        .confirm-box {
            background: white;
            border-radius: 18px;
            padding: 38px 40px;
            max-width: 400px;
            width: 90%;
            text-align: center;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            animation: popIn 0.25s ease;
        }
        @keyframes popIn {
            from { transform: scale(0.88); opacity: 0; }
            to   { transform: scale(1);    opacity: 1; }
        }
        .confirm-box .c-icon { font-size: 2.8rem; margin-bottom: 14px; }
        .confirm-box h3 { font-size: 1.2rem; color: #0a4d68; margin-bottom: 8px; }
        .confirm-box p  { font-size: 0.88rem; color: #777; line-height: 1.6; margin-bottom: 24px; }
        .confirm-btns { display: flex; gap: 12px; justify-content: center; }
        .btn-confirm-exit {
            background: linear-gradient(135deg, #c0392b, #e74c3c);
            color: white;
            border: none;
            padding: 11px 26px;
            border-radius: 10px;
            font-size: 0.93rem;
            font-weight: 600;
            cursor: pointer;
            text-decoration: none;
            transition: opacity 0.2s;
        }
        .btn-confirm-exit:hover { opacity: 0.88; }
        .btn-cancel-exit {
            background: #f0f4f8;
            color: #555;
            border: 2px solid #ddd;
            padding: 11px 26px;
            border-radius: 10px;
            font-size: 0.93rem;
            cursor: pointer;
        }
        .btn-cancel-exit:hover { border-color: #aaa; }

        /* Main content */
        .main {
            padding: 35px 40px;
            max-width: 1200px;
            margin: 0 auto;
        }

        .welcome-banner {
            background: white;
            border-radius: 16px;
            padding: 30px 35px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.07);
            margin-bottom: 30px;
            border-left: 5px solid #088395;
        }

        .welcome-banner h2 {
            font-size: 1.6rem;
            color: #0a4d68;
            margin-bottom: 6px;
        }

        .welcome-banner p {
            color: #666;
            font-size: 0.95rem;
        }

        .badge {
            display: inline-block;
            background: #e0f7fa;
            color: #088395;
            padding: 3px 10px;
            border-radius: 20px;
            font-size: 0.78rem;
            font-weight: 600;
            margin-left: 10px;
            text-transform: uppercase;
        }

        /* Cards */
        .cards-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 20px;
        }

        .card {
            background: white;
            border-radius: 16px;
            padding: 28px 24px;
            box-shadow: 0 4px 18px rgba(0,0,0,0.07);
            text-align: center;
            transition: transform 0.2s, box-shadow 0.2s;
            cursor: pointer;
        }

        .card:hover {
            transform: translateY(-4px);
            box-shadow: 0 8px 28px rgba(0,0,0,0.12);
        }

        .card .icon {
            font-size: 2.8rem;
            margin-bottom: 14px;
        }

        .card h3 {
            font-size: 1rem;
            color: #0a4d68;
            font-weight: 600;
        }

        .card p {
            font-size: 0.82rem;
            color: #999;
            margin-top: 6px;
        }
    </style>
</head>
<body>

<!-- Navbar -->
<nav class="navbar">
    <div class="brand">
        &#127754; Ocean View Resort
    </div>
    <div class="user-info">
        <span>Hello, <strong><%= loggedUser.getFullName() != null ? loggedUser.getFullName() : loggedUser.getUsername() %></strong>
            <span class="badge"><%= loggedUser.getRole() != null ? loggedUser.getRole() : "user" %></span>
        </span>
        <a href="<%= request.getContextPath() %>/help">Help</a>
        <a href="<%= request.getContextPath() %>/logout" class="btn-logout">Logout</a>
        <a href="javascript:void(0)" onclick="showExitConfirm()" class="btn-exit">&#x23FB; Exit System</a>
    </div>
</nav>

<!-- Main -->
<div class="main">

    <!-- Welcome Banner -->
    <div class="welcome-banner">
        <h2>Welcome back, <%= loggedUser.getFullName() != null ? loggedUser.getFullName() : loggedUser.getUsername() %>!</h2>
        <p>You are logged in as <strong><%= loggedUser.getUsername() %></strong>. Manage your resort from the dashboard below.</p>
    </div>

    <!-- Quick Access Cards -->
    <div class="cards-grid">
        <div class="card">
            <div class="icon">&#127968;</div>
            <h3>Rooms</h3>
            <p>Manage room availability</p>
        </div>
        <div class="card" onclick="location.href='<%= request.getContextPath() %>/reservations'">
            <div class="icon">&#128203;</div>
            <h3>Reservations</h3>
            <p>View and manage bookings</p>
        </div>
        <div class="card">
            <div class="icon">&#128101;</div>
            <h3>Guests</h3>
            <p>Guest records & profiles</p>
        </div>
        <div class="card">
            <div class="icon">&#128184;</div>
            <h3>Payments</h3>
            <p>Billing &amp; invoices</p>
        </div>
        <div class="card">
            <div class="icon">&#128202;</div>
            <h3>Reports</h3>
            <p>Analytics &amp; statistics</p>
        </div>
        <div class="card" onclick="location.href='<%= request.getContextPath() %>/help'">
            <div class="icon">&#9881;</div>
            <h3>Settings</h3>
            <p>System configuration</p>
        </div>
        <div class="card" onclick="showExitConfirm()" style="border: 2px solid #fdecea;">
            <div class="icon">&#x23FB;</div>
            <h3>Exit System</h3>
            <p>Safely close your session</p>
        </div>
    </div>

    <!-- Help shortcut banner -->
    <div style="margin-top:28px; background:linear-gradient(135deg,#e0f7fa,#e8f5e9);
                border-radius:14px; padding:20px 28px; display:flex; align-items:center; gap:18px;
                box-shadow:0 2px 10px rgba(0,0,0,0.05);">
        <span style="font-size:2.2rem;">&#128218;</span>
        <div>
            <strong style="color:#0a4d68;font-size:1rem;">New to the system?</strong>
            <p style="font-size:0.87rem;color:#555;margin-top:3px;">
                Visit the <a href="<%= request.getContextPath() %>/help" style="color:#088395;font-weight:600;">Help &amp; Staff Guide</a>
                for step-by-step instructions on managing reservations, generating invoices, and more.
            </p>
        </div>
    </div>

</div><!-- /main -->

<!-- ===== Exit Confirm Overlay ===== -->
<div class="overlay" id="exitOverlay">
    <div class="confirm-box">
        <div class="c-icon">&#x23FB;</div>
        <h3>Exit System?</h3>
        <p>You are about to end your session. All unsaved work will be lost.<br>
           Are you sure you want to exit?</p>
        <div class="confirm-btns">
            <button class="btn-cancel-exit" onclick="hideExitConfirm()">Cancel</button>
            <a href="<%= request.getContextPath() %>/exit" class="btn-confirm-exit">Yes, Exit</a>
        </div>
    </div>
</div>

<script>
    function showExitConfirm() {
        document.getElementById('exitOverlay').classList.add('show');
    }
    function hideExitConfirm() {
        document.getElementById('exitOverlay').classList.remove('show');
    }
    // Close on backdrop click
    document.getElementById('exitOverlay').addEventListener('click', function(e) {
        if (e.target === this) hideExitConfirm();
    });
    // Close on Escape
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') hideExitConfirm();
    });
</script>

</body>
</html>
