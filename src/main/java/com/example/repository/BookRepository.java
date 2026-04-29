package com.example.repository;

import com.example.model.Book;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface BookRepository extends JpaRepository<Book, Integer> {

    List<Book> findByCategory(String category);

    List<Book> findByQuantityGreaterThan(int quantity);

    @Query("SELECT b FROM Book b WHERE LOWER(b.title) LIKE LOWER(CONCAT('%', :keyword, '%')) " +
           "OR LOWER(b.description) LIKE LOWER(CONCAT('%', :keyword, '%')) " +
           "OR LOWER(b.category) LIKE LOWER(CONCAT('%', :keyword, '%'))")
    List<Book> searchBooks(@Param("keyword") String keyword);

    @Query("SELECT b FROM Book b WHERE b.quantity > 0 AND b.quantity <= :threshold")
    List<Book> findLowStock(@Param("threshold") int threshold);

    @Query("SELECT SUM(b.price * b.quantity) FROM Book b")
    Double getTotalInventoryValue();

    Page<Book> findAll(Pageable pageable);

    @Query("SELECT DISTINCT b.category FROM Book b WHERE b.category IS NOT NULL ORDER BY b.category")
    List<String> findAllCategories();
}
