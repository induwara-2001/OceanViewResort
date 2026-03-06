<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.example.oceanviewresort.model.User" %>
<%
    User loggedUser = (User) session.getAttribute("loggedUser");
    if (loggedUser == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    String activeSection = (String) request.getAttribute("activeSection");
    if (activeSection == null) activeSection = "";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Help &amp; Staff Guide — Ocean View Resort</title>
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

        /* Navbar */
        .navbar {
            background: linear-gradient(135deg, #0a2540 0%, #0a4d68 60%, #088395 100%);
            height: 68px; padding: 0 36px;
            display: flex; align-items: center; justify-content: space-between;
            position: sticky; top: 0; z-index: 100;
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

        /* Layout */
        .page-wrapper {
            display: flex;
            max-width: 1150px;
            margin: 36px auto;
            padding: 0 20px;
            gap: 26px;
            align-items: flex-start;
        }

        /* ===== Sidebar ===== */
        .sidebar {
            width: 240px;
            flex-shrink: 0;
            background: white;
            border-radius: 14px;
            box-shadow: 0 4px 18px rgba(0,0,0,0.07);
            overflow: hidden;
            position: sticky;
            top: 85px;
        }
        .sidebar-header {
            background: linear-gradient(135deg, #0a4d68, #088395);
            color: white;
            padding: 16px 20px;
            font-size: 0.78rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 1px;
        }
        .sidebar ul { list-style: none; padding: 8px 0; }
        .sidebar ul li a {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 10px 20px;
            text-decoration: none;
            color: #555;
            font-size: 0.88rem;
            transition: background 0.15s, color 0.15s;
            border-left: 3px solid transparent;
        }
        .sidebar ul li a:hover,
        .sidebar ul li a.active {
            background: #e0f7fa;
            color: #088395;
            border-left-color: #088395;
        }
        .sidebar ul li a .icon { font-size: 1rem; width: 20px; text-align: center; }

        /* ===== Main content ===== */
        .main-content { flex: 1; min-width: 0; }

        /* Page title */
        .page-title-card {
            background: linear-gradient(135deg, #0a4d68, #088395);
            color: white;
            border-radius: 14px;
            padding: 28px 32px;
            margin-bottom: 24px;
            display: flex;
            align-items: center;
            gap: 20px;
        }
        .page-title-card .big-icon { font-size: 3rem; }
        .page-title-card h1 { font-size: 1.6rem; font-weight: 700; }
        .page-title-card p  { font-size: 0.9rem; opacity: 0.88; margin-top: 5px; line-height: 1.5; }

        /* Section */
        .section {
            background: white;
            border-radius: 14px;
            box-shadow: 0 4px 18px rgba(0,0,0,0.07);
            margin-bottom: 22px;
            overflow: hidden;
            scroll-margin-top: 90px;
        }
        .section-header {
            padding: 18px 28px;
            border-bottom: 1px solid #f0f4f8;
            display: flex;
            align-items: center;
            gap: 12px;
            cursor: pointer;
            user-select: none;
        }
        .section-header .s-icon {
            width: 40px;
            height: 40px;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.2rem;
            flex-shrink: 0;
        }
        .bg-blue   { background: #e3f2fd; }
        .bg-green  { background: #e8f5e9; }
        .bg-orange { background: #fff3e0; }
        .bg-purple { background: #f3e5f5; }
        .bg-teal   { background: #e0f7fa; }
        .bg-red    { background: #fce4ec; }

        .section-header h2 { font-size: 1.05rem; color: #0a4d68; font-weight: 700; }
        .section-header p  { font-size: 0.8rem; color: #999; margin-top: 2px; }
        .section-header .arrow {
            margin-left: auto;
            font-size: 0.9rem;
            color: #aaa;
            transition: transform 0.25s;
        }
        .section-header.open .arrow { transform: rotate(180deg); }

        .section-body { padding: 22px 28px; display: none; }
        .section-body.show { display: block; }

        /* Steps */
        .steps { counter-reset: step; list-style: none; }
        .steps li {
            display: flex;
            gap: 14px;
            margin-bottom: 16px;
            align-items: flex-start;
        }
        .steps li:last-child { margin-bottom: 0; }
        .step-num {
            counter-increment: step;
            width: 28px;
            height: 28px;
            border-radius: 50%;
            background: linear-gradient(135deg, #0a4d68, #088395);
            color: white;
            font-size: 0.78rem;
            font-weight: 700;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
            margin-top: 1px;
        }
        .step-text h4 { font-size: 0.93rem; font-weight: 600; color: #0a4d68; margin-bottom: 3px; }
        .step-text p  { font-size: 0.87rem; color: #666; line-height: 1.6; }

        /* Tips */
        .tip-box {
            background: #e0f7fa;
            border-left: 4px solid #088395;
            border-radius: 0 8px 8px 0;
            padding: 12px 16px;
            margin-top: 16px;
            font-size: 0.87rem;
            color: #0a4d68;
            line-height: 1.6;
        }
        .tip-box strong { display: block; margin-bottom: 3px; }

        .warn-box {
            background: #fff8e1;
            border-left: 4px solid #f39c12;
            border-radius: 0 8px 8px 0;
            padding: 12px 16px;
            margin-top: 12px;
            font-size: 0.87rem;
            color: #7a5000;
            line-height: 1.6;
        }
        .warn-box strong { display: block; margin-bottom: 3px; }

        /* Table */
        .help-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 14px;
            font-size: 0.88rem;
        }
        .help-table th {
            background: #f7fbfc;
            padding: 10px 14px;
            text-align: left;
            font-weight: 700;
            color: #555;
            border-bottom: 2px solid #e9f5f7;
        }
        .help-table td {
            padding: 10px 14px;
            border-bottom: 1px solid #f4f4f4;
            color: #444;
            vertical-align: top;
        }
        .help-table tr:last-child td { border-bottom: none; }
        .badge-role {
            display: inline-block;
            padding: 2px 10px;
            border-radius: 20px;
            font-size: 0.75rem;
            font-weight: 600;
        }
        .badge-admin    { background: #fdecea; color: #c0392b; }
        .badge-manager  { background: #e8f8f0; color: #1a7a4a; }
        .badge-staff    { background: #e3f2fd; color: #1565c0; }

        /* FAQ */
        .faq-item { margin-bottom: 14px; }
        .faq-q {
            font-weight: 600;
            color: #0a4d68;
            font-size: 0.92rem;
            margin-bottom: 5px;
            display: flex;
            gap: 8px;
        }
        .faq-q::before { content: "Q."; color: #088395; font-weight: 800; }
        .faq-a {
            font-size: 0.87rem;
            color: #555;
            line-height: 1.65;
            padding-left: 22px;
        }

        /* Quick ref */
        .quick-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 12px;
            margin-top: 4px;
        }
        .quick-item {
            background: #f7fbfc;
            border: 1px solid #e0f0f4;
            border-radius: 10px;
            padding: 14px 16px;
        }
        .quick-item .q-url {
            font-size: 0.78rem;
            background: #e0f7fa;
            color: #0a4d68;
            padding: 2px 8px;
            border-radius: 5px;
            font-family: monospace;
            font-weight: 600;
            display: inline-block;
            margin-bottom: 6px;
        }
        .quick-item h4 { font-size: 0.9rem; color: #0a4d68; margin-bottom: 3px; }
        .quick-item p  { font-size: 0.82rem; color: #777; }

        @media (max-width: 750px) {
            .page-wrapper { flex-direction: column; }
            .sidebar { width: 100%; position: static; }
            .quick-grid { grid-template-columns: 1fr; }
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
        <a href="<%= request.getContextPath() %>/guests">Guests</a>
        <a href="<%= request.getContextPath() %>/payments">Payments</a>
        <a href="<%= request.getContextPath() %>/reports">Reports</a>
        <a href="<%= request.getContextPath() %>/help" class="active">Help</a>
        <a href="<%= request.getContextPath() %>/logout" class="btn-logout">Logout</a>
    </div>
</nav>

<div class="page-wrapper">

    <!-- ===== Sidebar ===== -->
    <aside class="sidebar">
        <div class="sidebar-header">&#128218; Contents</div>
        <ul>
            <li><a href="#getting-started" class="nav-link"><span class="icon">&#127968;</span> Getting Started</a></li>
            <li><a href="#login"           class="nav-link"><span class="icon">&#128274;</span> Login &amp; Logout</a></li>
            <li><a href="#reservations"    class="nav-link"><span class="icon">&#128203;</span> Reservations</a></li>
            <li><a href="#add-reservation" class="nav-link"><span class="icon">&#10133;</span> Add Reservation</a></li>
            <li><a href="#view-details"    class="nav-link"><span class="icon">&#128269;</span> View Details</a></li>
            <li><a href="#billing"         class="nav-link"><span class="icon">&#128184;</span> Billing &amp; Invoice</a></li>
            <li><a href="#roles"           class="nav-link"><span class="icon">&#128101;</span> User Roles</a></li>
            <li><a href="#faq"             class="nav-link"><span class="icon">&#10067;</span> FAQ</a></li>
            <li><a href="#quickref"        class="nav-link"><span class="icon">&#9889;</span> Quick Reference</a></li>
        </ul>
    </aside>

    <!-- ===== Main ===== -->
    <div class="main-content">

        <!-- Page title -->
        <div class="page-title-card">
            <div class="big-icon">&#128218;</div>
            <div>
                <h1>Help &amp; Staff Guide</h1>
                <p>Welcome, <strong><%= loggedUser.getFullName() != null ? loggedUser.getFullName() : loggedUser.getUsername() %></strong>!
                   This guide walks you through everything you need to operate the Ocean View Resort management system.</p>
            </div>
        </div>

        <!-- ===== 1. Getting Started ===== -->
        <div class="section" id="getting-started">
            <div class="section-header open" onclick="toggleSection(this)">
                <div class="s-icon bg-blue">&#127968;</div>
                <div>
                    <h2>Getting Started</h2>
                    <p>System overview and navigation basics</p>
                </div>
                <span class="arrow">&#9660;</span>
            </div>
            <div class="section-body show">
                <p style="font-size:0.9rem;color:#555;line-height:1.7;margin-bottom:16px;">
                    The <strong>Ocean View Resort Management System</strong> is a web-based application that allows hotel
                    staff to manage guest reservations, view booking details, and generate invoices — all from one place.
                </p>
                <ul class="steps">
                    <li><div class="step-num">1</div><div class="step-text"><h4>Open Your Browser</h4><p>Use Google Chrome or Mozilla Firefox for the best experience. Navigate to <code>localhost:8080/OceanViewResort_war_exploded/</code>.</p></div></li>
                    <li><div class="step-num">2</div><div class="step-text"><h4>Log In</h4><p>Enter your username and password provided by your manager. The system will redirect you to the Dashboard.</p></div></li>
                    <li><div class="step-num">3</div><div class="step-text"><h4>Use the Dashboard</h4><p>The Dashboard shows quick-access cards for all major modules. Click any card to navigate to that section.</p></div></li>
                    <li><div class="step-num">4</div><div class="step-text"><h4>Use the Top Navigation</h4><p>The navigation bar at the top is always visible. Use it to jump between Dashboard, Reservations, and to Logout.</p></div></li>
                </ul>
                <div class="tip-box">
                    <strong>&#128161; Tip</strong>
                    Your session will automatically expire after <strong>30 minutes</strong> of inactivity. Always log out when you leave your workstation.
                </div>
            </div>
        </div>

        <!-- ===== 2. Login & Logout ===== -->
        <div class="section" id="login">
            <div class="section-header open" onclick="toggleSection(this)">
                <div class="s-icon bg-teal">&#128274;</div>
                <div>
                    <h2>Login &amp; Logout</h2>
                    <p>How to securely access and exit the system</p>
                </div>
                <span class="arrow">&#9660;</span>
            </div>
            <div class="section-body show">
                <ul class="steps">
                    <li><div class="step-num">1</div><div class="step-text"><h4>Go to Login Page</h4><p>The system automatically redirects you to the login page when you open the application URL.</p></div></li>
                    <li><div class="step-num">2</div><div class="step-text"><h4>Enter Credentials</h4><p>Type your <strong>Username</strong> and <strong>Password</strong> exactly as given. Passwords are case-sensitive.</p></div></li>
                    <li><div class="step-num">3</div><div class="step-text"><h4>Click "Sign In"</h4><p>On success you are taken to the Dashboard. If you see <em>"Invalid username or password"</em>, double-check your credentials and try again.</p></div></li>
                    <li><div class="step-num">4</div><div class="step-text"><h4>Logging Out</h4><p>Click the <strong>Logout</strong> button in the top-right corner at any time. This clears your session immediately.</p></div></li>
                </ul>
                <div class="warn-box">
                    <strong>&#9888; Important</strong>
                    Never share your password with other staff. If you think your account has been compromised, inform your system administrator immediately.
                </div>
            </div>
        </div>

        <!-- ===== 3. Reservations List ===== -->
        <div class="section" id="reservations">
            <div class="section-header open" onclick="toggleSection(this)">
                <div class="s-icon bg-green">&#128203;</div>
                <div>
                    <h2>Reservations List</h2>
                    <p>Viewing and managing all bookings</p>
                </div>
                <span class="arrow">&#9660;</span>
            </div>
            <div class="section-body show">
                <p style="font-size:0.9rem;color:#555;line-height:1.7;margin-bottom:16px;">
                    The Reservations page displays all guest bookings in a table sorted by the most recent first.
                </p>
                <ul class="steps">
                    <li><div class="step-num">1</div><div class="step-text"><h4>Access Reservations</h4><p>Click <strong>Reservations</strong> in the top navigation bar, or click the <em>Reservations card</em> on the Dashboard.</p></div></li>
                    <li><div class="step-num">2</div><div class="step-text"><h4>Read the Table</h4><p>Each row shows: Reservation Number, Guest Name, Contact, Room Type, Check-In, Check-Out, and Status.</p></div></li>
                    <li><div class="step-num">3</div><div class="step-text"><h4>Status Badges</h4><p>Coloured badges show the current state of each booking.</p></div></li>
                    <li><div class="step-num">4</div><div class="step-text"><h4>View a Reservation</h4><p>Click the <strong>View</strong> button on any row to open the full reservation details page.</p></div></li>
                </ul>

                <table class="help-table">
                    <thead><tr><th>Badge</th><th>Meaning</th></tr></thead>
                    <tbody>
                        <tr><td><span class="badge-role" style="background:#fff8e1;color:#f39c12;">PENDING</span></td><td>Reservation created but not yet confirmed by management.</td></tr>
                        <tr><td><span class="badge-role" style="background:#e8f8f0;color:#1a7a4a;">CONFIRMED</span></td><td>Booking has been confirmed and the room is reserved.</td></tr>
                        <tr><td><span class="badge-role" style="background:#e8eaf6;color:#3949ab;">CHECKED_OUT</span></td><td>Guest has completed their stay and checked out.</td></tr>
                        <tr><td><span class="badge-role" style="background:#fdecea;color:#c0392b;">CANCELLED</span></td><td>Reservation has been cancelled.</td></tr>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- ===== 4. Add Reservation ===== -->
        <div class="section" id="add-reservation">
            <div class="section-header open" onclick="toggleSection(this)">
                <div class="s-icon bg-orange">&#10133;</div>
                <div>
                    <h2>Adding a New Reservation</h2>
                    <p>Step-by-step guide to creating a booking</p>
                </div>
                <span class="arrow">&#9660;</span>
            </div>
            <div class="section-body show">
                <ul class="steps">
                    <li><div class="step-num">1</div><div class="step-text"><h4>Open the Add Form</h4><p>From the Reservations page, click the blue <strong>+ Add Reservation</strong> button at the top right.</p></div></li>
                    <li><div class="step-num">2</div><div class="step-text"><h4>Guest Full Name (Required)</h4><p>Enter the guest's full name exactly as it appears on their ID or passport. This is mandatory.</p></div></li>
                    <li><div class="step-num">3</div><div class="step-text"><h4>Address (Optional)</h4><p>Enter the guest's home address including street, city, and country. This can be filled in later.</p></div></li>
                    <li><div class="step-num">4</div><div class="step-text"><h4>Contact Number (Required)</h4><p>Enter the guest's mobile or telephone number with country code, e.g. <code>+94 77 123 4567</code>.</p></div></li>
                    <li><div class="step-num">5</div><div class="step-text"><h4>Room Type (Required)</h4><p>Select the room type from the dropdown. Available types are: Standard, Deluxe, Superior, Ocean View Suite, Family, Presidential Suite, and Penthouse Suite.</p></div></li>
                    <li><div class="step-num">6</div><div class="step-text"><h4>Check-In Date (Required)</h4><p>Select the guest's arrival date using the date picker. Cannot be in the past.</p></div></li>
                    <li><div class="step-num">7</div><div class="step-text"><h4>Check-Out Date (Required)</h4><p>Select the departure date. Must be <strong>after</strong> the check-in date. The system will prevent selecting an earlier date.</p></div></li>
                    <li><div class="step-num">8</div><div class="step-text"><h4>Save Reservation</h4><p>Click <strong>&#10003; Save Reservation</strong>. The system auto-generates a unique reservation number (e.g. <code>RES-2026-0001</code>) and shows it in the list.</p></div></li>
                </ul>
                <div class="tip-box">
                    <strong>&#128161; Auto-Generated Number</strong>
                    You do not need to enter a reservation number — the system creates it automatically in the format <code>RES-YYYY-XXXX</code> (e.g. RES-2026-0015).
                </div>
                <div class="warn-box">
                    <strong>&#9888; Common Mistakes to Avoid</strong>
                    &bull; Leaving Check-Out before Check-In &mdash; the system will reject it.<br>
                    &bull; Leaving Guest Name blank &mdash; this field is mandatory.<br>
                    &bull; Not selecting a Room Type &mdash; must be picked from the dropdown.
                </div>
            </div>
        </div>

        <!-- ===== 5. View Details ===== -->
        <div class="section" id="view-details">
            <div class="section-header open" onclick="toggleSection(this)">
                <div class="s-icon bg-purple">&#128269;</div>
                <div>
                    <h2>Viewing Reservation Details</h2>
                    <p>How to retrieve complete booking information</p>
                </div>
                <span class="arrow">&#9660;</span>
            </div>
            <div class="section-body show">
                <ul class="steps">
                    <li><div class="step-num">1</div><div class="step-text"><h4>Find the Reservation</h4><p>Go to the Reservations list and locate the booking by guest name or reservation number.</p></div></li>
                    <li><div class="step-num">2</div><div class="step-text"><h4>Click "View"</h4><p>Press the teal <strong>View</strong> button on the right side of the row.</p></div></li>
                    <li><div class="step-num">3</div><div class="step-text"><h4>Review Full Details</h4><p>The details page shows: booking reference, stay summary strip, guest information (name, contact, address), booking details (room type, dates, duration), and system info (ID, status, created date).</p></div></li>
                    <li><div class="step-num">4</div><div class="step-text"><h4>Print the Details</h4><p>Click the <strong>&#128424; Print</strong> button to print the details page. The navigation bar is hidden in print mode for a clean output.</p></div></li>
                    <li><div class="step-num">5</div><div class="step-text"><h4>Go to Bill</h4><p>To calculate the bill directly from this page, click <strong>&#128184; Calculate &amp; Print Bill</strong>.</p></div></li>
                </ul>
            </div>
        </div>

        <!-- ===== 6. Billing ===== -->
        <div class="section" id="billing">
            <div class="section-header open" onclick="toggleSection(this)">
                <div class="s-icon bg-green">&#128184;</div>
                <div>
                    <h2>Billing &amp; Invoice</h2>
                    <p>How to calculate the stay cost and print an invoice</p>
                </div>
                <span class="arrow">&#9660;</span>
            </div>
            <div class="section-body show">
                <ul class="steps">
                    <li><div class="step-num">1</div><div class="step-text"><h4>Open the Bill</h4><p>From the Reservation Details page, click <strong>Calculate &amp; Print Bill</strong>. You can also go directly to <code>/reservations/bill?id=X</code>.</p></div></li>
                    <li><div class="step-num">2</div><div class="step-text"><h4>Review the Charges</h4><p>The invoice shows a breakdown: Room Charge (rate × nights), Government Tax (10%), Service Charge (5%), and Grand Total.</p></div></li>
                    <li><div class="step-num">3</div><div class="step-text"><h4>Print the Invoice</h4><p>Click <strong>&#128424; Print Invoice</strong>. The printed output is clean &mdash; no navbar, no buttons, just the invoice.</p></div></li>
                    <li><div class="step-num">4</div><div class="step-text"><h4>Hand to Guest</h4><p>Give the printed invoice to the guest at checkout. The invoice includes the reservation number, guest details, itemised charges, and a footer message.</p></div></li>
                </ul>

                <table class="help-table" style="margin-top:16px;">
                    <thead><tr><th>Room Type</th><th>Rate per Night (USD)</th></tr></thead>
                    <tbody>
                        <tr><td>Standard Room</td><td>$ 80.00</td></tr>
                        <tr><td>Deluxe Room</td><td>$ 120.00</td></tr>
                        <tr><td>Superior Room</td><td>$ 150.00</td></tr>
                        <tr><td>Ocean View Suite</td><td>$ 200.00</td></tr>
                        <tr><td>Family Room</td><td>$ 180.00</td></tr>
                        <tr><td>Presidential Suite</td><td>$ 350.00</td></tr>
                        <tr><td>Penthouse Suite</td><td>$ 500.00</td></tr>
                    </tbody>
                </table>

                <div class="tip-box" style="margin-top:16px;">
                    <strong>&#128161; Bill Formula</strong>
                    Subtotal = Rate/Night &times; Nights &nbsp;|&nbsp;
                    Tax = Subtotal &times; 10% &nbsp;|&nbsp;
                    Service = Subtotal &times; 5% &nbsp;|&nbsp;
                    <strong>Grand Total = Subtotal + Tax + Service</strong>
                </div>
            </div>
        </div>

        <!-- ===== 7. User Roles ===== -->
        <div class="section" id="roles">
            <div class="section-header open" onclick="toggleSection(this)">
                <div class="s-icon bg-red">&#128101;</div>
                <div>
                    <h2>User Roles &amp; Permissions</h2>
                    <p>What each role can and cannot do</p>
                </div>
                <span class="arrow">&#9660;</span>
            </div>
            <div class="section-body show">
                <table class="help-table">
                    <thead>
                        <tr>
                            <th>Role</th>
                            <th>View Reservations</th>
                            <th>Add Reservation</th>
                            <th>Generate Invoice</th>
                            <th>Manage Users</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td><span class="badge-role badge-admin">Admin</span></td>
                            <td>&#10003; Yes</td>
                            <td>&#10003; Yes</td>
                            <td>&#10003; Yes</td>
                            <td>&#10003; Yes</td>
                        </tr>
                        <tr>
                            <td><span class="badge-role badge-manager">Manager</span></td>
                            <td>&#10003; Yes</td>
                            <td>&#10003; Yes</td>
                            <td>&#10003; Yes</td>
                            <td>&#10007; No</td>
                        </tr>
                        <tr>
                            <td><span class="badge-role badge-staff">Staff</span></td>
                            <td>&#10003; Yes</td>
                            <td>&#10003; Yes</td>
                            <td>&#10003; Yes</td>
                            <td>&#10007; No</td>
                        </tr>
                    </tbody>
                </table>
                <div class="warn-box" style="margin-top:16px;">
                    <strong>&#9888; Note</strong>
                    If you need access to functions not available under your role, contact your system administrator or hotel manager.
                </div>
            </div>
        </div>

        <!-- ===== 8. FAQ ===== -->
        <div class="section" id="faq">
            <div class="section-header open" onclick="toggleSection(this)">
                <div class="s-icon bg-teal">&#10067;</div>
                <div>
                    <h2>Frequently Asked Questions</h2>
                    <p>Common questions from new staff members</p>
                </div>
                <span class="arrow">&#9660;</span>
            </div>
            <div class="section-body show">
                <div class="faq-item">
                    <div class="faq-q">What do I do if I forget my password?</div>
                    <div class="faq-a">Contact your system administrator or hotel manager. They can reset your password in the database directly.</div>
                </div>
                <div class="faq-item">
                    <div class="faq-q">Can I edit or delete a reservation?</div>
                    <div class="faq-a">Currently the system supports adding and viewing reservations. For modifications or cancellations, inform your manager who will update it in the database. Future updates will add this feature.</div>
                </div>
                <div class="faq-item">
                    <div class="faq-q">Why does my session keep logging out?</div>
                    <div class="faq-a">Sessions expire after 30 minutes of inactivity for security. Simply log in again. If it happens more frequently, check with your IT team.</div>
                </div>
                <div class="faq-item">
                    <div class="faq-q">What if the system shows a database error?</div>
                    <div class="faq-a">This usually means the database server is not running. Notify your system administrator. Do not attempt to restart the server yourself unless authorised.</div>
                </div>
                <div class="faq-item">
                    <div class="faq-q">How do I find a specific reservation quickly?</div>
                    <div class="faq-a">Go to the Reservations list. Reservations are sorted by newest first. Use Ctrl+F in your browser to search for a guest name or reservation number on the current page.</div>
                </div>
                <div class="faq-item">
                    <div class="faq-q">The bill shows the wrong amount — what should I do?</div>
                    <div class="faq-a">Verify the check-in and check-out dates on the reservation. The bill is calculated automatically from those dates and the room rate. If dates are wrong, inform your manager.</div>
                </div>
            </div>
        </div>

        <!-- ===== 9. Quick Reference ===== -->
        <div class="section" id="quickref">
            <div class="section-header open" onclick="toggleSection(this)">
                <div class="s-icon bg-blue">&#9889;</div>
                <div>
                    <h2>Quick Reference</h2>
                    <p>Key URLs and shortcuts at a glance</p>
                </div>
                <span class="arrow">&#9660;</span>
            </div>
            <div class="section-body show">
                <div class="quick-grid">
                    <div class="quick-item">
                        <div class="q-url">/login</div>
                        <h4>Login Page</h4>
                        <p>Sign in to the system with username &amp; password.</p>
                    </div>
                    <div class="quick-item">
                        <div class="q-url">/dashboard</div>
                        <h4>Dashboard</h4>
                        <p>Overview &amp; quick-access to all modules.</p>
                    </div>
                    <div class="quick-item">
                        <div class="q-url">/reservations</div>
                        <h4>Reservations List</h4>
                        <p>View all guest bookings in a table.</p>
                    </div>
                    <div class="quick-item">
                        <div class="q-url">/reservations/add</div>
                        <h4>Add Reservation</h4>
                        <p>Create a new guest booking.</p>
                    </div>
                    <div class="quick-item">
                        <div class="q-url">/reservations/view?id=X</div>
                        <h4>Reservation Details</h4>
                        <p>Full details of a specific booking.</p>
                    </div>
                    <div class="quick-item">
                        <div class="q-url">/reservations/bill?id=X</div>
                        <h4>Bill / Invoice</h4>
                        <p>Calculate and print the stay invoice.</p>
                    </div>
                    <div class="quick-item">
                        <div class="q-url">/help</div>
                        <h4>Help &amp; Staff Guide</h4>
                        <p>This page — guidelines for all staff.</p>
                    </div>
                    <div class="quick-item">
                        <div class="q-url">/logout</div>
                        <h4>Logout</h4>
                        <p>End your session and return to login.</p>
                    </div>
                </div>
            </div>
        </div>

    </div><!-- /main-content -->
</div><!-- /page-wrapper -->

<script>
    function toggleSection(header) {
        header.classList.toggle('open');
        const body = header.nextElementSibling;
        body.classList.toggle('show');
    }

    // Smooth scroll for sidebar nav
    document.querySelectorAll('.nav-link').forEach(link => {
        link.addEventListener('click', function(e) {
            const href = this.getAttribute('href');
            if (href.startsWith('#')) {
                e.preventDefault();
                const target = document.querySelector(href);
                if (target) {
                    target.scrollIntoView({ behavior: 'smooth' });
                }
            }
        });
    });
</script>

</body>
</html>
