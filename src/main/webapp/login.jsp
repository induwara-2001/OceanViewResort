<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Ocean View Resort — Staff Login</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">
    <style>
        *, *::before, *::after { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            font-family: 'Inter', 'Segoe UI', sans-serif;
            min-height: 100vh;
            display: flex;
            background: #0a1628;
        }

        /* ── LEFT PANEL ── */
        .left-panel {
            flex: 1.1;
            background:
                linear-gradient(160deg, rgba(5,40,60,0.92) 0%, rgba(8,100,120,0.88) 55%, rgba(11,184,196,0.6) 100%),
                url('https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=1200') center/cover no-repeat;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            padding: 48px 52px;
            position: relative;
            overflow: hidden;
        }
        /* decorative blobs */
        .left-panel::before {
            content: '';
            position: absolute; bottom: -80px; left: -60px;
            width: 340px; height: 340px; border-radius: 50%;
            background: rgba(11,184,196,0.12);
        }
        .left-panel::after {
            content: '';
            position: absolute; top: -60px; right: -50px;
            width: 260px; height: 260px; border-radius: 50%;
            background: rgba(255,255,255,0.05);
        }

        .brand-mark {
            display: flex; align-items: center; gap: 14px;
            color: white; position: relative; z-index: 1;
        }
        .brand-mark .logo-box {
            width: 46px; height: 46px; border-radius: 13px;
            background: rgba(255,255,255,0.15);
            backdrop-filter: blur(8px);
            border: 1px solid rgba(255,255,255,0.25);
            display: flex; align-items: center; justify-content: center;
            font-size: 1.5rem;
        }
        .brand-mark span {
            font-size: 1.05rem; font-weight: 700; letter-spacing: -0.2px;
        }

        .hero-text {
            color: white; position: relative; z-index: 1;
        }
        .hero-text h1 {
            font-size: 2.8rem; font-weight: 900; line-height: 1.15;
            letter-spacing: -1px; margin-bottom: 16px;
        }
        .hero-text h1 span { color: #4dd9e8; }
        .hero-text p {
            font-size: 1rem; opacity: 0.75; line-height: 1.7; max-width: 340px;
        }

        .feature-chips {
            display: flex; flex-direction: column; gap: 12px;
            position: relative; z-index: 1;
        }
        .chip {
            display: inline-flex; align-items: center; gap: 10px;
            background: rgba(255,255,255,0.1);
            backdrop-filter: blur(8px);
            border: 1px solid rgba(255,255,255,0.18);
            color: white; padding: 10px 16px; border-radius: 30px;
            font-size: 0.82rem; font-weight: 500; width: fit-content;
        }
        .chip-icon { font-size: 1rem; }

        /* ── RIGHT PANEL ── */
        .right-panel {
            flex: 0.9;
            background: #ffffff;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            padding: 60px 56px;
        }

        .form-box { width: 100%; max-width: 360px; }

        .form-box .eyebrow {
            font-size: 0.72rem; font-weight: 700; letter-spacing: 2px;
            text-transform: uppercase; color: #0bb8c4; margin-bottom: 10px;
        }
        .form-box h2 {
            font-size: 2rem; font-weight: 800; color: #0a1628;
            letter-spacing: -0.8px; margin-bottom: 6px;
        }
        .form-box .subtitle {
            font-size: 0.88rem; color: #94a3b8; margin-bottom: 36px;
        }

        /* Input group with icon */
        .input-group { position: relative; margin-bottom: 18px; }
        .input-group label {
            display: block; font-size: 0.78rem; font-weight: 600;
            color: #475569; margin-bottom: 7px; letter-spacing: 0.2px;
        }
        .input-icon-wrap {
            position: relative; display: flex; align-items: center;
        }
        .input-icon {
            position: absolute; left: 14px; top: 50%; transform: translateY(-50%);
            color: #94a3b8; pointer-events: none;
        }
        .input-group input {
            width: 100%; padding: 13px 16px 13px 42px;
            border: 2px solid #e2e8f0; border-radius: 12px;
            font-size: 0.93rem; font-family: 'Inter', sans-serif;
            color: #1e293b; background: #f8fafc;
            outline: none; transition: border-color 0.2s, background 0.2s, box-shadow 0.2s;
        }
        .input-group input:focus {
            border-color: #0bb8c4; background: white;
            box-shadow: 0 0 0 3px rgba(11,184,196,0.12);
        }
        .input-group input::placeholder { color: #c8d5e0; }

        .btn-login {
            width: 100%; padding: 14px;
            background: linear-gradient(135deg, #0a4d68 0%, #0bb8c4 100%);
            color: white; border: none; border-radius: 12px;
            font-size: 0.95rem; font-weight: 700; font-family: 'Inter', sans-serif;
            cursor: pointer; margin-top: 8px;
            transition: opacity 0.2s, transform 0.15s, box-shadow 0.2s;
            box-shadow: 0 4px 18px rgba(8,131,149,0.35);
            letter-spacing: 0.3px;
        }
        .btn-login:hover {
            opacity: 0.93; transform: translateY(-2px);
            box-shadow: 0 8px 24px rgba(8,131,149,0.4);
        }
        .btn-login:active { transform: translateY(0); }

        /* Error */
        .error-box {
            display: flex; align-items: flex-start; gap: 10px;
            background: #fff1f1; border: 1.5px solid #fca5a5;
            color: #b91c1c; padding: 12px 14px; border-radius: 10px;
            font-size: 0.84rem; margin-bottom: 20px; line-height: 1.5;
        }
        .error-icon { font-size: 1rem; flex-shrink: 0; margin-top: 1px; }

        .footer-note {
            margin-top: 30px;
            font-size: 0.75rem; color: #c8d5e0; text-align: center;
        }

        /* Animated fade-in */
        @keyframes slideUp {
            from { opacity: 0; transform: translateY(18px); }
            to   { opacity: 1; transform: translateY(0); }
        }
        .form-box { animation: slideUp 0.45s ease both; }

        @media(max-width: 768px) {
            body { flex-direction: column; }
            .left-panel { min-height: 220px; padding: 28px; }
            .hero-text h1 { font-size: 1.8rem; }
            .right-panel { padding: 40px 28px; }
            .feature-chips { display: none; }
        }
    </style>
</head>
<body>

<!-- LEFT PANEL -->
<div class="left-panel">
    <div class="brand-mark">
        <div class="logo-box">&#127754;</div>
        <span>Ocean View Resort</span>
    </div>

    <div class="hero-text">
        <h1>Manage your<br>resort <span>smarter</span>.</h1>
        <p>The all-in-one management portal for reservations, guests, billing, and operations — built for hospitality teams.</p>
    </div>

    <div class="feature-chips">
        <div class="chip"><span class="chip-icon">&#128203;</span> Reservations &amp; bookings at a glance</div>
        <div class="chip"><span class="chip-icon">&#127968;</span> Real-time room availability</div>
        <div class="chip"><span class="chip-icon">&#128184;</span> Automated billing &amp; invoicing</div>
        <div class="chip"><span class="chip-icon">&#128202;</span> Analytics &amp; occupancy reports</div>
    </div>
</div>

<!-- RIGHT PANEL -->
<div class="right-panel">
    <div class="form-box">
        <p class="eyebrow">Staff Portal</p>
        <h2>Welcome back</h2>
        <p class="subtitle">Sign in with your credentials to continue</p>

        <%
            String errorMessage = (String) request.getAttribute("errorMessage");
            if (errorMessage != null) {
        %>
        <div class="error-box">
            <span class="error-icon">&#9888;</span>
            <%= errorMessage %>
        </div>
        <% } %>

        <form method="post" action="<%= request.getContextPath() %>/login">
            <div class="input-group">
                <label for="username">Username</label>
                <div class="input-icon-wrap">
                    <svg class="input-icon" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                    <input type="text" id="username" name="username"
                           placeholder="e.g. admin"
                           value="<%= request.getParameter("username") != null ? request.getParameter("username") : "" %>"
                           required autofocus>
                </div>
            </div>

            <div class="input-group">
                <label for="password">Password</label>
                <div class="input-icon-wrap">
                    <svg class="input-icon" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
                    <input type="password" id="password" name="password"
                           placeholder="Enter your password"
                           required>
                </div>
            </div>

            <button type="submit" class="btn-login">Sign In &rarr;</button>
        </form>

        <p class="footer-note">&copy; 2026 Ocean View Resort &nbsp;&middot;&nbsp; Staff Portal v2.0</p>
    </div>
</div>

</body>
</html>
