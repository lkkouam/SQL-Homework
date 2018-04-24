use sakila;

-- 1a Display the first and lastname of all the actors
select first_name, last_name from actor;

-- 1b Display the first and lastname of all the actors in upper case letters in a single column
select CONCAT(UPPER(a.first_name), ' ', UPPER(a.last_name)) as ACTOR_NAME
from actor a;

-- 2a Find the ID number, firstname, last name of the actor whose First name is "Joe"
select actor_id, first_name, last_name
from actor 
where first_name = 'Joe';

-- 2b. Find all actors whose last name contain the letters GEN:
select actor_id, first_name, last_name
from actor 
where last_name like '%GEN%';

-- 2c. Find all actors whose last names contain the letters LI,order the rows by last name and first name:
select actor_id, first_name, last_name
from actor 
where last_name like '%LI%'
order by last_name, first_name;

-- 2d Display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
select country_id, country 
from country 
where country in ('Afghanistan', 'Bangladesh', 'China');

-- 3a Add a middle_name column to the table actor. 
-- Position it between first_name and last_name. Hint: you will need to specify the data type.
ALTER TABLE actor
ADD middle_name VARCHAR(50) after first_name;

-- 3b Change the data type of the 'middle_name' column
ALTER TABLE actor
MODIFY COLUMN middle_name blob;

-- 3c the column 'middle_name' column
ALTER TABLE actor
DROP COLUMN middle_name;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(*) AS nb_actors
FROM actor
GROUP BY last_name;

-- 4b List last names of actors and the number of actors who have that last name, 
-- but only for names that are shared by at least two actors
SELECT last_name, COUNT(*) AS nb_actors
FROM actor
GROUP BY last_name
HAVING nb_actors > 1;

-- 4c
UPDATE actor
   SET first_name = 'HARPO' 
 WHERE (first_name = 'GROUCHO' AND last_name = 'WILLIAMS');
 
-- 4d
 UPDATE actor
   SET first_name = 'MUCHO GROUCHO' 
 WHERE (first_name = 'HARPO' AND last_name = 'WILLIAMS');
 
-- 5a Locate the schema of the address table
 DESCRIBE address;
 
 CREATE TABLE address (
    address_id smallint(5) AUTO_INCREMENT NOT NULL,
    address varchar(50) NOT NULL,
    address2 varchar(50),
    district varchar(20) NOT NULL,
    city_id smallint(5) NOT NULL,
    postal_code varchar(10),
    phone varchar(20) NOT NULL,
    location geometry NOT NULL ,
    last_update timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (address_id),
    FOREIGN KEY(city_id) REFERENCES city(city_id)
);

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address
 select s.first_name, s.last_name, ad.address, ad.address, ad.district, ad.postal_code
 from staff s
 left join address ad on s.address_id = ad.address_id;
 
 
-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005.
 select s.last_name, p.staff_id, sum(p.amount) as total_amount
 from payment p
 join staff s on s.staff_id = p.staff_id
 where year(payment_date) = 2005 and month(payment_date) = 08
 group by s.staff_id;
 
-- 6c List each film and the number of actors who are listed for that film. Use tables film_actor and film. 
select f.film_id, f.title, count(a.actor_id) as num_of_actors
from film f 
join film_actor a
where f.film_id = a.film_id
group by f.title;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
select f.film_id, f.title, count(i.film_id) as nb_of_copy
from inventory i
join film f on i.film_id = f.film_id
where f.title = 'Hunchback Impossible';
-- 6e. Using the tables payment and customer and the JOIN command, 
-- list the total paid by each customer. List the customers alphabetically by last name:

select p.customer_id, c.last_name, c.first_name, sum(p.amount) as total_payment
from payment p
right join customer c on p.customer_id = c.customer_id
group by c.last_name
order by c.last_name;


-- 7a Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
select title
from film
where title like 'K%' or title like 'Q%' 
and language_id in
(select language_id from language where name = 'English');

-- 7b Use subqueries to display all actors who appear in the film Alone Trip.
select first_name, last_name 
from actor
where actor_id in
(select actor_id
from film_actor where film_id in 
(select film_id from film where title = 'Alone Trip'));

-- 7c.  Names and email addresses of all Canadian customers. 
SELECT first_name, last_name, email
	FROM customer
	WHERE address_id IN 
		(SELECT address_id
		FROM address WHERE city_id IN 
			(SELECT city_id FROM city WHERE country_id IN 
					(SELECT country_id FROM country WHERE country = 'Canada')));


-- 7d Identify all movies categorized as family films.
SELECT title
	FROM film
	WHERE film_id IN
		(SELECT film_id 
			FROM film_category
			WHERE category_id IN (SELECT category_id FROM category WHERE name = 'Family'));


-- 7e. Display the most frequently rented movies in descending order.
SELECT f.title, COUNT(i.inventory_id) AS FreqRent
    FROM film AS f 
    JOIN inventory as i ON i.film_id = f.film_id
    JOIN rental AS r ON r.inventory_id = i.inventory_id
GROUP BY f.title
ORDER BY FreqRent DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT s.store_id, SUM(p.amount) as revenue
	FROM store s
    JOIN inventory AS i ON s.store_id = i.store_id
    JOIN rental AS r ON i.inventory_id = r.inventory_id
    JOIN payment AS p ON r.rental_id = p.rental_id
GROUP BY s.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.

SELECT s.store_id, c.city, co.country
	FROM store s
    JOIN address AS a ON s.address_id = a.address_id
	JOIN city AS c ON c.city_id = a.city_id
    JOIN country AS co ON co.country_id = c.country_id;

-- 7h. List the top five genres in gross revenue in descending order
SELECT c.name, SUM(p.amount) AS revenue
	FROM category c
    JOIN film_category AS fc ON c.category_id = fc.category_id
    JOIN inventory AS i ON fc.film_id = i.film_id
    JOIN rental AS r ON r.inventory_id = i.inventory_id
    JOIN payment AS p ON p.rental_id = r.rental_id
GROUP BY c.name
ORDER BY revenue DESC
LIMIT 5;

-- 8a Create a view of the Top five genres by gross revenue.
CREATE VIEW TopFiveGenresGrossrevenue AS
SELECT c.name, SUM(p.amount) AS revenue
	FROM category c
    JOIN film_category AS fc ON c.category_id = fc.category_id
    JOIN inventory AS i ON fc.film_id = i.film_id
    JOIN rental AS r ON r.inventory_id = i.inventory_id
    JOIN payment AS p ON p.rental_id = r.rental_id
GROUP BY c.name
ORDER BY revenue DESC
LIMIT 5;

-- 8b Display the view of the Top five genres by gross revenue.
SELECT * FROM TopFiveGenresGrossrevenue;

-- 8c Delete the view  of the Top five genres by gross revenue.
DROP VIEW TopFiveGenresGrossrevenue;