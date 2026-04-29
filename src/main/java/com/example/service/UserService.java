package com.example.service;

import com.example.model.User;
import com.example.repository.UserRepository;
import com.example.util.PasswordUtil;
import com.example.util.ValidationUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;

    public Optional<User> authenticate(String username, String password) {
        Optional<User> userOpt = userRepository.findByUsername(username);
        if (userOpt.isEmpty()) return Optional.empty();
        User user = userOpt.get();
        if (PasswordUtil.verifyPassword(password, user.getPassword())) {
            return Optional.of(user);
        }
        return Optional.empty();
    }

    public User register(String username, String email, String name, String password) {
        if (userRepository.existsByUsername(username)) {
            throw new IllegalArgumentException("Username already taken.");
        }
        if (userRepository.existsByEmail(email)) {
            throw new IllegalArgumentException("Email already registered.");
        }
        if (!ValidationUtil.isValidUsername(username)) {
            throw new IllegalArgumentException("Username must be 3-20 characters (letters, numbers, underscore).");
        }
        if (!ValidationUtil.isValidEmail(email)) {
            throw new IllegalArgumentException("Please enter a valid email address.");
        }
        if (!ValidationUtil.isValidPassword(password)) {
            throw new IllegalArgumentException("Password must be at least 6 characters.");
        }
        User user = new User();
        user.setUsername(username.trim());
        user.setEmail(email.trim());
        user.setName(name != null && !name.trim().isEmpty() ? name.trim() : username.trim());
        user.setPassword(PasswordUtil.hashPassword(password));
        return userRepository.save(user);
    }

    public Optional<User> findById(Integer id) {
        return userRepository.findById(id);
    }
}
