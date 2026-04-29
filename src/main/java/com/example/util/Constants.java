package com.example.util;

public class Constants {

    public static final String SESSION_USER = "user";
    public static final String SESSION_ADMIN = "admin";
    public static final int SESSION_TIMEOUT_MINUTES = 30;

    public static final String PARAM_USERNAME = "username";
    public static final String PARAM_EMAIL = "email";
    public static final String PARAM_PASSWORD = "password";
    public static final String PARAM_CONFIRM_PASSWORD = "confirmPassword";
    public static final String PARAM_NAME = "name";

    public static final String MSG_LOGIN_FAILED = "Invalid username or password.";
    public static final String MSG_REGISTER_SUCCESS = "Registration successful! Please log in.";
    public static final String MSG_OUT_OF_STOCK = "This book is out of stock.";
    public static final String MSG_ORDER_CREATED = "Order placed successfully!";
    public static final String MSG_PAYMENT_SUCCESS = "Payment successful!";
    public static final String MSG_BOOK_ADDED = "Book added successfully!";
    public static final String MSG_BOOK_UPDATED = "Book updated successfully!";
    public static final String MSG_BOOK_DELETED = "Book deleted successfully!";
    public static final String EMAIL_SUBJECT_ORDER = "Order Confirmation - The Modern Archive";

    public static final double TAX_RATE = 0.08;
    public static final int LOW_STOCK_THRESHOLD = 5;
    public static final int MAX_CART_ITEMS_PER_BOOK = 99;
    public static final int PAGE_SIZE_BOOKS = 12;
    public static final int PAGE_SIZE_ORDERS = 10;

    public static final String STATUS_PENDING = "PENDING";
    public static final String STATUS_CONFIRMED = "CONFIRMED";
    public static final String STATUS_SHIPPED = "SHIPPED";
    public static final String STATUS_CANCELLED = "CANCELLED";
}
