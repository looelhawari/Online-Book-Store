package com.example.controller;

import com.example.model.CartItem;
import com.example.model.User;
import com.example.service.CartService;
import com.example.util.Constants;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.List;

@Controller
@RequiredArgsConstructor
public class CartController {

    private final CartService cartService;

    @GetMapping("/cart")
    public String viewCart(HttpSession session, Model model) {
        User user = (User) session.getAttribute(Constants.SESSION_USER);
        List<CartItem> items = cartService.getCartItems(user.getId());
        double subtotal = cartService.getCartTotal(user.getId());
        double tax = subtotal * Constants.TAX_RATE;
        model.addAttribute("cartItems", items);
        model.addAttribute("subtotal", subtotal);
        model.addAttribute("tax", tax);
        model.addAttribute("total", subtotal + tax);
        model.addAttribute("cartCount", items.size());
        return "user/cart";
    }

    @PostMapping("/cart/add")
    public String addToCart(@RequestParam Integer bookId,
                            @RequestParam(defaultValue = "1") int quantity,
                            HttpSession session,
                            RedirectAttributes flash) {
        User user = (User) session.getAttribute(Constants.SESSION_USER);
        try {
            cartService.addToCart(user.getId(), bookId, quantity);
            flash.addFlashAttribute("success", "Book added to cart!");
        } catch (IllegalStateException e) {
            flash.addFlashAttribute("error", e.getMessage());
        }
        return "redirect:/catalog";
    }

    @PostMapping("/cart/update")
    public String updateQuantity(@RequestParam Integer cartItemId,
                                 @RequestParam int quantity,
                                 HttpSession session,
                                 RedirectAttributes flash) {
        User user = (User) session.getAttribute(Constants.SESSION_USER);
        try {
            cartService.updateQuantity(cartItemId, user.getId(), quantity);
        } catch (Exception e) {
            flash.addFlashAttribute("error", e.getMessage());
        }
        return "redirect:/cart";
    }

    @PostMapping("/cart/remove")
    public String removeItem(@RequestParam Integer cartItemId,
                             HttpSession session,
                             RedirectAttributes flash) {
        User user = (User) session.getAttribute(Constants.SESSION_USER);
        try {
            cartService.removeItem(cartItemId, user.getId());
        } catch (Exception e) {
            flash.addFlashAttribute("error", e.getMessage());
        }
        return "redirect:/cart";
    }
}
