package com.example.controller;

import com.example.model.CartItem;
import com.example.model.Order;
import com.example.model.User;
import com.example.service.CartService;
import com.example.service.OrderService;
import com.example.util.Constants;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.List;

@Controller
@RequiredArgsConstructor
public class CheckoutController {

    private final CartService cartService;
    private final OrderService orderService;

    // ---- CHECKOUT ----

    @GetMapping("/checkout")
    public String checkoutPage(HttpSession session, Model model) {
        User user = (User) session.getAttribute(Constants.SESSION_USER);
        List<CartItem> items = cartService.getCartItems(user.getId());
        if (items.isEmpty()) return "redirect:/cart";

        double subtotal = cartService.getCartTotal(user.getId());
        double tax = subtotal * Constants.TAX_RATE;
        model.addAttribute("cartItems", items);
        model.addAttribute("subtotal", subtotal);
        model.addAttribute("tax", tax);
        model.addAttribute("total", subtotal + tax);
        addCartCount(model, user);
        return "user/checkout";
    }

    @PostMapping("/checkout")
    public String placeOrder(HttpSession session, RedirectAttributes flash) {
        User user = (User) session.getAttribute(Constants.SESSION_USER);
        try {
            Order order = orderService.checkout(user.getId());
            return "redirect:/payment?orderId=" + order.getId();
        } catch (Exception e) {
            flash.addFlashAttribute("error", e.getMessage());
            return "redirect:/checkout";
        }
    }

    // ---- PAYMENT ----

    @GetMapping("/payment")
    public String paymentPage(@RequestParam Integer orderId,
                              HttpSession session, Model model) {
        User user = (User) session.getAttribute(Constants.SESSION_USER);
        Order order = orderService.findById(orderId).orElse(null);
        if (order == null || !order.getUser().getId().equals(user.getId())) {
            return "redirect:/catalog";
        }
        model.addAttribute("order", order);
        addCartCount(model, user);
        return "user/payment";
    }

    @PostMapping("/payment")
    public String processPayment(@RequestParam Integer orderId,
                                 HttpSession session, RedirectAttributes flash) {
        User user = (User) session.getAttribute(Constants.SESSION_USER);
        try {
            orderService.processPayment(orderId, user.getId());
            return "redirect:/order-confirmation?orderId=" + orderId;
        } catch (Exception e) {
            flash.addFlashAttribute("error", e.getMessage());
            return "redirect:/payment?orderId=" + orderId;
        }
    }

    // ---- ORDER CONFIRMATION ----

    @GetMapping("/order-confirmation")
    public String confirmationPage(@RequestParam Integer orderId,
                                   HttpSession session, Model model) {
        User user = (User) session.getAttribute(Constants.SESSION_USER);
        Order order = orderService.findById(orderId).orElse(null);
        if (order == null || !order.getUser().getId().equals(user.getId())) {
            return "redirect:/catalog";
        }
        model.addAttribute("order", order);
        addCartCount(model, user);
        return "user/order-confirmation";
    }

    // ---- MY ORDERS ----

    @GetMapping("/my-orders")
    public String myOrders(HttpSession session, Model model) {
        User user = (User) session.getAttribute(Constants.SESSION_USER);
        model.addAttribute("orders", orderService.getOrdersByUser(user.getId()));
        addCartCount(model, user);
        return "user/my-orders";
    }

    private void addCartCount(Model model, User user) {
        model.addAttribute("cartCount", cartService.getCartCount(user.getId()));
    }
}
