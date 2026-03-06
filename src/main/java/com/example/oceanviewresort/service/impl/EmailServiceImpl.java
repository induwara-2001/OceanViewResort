package com.example.oceanviewresort.service.impl;

import com.example.oceanviewresort.config.EmailConfig;
import com.example.oceanviewresort.model.Reservation;
import com.example.oceanviewresort.service.EmailService;

import javax.mail.*;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;
import java.util.Properties;

/**
 * Sends HTML reservation confirmation emails via SMTP (JavaMail).
 * Configure credentials in EmailConfig.java.
 *
 * The send is dispatched on a daemon thread so the HTTP request
 * returns to the browser immediately without waiting for SMTP.
 */
public class EmailServiceImpl implements EmailService {

    @Override
    public void sendReservationConfirmation(Reservation reservation) {
        // Skip silently if no email address was provided
        if (reservation.getGuestEmail() == null || reservation.getGuestEmail().trim().isEmpty()) {
            return;
        }

        // Run in background so the HTTP response is not delayed
        Thread mailThread = new Thread(() -> {
            try {
                Session session = buildSession();

                MimeMessage message = new MimeMessage(session);
                message.setFrom(new InternetAddress(EmailConfig.SMTP_FROM, EmailConfig.FROM_NAME));
                message.setRecipient(Message.RecipientType.TO,
                        new InternetAddress(reservation.getGuestEmail(), reservation.getGuestName()));
                message.setSubject("Reservation Confirmation – " + reservation.getReservationNumber());
                message.setContent(buildHtmlBody(reservation), "text/html; charset=UTF-8");

                Transport.send(message);
                System.out.println("[EmailService] Confirmation sent to: " + reservation.getGuestEmail());

            } catch (Exception e) {
                // Log but never crash the main request
                System.err.println("[EmailService] Failed to send email: " + e.getMessage());
            }
        });
        mailThread.setDaemon(true);
        mailThread.start();
    }

    // ── SMTP Session ──────────────────────────────────────────────

    private Session buildSession() {
        Properties props = new Properties();
        props.put("mail.smtp.host",            EmailConfig.SMTP_HOST);
        props.put("mail.smtp.port",            String.valueOf(EmailConfig.SMTP_PORT));
        props.put("mail.smtp.auth",            "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.ssl.trust",       EmailConfig.SMTP_HOST);

        return Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(EmailConfig.SMTP_USERNAME, EmailConfig.SMTP_PASSWORD);
            }
        });
    }

    // ── HTML Email Body ───────────────────────────────────────────

    private String buildHtmlBody(Reservation r) {
        String nights = "";
        if (r.getCheckInDate() != null && r.getCheckOutDate() != null) {
            long n = (r.getCheckOutDate().getTime() - r.getCheckInDate().getTime()) / (1000L * 60 * 60 * 24);
            nights = n + " night" + (n != 1 ? "s" : "");
        }

        return "<!DOCTYPE html>" +
               "<html lang='en'><head><meta charset='UTF-8'></head><body style='" +
               "margin:0;padding:0;background:#f0f4f8;font-family:Segoe UI,Arial,sans-serif;'>" +

               // ── Header ──
               "<div style='background:linear-gradient(135deg,#0a4d68,#088395);" +
               "padding:32px 0;text-align:center;'>" +
               "<h1 style='color:white;margin:0;font-size:1.6rem;letter-spacing:1px;'>&#127754; Ocean View Resort</h1>" +
               "<p style='color:rgba(255,255,255,0.8);margin:6px 0 0;font-size:0.9rem;'>Reservation Confirmation</p>" +
               "</div>" +

               // ── Body card ──
               "<div style='max-width:580px;margin:30px auto;background:white;" +
               "border-radius:16px;box-shadow:0 4px 20px rgba(0,0,0,0.08);overflow:hidden;'>" +

               // Greeting
               "<div style='padding:30px 35px 10px;'>" +
               "<p style='font-size:1rem;color:#333;'>Dear <strong>" + esc(r.getGuestName()) + "</strong>,</p>" +
               "<p style='color:#555;margin-top:10px;line-height:1.6;'>" +
               "Thank you for choosing <strong>Ocean View Resort</strong>! Your reservation has been received " +
               "and is currently <span style='color:#088395;font-weight:600;'>PENDING</span> confirmation. " +
               "Below are your booking details:</p>" +
               "</div>" +

               // Booking summary strip
               "<div style='background:#f7fbfc;border-top:1px solid #e0f0f3;" +
               "border-bottom:1px solid #e0f0f3;padding:20px 35px;'>" +
               "<table style='width:100%;border-collapse:collapse;'>" +
               row("Reservation No.",  "<strong style='color:#088395;font-size:1.05rem;'>" + esc(r.getReservationNumber()) + "</strong>") +
               row("Guest Name",       esc(r.getGuestName())) +
               row("Contact",          esc(r.getContactNumber())) +
               row("Room Type",        esc(r.getRoomType())) +
               row("Check-In",         r.getCheckInDate() != null ? r.getCheckInDate().toString() : "-") +
               row("Check-Out",        r.getCheckOutDate() != null ? r.getCheckOutDate().toString() : "-") +
               row("Duration",         nights) +
               row("Status",           "<span style='background:#fff8e1;color:#856404;padding:3px 10px;" +
                                       "border-radius:12px;font-size:0.85rem;font-weight:600;'>PENDING</span>") +
               "</table>" +
               "</div>" +

               // Note
               "<div style='padding:20px 35px 30px;'>" +
               "<p style='color:#777;font-size:0.88rem;line-height:1.7;'>" +
               "Our front desk team will confirm your reservation shortly. " +
               "If you have any questions please contact us at " +
               "<a href='mailto:info@oceanviewresort.com' style='color:#088395;'>info@oceanviewresort.com</a>." +
               "</p>" +
               "</div>" +

               // CTA bar
               "<div style='background:linear-gradient(135deg,#0a4d68,#088395);" +
               "padding:18px 35px;text-align:center;'>" +
               "<p style='color:rgba(255,255,255,0.9);font-size:0.82rem;margin:0;'>" +
               "&#9993; This is an automated email – please do not reply directly to this message.</p>" +
               "</div>" +

               "</div>" + // card
               "</body></html>";
    }

    /** Renders a two-column table row. */
    private String row(String label, String value) {
        return "<tr>" +
               "<td style='padding:8px 0;color:#888;font-size:0.85rem;width:38%;vertical-align:top;'>" + label + "</td>" +
               "<td style='padding:8px 0;color:#333;font-size:0.9rem;font-weight:500;vertical-align:top;'>" + value + "</td>" +
               "</tr>";
    }

    /** Simple HTML escaping to prevent XSS in email content. */
    private String esc(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;");
    }
}
