<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    // Session is already invalidated by ExitServlet.
    // Read the name passed as a request attribute.
    String exitUserName = (String) request.getAttribute("exitUserName");
    if (exitUserName == null) exitUserName = "Staff";

    // Current time for the log stamp
    java.time.LocalDateTime now = java.time.LocalDateTime.now();
    java.time.format.DateTimeFormatter fmt =
            java.time.format.DateTimeFormatter.ofPattern("MMMM d, yyyy  hh:mm a");
    String exitTime = now.format(fmt);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Session Ended - Ocean View Resort</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #0a4d68 0%, #088395 50%, #05bfdb 100%);
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }

        .exit-card {
            background: white;
            border-radius: 24px;
            box-shadow: 0 30px 70px rgba(0,0,0,0.35);
            padding: 52px 56px;
            text-align: center;
            max-width: 480px;
            width: 100%;
            animation: fadeUp 0.5s ease;
        }

        @keyframes fadeUp {
            from { opacity: 0; transform: translateY(30px); }
            to   { opacity: 1; transform: translateY(0); }
        }

        .check-circle {
            width: 80px;
            height: 80px;
            background: linear-gradient(135deg, #e8f8f0, #c8f0dc);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 24px;
            font-size: 2.4rem;
            border: 3px solid #a3e4c0;
        }

        .exit-card h1 {
            font-size: 1.6rem;
            color: #0a4d68;
            font-weight: 700;
            margin-bottom: 10px;
        }

        .exit-card .subtitle {
            font-size: 0.95rem;
            color: #777;
            line-height: 1.65;
            margin-bottom: 28px;
        }

        .exit-card .subtitle strong {
            color: #0a4d68;
        }

        /* Session info strip */
        .session-strip {
            background: #f7fbfc;
            border: 1px solid #e0f0f4;
            border-radius: 12px;
            padding: 14px 20px;
            margin-bottom: 30px;
            font-size: 0.83rem;
            color: #666;
            line-height: 1.8;
        }
        .session-strip .row {
            display: flex;
            justify-content: space-between;
            gap: 12px;
        }
        .session-strip .row:not(:last-child) {
            border-bottom: 1px solid #edf4f6;
            padding-bottom: 8px;
            margin-bottom: 8px;
        }
        .session-strip .lbl { font-weight: 600; color: #444; }
        .session-strip .val { color: #088395; font-weight: 600; }

        /* Buttons */
        .btn-login {
            display: block;
            width: 100%;
            padding: 14px;
            background: linear-gradient(135deg, #0a4d68, #088395);
            color: white;
            border: none;
            border-radius: 12px;
            font-size: 1rem;
            font-weight: 600;
            text-decoration: none;
            cursor: pointer;
            transition: opacity 0.2s, transform 0.1s;
            margin-bottom: 12px;
        }
        .btn-login:hover {
            opacity: 0.9;
            transform: translateY(-1px);
        }

        .brand-footer {
            margin-top: 32px;
            font-size: 0.8rem;
            color: #bbb;
        }
        .brand-footer span { font-size: 1.2rem; vertical-align: middle; margin-right: 6px; }

        /* Security note */
        .security-note {
            background: #fff8e1;
            border: 1px solid #ffe082;
            border-radius: 10px;
            padding: 11px 16px;
            font-size: 0.82rem;
            color: #7a5000;
            text-align: left;
            margin-bottom: 24px;
            line-height: 1.6;
        }
        .security-note strong { display: block; margin-bottom: 2px; }
    </style>
</head>
<body>

<div class="exit-card">

    <!-- Success icon -->
    <div class="check-circle">&#10003;</div>

    <h1>Session Ended Safely</h1>
    <p class="subtitle">
        Thank you, <strong><%= exitUserName %></strong>.<br>
        You have successfully exited the Ocean View Resort management system.
    </p>

    <!-- Session info -->
    <div class="session-strip">
        <div class="row">
            <span class="lbl">User</span>
            <span class="val"><%= exitUserName %></span>
        </div>
        <div class="row">
            <span class="lbl">Session Status</span>
            <span class="val" style="color:#1a7a4a;">&#10003; Terminated</span>
        </div>
        <div class="row">
            <span class="lbl">Exit Time</span>
            <span class="val"><%= exitTime %></span>
        </div>
    </div>

    <!-- Security reminder -->
    <div class="security-note">
        <strong>&#128274; Security Reminder</strong>
        Please close this browser tab if you are on a shared or public computer to protect guest data.
    </div>

    <!-- Log in again -->
    <a href="<%= request.getContextPath() %>/login" class="btn-login">
        &#128274; Log In Again
    </a>

    <div class="brand-footer">
        <span>&#127754;</span> Ocean View Resort Management System
    </div>

</div>

</body>
</html>
