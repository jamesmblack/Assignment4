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

-- Problem 1: What is the average length of films in each category? List the results in alphabetic order of categories.
SELECT category.name AS category_name,  -- Selects category name and then finds the average length of the films.
       ROUND(AVG(film.length), 2) AS avg_film_length
FROM film_category
JOIN category ON film_category.category_id = category.category_id -- Joins on category and film id.
JOIN film ON film_category.film_id = film.film_id
GROUP BY category.name -- grouped by category
ORDER BY category.name ASC; -- Ascending order for alphabetization. 

-- Problem 2: Which categories have the longest and shortest average film lengths?
-- First create a average length table with a WITH keyword, since we won't use it again.
WITH avg_length AS (
    SELECT category.name AS category_name,  -- Selects category and averages film length.
           ROUND(AVG(film.length), 2) AS avg_film_length
    FROM film_category
    JOIN category ON film_category.category_id = category.category_id -- Joins on category_id and film_id
    JOIN film ON film_category.film_id = film.film_id
    GROUP BY category.name
)
-- Select the categories with the longest and shortest average lengths from the table avg_length
SELECT category_name, avg_film_length
FROM avg_length
WHERE avg_film_length = (SELECT MAX(avg_film_length) FROM avg_length)
   OR avg_film_length = (SELECT MIN(avg_film_length) FROM avg_length);
   
-- Problem 3: Which customers have rented action but not comedy or classic movies?
-- SATA Customers redux, 

WITH action_customers AS (
    -- Find customers who rented Action movies
    SELECT DISTINCT customer.customer_id, customer.first_name, customer.last_name
    FROM customer
    JOIN rental ON customer.customer_id = rental.customer_id -- Joins 
    JOIN inventory ON rental.inventory_id = inventory.inventory_id
    JOIN film ON inventory.film_id = film.film_id
    JOIN film_category ON film.film_id = film_category.film_id
    JOIN category ON film_category.category_id = category.category_id
    WHERE category.name = 'Action' -- Conditional statement to find action.
),

excluded_customers AS (
    -- Find customers who rented Comedy or Classics
    SELECT DISTINCT customer.customer_id
    FROM customer
    JOIN rental ON customer.customer_id = rental.customer_id -- Joins
    JOIN inventory ON rental.inventory_id = inventory.inventory_id
    JOIN film ON inventory.film_id = film.film_id
    JOIN film_category ON film.film_id = film_category.film_id
    JOIN category ON film_category.category_id = category.category_id
    WHERE category.name IN ('Comedy', 'Classics') -- Comedy or classic conditional.
)

-- Select customers who rented Action movies but not Comedy or Classics
SELECT action_customers.customer_id, action_customers.first_name, action_customers.last_name
FROM action_customers
LEFT JOIN excluded_customers ON action_customers.customer_id = excluded_customers.customer_id -- Left Join to keep null values for excluded customers.
WHERE excluded_customers.customer_id IS NULL;

-- Problem 4: Which actor has appeared in the most English-language movies?
-- Find first the counts for who has appeared in the most movies grouped by language, then row number 1,  then select actor.
SELECT actor.actor_id, actor.first_name, actor.last_name, COUNT(film.film_id) AS movie_count
FROM actor
JOIN film_actor ON actor.actor_id = film_actor.actor_id -- Joins
JOIN film ON film_actor.film_id = film.film_id
JOIN language ON film.language_id = language.language_id
WHERE language.name = 'English'
GROUP BY actor.actor_id, actor.first_name, actor.last_name
ORDER BY movie_count DESC;
-- Problem 5: How many distinct movies were rented for exactly 10 days from the store where Mike works?
-- Find distinct movies and subtract the dates and find  

-- Problem 6: Alphabetically list actors who appeared in the movie with the largest cast of actors.
-- -- First find the actor counts and limit it to 1 to have the one set of actors from the movie.
WITH movie_actor_counts AS (
    SELECT film.film_id, COUNT(film_actor.actor_id) AS actor_count
    FROM film
    JOIN film_actor ON film.film_id = film_actor.film_id
    GROUP BY film.film_id -- Grouped and ordered to put the films in descending order, then limit shows only the number one film in the list.
    ORDER BY actor_count DESC
    LIMIT 1
)

-- Select actor names and display them in alphabetical order.
SELECT actor.first_name, actor.last_name
FROM actor
JOIN film_actor ON actor.actor_id = film_actor.actor_id -- Joins
JOIN movie_actor_counts ON film_actor.film_id = movie_actor_counts.film_id
ORDER BY actor.last_name, actor.first_name; -- Order by actors' names. Alphabetically focuses on last name first