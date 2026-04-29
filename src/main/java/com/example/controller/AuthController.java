package com.example.controller;

import com.example.model.User;
import com.example.service.UserService;
import com.example.util.Constants;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.Optional;

@Controller
@RequiredArgsConstructor
public class AuthController {

    private final UserService userService;

    // ---- LOGIN ----

    @GetMapping("/login")
    public String loginPage(HttpSession session, Model model) {
        if (session.getAttribute(Constants.SESSION_USER) != null) {
            return "redirect:/catalog";
        }
        return "auth/login";
    }

    @PostMapping("/login")
    public String login(@RequestParam String username,
                        @RequestParam String password,
                        HttpSession session,
                        Model model) {
        Optional<User> userOpt = userService.authenticate(username.trim(), password);
        if (userOpt.isEmpty()) {
            model.addAttribute("error", Constants.MSG_LOGIN_FAILED);
            model.addAttribute("username", username);
            return "auth/login";
        }
        session.setAttribute(Constants.SESSION_USER, userOpt.get());
        session.setMaxInactiveInterval(Constants.SESSION_TIMEOUT_MINUTES * 60);
        return "redirect:/catalog";
    }

    // ---- REGISTER ----

    @GetMapping("/register")
    public String registerPage() {
        return "auth/register";
    }

    @PostMapping("/register")
    public String register(@RequestParam String username,
                           @RequestParam String email,
                           @RequestParam(required = false) String name,
                           @RequestParam String password,
                           @RequestParam String confirmPassword,
                           Model model,
                           RedirectAttributes flash) {
        model.addAttribute("username", username);
        model.addAttribute("email", email);
        model.addAttribute("name", name);

        if (!password.equals(confirmPassword)) {
            model.addAttribute("error", "Passwords do not match.");
            return "auth/register";
        }
        try {
            userService.register(username, email, name, password);
            flash.addFlashAttribute("success", Constants.MSG_REGISTER_SUCCESS);
            return "redirect:/login";
        } catch (IllegalArgumentException e) {
            model.addAttribute("error", e.getMessage());
            return "auth/register";
        }
    }

    // ---- LOGOUT ----

    @GetMapping("/logout")
    public String logout(HttpSession session) {
        session.invalidate();
        return "redirect:/login";
    }
}
