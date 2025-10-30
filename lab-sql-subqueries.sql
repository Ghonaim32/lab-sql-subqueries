USE sakila;
SELECT * FROM customer;
SELECT * FROM payment;
SELECT * FROM rental;
SELECT * FROM inventory;

-- Write SQL queries to perform the following tasks using the Sakila database:

-- Determine the number of copies of the film  that exist in the inventory system.
SELECT title, available_inventory
FROM (SELECT film_id, COUNT(*) AS available_inventory
		FROM inventory
		GROUP BY film_id) AS t
JOIN film f
ON f.film_id = t.film_id
WHERE title = "Hunchback Impossible";

-- List all films whose length is longer than the average length of all the films in the Sakila database.
SELECT *
FROM film
WHERE length > (SELECT AVG(length) FROM film);

-- Use a subquery to display all actors who appear in the film "Alone Trip".
SELECT * 
	FROM actor
    WHERE actor_id IN (SELECT actor_id
						FROM film_actor
						WHERE film_id = (SELECT film_id
						FROM film
						WHERE title = "Alone Trip"));
-- Bonus:

-- Sales have been lagging among young families, and you want to target family movies for a promotion. Identify all movies categorized as family films.
SELECT *
FROM film
WHERE film_id IN (SELECT film_id
					FROM film_category
					WHERE category_id = (SELECT category_id
					FROM category
					WHERE name = "Family"));

-- Retrieve the name and email of customers from Canada using both subqueries and joins. To use joins, you will need to identify the relevant tables and their primary and foreign keys.
SELECT *
FROM customer
WHERE address_id IN (SELECT address_id
	FROM address
			WHERE city_id IN (SELECT city_id
							FROM country co
							JOIN city ci
							ON co.country_id = ci.country_id
							WHERE country = "Canada"));


-- Determine which films were starred by the most prolific actor in the Sakila database. A prolific actor is defined as the actor who has acted in the most number of films. First, you will need to find the most prolific actor and then use that actor_id to find the different films that he or she starred in.
SELECT *
FROM film
WHERE film_id IN (
    SELECT film_id
    FROM film_actor
    WHERE actor_id = (
        SELECT actor_id FROM (
            SELECT actor_id
            FROM film_actor
            GROUP BY actor_id
            ORDER BY COUNT(*) DESC
            LIMIT 1) AS top_actor));

-- Find the films rented by the most profitable customer in the Sakila database. You can use the customer and payment tables to find the most profitable customer, i.e., the customer who has made the largest sum of payments.
SELECT *
FROM film f
JOIN inventory inv
ON inv.film_id = f.film_id
JOIN rental r
ON r.inventory_id = inv.inventory_id
WHERE rental_id IN (SELECT rental_id
	FROM payment
	WHERE customer_id IN 
	(SELECT customer_id FROM 
		(SELECT customer_id, SUM(amount) AS total_paid
		FROM payment
		GROUP BY customer_id
		ORDER BY total_paid DESC
		LIMIT 1) AS top_customer));

-- Retrieve the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent by each client. You can use subqueries to accomplish this.
SELECT customer_id, SUM(amount) AS total_amount_spent
FROM payment
GROUP BY customer_id
HAVING total_amount_spent >=
			(SELECT AVG(total_amount_spent) 
			FROM (SELECT customer_id, SUM(amount) AS total_amount_spent
			FROM payment
			GROUP BY customer_id) AS total_payment);