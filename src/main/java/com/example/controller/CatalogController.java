package com.example.controller;

import com.example.model.Book;
import com.example.service.BookService;
import com.example.service.CartService;
import com.example.util.Constants;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;

@Controller
@RequiredArgsConstructor
public class CatalogController {

    private final BookService bookService;
    private final CartService cartService;

    @GetMapping({"/", "/catalog"})
    public String catalog(@RequestParam(required = false) String search,
                          @RequestParam(required = false) String category,
                          HttpSession session,
                          Model model) {
        List<Book> books;
        if (search != null && !search.trim().isEmpty()) {
            books = bookService.searchBooks(search);
            model.addAttribute("search", search);
        } else if (category != null && !category.trim().isEmpty()) {
            books = bookService.getByCategory(category);
            model.addAttribute("selectedCategory", category);
        } else {
            books = bookService.getAllBooks();
        }

        model.addAttribute("books", books);
        model.addAttribute("categories", bookService.getAllCategories());

        // Cart count for navbar badge
        Object user = session.getAttribute(Constants.SESSION_USER);
        if (user instanceof com.example.model.User u) {
            model.addAttribute("cartCount", cartService.getCartCount(u.getId()));
        }
        return "user/catalog";
    }
}
