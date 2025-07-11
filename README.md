# SQL_projects_intermidiate
# Intermidiate Sql Project :  Library Management System, 

## Library Management System SQL Project 3

**Project Title**: Library Management System 
**Level**: Intermidiate
**Database**: `manually generated/Library_db`

This project demonstrates the implementation of a Library Management System using SQL. It includes creating and managing tables, performing CRUD operations, and executing advanced SQL queries. The goal is to showcase skills in database design, manipulation, and querying.

## Objectives

1. **Set up the Library Management System Database**: Create and populate the database with tables for branches, employees, members, books, issued status, and return status.
2. **CRUD Operations**: Perform Create, Read, Update, and Delete operations on the data.
3. **CTAS (Create Table As Select)**: Utilize CTAS to create new tables based on query results.
4. **Advanced SQL Queries**: Develop complex queries to analyze and retrieve specific data.

## Project Structure
### 1. Database Setup

- **Database Creation**: Created a database named `sql_p3`.
- **Table Creation**: Created tables for branches, employees, members, books, issued status, and return status. Each table includes relevant columns and relationships.

```sql
-- Create Table
DROP TABLE IF EXISTS branch;
CREATE TABLE branch
(
            branch_id VARCHAR(10) PRIMARY KEY,
            manager_id VARCHAR(10),
            branch_address VARCHAR(30),
            contact_no VARCHAR(15)
);

DROP TABLE IF EXISTS employees;
CREATE TABLE employees
(
            emp_id VARCHAR(10) PRIMARY KEY,
            emp_name VARCHAR(30),
            position VARCHAR(30),
            salary DECIMAL(10,2),
            branch_id VARCHAR(10),
            FOREIGN KEY (branch_id) REFERENCES  branch(branch_id)
);

DROP TABLE IF EXISTS members;
CREATE TABLE members
(
            member_id VARCHAR(10) PRIMARY KEY,
            member_name VARCHAR(30),
            member_address VARCHAR(30),
            reg_date DATE
);

DROP TABLE IF EXISTS books;
CREATE TABLE books
(
            isbn VARCHAR(50) PRIMARY KEY,
            book_title VARCHAR(80),
            category VARCHAR(30),
            rental_price DECIMAL(10,2),
            status VARCHAR(10),
            author VARCHAR(30),
            publisher VARCHAR(30)
);

DROP TABLE IF EXISTS issued_status;
CREATE TABLE issued_status
(
            issued_id VARCHAR(10) PRIMARY KEY,
            issued_member_id VARCHAR(30),
            issued_book_name VARCHAR(80),
            issued_date DATE,
            issued_book_isbn VARCHAR(50),
            issued_emp_id VARCHAR(10),
            FOREIGN KEY (issued_member_id) REFERENCES members(member_id),
            FOREIGN KEY (issued_emp_id) REFERENCES employees(emp_id),
            FOREIGN KEY (issued_book_isbn) REFERENCES books(isbn) 
);

DROP TABLE IF EXISTS return_status;
CREATE TABLE return_status
(
            return_id VARCHAR(10) PRIMARY KEY,
            issued_id VARCHAR(30),
            return_book_name VARCHAR(80),
            return_date DATE,
            return_book_isbn VARCHAR(50),
            FOREIGN KEY (return_book_isbn) REFERENCES books(isbn)
);
```

### You can get the VALUES in Final_Query(uploaded) you can refer from there 

ADD erp table


### 2. CRUD Operations (Basic)

Q1. Create a New Book Record "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"
```sql
INSERT INTO books (isbn, book_title, category, rental_price, status, author, publisher)
VALUES('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
```

Q2: Update an Existing Member's Address
```sql UPDATE members
SET member_address ='19 mumbai'
WHERE member_id = 'C101';
```

Q3: Delete a Record from the Issued Status Table
Objective: Delete the record with issued_id = 'IS104' from the issued_status table.
```sql
DELETE FROM issued_status
WHERE issued_id ='IS104';
```

Q 4: Retrieve All Books Issued by a Specific Employee
Objective: Select all books issued by the employee with emp_id = 'E101'.
```sql
SELECT * FROM issued_status
WHERE issued_emp_id='E101';
```

Q 5: List Members Who Have Issued More Than One Book
Objective: Use GROUP BY to find members who have issued more than one book.
```sql
SELECT
	issued_emp_id,
    COUNT(issued_id) AS Books_issued
FROM issued_status
GROUP BY 1;
```

Q6: Create Summary Tables**: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt
```sql
CREATE TABLE book_issued_cnt AS 
SELECT 
	b.isbn,
    b.book_title ,
    COUNT(ist.issued_id) as Isuued_count
FROM issued_status as ist
JOIN books as b
ON ist.issued_book_isbn = b.isbn
GROUP BY 1, 2;
SELECT * FROM book_issued_cnt;
```

8: Find Total Rental Income by Category:
```sql
SELECT 
	category,
    SUM(rental_price) AS sum_rental_price
FROM books
GROUP BY 1
ORDER BY 2;
```
Q.9 List Employees with Their Branch Manager's Name and their branch details
```sql
SELECT 
    e1.emp_id,
    e1.emp_name,
    e1.position,
    e1.salary,
    b.*,
    e2.emp_name as manager
FROM employees as e1
JOIN 
branch as b
ON e1.branch_id = b.branch_id    
JOIN
employees as e2
ON e2.emp_id = b.manager_id;
```

Q.10 Create a Table of Books with Rental Price Above a Certain Threshold
```sql
CREATE TABLE rental_books AS
SELECT * FROM books
WHERE rental_price >7.0;
```

Q.11 Retrieve the List of Books Not Yet Returned
```sql
SELECT * FROM issued_status as ist
LEFT JOIN
return_status as rs
ON rs.issued_id = ist.issued_id
WHERE rs.return_id IS NULL;
```

### Advanced SQL Operations
Q1. Identify Members with Overdue Books
Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's name, book title, issue date, and days overdue.
```sql
SELECT 
	m.member_name,
    bk.book_title,
    ist.issued_date,
    rs.return_date,
    (current_date - ist.issued_date)/10 as Overdues_day
FROM issued_status AS ist
JOIN members as m
ON m.member_id = ist.issued_member_id
JOIN books as bk
ON bk.isbn = ist.issued_book_isbn
LEFT JOIN return_status AS rs
ON rs.issued_id = ist.issued_id

WHERE rs.return_date IS NULL
	AND
      (current_date - ist.issued_date)/10 > 1030
ORDER BY 1;
```

Q2. Update Book Status on Return
Write a query to update the status of books in the books table to "available" when they are returned (based on entries in the return_status table).
```sql
DELIMITER $$

CREATE PROCEDURE add_return_records(
	IN p_return_id VARCHAR(10),
    IN p_issued_id VARCHAR(10),
    IN p_book_quality VARCHAR(10)
)
BEGIN 
	DECLARE v_isbn VARCHAR(50);
    DECLARE v_book_name VARCHAR(80);
    
	-- Insert return record
    INSERT INTO return_status(return_id, issued_id, return_date, book_quality)
    VALUES(p_return_id, p_issued_id, CURDATE(), p_book_quality);
    
    -- Fetch ISBN and book name from issued_status
    SELECT issued_book_isbn, issued_book_name
    INTO v_isbn, v_book_name
    FROM issued_status
    WHERE issued_id = p_issued_id
    LIMIT 1;
    
    -- Update book status to 'yes'
    UPDATE books
    SET status = 'Yes'
    WHERE isbn = v_isbn ;
    
    SELECT CONCAT('Thank you for returning the book :', v_book_name) AS message;
    
END $$

DELIMITER ;

-- CALL add_return_records('RS138', 'IS135', 'Good');
```

Q3. Branch Performance Report
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.
```sql
CREATE TABLE branch_reports
AS
SELECT 
    b.branch_id,
    b.manager_id,
    COUNT(ist.issued_id) as number_book_issued,
    COUNT(rs.return_id) as number_of_book_return,
    SUM(bk.rental_price) as total_revenue
FROM issued_status as ist
JOIN 
employees as e
ON e.emp_id = ist.issued_emp_id
JOIN
branch as b
ON e.branch_id = b.branch_id
LEFT JOIN
return_status as rs
ON rs.issued_id = ist.issued_id
JOIN 
books as bk
ON ist.issued_book_isbn = bk.isbn
GROUP BY 1, 2;

SELECT * FROM branch_reports;
```
 
Q.4 CTAS: Create a Table of Active Members**  
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.
```sql
CREATE TABLE active_members
AS
SELECT *
FROM members
WHERE member_id IN (
		SELECT 
			DISTINCT(issued_member_id)
		FROM issued_status
		WHERE issued_date >= current_date - INTERVAL 19 month
	  );
SELECT * FROM active_members;
```

Q.5 Find Employees with the Most Book Issues Processed**  
Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.
```sql
SELECT 
    e.emp_name,
    b.*,
    COUNT(ist.issued_id) as no_book_issued
FROM issued_status as ist
JOIN
employees as e
ON e.emp_id = ist.issued_emp_id
JOIN
branch as b
ON e.branch_id = b.branch_id
GROUP BY 1, 2
ORDER BY COUNT(ist.issued_id) DESC;
```

Q.6: Stored Procedure
```sql
Create a stored procedure to manage the status of books in a library system.
Description:
Write a stored procedure that updates the status of a book in the library based on its issuance. The procedure should function as follows:
The stored procedure should take the book_id as an input parameter.
The procedure should first check if the book is available (status = 'yes').
If the book is available, it should be issued, and the status in the books table should be updated to 'no'.
If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.*/
```
```sql
DELIMITER $$
CREATE PROCEDURE issue_book(
	IN p_issued_id VARCHAR(10),
    IN p_issued_member_id VARCHAR(30),
    IN p_issued_book_isbn VARCHAR(30),
	IN p_issued_emp_id VARCHAR(10)
)
BEGIN 
	DECLARE v_status VARCHAR(10);
    
    -- CHECK IF THE BOOK IS AVAILABL OR NOT 
    SELECT status
    INTO v_status FROM books
	WHERE isbn= p_issued_book_isbn
    limit 1;
   
	IF v_status = 'yes' THEN 
    INSERT INTO issued_status(issued_id, issued_member_id, issued_date, issued_book_isbn, isued_emp_id)
    VALUES (p_issued_id, p_issued_member_id, CURDATE(), p_issued_book_isbn, p_issued_emp_id);
 
		-- update book status to 'no'
		UPDATE books
        SET status ='no'
        WHERE isbn = p_issued_book_isbn;
        
        SELECT CONCAT ('Books records added successfully for book ISBN : ', p_issued_book_isbn) AS message;
	ELSE
		SELECT CONCAT('Sorry , yhe book you requested is unavailable. ISBN:', p_issued_book_isbn) AS message;

    END IF;
END$$

DELIMITER ;

-- CALL issue_book('IS155', 'C108', '978-0-553-29698-2', 'E104');
-- CALL issue_book('IS156', 'C108', '978-0-375-41398-8', 'E104');
```

## Reports

- **Database Schema**: Detailed table structures and relationships.
- **Data Analysis**: Insights into book categories, employee salaries, member registration trends, and issued books.
- **Summary Reports**: Aggregated data on high-demand books and employee performance.

## Conclusion

This project demonstrates the application of SQL skills in creating and managing a library management system. It includes database setup, data manipulation, and advanced querying, providing a solid foundation for data management and analysis.





## Author - Dhruv Devaliya-->Bit-Bard

This project is part of my portfolio, showcasing the SQL skills essential for data analyst roles. If you have any questions, feedback, or would like to collaborate, feel free to get in touch!
Thank you for your support, and I look forward to connecting with you!














