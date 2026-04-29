package com.example.util;

import com.example.model.Order;
import com.example.model.OrderItem;
import lombok.RequiredArgsConstructor;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Component;

import jakarta.mail.internet.MimeMessage;

@Component
@RequiredArgsConstructor
public class EmailUtil {

    private final JavaMailSender mailSender;

    public void sendOrderConfirmationEmail(Order order) {
        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");
            helper.setFrom("noreply@themoderarchive.com", "The Modern Archive");
            helper.setTo(order.getUser().getEmail());
            helper.setSubject(Constants.EMAIL_SUBJECT_ORDER);
            helper.setText(buildEmailBody(order), true);
            mailSender.send(message);
        } catch (Exception e) {
            System.err.println("Email send failed: " + e.getMessage());
        }
    }

    private String buildEmailBody(Order order) {
        StringBuilder sb = new StringBuilder();
        sb.append("<!DOCTYPE html><html><head><style>");
        sb.append("body{font-family:Arial,sans-serif;color:#0d1c2e;background:#f8f9ff;}");
        sb.append(".container{max-width:600px;margin:0 auto;padding:20px;}");
        sb.append(".header{background:#0F172A;color:#fff;padding:20px;text-align:center;border-radius:8px 8px 0 0;}");
        sb.append(".content{border:1px solid #c6c6cd;padding:24px;background:#fff;}");
        sb.append("table{width:100%;border-collapse:collapse;margin:16px 0;}");
        sb.append("th{background:#e6eeff;padding:10px;text-align:left;}");
        sb.append("td{padding:10px;border-bottom:1px solid #c6c6cd;}");
        sb.append(".footer{background:#f3f4f6;padding:12px;text-align:center;font-size:12px;color:#45464d;border-radius:0 0 8px 8px;}");
        sb.append("</style></head><body><div class='container'>");
        sb.append("<div class='header'><h1>The Modern Archive</h1><p>Order Confirmation</p></div>");
        sb.append("<div class='content'>");
        sb.append("<p>Dear ").append(order.getUser().getName()).append(",</p>");
        sb.append("<p>Thank you for your order! Here are your order details:</p>");
        sb.append("<table><tr><td><strong>Order #</strong></td><td>").append(order.getId()).append("</td></tr>");
        sb.append("<tr><td><strong>Date</strong></td><td>").append(order.getCreatedAt()).append("</td></tr>");
        sb.append("<tr><td><strong>Status</strong></td><td>").append(order.getStatus()).append("</td></tr></table>");
        sb.append("<table><tr><th>Book</th><th>Qty</th><th>Price</th><th>Total</th></tr>");
        if (order.getOrderItems() != null) {
            for (OrderItem item : order.getOrderItems()) {
                sb.append("<tr><td>").append(item.getBook().getTitle()).append("</td>");
                sb.append("<td>").append(item.getQuantity()).append("</td>");
                sb.append("<td>$").append(String.format("%.2f", item.getUnitPrice())).append("</td>");
                sb.append("<td>$").append(String.format("%.2f",
                    item.getUnitPrice().multiply(java.math.BigDecimal.valueOf(item.getQuantity())))).append("</td></tr>");
            }
        }
        sb.append("<tr><td colspan='3' style='text-align:right'><strong>Grand Total</strong></td>");
        sb.append("<td><strong>$").append(String.format("%.2f", order.getTotalPrice())).append("</strong></td></tr></table>");
        sb.append("</div><div class='footer'>&copy; 2026 The Modern Archive</div></div></body></html>");
        return sb.toString();
    }
}
