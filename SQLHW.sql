
USE sakila



--1a.  Display the first and last names of all actors from the table actor.
SELECT  first_name, last_name FROM actor

--1.b Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name
SELECT  concat(first_name,'  ' ,last_name)  AS 'Actor Name' FROM actor

--2.a You need to find the ID number, first name, and last name of an actor,  of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name  FROM actor WHERE first_name = 'Joe'

--2b. Find all actors whose last name contain the letters GEN:
SELECT * FROM actor WHERE last_name  LIKE  '%GEN%'


--2c. Find all actors whose last names contain the letters LI.  This time, order the rows by last name and first name, in that order:
SELECT * FROM actor WHERE last_name LIKE '%LI%' ORDER BY last_name AND first_name

--2d. Using IN, display the country_id and country columns of the following countries:  Afghanistan, Bangladesh, and China:
SELECT country_id, country FROM country WHERE country IN ('Afghanistan', 'Bangladesh', 'China')


--3a. Add a middle_name column to the table actor. 
--Position it between first_name and last_name. Hint: you will need to specify the data type.
set innodb_lock_wait_timeout=100
show variables like 'innodb_lock_wait_timeout';
show full processlist;
set innodb_lock_wait_timeout=100


ALTER TABLE actor ADD COLUMN middle_name VARCHAR(20) NOT NULL AFTER first_name;

Select * FROM actor


ALTER TABLE actor MODIFY COLUMN middle_name BLOB;
COMMIT; 

ALTER TABLE actor DROP COLUMN middle_name;
COMMIT; 

SELECT last_name FROM actor

--4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(*) AS 'number_of_actors' FROM actor GROUP BY last_name 

---4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, COUNT(*) AS 'number_of_actors' FROM actor GROUP BY last_name HAVING number_of_actors >= 2

--4c. Oh, no! The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS, the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.

Update actor set first_name = 'HARPO' WHERE first_name = 'GROUCHO' AND last_name = 'WILLIAMS'

--4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO. Otherwise, change the first name to MUCHO GROUCHO, as that is exactly what the actor will be with the grievous error. 
--BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO MUCHO GROUCHO, HOWEVER! 
--(Hint: update the record using a unique identifier.)


SELECT * FROM actor GROUP BY first_name, last_name HAVING first_name = 'GROUCHO'

Update actor set first_name = 'GROUCHO' WHERE first_name = 'HARPO' AND actor_id = 172 
---then first_name = 'MUCHO GROUCHO' WHERE first_name = 'GROUCHO'


-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it? Hint: https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html

DESCRIBE sakila.address;

-- 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff 
--member. Use the tables `staff` and `address`:Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT first_name AS 'FIRST NAMES', last_name AS 'LAST NAMES', address AS 'ADDRESSES' FROM staff S 
JOIN address A ON S.address_id = A.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT staff.first_name, staff.last_name, payment.staff_id AS 'MEMBER ID', SUM(payment.amount) AS 'TOTAL AMOUNT' FROM staff INNER JOIN payment ON
staff.staff_id = payment.staff_id AND payment_date LIKE '2005-08%' GROUP BY staff.staff_id ; 


-- 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
SELECT F.title AS 'FILM', COUNT(A.actor_id) AS 'NUMBER OF ACTORS'
FROM film_actor A 
INNER JOIN film F ON A.film_id= F.film_id
GROUP BY F.title;

-- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
--SELECT * FROM inventory
SELECT title, (SELECT COUNT(*) FROM inventory I
WHERE F.film_id = I.film_id) AS 'Number of Copies'
FROM film F
WHERE title = "Hunchback Impossible";

-- 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:

SELECT C.first_name, C.last_name, sum(P.amount) AS 'TOTAL PAID'
FROM customer C JOIN payment P 
ON C.customer_id= P.customer_id GROUP BY C.last_name ASC ;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. 
--Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English. 

SELECT title AS 'TITLES OF MOVIES' FROM film WHERE title 
LIKE 'K%' OR title LIKE 'Q%'
AND title IN ( SELECT title 
FROM film  WHERE language_id = 1 );

-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.

SELECT first_name, last_name FROM actor
WHERE actor_id IN (Select actor_id
FROM film_actor
WHERE film_id IN (SELECT film_id
FROM film
WHERE title = 'Alone Trip'));

-- 7c. You want to run an email marketing campaign in Canada, for which you  will need the names and email addresses of all Canadian customers.  Use joins to retrieve this information.

SELECT CONCAT(C.first_name,' ', C.last_name) AS 'NAMES', C.email AS EMAIL
FROM customer C 
JOIN address A ON (C.address_id = A.address_id)
JOIN city c ON (c.city_id = A.city_id)
JOIN country ON (country.country_id = c.country_id)
WHERE country.country= 'Canada';

-- 7d.Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.

SELECT * FROM film 
WHERE film_id 
IN (SELECT film_id FROM film_category
WHERE category_id 
IN (SELECT category_id FROM category
WHERE name = "Family"
));


-- 7e. Display the most frequently rented movies in descending order.

SELECT F.title AS 'Rented Movies', COUNT(rental_id) AS 'FREQUENCY'
FROM rental R 
JOIN inventory I ON (R.inventory_id = I.inventory_id)
JOIN film F ON (I.film_id = F.film_id)
GROUP BY F.title
ORDER BY FREQUENCY DESC;

-- 7f.  Write a query to display how much business, in dollars, each store brought in.

SELECT S.store_id AS 'STORE ID', SUM(amount) AS 'REVENUE'
FROM payment P JOIN rental R
ON (P.rental_id = R.rental_id)
JOIN inventory I
ON (I.inventory_id = R.inventory_id)
JOIN store S
ON (S.store_id = I.store_id)
GROUP BY S.store_id; 

-- 7g. Write a query to display for each store its store ID, city, and country.

SELECT S.store_id, c.city, C.country 
FROM store S
JOIN address A ON (S.address_id = A.address_id)
JOIN city c ON (c.city_id = A.city_id)
JOIN country C ON (C.country_id = c.country_id)


--  7h.List the top five genres in gross revenue in descending order. 
--(Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)

SELECT C.name AS 'GENRES', SUM(P.amount) AS 'GROSS REVENUE' 
FROM category C
JOIN film_category F ON (C.category_id = F.category_id)
JOIN inventory I ON (F.film_id = I.film_id)
JOIN rental R ON (I.inventory_id = R.inventory_id)
JOIN payment P ON (R.rental_id = P.rental_id)
GROUP BY C.name ORDER BY 'GROSS REVENUE' LIMIT 5

--  8a.  In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue.
--- Use the solution from the problem above to create a view. 
--If you haven't solved 7h, you can substitute another query to create a view.

CREATE VIEW top_five_genres AS
SELECT C.name AS 'GENRES', SUM(P.amount) AS 'GROSS REVENUE' 
FROM category C
JOIN film_category F ON (C.category_id = F.category_id)
JOIN inventory I ON (F.film_id = I.film_id)
JOIN rental R ON (I.inventory_id = R.inventory_id)
JOIN payment P ON (R.rental_id = P.rental_id)
GROUP BY C.name ORDER BY 'GROSS REVENUE' LIMIT 5;

COMMIT;

--  8b.  How would you display the view that you created in 8a?

SELECT * FROM top_five_genres

--  8c. You find that you no longer need the view top_five_genres. Write a query to delete it.

DROP VIEW top_five_genres;

COMMIT;