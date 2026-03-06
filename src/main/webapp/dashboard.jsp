<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.example.oceanviewresort.model.User" %>
<%
    User loggedUser = (User) session.getAttribute("loggedUser");
    if (loggedUser == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    java.time.LocalTime now = java.time.LocalTime.now();
    String greeting = now.getHour() < 12 ? "Good Morning" : now.getHour() < 17 ? "Good Afternoon" : "Good Evening";
    String displayName = loggedUser.getFullName() != null ? loggedUser.getFullName() : loggedUser.getUsername();
    String roleName = loggedUser.getRole() != null ? loggedUser.getRole() : "Staff";
    java.time.format.DateTimeFormatter dtf = java.time.format.DateTimeFormatter.ofPattern("EEEE, MMMM d, yyyy");
    String dateStr = java.time.LocalDate.now().format(dtf);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard â€” Ocean View Resort</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">
    <style>
        *, *::before, *::after { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            font-family: 'Inter', 'Segoe UI', sans-serif;
            background: #f1f5f9;
            color: #1e293b;
            min-height: 100vh;
        }

        /* â”€â”€ NAVBAR â”€â”€ */
        .navbar {
            background: linear-gradient(135deg, #0a2540 0%, #0a4d68 60%, #088395 100%);
            height: 68px;
            padding: 0 36px;
            display: flex; align-items: center; justify-content: space-between;
            position: sticky; top: 0; z-index: 200;
            box-shadow: 0 2px 20px rgba(10,37,64,0.4);
        }
        .navbar-left { display: flex; align-items: center; gap: 14px; }
        .nav-logo {
            width: 38px; height: 38px; border-radius: 10px;
            background: rgba(255,255,255,0.15); border: 1px solid rgba(255,255,255,0.25);
            display: flex; align-items: center; justify-content: center;
            font-size: 1.3rem;
        }
        .nav-brand { color: white; font-size: 1.05rem; font-weight: 700; letter-spacing: -0.3px; }
        .nav-brand small { display: block; font-size: 0.68rem; font-weight: 400; opacity: 0.6; letter-spacing: 0.5px; }

        .navbar-right { display: flex; align-items: center; gap: 10px; }
        .nav-link {
            color: rgba(255,255,255,0.75); text-decoration: none;
            font-size: 0.85rem; font-weight: 500; padding: 6px 12px; border-radius: 8px;
            transition: background 0.15s, color 0.15s;
        }
        .nav-link:hover { color: white; background: rgba(255,255,255,0.1); }
        .nav-btn-logout {
            color: white; text-decoration: none;
            background: rgba(255,255,255,0.12); border: 1px solid rgba(255,255,255,0.25);
            font-size: 0.82rem; font-weight: 600; padding: 7px 16px; border-radius: 8px;
            transition: background 0.15s;
        }
        .nav-btn-logout:hover { background: rgba(255,255,255,0.22); }
        .nav-btn-exit {
            color: white; text-decoration: none;
            background: rgba(239,68,68,0.2); border: 1px solid rgba(239,68,68,0.45);
            font-size: 0.82rem; font-weight: 600; padding: 7px 16px; border-radius: 8px;
            cursor: pointer; transition: background 0.15s;
        }
        .nav-btn-exit:hover { background: rgba(239,68,68,0.4); }
        .user-chip {
            display: flex; align-items: center; gap: 9px;
            background: rgba(255,255,255,0.1); border: 1px solid rgba(255,255,255,0.2);
            border-radius: 30px; padding: 5px 14px 5px 6px; color: white;
        }
        .user-avatar {
            width: 28px; height: 28px; border-radius: 50%;
            background: linear-gradient(135deg, #0bb8c4, #0891b2);
            display: flex; align-items: center; justify-content: center;
            font-size: 0.75rem; font-weight: 700; border: 2px solid rgba(255,255,255,0.4);
        }
        .user-chip-name { font-size: 0.82rem; font-weight: 600; }
        .user-chip-role { font-size: 0.68rem; opacity: 0.65; }

        /* â”€â”€ MAIN â”€â”€ */
        .main { max-width: 1240px; margin: 0 auto; padding: 38px 28px 60px; }

        /* Hero welcome banner */
        .welcome {
            background: linear-gradient(135deg, #0a2540 0%, #0a4d68 50%, #0bb8c4 100%);
            border-radius: 22px; padding: 36px 44px;
            display: flex; align-items: center; justify-content: space-between;
            margin-bottom: 32px; position: relative; overflow: hidden;
            box-shadow: 0 8px 32px rgba(10,37,64,0.25);
        }
        .welcome::before {
            content: '';
            position: absolute; top: -50px; right: -50px;
            width: 280px; height: 280px; border-radius: 50%;
            background: rgba(255,255,255,0.06); pointer-events: none;
        }
        .welcome::after {
            content: '';
            position: absolute; bottom: -40px; right: 200px;
            width: 180px; height: 180px; border-radius: 50%;
            background: rgba(255,255,255,0.04); pointer-events: none;
        }
        .welcome-text { color: white; position: relative; z-index: 1; }
        .welcome-text .label {
            font-size: 0.72rem; font-weight: 600; letter-spacing: 2.5px;
            text-transform: uppercase; color: #4dd9e8; margin-bottom: 8px;
        }
        .welcome-text h2 {
            font-size: 2rem; font-weight: 800; letter-spacing: -0.7px; margin-bottom: 6px;
        }
        .welcome-text p { font-size: 0.9rem; opacity: 0.7; }
        .welcome-badge {
            background: rgba(255,255,255,0.12);
            border: 1px solid rgba(255,255,255,0.2);
            border-radius: 14px; padding: 20px 28px;
            color: white; text-align: center;
            position: relative; z-index: 1;
            backdrop-filter: blur(8px);
        }
        .welcome-badge .wb-icon { font-size: 2.2rem; margin-bottom: 8px; }
        .welcome-badge .wb-date { font-size: 0.78rem; opacity: 0.7; }
        .welcome-badge .wb-role {
            display: inline-block; margin-top: 6px;
            background: rgba(77,217,232,0.25); border: 1px solid rgba(77,217,232,0.4);
            color: #4dd9e8; padding: 3px 12px; border-radius: 20px;
            font-size: 0.72rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.8px;
        }

        /* â”€â”€ Section heading â”€â”€ */
        .section-heading {
            font-size: 0.72rem; font-weight: 700; text-transform: uppercase;
            letter-spacing: 2px; color: #64748b; margin-bottom: 16px;
            display: flex; align-items: center; gap: 10px;
        }
        .section-heading::after {
            content: ''; flex: 1; height: 1px; background: #e2e8f0;
        }

        /* â”€â”€ Nav Cards Grid â”€â”€ */
        .cards-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(230px, 1fr));
            gap: 18px;
            margin-bottom: 32px;
        }

        .nav-card {
            background: white;
            border-radius: 18px;
            padding: 0;
            box-shadow: 0 2px 12px rgba(0,0,0,0.06);
            cursor: pointer; text-decoration: none; display: block;
            transition: transform 0.22s cubic-bezier(.32,1.25,.55,1), box-shadow 0.22s;
            overflow: hidden; border: 1px solid #f0f4f8;
        }
        .nav-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 12px 36px rgba(0,0,0,0.12);
        }
        .nav-card-header {
            height: 6px; width: 100%;
        }
        .nav-card-body {
            padding: 22px 22px 20px;
            display: flex; align-items: flex-start; gap: 14px;
        }
        .nav-card-icon {
            width: 48px; height: 48px; border-radius: 14px; flex-shrink: 0;
            display: flex; align-items: center; justify-content: center;
            font-size: 1.5rem;
        }
        .nav-card-text h3 {
            font-size: 0.97rem; font-weight: 700; color: #0f172a; margin-bottom: 4px;
        }
        .nav-card-text p { font-size: 0.8rem; color: #94a3b8; line-height: 1.5; }
        .nav-card-arrow {
            margin-top: auto; margin-left: auto; align-self: flex-end;
            font-size: 0.8rem; color: #cbd5e1; transition: color 0.15s;
        }
        .nav-card:hover .nav-card-arrow { color: #0bb8c4; }

        /* Card accent colors */
        .card-teal   .nav-card-header { background: linear-gradient(90deg,#0a4d68,#0bb8c4); }
        .card-teal   .nav-card-icon   { background: #e0f7fa; }
        .card-blue   .nav-card-header { background: linear-gradient(90deg,#1e40af,#3b82f6); }
        .card-blue   .nav-card-icon   { background: #eff6ff; }
        .card-green  .nav-card-header { background: linear-gradient(90deg,#065f46,#10b981); }
        .card-green  .nav-card-icon   { background: #ecfdf5; }
        .card-amber  .nav-card-header { background: linear-gradient(90deg,#92400e,#f59e0b); }
        .card-amber  .nav-card-icon   { background: #fffbeb; }
        .card-violet .nav-card-header { background: linear-gradient(90deg,#4c1d95,#8b5cf6); }
        .card-violet .nav-card-icon   { background: #f5f3ff; }
        .card-slate  .nav-card-header { background: linear-gradient(90deg,#334155,#64748b); }
        .card-slate  .nav-card-icon   { background: #f8fafc; }
        .card-red    .nav-card-header { background: linear-gradient(90deg,#991b1b,#ef4444); }
        .card-red    .nav-card-icon   { background: #fef2f2; }

        /* â”€â”€ Quick tip banner â”€â”€ */
        .tip-banner {
            background: white; border-radius: 16px; padding: 22px 28px;
            display: flex; align-items: center; gap: 20px;
            box-shadow: 0 2px 12px rgba(0,0,0,0.05);
            border: 1px solid #e0f7fa;
        }
        .tip-icon { font-size: 2rem; flex-shrink: 0; }
        .tip-banner h4 { font-size: 0.9rem; font-weight: 700; color: #0a4d68; margin-bottom: 3px; }
        .tip-banner p  { font-size: 0.82rem; color: #64748b; line-height: 1.5; }
        .tip-banner a  { color: #0bb8c4; font-weight: 600; text-decoration: none; }
        .tip-banner a:hover { text-decoration: underline; }

        /* â”€â”€ Exit overlay â”€â”€ */
        .overlay {
            display: none; position: fixed; inset: 0;
            background: rgba(10,22,40,0.65); z-index: 999;
            align-items: center; justify-content: center;
            backdrop-filter: blur(4px);
        }
        .overlay.show { display: flex; }
        .confirm-box {
            background: white; border-radius: 22px; padding: 40px 44px;
            max-width: 420px; width: 90%; text-align: center;
            box-shadow: 0 24px 64px rgba(0,0,0,0.3);
            animation: popIn 0.28s cubic-bezier(.32,1.25,.55,1);
        }
        @keyframes popIn {
            from { transform: scale(0.85); opacity: 0; }
            to   { transform: scale(1);    opacity: 1; }
        }
        .confirm-box .c-icon { font-size: 2.8rem; margin-bottom: 16px; }
        .confirm-box h3 { font-size: 1.2rem; font-weight: 700; color: #0a1628; margin-bottom: 8px; }
        .confirm-box p  { font-size: 0.88rem; color: #64748b; line-height: 1.6; margin-bottom: 28px; }
        .confirm-btns { display: flex; gap: 12px; justify-content: center; }
        .btn-confirm-exit {
            background: linear-gradient(135deg, #dc2626, #ef4444);
            color: white; border: none; padding: 12px 28px;
            border-radius: 10px; font-size: 0.92rem; font-weight: 700;
            font-family: 'Inter', sans-serif;
            cursor: pointer; text-decoration: none;
            box-shadow: 0 4px 14px rgba(239,68,68,0.4);
            transition: opacity 0.15s;
        }
        .btn-confirm-exit:hover { opacity: 0.88; }
        .btn-cancel-exit {
            background: #f1f5f9; color: #475569;
            border: 2px solid #e2e8f0; padding: 12px 28px;
            border-radius: 10px; font-size: 0.92rem; font-weight: 600;
            font-family: 'Inter', sans-serif; cursor: pointer;
            transition: border-color 0.15s;
        }
        .btn-cancel-exit:hover { border-color: #94a3b8; }
    </style>
</head>
<body>

<!-- NAVBAR -->
<nav class="navbar">
    <div class="navbar-left">
        <div class="nav-logo">&#127754;</div>
        <div class="nav-brand">
            Ocean View Resort
            <small>Management Portal</small>
        </div>
    </div>
    <div class="navbar-right">
        <a href="<%= request.getContextPath() %>/help" class="nav-link">Help</a>
        <div class="user-chip">
            <div class="user-avatar"><%= displayName.substring(0,1).toUpperCase() %></div>
            <div>
                <div class="user-chip-name"><%= displayName %></div>
                <div class="user-chip-role"><%= roleName %></div>
            </div>
        </div>
        <a href="<%= request.getContextPath() %>/logout" class="nav-btn-logout">Logout</a>
        <a href="javascript:void(0)" onclick="showExitConfirm()" class="nav-btn-exit">&#x23FB; Exit</a>
    </div>
</nav>

<div class="main">

    <!-- Welcome Banner -->
    <div class="welcome">
        <div class="welcome-text">
            <div class="label">Staff Dashboard</div>
            <h2><%= greeting %>, <%= displayName %>! &#x1F44B;</h2>
            <p>Manage your resort operations from one central hub.</p>
        </div>
        <div class="welcome-badge">
            <div class="wb-icon">&#127754;</div>
            <div class="wb-date"><%= dateStr %></div>
            <div class="wb-role"><%= roleName %></div>
        </div>
    </div>

    <!-- Nav Cards -->
    <div class="section-heading">Quick Access</div>
    <div class="cards-grid">

        <a href="<%= request.getContextPath() %>/rooms" class="nav-card card-teal">
            <div class="nav-card-header"></div>
            <div class="nav-card-body">
                <div class="nav-card-icon">&#127968;</div>
                <div class="nav-card-text">
                    <h3>Rooms</h3>
                    <p>View availability, update room status and manage inventory.</p>
                </div>
                <div class="nav-card-arrow">&#8594;</div>
            </div>
        </a>

        <a href="<%= request.getContextPath() %>/reservations" class="nav-card card-blue">
            <div class="nav-card-header"></div>
            <div class="nav-card-body">
                <div class="nav-card-icon">&#128203;</div>
                <div class="nav-card-text">
                    <h3>Reservations</h3>
                    <p>Create, edit and track all guest bookings.</p>
                </div>
                <div class="nav-card-arrow">&#8594;</div>
            </div>
        </a>

        <a href="<%= request.getContextPath() %>/guests" class="nav-card card-green">
            <div class="nav-card-header"></div>
            <div class="nav-card-body">
                <div class="nav-card-icon">&#128101;</div>
                <div class="nav-card-text">
                    <h3>Guests</h3>
                    <p>Guest profiles, contact info and stay history.</p>
                </div>
                <div class="nav-card-arrow">&#8594;</div>
            </div>
        </a>

        <a href="<%= request.getContextPath() %>/payments" class="nav-card card-amber">
            <div class="nav-card-header"></div>
            <div class="nav-card-body">
                <div class="nav-card-icon">&#128184;</div>
                <div class="nav-card-text">
                    <h3>Payments</h3>
                    <p>Billing totals, invoices and payment records.</p>
                </div>
                <div class="nav-card-arrow">&#8594;</div>
            </div>
        </a>

        <a href="<%= request.getContextPath() %>/reports" class="nav-card card-violet">
            <div class="nav-card-header"></div>
            <div class="nav-card-body">
                <div class="nav-card-icon">&#128202;</div>
                <div class="nav-card-text">
                    <h3>Reports</h3>
                    <p>Occupancy analytics, revenue charts and trends.</p>
                </div>
                <div class="nav-card-arrow">&#8594;</div>
            </div>
        </a>

        <a href="<%= request.getContextPath() %>/help" class="nav-card card-slate">
            <div class="nav-card-header"></div>
            <div class="nav-card-body">
                <div class="nav-card-icon">&#128218;</div>
                <div class="nav-card-text">
                    <h3>Help &amp; Guide</h3>
                    <p>Staff documentation, FAQs and step-by-step guides.</p>
                </div>
                <div class="nav-card-arrow">&#8594;</div>
            </div>
        </a>

        <a href="javascript:void(0)" onclick="showExitConfirm()" class="nav-card card-red" style="text-decoration:none;">
            <div class="nav-card-header"></div>
            <div class="nav-card-body">
                <div class="nav-card-icon">&#x23FB;</div>
                <div class="nav-card-text">
                    <h3>Exit System</h3>
                    <p>End your session and securely sign out.</p>
                </div>
                <div class="nav-card-arrow">&#8594;</div>
            </div>
        </a>

    </div>

    <!-- Tip Banner -->
    <div class="tip-banner">
        <div class="tip-icon">&#128161;</div>
        <div>
            <h4>New to the system?</h4>
            <p>Visit the <a href="<%= request.getContextPath() %>/help">Help &amp; Staff Guide</a> for step-by-step instructions on managing reservations, generating invoices, updating room statuses, and more.</p>
        </div>
    </div>

</div>

<!-- Exit Overlay -->
<div class="overlay" id="exitOverlay">
    <div class="confirm-box">
        <div class="c-icon">&#x23FB;</div>
        <h3>Exit System?</h3>
        <p>You are about to end your session.<br>Any unsaved work will be lost.</p>
        <div class="confirm-btns">
            <button class="btn-cancel-exit" onclick="hideExitConfirm()">Cancel</button>
            <a href="<%= request.getContextPath() %>/exit" class="btn-confirm-exit">Yes, Exit</a>
        </div>
    </div>
</div>

<script>
    function showExitConfirm() { document.getElementById('exitOverlay').classList.add('show'); }
    function hideExitConfirm() { document.getElementById('exitOverlay').classList.remove('show'); }
    document.getElementById('exitOverlay').addEventListener('click', function(e) {
        if (e.target === this) hideExitConfirm();
    });
    document.addEventListener('keydown', function(e) { if (e.key === 'Escape') hideExitConfirm(); });
</script>

</body>
</html>
