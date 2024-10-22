-- Category table constraints
ALTER TABLE category
ADD CONSTRAINT chk_category_name
CHECK (name IN ('Animation', 'Comedy', 'Family', 'Foreign', 'Sci-Fi', 'Travel', 'Children', 'Drama', 'Horror', 'Action', 'Classics', 'Games', 'New', 'Documentary', 'Sports', 'Music'));

-- Film tables constraints
ALTER TABLE film
ADD CONSTRAINT chk_special_features
CHECK (special_features IN ('Behind the Scenes', 'Commentaries', 'Deleted Scenes', 'Trailers')),
ADD CONSTRAINT chk_rental_duration
CHECK (rental_duration BETWEEN 2 AND 8),
ADD CONSTRAINT chk_rental_rate
CHECK (rental_rate BETWEEN 0.99 AND 6.99),
ADD CONSTRAINT chk_length
CHECK (length BETWEEN 30 AND 200),
ADD CONSTRAINT chk_replacement_cost
CHECK (replacement_cost BETWEEN 5.00 AND 100.00),
ADD CONSTRAINT chk_rating
CHECK (rating IN ('PG', 'G', 'NC-17', 'PG-13', 'R'));

-- Customer table constraints
ALTER TABLE customer
ADD CONSTRAINT chk_customer_active
CHECK (active IN (0, 1));

-- Staff table constraints
ALTER TABLE staff
ADD CONSTRAINT chk_staff_active
CHECK (active IN (0, 1));

-- Payment table constraints
ALTER TABLE payment
ADD CONSTRAINT chk_payment_amount
CHECK (amount >= 0);

-- Rental table constraints
ALTER TABLE rental
ADD CONSTRAINT chk_valid_dates
CHECK (rental_date < return_date);