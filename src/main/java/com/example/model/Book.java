package com.example.model;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import java.math.BigDecimal;

@Entity
@Table(name = "books")
@Getter @Setter @NoArgsConstructor
public class Book {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(nullable = false, length = 500)
    private String title;

    @Column(length = 200)
    private String author;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(length = 100)
    private String category;

    @Column(name = "image_url", length = 1000)
    private String imageUrl;

    @Column(name = "star_rating")
    private Integer starRating = 0;

    @Column(nullable = false, precision = 8, scale = 2)
    private BigDecimal price;

    @Column(nullable = false)
    private Integer quantity;

    // Generated column — read-only from DB
    @Column(name = "in_stock", insertable = false, updatable = false)
    private Boolean inStock;
}
