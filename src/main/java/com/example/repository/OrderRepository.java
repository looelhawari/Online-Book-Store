package com.example.repository;

import com.example.model.Order;
import com.example.model.OrderStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface OrderRepository extends JpaRepository<Order, Integer> {

    List<Order> findByUserIdOrderByCreatedAtDesc(Integer userId);

    Page<Order> findAll(Pageable pageable);

    List<Order> findByStatus(OrderStatus status);

    long countByStatus(OrderStatus status);
}
