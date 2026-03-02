<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.example.oceanviewresort.model.User" %>
<%@ page import="com.example.oceanviewresort.model.Bill" %>
<%@ page import="com.example.oceanviewresort.model.Reservation" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>
<%
    User loggedUser = (User) session.getAttribute("loggedUser");
    if (loggedUser == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }

    Bill bill        = (Bill) request.getAttribute("bill");
    Reservation r    = bill.getReservation();
    NumberFormat nf  = NumberFormat.getInstance(Locale.US);
    nf.setMinimumFractionDigits(2);
    nf.setMaximumFractionDigits(2);

    // Current date for invoice header
    java.time.LocalDate today = java.time.LocalDate.now();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Invoice <%= r.getReservationNumber() %> - Ocean View Resort</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: #f0f4f8;
            color: #333;
        }

        /* ---- Screen-only: Navbar ---- */
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
        .navbar-links  { display: flex; align-items: center; gap: 18px; }
        .navbar-links a { color: rgba(255,255,255,0.85); text-decoration: none; font-size: 0.9rem; }
        .navbar-links a:hover { color: white; }
        .btn-logout {
            background: rgba(255,255,255,0.2);
            color: white !important;
            border: 1px solid rgba(255,255,255,0.5);
            padding: 7px 16px;
            border-radius: 8px;
            text-decoration: none !important;
            font-size: 0.85rem;
        }

        /* ---- Screen-only: page wrapper ---- */
        .screen-wrapper {
            max-width: 820px;
            margin: 35px auto;
            padding: 0 20px;
        }

        .action-bar {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 22px;
        }
        .btn-print {
            background: linear-gradient(135deg, #0a4d68, #088395);
            color: white;
            border: none;
            padding: 11px 24px;
            border-radius: 10px;
            font-size: 0.9rem;
            font-weight: 600;
            cursor: pointer;
            transition: opacity 0.2s;
        }
        .btn-print:hover { opacity: 0.88; }
        .btn-back {
            color: #088395;
            text-decoration: none;
            font-size: 0.9rem;
            font-weight: 600;
        }
        .btn-back:hover { text-decoration: underline; }

        /* ---- Invoice card ---- */
        .invoice {
            background: white;
            border-radius: 16px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.09);
            overflow: hidden;
        }

        /* Invoice top header */
        .invoice-header {
            background: linear-gradient(135deg, #0a4d68, #088395);
            color: white;
            padding: 32px 40px;
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            flex-wrap: wrap;
            gap: 20px;
        }
        .hotel-brand { }
        .hotel-brand h1 { font-size: 1.6rem; font-weight: 800; letter-spacing: 0.5px; }
        .hotel-brand p  { font-size: 0.82rem; opacity: 0.85; margin-top: 4px; line-height: 1.6; }

        .invoice-meta { text-align: right; }
        .invoice-meta .invoice-label {
            font-size: 0.75rem;
            opacity: 0.8;
            text-transform: uppercase;
            letter-spacing: 1px;
        }
        .invoice-meta .invoice-number {
            font-size: 1.4rem;
            font-weight: 800;
            letter-spacing: 1px;
            margin: 3px 0;
        }
        .invoice-meta .invoice-date { font-size: 0.85rem; opacity: 0.9; }

        /* Guest & booking info row */
        .info-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 0;
            border-bottom: 1px solid #f0f4f8;
        }
        .info-block {
            padding: 22px 40px;
        }
        .info-block:first-child { border-right: 1px solid #f0f4f8; }
        .info-block .block-label {
            font-size: 0.72rem;
            font-weight: 700;
            color: #088395;
            text-transform: uppercase;
            letter-spacing: 1px;
            margin-bottom: 10px;
        }
        .info-block p  { font-size: 0.9rem; line-height: 1.7; color: #444; }
        .info-block strong { color: #0a4d68; font-size: 1rem; }

        /* Charges table */
        .charges-section { padding: 28px 40px; }
        .charges-section h3 {
            font-size: 0.75rem;
            font-weight: 700;
            color: #088395;
            text-transform: uppercase;
            letter-spacing: 1px;
            margin-bottom: 16px;
        }

        .charges-table {
            width: 100%;
            border-collapse: collapse;
        }
        .charges-table th {
            background: #f7fbfc;
            padding: 11px 14px;
            font-size: 0.78rem;
            font-weight: 700;
            color: #555;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            text-align: left;
            border-bottom: 2px solid #e9f5f7;
        }
        .charges-table th:last-child,
        .charges-table td:last-child { text-align: right; }
        .charges-table td {
            padding: 13px 14px;
            font-size: 0.92rem;
            border-bottom: 1px solid #f4f4f4;
            color: #444;
        }
        .charges-table tr:last-child td { border-bottom: none; }

        /* Totals box */
        .totals-box {
            margin-top: 20px;
            border-top: 2px solid #e9f5f7;
            padding-top: 16px;
        }
        .totals-row {
            display: flex;
            justify-content: flex-end;
            gap: 20px;
            padding: 5px 0;
        }
        .totals-row .tl { font-size: 0.88rem; color: #777; min-width: 160px; text-align: right; }
        .totals-row .tv { font-size: 0.88rem; color: #333; min-width: 100px; text-align: right; }
        .totals-row.grand {
            border-top: 2px solid #0a4d68;
            margin-top: 10px;
            padding-top: 12px;
        }
        .totals-row.grand .tl {
            font-size: 1rem;
            font-weight: 700;
            color: #0a4d68;
        }
        .totals-row.grand .tv {
            font-size: 1.2rem;
            font-weight: 800;
            color: #0a4d68;
        }

        /* Status badge */
        .badge {
            display: inline-block;
            padding: 3px 12px;
            border-radius: 20px;
            font-size: 0.75rem;
            font-weight: 700;
            text-transform: uppercase;
        }
        .badge-pending    { background: #fff8e1; color: #f39c12; }
        .badge-confirmed  { background: #e8f8f0; color: #1a7a4a; }
        .badge-cancelled  { background: #fdecea; color: #c0392b; }
        .badge-checked_out { background: #e8eaf6; color: #3949ab; }

        /* Footer strip */
        .invoice-footer {
            background: #f7fbfc;
            padding: 18px 40px;
            text-align: center;
            font-size: 0.8rem;
            color: #aaa;
            border-top: 1px solid #e9f5f7;
        }

        /* ---- Print styles ---- */
        @media print {
            body { background: white; }
            .navbar, .action-bar { display: none !important; }
            .screen-wrapper { margin: 0; padding: 0; max-width: 100%; }
            .invoice {
                box-shadow: none;
                border-radius: 0;
                border: 1px solid #ddd;
            }
            .invoice-header {
                -webkit-print-color-adjust: exact;
                print-color-adjust: exact;
            }
        }

        @media (max-width: 600px) {
            .invoice-header, .info-row { flex-direction: column; }
            .invoice-meta { text-align: left; }
            .info-row { grid-template-columns: 1fr; }
            .info-block:first-child { border-right: none; border-bottom: 1px solid #f0f4f8; }
            .charges-section, .info-block, .invoice-header { padding-left: 20px; padding-right: 20px; }
        }
    </style>
</head>
<body>

<!-- Navbar (screen only) -->
<nav class="navbar">
    <div class="brand">&#127754; Ocean View Resort</div>
    <div class="navbar-links">
        <a href="<%= request.getContextPath() %>/dashboard">Dashboard</a>
        <a href="<%= request.getContextPath() %>/reservations">Reservations</a>
        <a href="<%= request.getContextPath() %>/logout" class="btn-logout">Logout</a>
    </div>
</nav>

<div class="screen-wrapper">

    <!-- Action bar (screen only) -->
    <div class="action-bar">
        <a href="<%= request.getContextPath() %>/reservations/view?id=<%= r.getId() %>" class="btn-back">
            &#8592; Back to Reservation
        </a>
        <button class="btn-print" onclick="window.print()">&#128424; Print Invoice</button>
    </div>

    <!-- ======= INVOICE ======= -->
    <div class="invoice">

        <!-- Header -->
        <div class="invoice-header">
            <div class="hotel-brand">
                <h1>&#127754; Ocean View Resort</h1>
                <p>
                    Beachfront Avenue, Colombo 03, Sri Lanka<br>
                    Tel: +94 11 234 5678 &nbsp;|&nbsp; info@oceanviewresort.com
                </p>
            </div>
            <div class="invoice-meta">
                <div class="invoice-label">Invoice</div>
                <div class="invoice-number"><%= r.getReservationNumber() %></div>
                <div class="invoice-date">Date: <%= today %></div>
            </div>
        </div>

        <!-- Guest & Booking info -->
        <div class="info-row">
            <div class="info-block">
                <div class="block-label">&#128101; Bill To</div>
                <p>
                    <strong><%= r.getGuestName() %></strong><br>
                    <% if (r.getAddress() != null && !r.getAddress().isEmpty()) { %>
                        <%= r.getAddress() %><br>
                    <% } %>
                    Tel: <%= r.getContactNumber() %>
                </p>
            </div>
            <div class="info-block">
                <div class="block-label">&#127968; Booking Summary</div>
                <p>
                    <strong>Room Type:</strong> <%= r.getRoomType() %><br>
                    <strong>Check-In:</strong> &nbsp;<%= r.getCheckInDate() %><br>
                    <strong>Check-Out:</strong> <%= r.getCheckOutDate() %><br>
                    <strong>Duration:</strong> &nbsp;<%= bill.getNights() %> night<%= bill.getNights() != 1 ? "s" : "" %>
                    &nbsp;
                    <%
                        String status = r.getStatus() != null ? r.getStatus() : "PENDING";
                        String badgeClass = "badge-pending";
                        if ("CONFIRMED".equalsIgnoreCase(status))   badgeClass = "badge-confirmed";
                        if ("CANCELLED".equalsIgnoreCase(status))   badgeClass = "badge-cancelled";
                        if ("CHECKED_OUT".equalsIgnoreCase(status)) badgeClass = "badge-checked_out";
                    %>
                    <span class="badge <%= badgeClass %>"><%= status %></span>
                </p>
            </div>
        </div>

        <!-- Charges breakdown -->
        <div class="charges-section">
            <h3>Charges Breakdown</h3>

            <table class="charges-table">
                <thead>
                    <tr>
                        <th>Description</th>
                        <th>Rate / Night</th>
                        <th>Nights</th>
                        <th>Amount (USD)</th>
                    </tr>
                </thead>
                <tbody>
                    <!-- Room charge -->
                    <tr>
                        <td><%= r.getRoomType() %> &mdash; Room Charge</td>
                        <td>$ <%= nf.format(bill.getRatePerNight()) %></td>
                        <td><%= bill.getNights() %></td>
                        <td><strong>$ <%= nf.format(bill.getSubtotal()) %></strong></td>
                    </tr>
                </tbody>
            </table>

            <!-- Totals -->
            <div class="totals-box">
                <div class="totals-row">
                    <span class="tl">Subtotal</span>
                    <span class="tv">$ <%= nf.format(bill.getSubtotal()) %></span>
                </div>
                <div class="totals-row">
                    <span class="tl">Government Tax (<%= (int)(bill.getTaxRate() * 100) %>%)</span>
                    <span class="tv">$ <%= nf.format(bill.getTaxAmount()) %></span>
                </div>
                <div class="totals-row">
                    <span class="tl">Service Charge (<%= (int)(bill.getServiceChargeRate() * 100) %>%)</span>
                    <span class="tv">$ <%= nf.format(bill.getServiceChargeAmount()) %></span>
                </div>
                <div class="totals-row grand">
                    <span class="tl">GRAND TOTAL</span>
                    <span class="tv">$ <%= nf.format(bill.getGrandTotal()) %></span>
                </div>
            </div>

        </div><!-- /charges-section -->

        <!-- Footer -->
        <div class="invoice-footer">
            Thank you for choosing Ocean View Resort &mdash; We hope to see you again!<br>
            This is a computer-generated invoice. No signature required.
        </div>

    </div><!-- /invoice -->

</div><!-- /screen-wrapper -->

</body>
</html>
