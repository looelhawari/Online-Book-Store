package com.example.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class SiteController {

    @GetMapping("/privacy")
    public String privacyPage() {
        return "user/privacy";
    }

    @GetMapping("/terms")
    public String termsPage() {
        return "user/terms";
    }

    @GetMapping("/contact")
    public String contactPage() {
        return "user/contact";
    }
}
