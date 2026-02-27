<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Ocean View Resort - Login</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #0a4d68 0%, #088395 50%, #05bfdb 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .login-wrapper {
            display: flex;
            width: 900px;
            min-height: 500px;
            border-radius: 20px;
            overflow: hidden;
            box-shadow: 0 25px 60px rgba(0, 0, 0, 0.4);
        }

        /* Left side - branding */
        .login-brand {
            flex: 1;
            background: linear-gradient(180deg, rgba(0,0,0,0.2) 0%, rgba(0,0,0,0.5) 100%),
                        url('https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=800') center/cover;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            padding: 40px;
            color: white;
            text-align: center;
        }

        .login-brand h1 {
            font-size: 2rem;
            font-weight: 700;
            margin-bottom: 12px;
            text-shadow: 0 2px 8px rgba(0,0,0,0.5);
        }

        .login-brand p {
            font-size: 1rem;
            opacity: 0.9;
            line-height: 1.6;
        }

        .brand-icon {
            font-size: 3.5rem;
            margin-bottom: 20px;
        }

        /* Right side - form */
        .login-form-container {
            flex: 1;
            background: #ffffff;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            padding: 50px 40px;
        }

        .login-form-container h2 {
            font-size: 1.8rem;
            color: #0a4d68;
            margin-bottom: 8px;
            font-weight: 700;
        }

        .login-form-container .subtitle {
            color: #888;
            font-size: 0.9rem;
            margin-bottom: 30px;
        }

        .form-group {
            width: 100%;
            margin-bottom: 20px;
        }

        .form-group label {
            display: block;
            font-size: 0.85rem;
            font-weight: 600;
            color: #444;
            margin-bottom: 6px;
        }

        .form-group input {
            width: 100%;
            padding: 12px 16px;
            border: 2px solid #e0e0e0;
            border-radius: 10px;
            font-size: 0.95rem;
            color: #333;
            transition: border-color 0.3s ease;
            outline: none;
        }

        .form-group input:focus {
            border-color: #088395;
        }

        .btn-login {
            width: 100%;
            padding: 13px;
            background: linear-gradient(135deg, #0a4d68, #088395);
            color: white;
            border: none;
            border-radius: 10px;
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            transition: opacity 0.3s ease, transform 0.1s ease;
            margin-top: 5px;
        }

        .btn-login:hover {
            opacity: 0.9;
            transform: translateY(-1px);
        }

        .btn-login:active {
            transform: translateY(0);
        }

        .error-box {
            width: 100%;
            background: #fff0f0;
            border: 1px solid #f5c6c6;
            color: #c0392b;
            padding: 10px 14px;
            border-radius: 8px;
            font-size: 0.88rem;
            margin-bottom: 18px;
        }

        .divider {
            width: 100%;
            text-align: center;
            position: relative;
            margin: 18px 0;
        }

        .footer-note {
            margin-top: 20px;
            font-size: 0.8rem;
            color: #aaa;
            text-align: center;
        }
    </style>
</head>
<body>

<div class="login-wrapper">

    <!-- LEFT: Branding -->
    <div class="login-brand">
        <div class="brand-icon">&#127754;</div>
        <h1>Ocean View Resort</h1>
        <p>Experience luxury by the sea.<br>Please sign in to access your management portal.</p>
    </div>

    <!-- RIGHT: Login Form -->
    <div class="login-form-container">
        <h2>Welcome Back</h2>
        <p class="subtitle">Sign in to your account</p>

        <!-- Error message -->
        <%
            String errorMessage = (String) request.getAttribute("errorMessage");
            if (errorMessage != null) {
        %>
        <div class="error-box">
            <%=  errorMessage %>
        </div>
        <% } %>

        <form method="post" action="<%= request.getContextPath() %>/login" style="width:100%">
            <div class="form-group">
                <label for="username">Username</label>
                <input type="text" id="username" name="username"
                       placeholder="Enter your username"
                       value="<%= request.getParameter("username") != null ? request.getParameter("username") : "" %>"
                       required autofocus>
            </div>

            <div class="form-group">
                <label for="password">Password</label>
                <input type="password" id="password" name="password"
                       placeholder="Enter your password"
                       required>
            </div>

            <button type="submit" class="btn-login">Sign In</button>
        </form>

        <p class="footer-note">&copy; 2026 Ocean View Resort. All rights reserved.</p>
    </div>

</div>

</body>
</html>
