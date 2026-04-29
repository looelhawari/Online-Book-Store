package com.example.repository;

import com.example.model.CartItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface CartItemRepository extends JpaRepository<CartItem, Integer> {

    List<CartItem> findByUserId(Integer userId);

    Optional<CartItem> findByUserIdAndBookId(Integer userId, Integer bookId);

    @Modifying
    @Query("DELETE FROM CartItem c WHERE c.user.id = :userId")
    void deleteByUserId(@Param("userId") Integer userId);

    @Query("SELECT SUM(c.quantity * c.book.price) FROM CartItem c WHERE c.user.id = :userId")
    Double getCartTotal(@Param("userId") Integer userId);

    long countByUserId(Integer userId);
}
