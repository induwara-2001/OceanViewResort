<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    // Redirect root URL to login
    response.sendRedirect(request.getContextPath() + "/login");
%>