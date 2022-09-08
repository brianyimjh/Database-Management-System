DROP TABLE IF EXISTS CUSTOMER;
CREATE TABLE CUSTOMER (
	id				CHAR(9)				not null,
	c_name			CHAR(50)			not null,
	c_address		VARCHAR(100)		not null,
	contact			CHAR(8)				not null,
	dateOfBirth		DATE				not null,
	occupation		VARCHAR(30)			null,


	CONSTRAINT		CHECK_ID			CHECK (id LIKE '[ST][0-9][0-9][0-9][0-9][0-9][0-9][0-9][A-Z]'),
	CONSTRAINT		CHECK_CONTACT		CHECK (contact LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
	CONSTRAINT		CHECK_DOB			CHECK (DATEDIFF(year, dateOfBirth, getdate()) >= 21),
	CONSTRAINT		CUSTOMER_PK			PRIMARY KEY (id)
);

DROP TABLE IF EXISTS EQUIPMENT;
CREATE TABLE EQUIPMENT (
	equipmentCode			CHAR(5)				not null,
	e_name					VARCHAR(50)			not null,
	e_description			VARCHAR(255)		null,
	RentalRatePerDay		DECIMAL(4, 2)		not null,

	CONSTRAINT				CHECK_RATE			CHECK (RentalRatePerDay >= 4 AND RentalRatePerDay <= 50),
	CONSTRAINT				EQUIPMENT_PK		PRIMARY KEY (equipmentCode)
);

DROP TABLE IF EXISTS LOAN;
CREATE TABLE LOAN (
	id				CHAR(9)				not null,
	equipmentCode	CHAR(5)				not null,
	startDate		DATE				not null,
	returnedDate	DATE				null,

	CONSTRAINT		CHECK_RETURN_DATE	CHECK (returnedDate >= startDate),
	CONSTRAINT		LOAN_PK				PRIMARY KEY (id, equipmentCode, startDate),
	CONSTRAINT		LOAN_FK1			FOREIGN KEY (id)
					REFERENCES			CUSTOMER (id)
					ON UPDATE			CASCADE
					ON DELETE			CASCADE,
	CONSTRAINT		LOAN_FK2			FOREIGN KEY (equipmentCode)
					REFERENCES			EQUIPMENT (equipmentCode)
					ON UPDATE			CASCADE
					ON DELETE			NO ACTION
);

DROP TABLE IF EXISTS DAMAGEREPORT;
CREATE TABLE DAMAGEREPORT (
	reportId		INT					not null		IDENTITY(1, 1),
	damageType		VARCHAR(16)			not null,
	id				CHAR(9)				not null,
	equipmentCode	CHAR(5)				not null,
	startDate		DATE				not null,

	CONSTRAINT		CHECK_DAMAGE_TYPE	CHECK (damageType in ('Wear and tear', 'Customer Damaged')),
	CONSTRAINT		DAMAGEREPORT_PK		PRIMARY KEY (reportId),
	CONSTRAINT		DAMAGEREPORT_FK		FOREIGN KEY (id, equipmentCode, startDate)
					REFERENCES			LOAN (id, equipmentCode, startDate)
					ON UPDATE			NO ACTION
					ON DELETE			NO ACTION
);


-- CUSTOMER
INSERT INTO CUSTOMER VALUES ('S7615682J', 'Charles Toles', '23 Haig Road', '92142331', '1976-03-15', 'Teacher');
INSERT INTO CUSTOMER VALUES ('S8512123F', 'Damien Low', '5 Still Road', '88128833', '1985-07-05', 'Teacher');
INSERT INTO CUSTOMER VALUES ('S8823456F', 'Audrey Ng', '10 Bedok Road', '82138213', '1988-01-23', 'Nurse');
INSERT INTO CUSTOMER VALUES ('S9012345G', 'Betsey Tan', '2 Jalan Eunos', '98981212', '1990-05-12', 'Cartoonist');
INSERT INTO CUSTOMER VALUES ('S9144234J', 'Peter Lee', '8 Jalan Melayu', '97589758', '1991-03-04', 'Student');
INSERT INTO CUSTOMER VALUES ('S9712345Z', 'Ali Bin Mohd Hassan', '10 Clementi Road', '91239123', '1997-07-10', 'IT Programmer');
INSERT INTO CUSTOMER VALUES ('S9945675J', 'Ravi S/O Ramasamy', '12 Jurong Road', '82223333', '1998-08-12', 'Personal Trainer');
SELECT * FROM CUSTOMER;

-- EQUIPMENT
INSERT INTO EQUIPMENT VALUES ('CAM01', 'Tent 2 Persons', '2-Person Tent', 15.00);
INSERT INTO EQUIPMENT VALUES ('CAM02', 'Tent 4 Persons', '4-Person Tent', 18.00);
INSERT INTO EQUIPMENT VALUES ('CAM03', 'Tent 6 Persons', '6-Person Tent', 22.00);
INSERT INTO EQUIPMENT VALUES ('CAM04', 'Camp Stove', '2 Burner Camping Stove', 8.00);
INSERT INTO EQUIPMENT VALUES ('DIV04', 'Mask', 'Diving Mask', 4.00);
INSERT INTO EQUIPMENT VALUES ('DIV05', 'Dive Torch', 'Diving Torch requires 4D size battery', 10.00);
INSERT INTO EQUIPMENT VALUES ('DIV09', 'Wet Suit', 'Full Suit', 20.00);
INSERT INTO EQUIPMENT VALUES ('DIV10', 'Wet Suit', 'Shorty', 10.00);
SELECT * FROM EQUIPMENT;

-- LOAN
INSERT INTO LOAN VALUES ('S7615682J', 'DIV09', '2021-05-01', '2021-05-02');
INSERT INTO LOAN VALUES ('S8512123F', 'CAM04', '2021-06-22', '2021-06-24');
INSERT INTO LOAN VALUES ('S8823456F', 'CAM02', '2021-06-24', '2021-06-29');
INSERT INTO LOAN VALUES ('S8823456F', 'CAM03', '2021-05-24', '2021-05-26');
INSERT INTO LOAN VALUES ('S8823456F', 'CAM04', '2021-05-24', '2021-05-26');
INSERT INTO LOAN VALUES ('S9012345G', 'DIV04', '2021-05-01', '2021-05-02');
INSERT INTO LOAN VALUES ('S9012345G', 'DIV05', '2021-05-02', '2021-05-02');
INSERT INTO LOAN VALUES ('S9144234J', 'CAM04', '2021-06-22', '2021-06-25');
SELECT * FROM LOAN;

-- DAMAGEREPORT
INSERT INTO DAMAGEREPORT VALUES ('Customer Damaged', 'S8512123F', 'CAM04', '2021-06-22');
INSERT INTO DAMAGEREPORT VALUES ('Customer Damaged', 'S8823456F', 'CAM03', '2021-05-24');
INSERT INTO DAMAGEREPORT VALUES ('Wear and tear', 'S9012345G', 'DIV04', '2021-05-01');
SELECT * FROM DAMAGEREPORT;


-- b(i)
SELECT * FROM EQUIPMENT
WHERE (RentalRatePerDay > 10) AND 
(equipmentCode LIKE 'CAM%') AND
(equipmentCode IN
(SELECT equipmentCode FROM LOAN WHERE id IN
(SELECT id FROM CUSTOMER WHERE DATEDIFF(year, dateOfBirth, getdate()) >= 30)))
ORDER BY e_name, RentalRatePerDay ASC;

-- b(ii)
SELECT "Start Code" = SUBSTRING(equipmentCode, 1, 3), 
"Number of Equipment for June" = COUNT(equipmentCode)
FROM LOAN
WHERE (MONTH(startDate) = 6) OR (MONTH(returnedDate) = 6)
GROUP BY SUBSTRING(equipmentCode, 1, 3)
HAVING COUNT(SUBSTRING(equipmentCode, 1, 3)) > 2;

-- b(iii)
CREATE VIEW CustomerSummary AS
SELECT 
CUSTOMER.*,
"Number of Equipment Rented" = COUNT(LOAN.equipmentCode),
"Total Rent" = ISNULL(SUM(EQUIPMENT.RentalRatePerDay * DATEDIFF(day, LOAN.startDate, LOAN.returnedDate)), 0),
"NumDamage" = COUNT(DAMAGEREPORT.reportId)

FROM CUSTOMER LEFT JOIN LOAN
ON CUSTOMER.id = LOAN.id

LEFT JOIN EQUIPMENT
ON LOAN.equipmentCode = EQUIPMENT.equipmentCode

LEFT JOIN DAMAGEREPORT
ON LOAN.id = DAMAGEREPORT.id AND 
LOAN.equipmentCode = DAMAGEREPORT.equipmentCode AND 
LOAN.startDate = DAMAGEREPORT.startDate AND
DAMAGEREPORT.damageType <> 'Wear and tear'

GROUP BY CUSTOMER.id, CUSTOMER.c_name, CUSTOMER.c_address, CUSTOMER.contact, CUSTOMER.dateOfBirth, CUSTOMER.occupation;

--b(iv)
SELECT 
c_name, 
contact, 
"Number of Equipment Rented", 
"Total Rent", 
"Average Rental for biggest customer" = CONVERT(DECIMAL(7,2), "Total Rent"/"Number of Equipment Rented"), 
NumDamage 
FROM CustomerSummary
WHERE "Number of Equipment Rented" = (SELECT MAX("Number of Equipment Rented") FROM CustomerSummary);


--c
DROP TRIGGER LOAN_InsteadOfInsertCheckNumDamage
CREATE TRIGGER LOAN_InsteadOfInsertCheckNumDamage 
ON LOAN
INSTEAD OF INSERT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE		@CustomerID				AS CHAR(9),
				@EquipmentCode			AS CHAR(5),
				@StartDate				AS DATE,
				@ReturnedDate			AS DATE,
				@LastLoanReturnDate		AS DATE,
				@OneLoanStartDate		AS DATE,
				@OneLoanEndDate			AS DATE

	SELECT		@CustomerID = id,
				@EquipmentCode = equipmentCode,
				@StartDate = startDate,
				@ReturnedDate = returnedDate
	FROM		inserted;

	-- Check if there is at least 3 damages in the past 12 months
	IF (SELECT COUNT(reportId)
		FROM LOAN RIGHT JOIN DAMAGEREPORT
		ON
		LOAN.id = DAMAGEREPORT.id AND 
		LOAN.equipmentCode = DAMAGEREPORT.equipmentCode AND 
		LOAN.startDate = DAMAGEREPORT.startDate
		WHERE (DAMAGEREPORT.id = @CustomerID
		AND DATEADD(YEAR, -1, @StartDate) <= LOAN.returnedDate) 
		AND LOAN.returnedDate <= @StartDate) >= 3

		BEGIN
			-- Get the last returned date of damaged equipment
			SELECT TOP 1 @LastLoanReturnDate = returnedDate
			FROM LOAN RIGHT JOIN DAMAGEREPORT
			ON
			LOAN.id = DAMAGEREPORT.id AND 
			LOAN.equipmentCode = DAMAGEREPORT.equipmentCode AND 
			LOAN.startDate = DAMAGEREPORT.startDate
			WHERE (DAMAGEREPORT.id = @CustomerID) ORDER BY reportId DESC

			-- Check if the last returned date of damaged equipment is within grace period
			IF @LastLoanReturnDate > DATEADD(day, -1, (DATEADD(month, -1, @StartDate)))
				PRINT 'Loan request rejected. Last date of return of damaged equipment is within a month away.';
			ELSE
				BEGIN
					SET @OneLoanStartDate = DATEADD(month, 1, @LastLoanReturnDate)
					SET @OneLoanEndDate = DATEADD(year, 1, @OneLoanStartDate)

					-- Check if loan request in within one loan per month period
					IF (
						(MONTH(@OneLoanStartDate) <= MONTH(@StartDate))
						AND (YEAR(@OneLoanStartDate) <= YEAR(@StartDate))
						)
						AND (
						(MONTH(@StartDate) <= MONTH(@OneLoanEndDate))
						AND (YEAR(@StartDate) <= YEAR(@OneLoanEndDate))
						)

						-- Check if there is already a loan for the current month and year
						IF (SELECT COUNT(id) FROM LOAN
							WHERE id = @CustomerID
							AND (
								(MONTH(startDate) = MONTH(@StartDate))
								AND (YEAR(startDate) = YEAR(@StartDate))
								)
							OR (
								(MONTH(returnedDate) = MONTH(@StartDate))
								AND (YEAR(returnedDate) = YEAR(@StartDate))
								)
							) > 0
						
							PRINT 'Loan request rejected. Only one loan is allowed per month.';

						ELSE
							BEGIN
								INSERT INTO LOAN VALUES (@CustomerID, @EquipmentCode, @StartDate, @ReturnedDate);
								PRINT 'Loan request recorded.';
							END;

					ELSE
							BEGIN
								INSERT INTO LOAN VALUES (@CustomerID, @EquipmentCode, @StartDate, @ReturnedDate);
								PRINT 'Loan request recorded.';
							END;
				END;
		END;

	ELSE
		BEGIN
			INSERT INTO LOAN VALUES (@CustomerID, @EquipmentCode, @StartDate, @ReturnedDate);
			PRINT 'Loan request recorded.';
		END;
END;