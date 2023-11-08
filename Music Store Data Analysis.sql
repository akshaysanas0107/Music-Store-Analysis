------------------------------------------------------
--     SQL PROJECT MUSIC STORE DATA ANALYSIS	    --
------------------------------------------------------

SELECT * FROM employee

SELECT * FROM customer

SELECT * FROM invoice

SELECT * FROM invoice_line

SELECT * FROM track

SELECT * FROM media_type

SELECT * FROM genre

SELECT * FROM playlist_track

SELECT * FROM playlist

SELECT * FROM album

SELECT * FROM artist

-----------------------------------------------
--             Question Set 1 - Easy         --
-----------------------------------------------

--1. Who is the senior most employee based on job title?

SELECT TOP 1 * 
FROM employee
ORDER BY levels DESC

--2. Which countries have the most Invoices?

SELECT BILLING_COUNTRY,COUNT(*) AS NO_OF_INVOICES
FROM invoice
GROUP BY BILLING_COUNTRY
ORDER BY NO_OF_INVOICES DESC

--3. What are top 3 values of total invoice?

SELECT TOP 3 invoice_id,total
FROM invoice
ORDER BY total DESC

--4. Which city has the best customers? We would like to throw a promotional Music 
--Festival in the city we made the most money. Write a query that returns one city that 
--has the highest sum of invoice totals. Return both the city name & sum of all invoice totals

SELECT TOP 1 billing_city,SUM(total) AS TOTAL_SALES
FROM invoice
GROUP BY billing_city
ORDER BY TOTAL_SALES DESC

--5. Who is the best customer? The customer who has spent the most money will be 
--declared the best customer. Write a query that returns the person who has spent the most money

SELECT TOP 1 i.customer_id,c.first_name,c.last_name,SUM(i.total) AS TOTAL_SPENT
FROM invoice i
JOIN customer c
ON i.customer_id = c.customer_id
GROUP BY i.customer_id,c.first_name,c.last_name
ORDER BY TOTAL_SPENT DESC


-----------------------------------------------
--             Question Set 2 - Moderate     --
-----------------------------------------------

--1. Write query to return the email, first name, last name, & Genre of all Rock Music 
--listeners. Return your list ordered alphabetically by email starting with A

SELECT DISTINCT c.email,c.first_name,c.last_name,g.name
FROM genre g
JOIN track t
ON g.genre_id = t.genre_id
JOIN invoice_line il
ON t.track_id = il.track_id
JOIN invoice i
ON il.invoice_id = i.invoice_id
JOIN customer c
ON i.customer_id = c.customer_id
WHERE g.name = 'Rock'
ORDER BY c.email

--2. Let's invite the artists who have written the most rock music in our dataset. Write a 
--query that returns the Artist name and total track count of the top 10 rock bands

SELECT TOP 10 a.artist_id,a.name,COUNT(*) AS TOTAL_TRACKS
FROM artist a
JOIN album al
ON A.artist_id = al.artist_id
JOIN track t
ON al.album_id = t.album_id
JOIN genre g
ON t.genre_id = g.genre_id
WHERE g.name LIKE 'Rock'
GROUP BY a.artist_id,a.name
ORDER BY TOTAL_TRACKS DESC

--3. Return all the track names that have a song length longer than the average song length. 
--Return the Name and Milliseconds for each track. Order by the song length with the 
--longest songs listed first

SELECT name,milliseconds
FROM track
WHERE milliseconds > (SELECT AVG(milliseconds) FROM track)
ORDER BY milliseconds DESC


-----------------------------------------------
--             Question Set 3 - Advance      --
-----------------------------------------------

--1. Find how much amount spent by each customer on artists? Write a query to return
--customer name, artist name and total spent

WITH BEST_SELLING_ARTIST
AS (SELECT TOP 1 art.artist_id,art.name,SUM(il.quantity * il.unit_price) TOTAL_SPENT
	FROM invoice i
	JOIN invoice_line il
	ON i.invoice_id = il.invoice_id
	JOIN track t
	ON il.track_id = t.track_id
	JOIN album a
	ON a.album_id = t.album_id
	JOIN artist art
	ON a.artist_id = art.artist_id
	GROUP BY art.artist_id,art.name
	ORDER BY TOTAL_SPENT DESC
	)


SELECT c.first_name,c.last_name,best_art.name,SUM(il.quantity * il.unit_price) TOTAL_SPENT
FROM customer c
JOIN invoice i
ON c.customer_id = i.customer_id
JOIN invoice_line il
ON i.invoice_id = il.invoice_id
JOIN track t
ON il.track_id = t.track_id
JOIN album a
ON a.album_id = t.album_id
JOIN BEST_SELLING_ARTIST best_art
ON a.artist_id = best_art.artist_id
GROUP BY c.first_name,c.last_name,best_art.name
ORDER BY TOTAL_SPENT DESC

--2. We want to find out the most popular music Genre for each country. We determine the 
--most popular genre as the genre with the highest amount of purchases. Write a query 
--that returns each country along with the top Genre. For countries where the maximum 
--number of purchases is shared return all Genres

WITH  
POPULAR_MUSIC_BY_COUNTRY AS (SELECT COUNT(*) AS TOTAL_PURCHASE,c.country,g.name,g.genre_id
							FROM customer c
							JOIN invoice i
							ON c.customer_id = i.customer_id
							JOIN invoice_line il
							ON i.invoice_id = il.invoice_id
							JOIN track t
							ON t.track_id = il.track_id
							JOIN genre g
							ON g.genre_id = t.genre_id
							GROUP BY c.country,g.name,g.genre_id
							--ORDER BY c.country ASC,TOTAL_PURCHASE DESC
							),

MAX_PER_COUNTRY AS ( SELECT MAX(TOTAL_PURCHASE) AS MAX_PURCHASE,COUNTRY,name,genre_id
						FROM POPULAR_MUSIC_BY_COUNTRY
						GROUP BY COUNTRY,name,genre_id
					)

SELECT *
FROM MAX_PER_COUNTRY
ORDER BY country ASC,MAX_PURCHASE DESC



--3. Write a query that determines the customer that has spent the most on music for each country. 
--Write a query that returns the country along with the top customer and how much they spent. 
--For countries where the top amount spent is shared, provide all customers who spent this amount

WITH
CUSTOMER_WITH_COUNTRY AS (SELECT c.first_name,c.last_name,i.billing_country,SUM(i.total) AS TOTAL_SPENT
							FROM customer c
							JOIN invoice i
							ON c.customer_id = i.customer_id
							GROUP BY c.first_name,c.last_name,i.billing_country
							
						),
MAX_SPENT_CUSTOMER AS (	SELECT billing_country,MAX(TOTAL_SPENT) MAX_SPENT
						FROM CUSTOMER_WITH_COUNTRY
						GROUP BY billing_country
						)

SELECT c.billing_country,c.TOTAL_SPENT,c.first_name,c.last_name
FROM CUSTOMER_WITH_COUNTRY c
JOIN MAX_SPENT_CUSTOMER m
ON c.billing_country = m.billing_country
WHERE c.TOTAL_SPENT = m.MAX_SPENT
ORDER BY billing_country 