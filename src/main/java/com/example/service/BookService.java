package com.example.service;

import com.example.model.Book;
import com.example.repository.BookRepository;
import com.example.util.Constants;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class BookService {

    private final BookRepository bookRepository;

    public List<Book> getAllBooks() {
        return bookRepository.findAll(Sort.by(Sort.Direction.DESC, "id"));
    }

    public List<Book> searchBooks(String keyword) {
        if (keyword == null || keyword.trim().isEmpty()) return getAllBooks();
        return bookRepository.searchBooks(keyword.trim());
    }

    public List<Book> getByCategory(String category) {
        return bookRepository.findByCategory(category);
    }

    public List<String> getAllCategories() {
        return bookRepository.findAllCategories();
    }

    public Optional<Book> findById(Integer id) {
        return bookRepository.findById(id);
    }

    public Book save(String title, String author, String description, String category, String imageUrl,
                     Integer starRating, BigDecimal price, Integer quantity) {
        Book book = new Book();
        book.setTitle(title.trim());
        book.setAuthor(author != null ? author.trim() : null);
        book.setDescription(description);
        book.setCategory(category != null ? category.trim() : null);
        book.setImageUrl(imageUrl != null ? imageUrl.trim() : null);
        book.setStarRating(starRating != null ? starRating : 0);
        book.setPrice(price);
        book.setQuantity(quantity);
        return bookRepository.save(book);
    }

    public Book update(Integer id, String title, String author, String description,
                       String category, String imageUrl, Integer starRating, BigDecimal price, Integer quantity) {
        Book book = bookRepository.findById(id)
            .orElseThrow(() -> new IllegalArgumentException("Book not found."));
        book.setTitle(title.trim());
        book.setAuthor(author != null ? author.trim() : null);
        book.setDescription(description);
        book.setCategory(category != null ? category.trim() : null);
        book.setImageUrl(imageUrl != null ? imageUrl.trim() : null);
        book.setStarRating(starRating != null ? starRating : 0);
        book.setPrice(price);
        book.setQuantity(quantity);
        return bookRepository.save(book);
    }

    public void delete(Integer id) {
        bookRepository.deleteById(id);
    }

    public long getTotalCount() {
        return bookRepository.count();
    }

    public long getLowStockCount() {
        return bookRepository.findLowStock(Constants.LOW_STOCK_THRESHOLD).size();
    }

    public Double getTotalInventoryValue() {
        Double val = bookRepository.getTotalInventoryValue();
        return val != null ? val : 0.0;
    }
}
