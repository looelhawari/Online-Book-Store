package com.example.controller;

import com.example.model.Book;
import com.example.model.OrderStatus;
import com.example.service.BookService;
import com.example.service.OrderService;
import com.example.util.Constants;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.math.BigDecimal;

@Controller
@RequestMapping("/admin")
@RequiredArgsConstructor
public class AdminController {

    private final BookService bookService;
    private final OrderService orderService;

    // ---- DASHBOARD ----

    @GetMapping("/dashboard")
    public String dashboard(Model model) {
        model.addAttribute("totalBooks", bookService.getTotalCount());
        model.addAttribute("totalOrders", orderService.getTotalCount());
        model.addAttribute("lowStockCount", bookService.getLowStockCount());
        model.addAttribute("inventoryValue", bookService.getTotalInventoryValue());
        model.addAttribute("recentOrders", orderService.getRecentOrders(5));
        return "admin/dashboard";
    }

    // ---- BOOK MANAGEMENT ----

    @GetMapping("/books")
    public String bookList(Model model) {
        model.addAttribute("books", bookService.getAllBooks());
        return "admin/books";
    }

    @GetMapping("/books/add")
    public String addBookForm() {
        return "admin/add-book";
    }

    @PostMapping("/books/add")
    public String addBook(@RequestParam String title,
                          @RequestParam(required = false) String author,
                          @RequestParam(required = false) String description,
                          @RequestParam(required = false) String category,
                          @RequestParam(required = false) String imageUrl,
                          @RequestParam(required = false) Integer starRating,
                          @RequestParam BigDecimal price,
                          @RequestParam Integer quantity,
                          RedirectAttributes flash) {
        try {
            bookService.save(title, author, description, category, imageUrl, starRating, price, quantity);
            flash.addFlashAttribute("success", Constants.MSG_BOOK_ADDED);
        } catch (Exception e) {
            flash.addFlashAttribute("error", e.getMessage());
            return "redirect:/admin/books/add";
        }
        return "redirect:/admin/books";
    }

    @GetMapping("/books/edit/{id}")
    public String editBookForm(@PathVariable Integer id, Model model) {
        Book book = bookService.findById(id)
            .orElseThrow(() -> new IllegalArgumentException("Book not found."));
        model.addAttribute("book", book);
        return "admin/edit-book";
    }

    @PostMapping("/books/edit/{id}")
    public String updateBook(@PathVariable Integer id,
                             @RequestParam String title,
                             @RequestParam(required = false) String author,
                             @RequestParam(required = false) String description,
                             @RequestParam(required = false) String category,
                             @RequestParam(required = false) String imageUrl,
                             @RequestParam(required = false) Integer starRating,
                             @RequestParam BigDecimal price,
                             @RequestParam Integer quantity,
                             RedirectAttributes flash) {
        try {
            bookService.update(id, title, author, description, category, imageUrl, starRating, price, quantity);
            flash.addFlashAttribute("success", Constants.MSG_BOOK_UPDATED);
        } catch (Exception e) {
            flash.addFlashAttribute("error", e.getMessage());
        }
        return "redirect:/admin/books";
    }

    @PostMapping("/books/delete/{id}")
    public String deleteBook(@PathVariable Integer id, RedirectAttributes flash) {
        try {
            bookService.delete(id);
            flash.addFlashAttribute("success", Constants.MSG_BOOK_DELETED);
        } catch (Exception e) {
            flash.addFlashAttribute("error", e.getMessage());
        }
        return "redirect:/admin/books";
    }

    // ---- ORDER MANAGEMENT ----

    @GetMapping("/orders")
    public String orders(Model model) {
        model.addAttribute("orders", orderService.getAllOrders());
        model.addAttribute("statuses", OrderStatus.values());
        return "admin/orders";
    }

    @PostMapping("/orders/{id}/status")
    public String updateOrderStatus(@PathVariable Integer id,
                                    @RequestParam String status,
                                    RedirectAttributes flash) {
        try {
            orderService.updateStatus(id, OrderStatus.valueOf(status));
            flash.addFlashAttribute("success", "Order #" + id + " status updated.");
        } catch (Exception e) {
            flash.addFlashAttribute("error", e.getMessage());
        }
        return "redirect:/admin/orders";
    }
}
