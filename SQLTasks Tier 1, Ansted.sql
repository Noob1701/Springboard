/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 1 of the case study, which means that there'll be more guidance for you about how to 
setup your local SQLite connection in PART 2 of the case study. 

The questions in the case study are exactly the same as with Tier 2. 

PART 1: PHPMyAdmin
You will complete questions 1-9 below in the PHPMyAdmin interface. 
Log in by pasting the following URL into your browser, and
using the following Username and Password:

URL: https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this case study, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */


/* QUESTIONS 
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */
SELECT membercost, name
FROM Facilities
WHERE membercost >0;

/* Q2: How many facilities do not charge a fee to members? */
SELECT COUNT(membercost)
FROM Facilities
WHERE membercost = 0;

/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT facid, name, membercost, monthlymaintenance
FROM Facilities
WHERE membercost > 0
	AND membercost < (monthlymaintenance * .2);
/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */
SELECT *
FROM Facilities
WHERE facid <> 0 
	AND facid <> 2
    AND facid <> 3
    AND facid <> 4
    AND facid <> 6
    AND facid <> 7
    AND facid <> 8


/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */
SELECT name, monthlymaintenance, 
    (monthlymaintenance <100) AS cheap, 
    (monthlymaintenance >100) AS expensive
FROM Facilities;

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */
SELECT firstname, surname, joindate
FROM Members 
WHERE joindate = (SELECT MAX(joindate) FROM Members);

/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */
SELECT DISTINCT b.memid, b.facid, f.name, CONCAT(m.surname, ', ', m.firstname) AS Member_Name
FROM Bookings AS b
INNER JOIN Facilities AS f
	USING(facid)
INNER JOIN Members AS m
	USING (memid)
WHERE f.name LIKE 'Tennis%'
	AND memid <> 0
ORDER BY Member_Name

/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */
SELECT f.name, 
	CONCAT(m.surname, ', ', m.firstname) AS Member_Name, 
    m.memid,
	f.guestcost, 
	f.membercost, 
    f.facid,
    b.facid, 
    b.memid, 
    b.slots,
    b.starttime,
    IF (b.memid = 0, b.slots*f.guestcost, b.slots*f.membercost) AS Cost
FROM Facilities AS f
INNER JOIN Bookings AS b
	USING (facid)
INNER JOIN Members AS m
	USING (memid)
WHERE IF(b.memid = 0, b.slots*f.guestcost, b.slots*f.membercost) >30
	AND starttime LIKE '2012-09-14%'
ORDER BY Cost DESC

/* Q9: This time, produce the same result as in Q8, but using a subquery. */
SELECT *
FROM
(SELECT f.name, 
	CONCAT(m.surname, ', ', m.firstname) AS Member_Name, 
 	IF (b.memid = 0, b.slots*f.guestcost, b.slots*f.membercost) AS Cost,
    b.memid,
    b.starttime    
    FROM Bookings AS b
    INNER JOIN Facilities AS f 
    USING (facid)
    INNER JOIN Members AS m 
    USING (memid)
    ) AS Cost
WHERE Cost >30
	AND starttime LIKE '2012-09-14%'
ORDER BY Cost DESC;

/* PART 2: SQLite
/* We now want you to jump over to a local instance of the database on your machine. 

Copy and paste the LocalSQLConnection.py script into an empty Jupyter notebook, and run it. 

Make sure that the SQLFiles folder containing thes files is in your working directory, and
that you haven't changed the name of the .db file from 'sqlite\db\pythonsqlite'.

You should see the output from the initial query 'SELECT * FROM FACILITIES'.

Complete the remaining tasks in the Jupyter interface. If you struggle, feel free to go back
to the PHPMyAdmin interface as and when you need to. 

You'll need to paste your query into value of the 'query1' variable and run the code block again to get an output.
 
QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */
SELECT DISTINCT f.name, 
	SUM(IF (b.memid = 0, b.slots*f.guestcost, b.slots*f.membercost)) AS Tot_Rev
FROM Facilities AS f
INNER JOIN Bookings AS b
USING (facid)
GROUP BY f.name 
HAVING Tot_Rev <1000
ORDER BY Tot_Rev
/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */
SELECT m1.surname,
m1.firstname,
m1.recommendedby,
m.surname,
m.firstname
FROM Members AS m1
INNER JOIN Members AS m
   ON m1.recommendedby = m.memid
ORDER BY m.surname, m.firstname

/* Q12: Find the facilities with their usage by member, but not guests */
SELECT 
m.firstname,
m.surname,
b.slots,
b.starttime,
f.name
FROM Bookings AS b
INNER JOIN Facilities AS f
USING (facid)
INNER JOIN Members AS m
USING (memid)
WHERE memid <>0

/* Q13: Find the facilities usage by month, but not guests */
SELECT 
DATE_FORMAT(starttime, '%Y-%m') AS year_and_month,
SUM(slots * .5) AS Mem_Fac_Use_Hours,
b.facid,
f.name
FROM Bookings As b
INNER JOIN Facilities As f
USING (facid)
WHERE memid <>0
GROUP BY year_and_month, b.facid, f.name
