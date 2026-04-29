package com.example.service;

import com.example.model.Book;
import com.example.model.CartItem;
import com.example.model.User;
import com.example.repository.BookRepository;
import com.example.repository.CartItemRepository;
import com.example.repository.UserRepository;
import com.example.util.Constants;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class CartService {

    private final CartItemRepository cartItemRepository;
    private final BookRepository bookRepository;
    private final UserRepository userRepository;

    public List<CartItem> getCartItems(Integer userId) {
        return cartItemRepository.findByUserId(userId);
    }

    @Transactional
    public CartItem addToCart(Integer userId, Integer bookId, int quantity) {
        Book book = bookRepository.findById(bookId)
            .orElseThrow(() -> new IllegalArgumentException("Book not found."));
        if (book.getQuantity() <= 0) {
            throw new IllegalStateException(Constants.MSG_OUT_OF_STOCK);
        }
        Optional<CartItem> existing = cartItemRepository.findByUserIdAndBookId(userId, bookId);
        if (existing.isPresent()) {
            CartItem item = existing.get();
            int newQty = Math.min(item.getQuantity() + quantity, Constants.MAX_CART_ITEMS_PER_BOOK);
            item.setQuantity(newQty);
            return cartItemRepository.save(item);
        } else {
            User user = userRepository.getReferenceById(userId);
            CartItem item = new CartItem();
            item.setUser(user);
            item.setBook(book);
            item.setQuantity(Math.min(quantity, Constants.MAX_CART_ITEMS_PER_BOOK));
            return cartItemRepository.save(item);
        }
    }

    @Transactional
    public CartItem updateQuantity(Integer cartItemId, Integer userId, int quantity) {
        CartItem item = cartItemRepository.findById(cartItemId)
            .orElseThrow(() -> new IllegalArgumentException("Cart item not found."));
        if (!item.getUser().getId().equals(userId)) {
            throw new SecurityException("Unauthorized.");
        }
        if (quantity <= 0) {
            cartItemRepository.delete(item);
            return null;
        }
        item.setQuantity(Math.min(quantity, Constants.MAX_CART_ITEMS_PER_BOOK));
        return cartItemRepository.save(item);
    }

    @Transactional
    public void removeItem(Integer cartItemId, Integer userId) {
        CartItem item = cartItemRepository.findById(cartItemId)
            .orElseThrow(() -> new IllegalArgumentException("Cart item not found."));
        if (!item.getUser().getId().equals(userId)) {
            throw new SecurityException("Unauthorized.");
        }
        cartItemRepository.delete(item);
    }

    @Transactional
    public void clearCart(Integer userId) {
        cartItemRepository.deleteByUserId(userId);
    }

    public double getCartTotal(Integer userId) {
        Double total = cartItemRepository.getCartTotal(userId);
        return total != null ? total : 0.0;
    }

    public long getCartCount(Integer userId) {
        return cartItemRepository.countByUserId(userId);
    }
}
