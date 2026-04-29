package com.example.service;

import com.example.model.Admin;
import com.example.repository.AdminRepository;
import com.example.util.PasswordUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
@RequiredArgsConstructor
public class AdminService {

    private final AdminRepository adminRepository;

    public Optional<Admin> authenticate(String username, String password) {
        Optional<Admin> adminOpt = adminRepository.findByUsername(username);
        if (adminOpt.isEmpty()) return Optional.empty();
        Admin admin = adminOpt.get();
        // Support both plain-text seed data and hashed passwords
        boolean valid = admin.getPassword().equals(password) ||
                        PasswordUtil.verifyPassword(password, admin.getPassword());
        return valid ? Optional.of(admin) : Optional.empty();
    }
}
