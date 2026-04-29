package com.example.controller;

import com.example.model.Admin;
import com.example.service.AdminService;
import com.example.util.Constants;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.Optional;

@Controller
@RequiredArgsConstructor
public class AdminAuthController {

    private final AdminService adminService;

    @GetMapping("/admin/login")
    public String loginPage(HttpSession session) {
        if (session.getAttribute(Constants.SESSION_ADMIN) != null) {
            return "redirect:/admin/dashboard";
        }
        return "auth/admin-login";
    }

    @PostMapping("/admin/login")
    public String login(@RequestParam String username,
                        @RequestParam String password,
                        HttpSession session,
                        Model model) {
        Optional<Admin> adminOpt = adminService.authenticate(username.trim(), password);
        if (adminOpt.isEmpty()) {
            model.addAttribute("error", Constants.MSG_LOGIN_FAILED);
            model.addAttribute("username", username);
            return "auth/admin-login";
        }
        session.setAttribute(Constants.SESSION_ADMIN, adminOpt.get());
        session.setMaxInactiveInterval(Constants.SESSION_TIMEOUT_MINUTES * 60);
        return "redirect:/admin/dashboard";
    }

    @GetMapping("/admin/logout")
    public String logout(HttpSession session) {
        session.invalidate();
        return "redirect:/admin/login";
    }
}
