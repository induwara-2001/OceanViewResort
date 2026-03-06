package com.example.oceanviewresort.config;

/**
 * SMTP configuration for outgoing emails.
 *
 * ─────────────────────────────────────────────────────────────────
 *  HOW TO SET UP (Gmail example)
 * ─────────────────────────────────────────────────────────────────
 *  1. Enable 2-Factor Authentication on your Google account.
 *  2. Generate an App Password:
 *       Google Account → Security → App Passwords → Mail → Other
 *  3. Paste the 16-character app password into SMTP_PASSWORD below.
 *  4. Set SMTP_FROM to the Gmail address you used above.
 *  5. Reload/redeploy Tomcat.
 *
 *  For other providers change SMTP_HOST / SMTP_PORT as required:
 *    Outlook / Hotmail  → smtp-mail.outlook.com  : 587
 *    Yahoo Mail         → smtp.mail.yahoo.com     : 465 (SSL)
 *    Custom SMTP        → your.mail.server        : 587
 * ─────────────────────────────────────────────────────────────────
 */
public final class EmailConfig {

    // ── Sender account ────────────────────────────────────────────
    public static final String SMTP_HOST     = "smtp.gmail.com";
    public static final int    SMTP_PORT     = 587;
    public static final String SMTP_USERNAME = "your-email@gmail.com";   // ← change this
    public static final String SMTP_PASSWORD = "your-app-password";       // ← change this
    public static final String SMTP_FROM     = "your-email@gmail.com";   // ← change this

    // ── Display name shown in recipient's inbox ───────────────────
    public static final String FROM_NAME     = "Ocean View Resort";

    private EmailConfig() {}
}
