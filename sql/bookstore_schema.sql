-- ============================================================
-- The Modern Archive - Bookstore Database Schema
-- CCS2304-CS244 Advanced Programming Applications
-- ============================================================

CREATE DATABASE IF NOT EXISTS bookstore_db;
USE bookstore_db;

-- ============================================================
-- USERS TABLE
-- ============================================================
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    name VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_username (username),
    INDEX idx_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- ADMINS TABLE
-- ============================================================
CREATE TABLE admins (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    INDEX idx_admin_username (username)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- BOOKS TABLE
-- ============================================================
CREATE TABLE books (
    id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(500) NOT NULL,
    author VARCHAR(200),
    description TEXT,
    category VARCHAR(100),
    image_url VARCHAR(1000),
    star_rating INT DEFAULT 0,
    price DECIMAL(8, 2) NOT NULL,
    quantity INT NOT NULL,
    in_stock TINYINT(1) GENERATED ALWAYS AS (quantity > 0) STORED,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_category (category),
    INDEX idx_title (title),
    INDEX idx_in_stock (in_stock)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET @has_image_col := (
    SELECT COUNT(*)
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'books'
      AND COLUMN_NAME = 'image_url'
);
SET @add_image_col_sql := IF(
    @has_image_col = 0,
    'ALTER TABLE books ADD COLUMN image_url VARCHAR(1000) NULL AFTER category',
    'SELECT 1'
);
PREPARE add_image_col_stmt FROM @add_image_col_sql;
EXECUTE add_image_col_stmt;
DEALLOCATE PREPARE add_image_col_stmt;

-- ============================================================
-- CART_ITEMS TABLE
-- ============================================================
CREATE TABLE cart_items (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    book_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_cart (user_id, book_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (book_id) REFERENCES books(id) ON DELETE CASCADE,
    INDEX idx_cart_user_id (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- ORDERS TABLE
-- ============================================================
CREATE TABLE orders (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,
    status ENUM('PENDING', 'CONFIRMED', 'SHIPPED', 'CANCELLED') DEFAULT 'PENDING',
    email_sent TINYINT(1) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_order_user_id (user_id),
    INDEX idx_order_status (status),
    INDEX idx_order_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- ORDER_ITEMS TABLE
-- ============================================================
CREATE TABLE order_items (
    id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    book_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(8, 2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (book_id) REFERENCES books(id) ON DELETE CASCADE,
    INDEX idx_oi_order_id (order_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- PAYMENTS TABLE
-- ============================================================
CREATE TABLE payments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL UNIQUE,
    status ENUM('PENDING', 'SUCCESS', 'FAILED') DEFAULT 'PENDING',
    transaction_id VARCHAR(100),
    paid_at TIMESTAMP NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    INDEX idx_transaction_id (transaction_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- SAMPLE DATA
-- ============================================================

INSERT IGNORE INTO admins (username, email, password) VALUES
('admin', 'admin@bookstore.com', 'admin123');

DELETE FROM books;
ALTER TABLE books AUTO_INCREMENT = 1;

INSERT INTO books (title, author, description, category, image_url, star_rating, price, quantity) VALUES
('The Hobbit', 'J.R.R. Tolkien', 'A widely read Fantasy title by J.R.R. Tolkien, curated for The Modern Archive catalog.', 'Fantasy', 'https://covers.openlibrary.org/b/title/The%20Hobbit-L.jpg', 4, 61.52, 16),
('The Fellowship of the Ring', 'J.R.R. Tolkien', 'A widely read Fantasy title by J.R.R. Tolkien, curated for The Modern Archive catalog.', 'Fantasy', 'https://covers.openlibrary.org/b/title/The%20Fellowship%20of%20the%20Ring-L.jpg', 3, 36.89, 1),
('The Two Towers', 'J.R.R. Tolkien', 'A widely read Fantasy title by J.R.R. Tolkien, curated for The Modern Archive catalog.', 'Fantasy', 'https://covers.openlibrary.org/b/title/The%20Two%20Towers-L.jpg', 3, 30.74, 1),
('The Return of the King', 'J.R.R. Tolkien', 'A widely read Fantasy title by J.R.R. Tolkien, curated for The Modern Archive catalog.', 'Fantasy', 'https://covers.openlibrary.org/b/title/The%20Return%20of%20the%20King-L.jpg', 5, 53.7, 16),
('Harry Potter and the Sorcerer''s Stone', 'J.K. Rowling', 'A widely read Fantasy title by J.K. Rowling, curated for The Modern Archive catalog.', 'Fantasy', 'https://covers.openlibrary.org/b/title/Harry%20Potter%20and%20the%20Sorcerer%27s%20Stone-L.jpg', 4, 19.98, 50),
('Harry Potter and the Chamber of Secrets', 'J.K. Rowling', 'A widely read Fantasy title by J.K. Rowling, curated for The Modern Archive catalog.', 'Fantasy', 'https://covers.openlibrary.org/b/title/Harry%20Potter%20and%20the%20Chamber%20of%20Secrets-L.jpg', 5, 33.44, 33),
('A Game of Thrones', 'George R.R. Martin', 'A widely read Fantasy title by George R.R. Martin, curated for The Modern Archive catalog.', 'Fantasy', 'https://covers.openlibrary.org/b/title/A%20Game%20of%20Thrones-L.jpg', 3, 37.21, 67),
('The Name of the Wind', 'Patrick Rothfuss', 'A widely read Fantasy title by Patrick Rothfuss, curated for The Modern Archive catalog.', 'Fantasy', 'https://covers.openlibrary.org/b/title/The%20Name%20of%20the%20Wind-L.jpg', 3, 34.01, 65),
('Mistborn: The Final Empire', 'Brandon Sanderson', 'A widely read Fantasy title by Brandon Sanderson, curated for The Modern Archive catalog.', 'Fantasy', 'https://covers.openlibrary.org/b/title/Mistborn%3A%20The%20Final%20Empire-L.jpg', 4, 36.36, 59),
('The Way of Kings', 'Brandon Sanderson', 'A widely read Fantasy title by Brandon Sanderson, curated for The Modern Archive catalog.', 'Fantasy', 'https://covers.openlibrary.org/b/title/The%20Way%20of%20Kings-L.jpg', 3, 66.61, 44),
('Dune', 'Frank Herbert', 'A widely read Science Fiction title by Frank Herbert, curated for The Modern Archive catalog.', 'Science Fiction', 'https://covers.openlibrary.org/b/title/Dune-L.jpg', 5, 31.87, 56),
('Foundation', 'Isaac Asimov', 'A widely read Science Fiction title by Isaac Asimov, curated for The Modern Archive catalog.', 'Science Fiction', 'https://covers.openlibrary.org/b/title/Foundation-L.jpg', 5, 20.71, 43),
('Neuromancer', 'William Gibson', 'A widely read Science Fiction title by William Gibson, curated for The Modern Archive catalog.', 'Science Fiction', 'https://covers.openlibrary.org/b/title/Neuromancer-L.jpg', 4, 44.15, 64),
('Ender''s Game', 'Orson Scott Card', 'A widely read Science Fiction title by Orson Scott Card, curated for The Modern Archive catalog.', 'Science Fiction', 'https://covers.openlibrary.org/b/title/Ender%27s%20Game-L.jpg', 3, 28.04, 58),
('The Martian', 'Andy Weir', 'A widely read Science Fiction title by Andy Weir, curated for The Modern Archive catalog.', 'Science Fiction', 'https://covers.openlibrary.org/b/title/The%20Martian-L.jpg', 4, 12.19, 46),
('Snow Crash', 'Neal Stephenson', 'A widely read Science Fiction title by Neal Stephenson, curated for The Modern Archive catalog.', 'Science Fiction', 'https://covers.openlibrary.org/b/title/Snow%20Crash-L.jpg', 5, 24.01, 39),
('The Left Hand of Darkness', 'Ursula K. Le Guin', 'A widely read Science Fiction title by Ursula K. Le Guin, curated for The Modern Archive catalog.', 'Science Fiction', 'https://covers.openlibrary.org/b/title/The%20Left%20Hand%20of%20Darkness-L.jpg', 3, 54.89, 6),
('The Three-Body Problem', 'Liu Cixin', 'A widely read Science Fiction title by Liu Cixin, curated for The Modern Archive catalog.', 'Science Fiction', 'https://covers.openlibrary.org/b/title/The%20Three-Body%20Problem-L.jpg', 3, 16.01, 62),
('Do Androids Dream of Electric Sheep?', 'Philip K. Dick', 'A widely read Science Fiction title by Philip K. Dick, curated for The Modern Archive catalog.', 'Science Fiction', 'https://covers.openlibrary.org/b/title/Do%20Androids%20Dream%20of%20Electric%20Sheep%3F-L.jpg', 4, 28.84, 33),
('Hyperion', 'Dan Simmons', 'A widely read Science Fiction title by Dan Simmons, curated for The Modern Archive catalog.', 'Science Fiction', 'https://covers.openlibrary.org/b/title/Hyperion-L.jpg', 3, 59.88, 0),
('Pride and Prejudice', 'Jane Austen', 'A widely read Classic Literature title by Jane Austen, curated for The Modern Archive catalog.', 'Classic Literature', 'https://covers.openlibrary.org/b/title/Pride%20and%20Prejudice-L.jpg', 3, 67.93, 27),
('Jane Eyre', 'Charlotte Bronte', 'A widely read Classic Literature title by Charlotte Bronte, curated for The Modern Archive catalog.', 'Classic Literature', 'https://covers.openlibrary.org/b/title/Jane%20Eyre-L.jpg', 4, 18.01, 26),
('Wuthering Heights', 'Emily Bronte', 'A widely read Classic Literature title by Emily Bronte, curated for The Modern Archive catalog.', 'Classic Literature', 'https://covers.openlibrary.org/b/title/Wuthering%20Heights-L.jpg', 4, 56.58, 70),
('Moby-Dick', 'Herman Melville', 'A widely read Classic Literature title by Herman Melville, curated for The Modern Archive catalog.', 'Classic Literature', 'https://covers.openlibrary.org/b/title/Moby-Dick-L.jpg', 3, 34, 57),
('The Great Gatsby', 'F. Scott Fitzgerald', 'A widely read Classic Literature title by F. Scott Fitzgerald, curated for The Modern Archive catalog.', 'Classic Literature', 'https://covers.openlibrary.org/b/title/The%20Great%20Gatsby-L.jpg', 4, 62.55, 11),
('Crime and Punishment', 'Fyodor Dostoevsky', 'A widely read Classic Literature title by Fyodor Dostoevsky, curated for The Modern Archive catalog.', 'Classic Literature', 'https://covers.openlibrary.org/b/title/Crime%20and%20Punishment-L.jpg', 3, 56.01, 26),
('Anna Karenina', 'Leo Tolstoy', 'A widely read Classic Literature title by Leo Tolstoy, curated for The Modern Archive catalog.', 'Classic Literature', 'https://covers.openlibrary.org/b/title/Anna%20Karenina-L.jpg', 3, 53.52, 15),
('The Brothers Karamazov', 'Fyodor Dostoevsky', 'A widely read Classic Literature title by Fyodor Dostoevsky, curated for The Modern Archive catalog.', 'Classic Literature', 'https://covers.openlibrary.org/b/title/The%20Brothers%20Karamazov-L.jpg', 3, 13.81, 14),
('The Catcher in the Rye', 'J.D. Salinger', 'A widely read Classic Literature title by J.D. Salinger, curated for The Modern Archive catalog.', 'Classic Literature', 'https://covers.openlibrary.org/b/title/The%20Catcher%20in%20the%20Rye-L.jpg', 4, 49.12, 19),
('Brave New World', 'Aldous Huxley', 'A widely read Classic Literature title by Aldous Huxley, curated for The Modern Archive catalog.', 'Classic Literature', 'https://covers.openlibrary.org/b/title/Brave%20New%20World-L.jpg', 5, 25.18, 61),
('Meditations', 'Marcus Aurelius', 'A widely read Philosophy title by Marcus Aurelius, curated for The Modern Archive catalog.', 'Philosophy', 'https://covers.openlibrary.org/b/title/Meditations-L.jpg', 3, 25.71, 51),
('The Republic', 'Plato', 'A widely read Philosophy title by Plato, curated for The Modern Archive catalog.', 'Philosophy', 'https://covers.openlibrary.org/b/title/The%20Republic-L.jpg', 5, 69.35, 22),
('Beyond Good and Evil', 'Friedrich Nietzsche', 'A widely read Philosophy title by Friedrich Nietzsche, curated for The Modern Archive catalog.', 'Philosophy', 'https://covers.openlibrary.org/b/title/Beyond%20Good%20and%20Evil-L.jpg', 4, 67.32, 63),
('Nicomachean Ethics', 'Aristotle', 'A widely read Philosophy title by Aristotle, curated for The Modern Archive catalog.', 'Philosophy', 'https://covers.openlibrary.org/b/title/Nicomachean%20Ethics-L.jpg', 3, 32.1, 31),
('The Prince', 'Niccolo Machiavelli', 'A widely read Philosophy title by Niccolo Machiavelli, curated for The Modern Archive catalog.', 'Philosophy', 'https://covers.openlibrary.org/b/title/The%20Prince-L.jpg', 4, 19.51, 25),
('Tao Te Ching', 'Laozi', 'A widely read Philosophy title by Laozi, curated for The Modern Archive catalog.', 'Philosophy', 'https://covers.openlibrary.org/b/title/Tao%20Te%20Ching-L.jpg', 3, 44.85, 14),
('Thus Spoke Zarathustra', 'Friedrich Nietzsche', 'A widely read Philosophy title by Friedrich Nietzsche, curated for The Modern Archive catalog.', 'Philosophy', 'https://covers.openlibrary.org/b/title/Thus%20Spoke%20Zarathustra-L.jpg', 5, 34.94, 37),
('Critique of Pure Reason', 'Immanuel Kant', 'A widely read Philosophy title by Immanuel Kant, curated for The Modern Archive catalog.', 'Philosophy', 'https://covers.openlibrary.org/b/title/Critique%20of%20Pure%20Reason-L.jpg', 3, 14.56, 7),
('Being and Nothingness', 'Jean-Paul Sartre', 'A widely read Philosophy title by Jean-Paul Sartre, curated for The Modern Archive catalog.', 'Philosophy', 'https://covers.openlibrary.org/b/title/Being%20and%20Nothingness-L.jpg', 5, 64.54, 66),
('Man''s Search for Meaning', 'Viktor E. Frankl', 'A widely read Philosophy title by Viktor E. Frankl, curated for The Modern Archive catalog.', 'Philosophy', 'https://covers.openlibrary.org/b/title/Man%27s%20Search%20for%20Meaning-L.jpg', 3, 61.24, 32),
('Thinking, Fast and Slow', 'Daniel Kahneman', 'A widely read Psychology title by Daniel Kahneman, curated for The Modern Archive catalog.', 'Psychology', 'https://covers.openlibrary.org/b/title/Thinking%2C%20Fast%20and%20Slow-L.jpg', 3, 42.54, 38),
('Influence: The Psychology of Persuasion', 'Robert B. Cialdini', 'A widely read Psychology title by Robert B. Cialdini, curated for The Modern Archive catalog.', 'Psychology', 'https://covers.openlibrary.org/b/title/Influence%3A%20The%20Psychology%20of%20Persuasion-L.jpg', 3, 67.92, 10),
('Predictably Irrational', 'Dan Ariely', 'A widely read Psychology title by Dan Ariely, curated for The Modern Archive catalog.', 'Psychology', 'https://covers.openlibrary.org/b/title/Predictably%20Irrational-L.jpg', 3, 50.74, 62),
('Quiet', 'Susan Cain', 'A widely read Psychology title by Susan Cain, curated for The Modern Archive catalog.', 'Psychology', 'https://covers.openlibrary.org/b/title/Quiet-L.jpg', 5, 51.9, 57),
('Grit', 'Angela Duckworth', 'A widely read Psychology title by Angela Duckworth, curated for The Modern Archive catalog.', 'Psychology', 'https://covers.openlibrary.org/b/title/Grit-L.jpg', 4, 69.09, 26),
('Flow', 'Mihaly Csikszentmihalyi', 'A widely read Psychology title by Mihaly Csikszentmihalyi, curated for The Modern Archive catalog.', 'Psychology', 'https://covers.openlibrary.org/b/title/Flow-L.jpg', 5, 53.59, 64),
('The Body Keeps the Score', 'Bessel van der Kolk', 'A widely read Psychology title by Bessel van der Kolk, curated for The Modern Archive catalog.', 'Psychology', 'https://covers.openlibrary.org/b/title/The%20Body%20Keeps%20the%20Score-L.jpg', 5, 27.68, 5),
('Behave', 'Robert M. Sapolsky', 'A widely read Psychology title by Robert M. Sapolsky, curated for The Modern Archive catalog.', 'Psychology', 'https://covers.openlibrary.org/b/title/Behave-L.jpg', 3, 23.56, 59),
('Drive', 'Daniel H. Pink', 'A widely read Psychology title by Daniel H. Pink, curated for The Modern Archive catalog.', 'Psychology', 'https://covers.openlibrary.org/b/title/Drive-L.jpg', 3, 14.39, 13),
('Emotional Intelligence', 'Daniel Goleman', 'A widely read Psychology title by Daniel Goleman, curated for The Modern Archive catalog.', 'Psychology', 'https://covers.openlibrary.org/b/title/Emotional%20Intelligence-L.jpg', 4, 17.91, 5),
('Atomic Habits', 'James Clear', 'A widely read Self-Help title by James Clear, curated for The Modern Archive catalog.', 'Self-Help', 'https://covers.openlibrary.org/b/title/Atomic%20Habits-L.jpg', 4, 27.15, 7),
('The 7 Habits of Highly Effective People', 'Stephen R. Covey', 'A widely read Self-Help title by Stephen R. Covey, curated for The Modern Archive catalog.', 'Self-Help', 'https://covers.openlibrary.org/b/title/The%207%20Habits%20of%20Highly%20Effective%20People-L.jpg', 4, 22.41, 58),
('How to Win Friends and Influence People', 'Dale Carnegie', 'A widely read Self-Help title by Dale Carnegie, curated for The Modern Archive catalog.', 'Self-Help', 'https://covers.openlibrary.org/b/title/How%20to%20Win%20Friends%20and%20Influence%20People-L.jpg', 5, 37.32, 11),
('The Power of Now', 'Eckhart Tolle', 'A widely read Self-Help title by Eckhart Tolle, curated for The Modern Archive catalog.', 'Self-Help', 'https://covers.openlibrary.org/b/title/The%20Power%20of%20Now-L.jpg', 3, 22.75, 63),
('Deep Work', 'Cal Newport', 'A widely read Self-Help title by Cal Newport, curated for The Modern Archive catalog.', 'Self-Help', 'https://covers.openlibrary.org/b/title/Deep%20Work-L.jpg', 3, 62.52, 50),
('Can''t Hurt Me', 'David Goggins', 'A widely read Self-Help title by David Goggins, curated for The Modern Archive catalog.', 'Self-Help', 'https://covers.openlibrary.org/b/title/Can%27t%20Hurt%20Me-L.jpg', 5, 48.07, 4),
('The Subtle Art of Not Giving a F*ck', 'Mark Manson', 'A widely read Self-Help title by Mark Manson, curated for The Modern Archive catalog.', 'Self-Help', 'https://covers.openlibrary.org/b/title/The%20Subtle%20Art%20of%20Not%20Giving%20a%20F%2Ack-L.jpg', 5, 13.28, 13),
('Essentialism', 'Greg McKeown', 'A widely read Self-Help title by Greg McKeown, curated for The Modern Archive catalog.', 'Self-Help', 'https://covers.openlibrary.org/b/title/Essentialism-L.jpg', 3, 31.59, 41),
('Tiny Habits', 'BJ Fogg', 'A widely read Self-Help title by BJ Fogg, curated for The Modern Archive catalog.', 'Self-Help', 'https://covers.openlibrary.org/b/title/Tiny%20Habits-L.jpg', 4, 13.57, 23),
('Mindset', 'Carol S. Dweck', 'A widely read Self-Help title by Carol S. Dweck, curated for The Modern Archive catalog.', 'Self-Help', 'https://covers.openlibrary.org/b/title/Mindset-L.jpg', 5, 58.35, 65),
('The Lean Startup', 'Eric Ries', 'A widely read Business title by Eric Ries, curated for The Modern Archive catalog.', 'Business', 'https://covers.openlibrary.org/b/title/The%20Lean%20Startup-L.jpg', 5, 39.12, 40),
('Zero to One', 'Peter Thiel', 'A widely read Business title by Peter Thiel, curated for The Modern Archive catalog.', 'Business', 'https://covers.openlibrary.org/b/title/Zero%20to%20One-L.jpg', 5, 39.06, 30),
('Good to Great', 'Jim Collins', 'A widely read Business title by Jim Collins, curated for The Modern Archive catalog.', 'Business', 'https://covers.openlibrary.org/b/title/Good%20to%20Great-L.jpg', 5, 14.33, 57),
('The Hard Thing About Hard Things', 'Ben Horowitz', 'A widely read Business title by Ben Horowitz, curated for The Modern Archive catalog.', 'Business', 'https://covers.openlibrary.org/b/title/The%20Hard%20Thing%20About%20Hard%20Things-L.jpg', 4, 62.88, 19),
('Blue Ocean Strategy', 'W. Chan Kim', 'A widely read Business title by W. Chan Kim, curated for The Modern Archive catalog.', 'Business', 'https://covers.openlibrary.org/b/title/Blue%20Ocean%20Strategy-L.jpg', 5, 48.22, 6),
('Start with Why', 'Simon Sinek', 'A widely read Business title by Simon Sinek, curated for The Modern Archive catalog.', 'Business', 'https://covers.openlibrary.org/b/title/Start%20with%20Why-L.jpg', 3, 56.14, 23),
('Measure What Matters', 'John Doerr', 'A widely read Business title by John Doerr, curated for The Modern Archive catalog.', 'Business', 'https://covers.openlibrary.org/b/title/Measure%20What%20Matters-L.jpg', 3, 46.91, 29),
('The Innovator''s Dilemma', 'Clayton M. Christensen', 'A widely read Business title by Clayton M. Christensen, curated for The Modern Archive catalog.', 'Business', 'https://covers.openlibrary.org/b/title/The%20Innovator%27s%20Dilemma-L.jpg', 3, 62.97, 5),
('Shoe Dog', 'Phil Knight', 'A widely read Business title by Phil Knight, curated for The Modern Archive catalog.', 'Business', 'https://covers.openlibrary.org/b/title/Shoe%20Dog-L.jpg', 5, 32.17, 65),
('The Personal MBA', 'Josh Kaufman', 'A widely read Business title by Josh Kaufman, curated for The Modern Archive catalog.', 'Business', 'https://covers.openlibrary.org/b/title/The%20Personal%20MBA-L.jpg', 4, 14.69, 10),
('Clean Code', 'Robert C. Martin', 'A widely read Technology title by Robert C. Martin, curated for The Modern Archive catalog.', 'Technology', 'https://covers.openlibrary.org/b/title/Clean%20Code-L.jpg', 4, 22.86, 45),
('The Pragmatic Programmer', 'Andrew Hunt and David Thomas', 'A widely read Technology title by Andrew Hunt and David Thomas, curated for The Modern Archive catalog.', 'Technology', 'https://covers.openlibrary.org/b/title/The%20Pragmatic%20Programmer-L.jpg', 3, 27.47, 50),
('Design Patterns: Elements of Reusable Object-Oriented Software', 'Erich Gamma et al.', 'A widely read Technology title by Erich Gamma et al., curated for The Modern Archive catalog.', 'Technology', 'https://covers.openlibrary.org/b/title/Design%20Patterns%3A%20Elements%20of%20Reusable%20Object-Oriented%20Software-L.jpg', 3, 41.87, 28),
('Introduction to Algorithms', 'Thomas H. Cormen et al.', 'A widely read Technology title by Thomas H. Cormen et al., curated for The Modern Archive catalog.', 'Technology', 'https://covers.openlibrary.org/b/title/Introduction%20to%20Algorithms-L.jpg', 3, 13.51, 41),
('Code Complete', 'Steve McConnell', 'A widely read Technology title by Steve McConnell, curated for The Modern Archive catalog.', 'Technology', 'https://covers.openlibrary.org/b/title/Code%20Complete-L.jpg', 3, 23.07, 10),
('Refactoring', 'Martin Fowler', 'A widely read Technology title by Martin Fowler, curated for The Modern Archive catalog.', 'Technology', 'https://covers.openlibrary.org/b/title/Refactoring-L.jpg', 5, 29.11, 50),
('Structure and Interpretation of Computer Programs', 'Harold Abelson and Gerald Jay Sussman', 'A widely read Technology title by Harold Abelson and Gerald Jay Sussman, curated for The Modern Archive catalog.', 'Technology', 'https://covers.openlibrary.org/b/title/Structure%20and%20Interpretation%20of%20Computer%20Programs-L.jpg', 4, 24.43, 18),
('The Mythical Man-Month', 'Frederick P. Brooks Jr.', 'A widely read Technology title by Frederick P. Brooks Jr., curated for The Modern Archive catalog.', 'Technology', 'https://covers.openlibrary.org/b/title/The%20Mythical%20Man-Month-L.jpg', 5, 45.97, 13),
('The Phoenix Project', 'Gene Kim', 'A widely read Technology title by Gene Kim, curated for The Modern Archive catalog.', 'Technology', 'https://covers.openlibrary.org/b/title/The%20Phoenix%20Project-L.jpg', 4, 59.45, 41),
('Cracking the Coding Interview', 'Gayle Laakmann McDowell', 'A widely read Technology title by Gayle Laakmann McDowell, curated for The Modern Archive catalog.', 'Technology', 'https://covers.openlibrary.org/b/title/Cracking%20the%20Coding%20Interview-L.jpg', 4, 64.53, 8),
('The Hunger Games', 'Suzanne Collins', 'A widely read Young Adult title by Suzanne Collins, curated for The Modern Archive catalog.', 'Young Adult', 'https://covers.openlibrary.org/b/title/The%20Hunger%20Games-L.jpg', 4, 22.1, 70),
('Catching Fire', 'Suzanne Collins', 'A widely read Young Adult title by Suzanne Collins, curated for The Modern Archive catalog.', 'Young Adult', 'https://covers.openlibrary.org/b/title/Catching%20Fire-L.jpg', 4, 15.29, 48),
('Mockingjay', 'Suzanne Collins', 'A widely read Young Adult title by Suzanne Collins, curated for The Modern Archive catalog.', 'Young Adult', 'https://covers.openlibrary.org/b/title/Mockingjay-L.jpg', 4, 40.65, 25),
('Divergent', 'Veronica Roth', 'A widely read Young Adult title by Veronica Roth, curated for The Modern Archive catalog.', 'Young Adult', 'https://covers.openlibrary.org/b/title/Divergent-L.jpg', 4, 60.9, 17),
('The Fault in Our Stars', 'John Green', 'A widely read Young Adult title by John Green, curated for The Modern Archive catalog.', 'Young Adult', 'https://covers.openlibrary.org/b/title/The%20Fault%20in%20Our%20Stars-L.jpg', 5, 60.91, 40),
('Percy Jackson and the Olympians: The Lightning Thief', 'Rick Riordan', 'A widely read Young Adult title by Rick Riordan, curated for The Modern Archive catalog.', 'Young Adult', 'https://covers.openlibrary.org/b/title/Percy%20Jackson%20and%20the%20Olympians%3A%20The%20Lightning%20Thief-L.jpg', 5, 62.91, 48),
('The Maze Runner', 'James Dashner', 'A widely read Young Adult title by James Dashner, curated for The Modern Archive catalog.', 'Young Adult', 'https://covers.openlibrary.org/b/title/The%20Maze%20Runner-L.jpg', 5, 69.18, 3),
('Six of Crows', 'Leigh Bardugo', 'A widely read Young Adult title by Leigh Bardugo, curated for The Modern Archive catalog.', 'Young Adult', 'https://covers.openlibrary.org/b/title/Six%20of%20Crows-L.jpg', 3, 13.89, 59),
('The Giver', 'Lois Lowry', 'A widely read Young Adult title by Lois Lowry, curated for The Modern Archive catalog.', 'Young Adult', 'https://covers.openlibrary.org/b/title/The%20Giver-L.jpg', 5, 40.64, 42),
('The Perks of Being a Wallflower', 'Stephen Chbosky', 'A widely read Young Adult title by Stephen Chbosky, curated for The Modern Archive catalog.', 'Young Adult', 'https://covers.openlibrary.org/b/title/The%20Perks%20of%20Being%20a%20Wallflower-L.jpg', 4, 54.84, 31),
('Gone Girl', 'Gillian Flynn', 'A widely read Thriller title by Gillian Flynn, curated for The Modern Archive catalog.', 'Thriller', 'https://covers.openlibrary.org/b/title/Gone%20Girl-L.jpg', 3, 61.07, 43),
('The Girl with the Dragon Tattoo', 'Stieg Larsson', 'A widely read Mystery title by Stieg Larsson, curated for The Modern Archive catalog.', 'Mystery', 'https://covers.openlibrary.org/b/title/The%20Girl%20with%20the%20Dragon%20Tattoo-L.jpg', 3, 57.09, 60),
('The Da Vinci Code', 'Dan Brown', 'A widely read Thriller title by Dan Brown, curated for The Modern Archive catalog.', 'Thriller', 'https://covers.openlibrary.org/b/title/The%20Da%20Vinci%20Code-L.jpg', 4, 46.94, 9),
('And Then There Were None', 'Agatha Christie', 'A widely read Mystery title by Agatha Christie, curated for The Modern Archive catalog.', 'Mystery', 'https://covers.openlibrary.org/b/title/And%20Then%20There%20Were%20None-L.jpg', 4, 27.38, 56),
('The Notebook', 'Nicholas Sparks', 'A widely read Romance title by Nicholas Sparks, curated for The Modern Archive catalog.', 'Romance', 'https://covers.openlibrary.org/b/title/The%20Notebook-L.jpg', 4, 19.32, 26),
('Me Before You', 'Jojo Moyes', 'A widely read Romance title by Jojo Moyes, curated for The Modern Archive catalog.', 'Romance', 'https://covers.openlibrary.org/b/title/Me%20Before%20You-L.jpg', 3, 16.35, 52),
('The Book Thief', 'Markus Zusak', 'A widely read Historical Fiction title by Markus Zusak, curated for The Modern Archive catalog.', 'Historical Fiction', 'https://covers.openlibrary.org/b/title/The%20Book%20Thief-L.jpg', 4, 50.63, 66),
('All the Light We Cannot See', 'Anthony Doerr', 'A widely read Historical Fiction title by Anthony Doerr, curated for The Modern Archive catalog.', 'Historical Fiction', 'https://covers.openlibrary.org/b/title/All%20the%20Light%20We%20Cannot%20See-L.jpg', 5, 43.97, 65),
('Steve Jobs', 'Walter Isaacson', 'A widely read Biography title by Walter Isaacson, curated for The Modern Archive catalog.', 'Biography', 'https://covers.openlibrary.org/b/title/Steve%20Jobs-L.jpg', 3, 29, 10),
('Sapiens: A Brief History of Humankind', 'Yuval Noah Harari', 'A widely read Nonfiction title by Yuval Noah Harari, curated for The Modern Archive catalog.', 'Nonfiction', 'https://covers.openlibrary.org/b/title/Sapiens%3A%20A%20Brief%20History%20of%20Humankind-L.jpg', 3, 56.42, 39);

INSERT IGNORE INTO users (username, email, password, name) VALUES
('testuser', 'test@example.com', 'password123', 'Test User');

-- ============================================================
-- PERFORMANCE INDEXES
-- ============================================================
CREATE INDEX idx_books_price ON books(price);
CREATE INDEX idx_books_quantity ON books(quantity);
