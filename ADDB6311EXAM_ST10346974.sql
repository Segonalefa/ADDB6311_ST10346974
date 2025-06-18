SET SERVEROUTPUT ON;

Create table EVENT
(
  EVENT_ID           number(5)        not null    primary key,
  EVENT_NAME         varchar2(100)    not null,
  EVENT_RATE        number(5)     not null
 );
 
Create table ARTIST
(
  ARTIST_ID            varchar2(5)    not null    primary key,
  ARTIST_NAME         varchar2(100)  not null,
  ARTIST_EMAIL        varchar2(100)  not null
  );
  
Create table BOOKINGS
(
  BOOKING_ID              number    not null    primary key,
  BOOKING_DATE            date           not null,
  EVENT_ID 		  number(5)	not null,
  ARTIST_ID             varchar2(5)        not null,
FOREIGN KEY (EVENT_ID) REFERENCES EVENT(EVENT_ID),
FOREIGN KEY (ARTIST_ID) REFERENCES ARTIST(ARTIST_ID)
); 


insert all
   into EVENT(EVENT_ID, EVENT_NAME, EVENT_RATE)
    values(1001, 'Open Air Comedy Festival', 300)
into EVENT(EVENT_ID, EVENT_NAME, EVENT_RATE)
    values(1002, 'Mountain Side Music Festival', 280)
into EVENT(EVENT_ID, EVENT_NAME, EVENT_RATE)
    values(1003, 'Beach Music Festival', 195)
  
Select * from dual;
Commit;

insert all
   into ARTIST(ARTIST_ID, ARTIST_NAME, ARTIST_EMAIL)
    values('A_101', 'Max Trillion', 'maxt@isat.com')
 into ARTIST(ARTIST_ID, ARTIST_NAME, ARTIST_EMAIL)
    values('A_102', 'Music Mayhem', 'mayhem@ymail.com')
into ARTIST(ARTIST_ID, ARTIST_NAME, ARTIST_EMAIL)
    values('A_103', 'LOL Man', 'lol@isat.com')
       Select * from dual;
  Commit;
  
insert all
   into BOOKINGS(BOOKING_ID, BOOKING_DATE, EVENT_ID, ARTIST_ID)
    values(1, '15 July 2024', 1002, 'A_101')
 into BOOKINGS(BOOKING_ID, BOOKING_DATE, EVENT_ID, ARTIST_ID)
    values(2, '15 July 2024', 1002, 'A_102')
 into BOOKINGS(BOOKING_ID, BOOKING_DATE, EVENT_ID, ARTIST_ID)
    values(3, '27 August 2024', 1001, 'A_103')
 into BOOKINGS(BOOKING_ID, BOOKING_DATE, EVENT_ID, ARTIST_ID)
    values(4, '30 August 2024', 1003, 'A_101')
into BOOKINGS(BOOKING_ID, BOOKING_DATE, EVENT_ID, ARTIST_ID)
    values(5, '30 August 2024', 1003, 'A_102')

      Select * from dual;
Commit;


--QUESTION 1
SELECT 
    b.BOOKING_ID,
    b.BOOKING_DATE,
    e.EVENT_NAME,
    e.EVENT_RATE,
    a.ARTIST_NAME,
    a.ARTIST_EMAIL
FROM 
    BOOKINGS b
JOIN 
    EVENT e ON b.EVENT_ID = e.EVENT_ID
JOIN 
    ARTIST a ON b.ARTIST_ID = a.ARTIST_ID
ORDER BY 
    b.BOOKING_ID;


--QUESTION 2
SELECT 
    a.ARTIST_ID,
    a.ARTIST_NAME,
    COUNT(b.BOOKING_ID) AS PERFORMANCE_COUNT
FROM 
    ARTIST a
LEFT JOIN 
    BOOKINGS b ON a.ARTIST_ID = b.ARTIST_ID
GROUP BY 
    a.ARTIST_ID, a.ARTIST_NAME
HAVING 
    COUNT(b.BOOKING_ID) = (
        SELECT MIN(performance_count)
        FROM (
            SELECT COUNT(BOOKING_ID) AS performance_count
            FROM BOOKINGS
            GROUP BY ARTIST_ID
        )
    )
    OR COUNT(b.BOOKING_ID) = 0
ORDER BY 
    PERFORMANCE_COUNT;


--QUESTION 3
SELECT 
    a.ARTIST_NAME,
    SUM(e.EVENT_RATE) AS TOTAL_REVENUE
FROM 
    ARTIST a
JOIN 
    BOOKINGS b ON a.ARTIST_ID = b.ARTIST_ID
JOIN 
    EVENT e ON b.EVENT_ID = e.EVENT_ID
GROUP BY 
    a.ARTIST_NAME
ORDER BY 
    TOTAL_REVENUE DESC;


--QUESTION 4
DECLARE
    CURSOR artist_booking_cursor IS
        SELECT a.ARTIST_NAME, b.BOOKING_DATE
        FROM ARTIST a
        JOIN BOOKINGS b ON a.ARTIST_ID = b.ARTIST_ID
        WHERE b.EVENT_ID = 1001;
    
    v_artist_name ARTIST.ARTIST_NAME%TYPE;
    v_booking_date BOOKINGS.BOOKING_DATE%TYPE;
BEGIN
    DBMS_OUTPUT.PUT_LINE('---------------------------------');
    DBMS_OUTPUT.PUT_LINE('---------------------------------');
    DBMS_OUTPUT.PUT_LINE('Artists booked for Event ID 1001:');
    DBMS_OUTPUT.PUT_LINE('---------------------------------');
    DBMS_OUTPUT.PUT_LINE('ARTIST NAME          BOOKING DATE');
    DBMS_OUTPUT.PUT_LINE('---------------------------------');
    
    OPEN artist_booking_cursor;
    LOOP
        FETCH artist_booking_cursor INTO v_artist_name, v_booking_date;
        EXIT WHEN artist_booking_cursor%NOTFOUND;
        
        DBMS_OUTPUT.PUT_LINE(
            RPAD(v_artist_name, 20) || '  ' || 
            TO_CHAR(v_booking_date, 'DD Month YYYY', 'NLS_DATE_LANGUAGE = ENGLISH')
        );
    END LOOP;
    
    IF artist_booking_cursor%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('No artists found for Event ID 1001');
    END IF;
    
    CLOSE artist_booking_cursor;
END;
/


--QUESTION 5
DECLARE
    CURSOR event_cursor IS
        SELECT EVENT_NAME, EVENT_RATE
        FROM EVENT
        ORDER BY EVENT_ID;
    
    v_event_name EVENT.EVENT_NAME%TYPE;
    v_original_rate EVENT.EVENT_RATE%TYPE;
    v_discounted_rate NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('-------------------------------');
    DBMS_OUTPUT.PUT_LINE('EVENT NAME                PRICE');
    DBMS_OUTPUT.PUT_LINE('-------------------------------');
    
    OPEN event_cursor;
    LOOP
        FETCH event_cursor INTO v_event_name, v_original_rate;
        EXIT WHEN event_cursor%NOTFOUND;
        
        IF v_original_rate > 250 THEN
            v_discounted_rate := v_original_rate * 0.9; -- Apply 10% discount
            DBMS_OUTPUT.PUT_LINE(
                RPAD(v_event_name, 22) || '  R' || 
                RPAD(TO_CHAR(v_original_rate, '999'), 6) || 
                ' (Discounted to R' || v_discounted_rate || ')'
            );
        ELSE
            DBMS_OUTPUT.PUT_LINE(
                RPAD(v_event_name, 22) || '  R' || 
                v_original_rate || '    (No discount)'
            );
        END IF;
    END LOOP;
    
    CLOSE event_cursor;
END;
/


--QUESTION 6
CREATE OR REPLACE VIEW Event_Schedules AS
SELECT 
    e.EVENT_NAME,
    b.BOOKING_DATE AS EVENT_DATE,
    e.EVENT_RATE
FROM 
    EVENT e
JOIN 
    BOOKINGS b ON e.EVENT_ID = b.EVENT_ID
WHERE 
    b.BOOKING_DATE BETWEEN TO_DATE('01-JUL-2024', 'DD-MON-YYYY') 
                        AND TO_DATE('28-AUG-2024', 'DD-MON-YYYY')
ORDER BY 
    b.BOOKING_DATE;
    
SELECT * FROM Event_Schedules;


--QUESTION 7
CREATE OR REPLACE PROCEDURE GetArtistBookings(
    p_artist_name IN VARCHAR2
)
AS
    -- Variable to track if any bookings were found
    v_bookings_found BOOLEAN := FALSE;
    
    -- Cursor to fetch booking details for Max Trillion
    CURSOR booking_cursor IS
        SELECT 
            b.BOOKING_ID,
            TO_CHAR(b.BOOKING_DATE, 'DD Month YYYY') AS BOOKING_DATE,
            e.EVENT_NAME,
            e.EVENT_RATE
        FROM 
            BOOKINGS b
        JOIN 
            ARTIST a ON b.ARTIST_ID = a.ARTIST_ID
        JOIN 
            EVENT e ON b.EVENT_ID = e.EVENT_ID
        WHERE 
            UPPER(a.ARTIST_NAME) = UPPER(p_artist_name)
        ORDER BY 
            b.BOOKING_DATE;
BEGIN
    -- Display header
    DBMS_OUTPUT.PUT_LINE('Booking Details for ' || p_artist_name);
    DBMS_OUTPUT.PUT_LINE(RPAD('-', LENGTH('Booking Details for ' || p_artist_name), '-'));
    DBMS_OUTPUT.PUT_LINE('Booking ID  Booking Date      Event Name                      Event Rate');
    DBMS_OUTPUT.PUT_LINE('----------  --------------    ------------------------------  ----------');
    
    -- Loop through results and display
    FOR booking_rec IN booking_cursor LOOP
        v_bookings_found := TRUE;
        DBMS_OUTPUT.PUT_LINE(
            RPAD(booking_rec.BOOKING_ID, 10) || '  ' ||
            RPAD(booking_rec.BOOKING_DATE, 16) || '  ' ||
            RPAD(booking_rec.EVENT_NAME, 30) || '  ' ||
            booking_rec.EVENT_RATE
        );
    END LOOP;
    
    -- If no bookings found
    IF NOT v_bookings_found THEN
        DBMS_OUTPUT.PUT_LINE('No bookings found for ' || p_artist_name);
    END IF;
END;
/


EXEC GetArtistBookings('Max Trillion');


--QUESTION 8
CREATE OR REPLACE FUNCTION CalculateArtistRevenue(
    p_artist_id IN VARCHAR2
) RETURN NUMBER
IS
    v_total_revenue NUMBER := 0;
    v_artist_exists NUMBER;
BEGIN
    -- Checking If Atrist Exists
    SELECT COUNT(*)
    INTO v_artist_exists
    FROM ARTIST
    WHERE ARTIST_ID = p_artist_id;
    
    IF v_artist_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Artist ID ' || p_artist_id || ' not found');
    END IF;
    
    -- Calculating Total Revenue With 10% Discount For Events Over 250
    SELECT SUM(
        CASE 
            WHEN e.EVENT_RATE > 250 THEN e.EVENT_RATE * 0.9
            ELSE e.EVENT_RATE
        END)
    INTO v_total_revenue
    FROM BOOKINGS b
    JOIN EVENT e ON b.EVENT_ID = e.EVENT_ID
    WHERE b.ARTIST_ID = p_artist_id;
    
    -- Returning A Value Of 0 If No Bookings Are Found Instead Of NULL
    RETURN NVL(v_total_revenue, 0);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error calculating revenue: ' || SQLERRM);
        RETURN -1; -- Returning A Vslue of -1 To Indicate Error
END;
/

--Execution With Exception Handling
DECLARE
    v_artist_id VARCHAR2(5) := 'A_101';
    v_revenue NUMBER;
BEGIN
    -- Calling The Function With Exception Handling
    BEGIN
        v_revenue := CalculateArtistRevenue(v_artist_id);
        
        -- Displaying The Results
        DBMS_OUTPUT.PUT_LINE('Calculating revenue for artist ID: ' || v_artist_id);
        DBMS_OUTPUT.PUT_LINE('-----------------------------------------------');
        
        IF v_revenue >= 0 THEN
            DBMS_OUTPUT.PUT_LINE('Total Revenue (with applicable discounts): $' || v_revenue);
        ELSE
            DBMS_OUTPUT.PUT_LINE('Error occurred during calculation');
        END IF;
        
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
    END;
END;
/




--QUESTION 9

/*Tools
-----------------------------------------------------------------------------------------------
Software applications or built-in database features that perform specific security tasks, such as:  
- Encryption tools (e.g., Oracle TDE for encrypting `EVENT_RATE` and `ARTIST_EMAIL`) 
    - What it does: Automatically encrypts sensitive data like ticket prices (`EVENT_RATE`) and artist emails (`ARTIST_EMAIL`) when stored in the database  
    - Why it matters: Protects financial and personal data if hackers breach the system
    
- Access control tools  (e.g., Oracle VPD to restrict artists to their own bookings)
    - What it does: Creates "invisible walls" so artists can only see their own booking records  
    - Why it matters: Prevents artists from accessing competitors' booking details 
      
- Monitoring tools (e.g., IBM Guardium to detect SQL injection attacks)  
    - What it does: Acts like a security camera that detects suspicious booking queries (e.g., SQL injection attacks)  
    - Why it matters: Stops hackers trying to steal attendee lists or manipulate bookings  
    
All three work together to:
- Keep payment data secure (Encryption)  
- Ensure artists see only their info (Access Control)  
- Catch hackers in real-time (Monitoring)  

Platforms
----------------------------------------------------------------------------------------------
Larger systems or frameworks that **integrate multiple security functions**, such as:  
- Oracle Audit Vault (Centralized logging/auditing platform)  
- CyberArk (Privileged access management platform for DBAs)  
- Imperva WAF (Web application firewall platform to block attacks)  


Why This Matters for Your Event Booking System?
------------------------------------------------------------------------------------------------
-Tools: handle precise tasks (e.g., encrypting payments, masking emails).  
-Platforms: provide end-to-end protection (e.g., monitoring all database activity)*/



--QUESTION 10
/*Scalar Data Types in PL/SQL
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Scalar data types are basic types that store only one value at a time.like numbers, characters, or even logical values each representing an individual value. The scalar data types are categorized into:

Numeric Types: It Stores any integer value along with a fractional entity whatever large it is or as per the requirement of the program.
Character Types: Nodes represent strings of text and These act as structures of text whereby an individual string is represented by a node.
Boolean Types: It Contains ‘true’ or ‘false’ values.
Datetime Types: It is Used to represent date and time values which are of typical usage in computer systems.
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Numeric data types store numbers, both integers and real numbers, and allow developers to perform arithmetic operations. The main numeric types include:
NUMBER: A highly flexible type that can store fixed-point or floating-point numbers. It has precision and scale parameters. For example, NUMBER(5, 2) can store up to 5 digits, with 2 of them after the decimal point.
- Example: Storing product prices (199.99) or scientific measurements (6.02214076e23)
  
BINARY_INTEGER/PLS_INTEGER: These types are used for signed integers and are often faster than the generic NUMBER type because they use machine-dependent formats.
- Example: Counting inventory items (150 units) or loop counters

FLOAT: It is a subtype of NUMBER designed for storing floating-point numbers. You can specify an optional precision such as FLOAT(10) which allows for storing a number with up to 10 digits of precision
- Example: Scientific calculations (3.1415926535) or astronomical distances
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Character Data Types and Subtypes in PL/SQL
Character data types are designed to store any text, numbers or symbols in the form of alphanumeric. They are used specifically for string manipulation and are a vital part of PL/SQL.
CHAR: It Handles variable-length binary data and fixed-length character strings. If the string is less than the defined length, then the rest is filled up with spaces. For instance, CHAR(10) would store string as CHAR data type that has a length of 10 characters regardless of the actual string length.
- Example: Country codes ('US ', 'GB ') where fixed width is required

VARCHAR2: To store character strings of varying lengths. VARCHAR2 is slightly different because it only allocates the required amount of space required to store the string. For instance, VARCHAR2(10) data type can accommodate a string with as many as 10 characters.
- Example: Customer names ('John Smith') or email addresses

LONG: It Can store variable-length character strings of up to 2 gigabytes. However, it is deprecated and it should be replaced with CLOB to 2 GB. However, it is deprecated and should be avoided in favour of CLOB.
- Example: (Legacy) Storing large XML documents or text reports
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
PL/SQL Boolean Data Types
The Boolean data type is unique to PL/SQL, allowing you to store logical values and use them in conditional expressions.

BOOLEAN: This type can have three possible values: TRUE, FALSE, or NULL. It is used in conditional statements and logical comparisons. Notably, the BOOLEAN data type is unique to PL/SQL and cannot be used in SQL statements directly.
- Example: Flagging active accounts (TRUE) or expired subscriptions (FALSE)
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
PL/SQL Datetime and Interval Types
Datetime data types contain date and time and interval types contain the difference between two datetime values. PL/SQL provides the following datetime and interval types:

DATE: It stores date and time values. These are the year, month, day, hour, minute, and second as a part of the Date type.
- Example: Order dates ('15-JUN-2023') or birthdates

TIMESTAMP: It is an extension of the DATE data type with the added feature of fractional seconds.
- Example: Transaction timestamps ('15-JUN-2023 14:30:45.123456')

TIMESTAMP WITH TIME ZONE: Saves a TIMESTAMP, but with information about the time zone in which it has been set.
- Example: Global meeting times ('15-JUN-2023 09:00:00 -07:00')

TIMESTAMP WITH LOCAL TIME ZONE: Standalone function that converts the TIMESTAMP to the time zone of the current database session.
- Example: System logs that adjust to viewer's timezone

INTERVAL YEAR TO MONTH: Saves the amount of time measured in years and months.
- Example: Warranty periods ('2-6' for 2 years 6 months)

INTERVAL DAY TO SECOND: Saves as the time duration in terms of days, hours, minutes, and seconds.
- Example: Service durations ('0 05:30:00' for 5 hours 30 minutes)

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/


--QUESTION 11
CREATE OR REPLACE TRIGGER trg_prevent_invalid_booking
BEFORE INSERT OR UPDATE ON BOOKINGS
FOR EACH ROW
DECLARE
    v_event_date DATE;
    v_day_of_week VARCHAR2(10);
BEGIN
    v_event_date := :NEW.BOOKING_DATE;
    
    -- Determining The Day Of The Week
    v_day_of_week := TO_CHAR(v_event_date, 'DY');
    
    -- Checking If The Booking Is For A Weekend
    IF v_day_of_week IN ('SAT', 'SUN') THEN
        RAISE_APPLICATION_ERROR(-20001, 
            'Bookings cannot be made for weekends (Saturday or Sunday). ' ||
            'Attempted booking date: ' || TO_CHAR(v_event_date, 'DD-MON-YYYY') ||
            ' (' || v_day_of_week || ')');
    END IF;
END;
/














