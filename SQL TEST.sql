
1. Write a script to create the Employees table
Create Table CostCentre
(
constCentreID INT primary key,
name varchar(50),
accountNo varchar(50)
)
--===========================================================
Create Table salaryLevel
(
salaryLevelID INT not null primary key identity(1,1),
amount decimal(7,2),
increasePercentage smallint
)
--===========================================================

Create Table Department
(
departmentID INT not null primary key identity(1,1),
name varchar(50) not null,
constcentreID int FOREIGN KEY REFERENCES CostCentre(constcentreID)
)
--===========================================================
Create Table Employees
(
employeeNo INT not null primary key identity(1,1),
lastName varchar(50) not null,
firstName varchar(50) not null,
gender char not null,
IDNumber varchar(20) not null,
salaryLevelID INT,
departmentID int FOREIGN KEY REFERENCES Department(departmentID)
)

1.2Write a script to alter the Employees table to increase the length
of the lastName field from 50 - 60 characters

Ans: 


IF EXISTS(SELECT 1 FROM sys.columns 
          WHERE Name = N'lastName'
          AND Object_ID = Object_ID(N'dbo.Employees'))

begin
alter table dbo.Employees
alter column lastName varchar(60)
end

1.3. Create a stored procedure that takes in a parameter of a
Department Name and returns all the employees’ details for the
department. If no department name is passed in, return all the
employees.

Ans: CREATE PROCEDURE usp_getEmployeesByDeptName 
	@DeptName varchar(50)
AS
BEGIN
	
	if isnull(@DeptName,'')<>''
	select emp.* from dbo.Employees emp inner join dbo.Department dept on emp.departmentID=dept.departmentID
	where dept.name=@DeptName
	else
	select emp.* from dbo.Employees emp left join dbo.Department dept on emp.departmentID=dept.departmentID


END
GO

1.4. Create a stored procedure that returns each department name and the number of employees in each department.


Ans: 
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE usp_getDeptnameandEmployeecount 
	@DeptName varchar(50)
AS
BEGIN
	
	select dept.name DepartmentName, count(*) EmployeesCount from dbo.Employees emp 
inner join dbo.Department dept on emp.departmentID=dept.departmentID
group by dept.name


END
GO

1.5. Create a stored procedure that takes in a department name and
updates the salary of each employee in the department based on
the increase percentage.

ANS: 

CREATE PROCEDURE usp_updatesEmployeesalary 
	@DeptName varchar(60)
AS
BEGIN


UPDATE sal
  SET sal.amount= CAST(sal.amount as decimal) * ( CAST(sal.increasePercentage AS decimal) / CAST(100 AS decimal))
  FROM dbo.Employees emp
  INNER JOIN dbo.Department dept on emp.departmentID=emp.departmentID
  inner join dbo.salaryLevel sal on emp.salaryLevelID=sal.salaryLevelID
  where dept.name=@DeptName  

END
GO


1.6. Can you identify any unintended consequences the above
procedure might have
1.7. Create a stored procedure that creates a new Employee. The
procedure takes in all the employee details as well as the
department and salarylevel.
Ans:

CREATE PROCEDURE usp_createEmployee 

	@lastName varchar(50),
	@firstName varchar(50),
	@gender char(1),
	@IDNumber varchar(20),
    @amount decimal(7,2),
    @increasePercentage smallint,
	@name varchar(50),
	@CostcenterId int

	as

BEGIN

declare @salarelvlID int,
		@deptID int

insert dbo.salaryLevel values(@amount,@increasePercentage)

set @salarelvlID=@@IDENTITY

insert dbo.Department values(@name,@CostcenterId)

set @deptID=@@IDENTITY

insert dbo.Employees values (@lastName,@firstName,@gender,@IDNumber,@salarelvlID,@deptID)



	
END
GO

1.8. Create a stored procedure that takes in a department name and
returns the number of Males and females in the department.

Ans: Create proc usp_GetmalefemaleDept

@name varchar(50)
as
begin

declare @countofMale int,@countofFemale int


select @countofMale=COUNT(*)  from dbo.Employees emp with(nolock) inner join dbo.Department dept with(nolock)
on emp.departmentID=dept.departmentID where dept.name=@name and emp.gender='M'

select @countofFemale=COUNT(*)  from dbo.Employees emp with(nolock) inner join dbo.Department dept with(nolock)
on emp.departmentID=dept.departmentID where dept.name=@name and emp.gender='F'
 

select @countofMale NumberofMale,@countofFemale NumberofFemale,@name DepartmentName



end

1.9. Create a stored procedure that takes in an employNo and returns
the salary amount as well as the department name.
Ans: create proc usp_EmpsalanddeptName

@employeeno int
as
begin

select sal.amount Salary,dept.name [Department Name] from dbo.Employees emp with(nolock) inner join dbo.salaryLevel sal with(nolock)
on emp.salaryLevelID=sal.salaryLevelID inner join dbo.Department dept with(nolock) 
on emp.departmentID=dept.departmentID
where emp.employeeNo=@employeeno

end

1.10. Assuming that the relationship between Employees and
salaryLevel does not exist, create a stored procedure that
returns all the employees that have a salarylevelID that is not in
the Salary level table.

Ans: 
CREATE PROCEDURE usp_empwithoutsalid
	
AS
BEGIN
	
	select * from dbo.Employees emp with(nolock) where emp.salaryLevelID not in
	(select salaryLevelID from dbo.salaryLevel (nolock))

END
GO

2. Please answer the following using the table structure defined
in section 1
2.1. Assuming that we have a front end that takes in any of these sets
of parameters to search for an employee
1. (First Name, Last Name and Department)
OR
2. IDNumber and lastName
OR
3. Department and lastName
2.1.1 Please list the tables and columns to add index(es) to in
order to improve performance?

Ans: /*
 When data is inserted/updated/deleted, then the index needs to be maintained as well as the original data. 
 This slows down updates and locks the tables (or parts of the tables), which can affect query processing.
*

2.1.2 What are the disadvantages in creating an index?
2.2. What is the difference between ISNULL and COALESCE?

Ans: /*COALESCE is ANSI Standard whereas, ISNULL is SQL Server Specific
COALESCE can accept multiple parameters whereas, ISNULL can accept only two parameters*/

2.3 Is the Following SQL Statement valid? If not please specify
INSERT INTO Employees
(employeeNo,lastName,firstName,gender,IDNumber,departmentID)
VALUES (12,'Terry','John','M','80050850980874',4)

Ans:  INSERT INTO Employees
(employeeNo,lastName,firstName,gender,IDNumber,departmentID)
VALUES (12,'Terry','John','M','80050850980874',4)

/* we  can not insert value identity column*/


2.4. Why use a relational table structure for the table structure above.
Why not have all the fields in one table?

Ans: /*
1. easy to index each table,
2. We can avoid locking on table
(eg. if we have a situation to read only department data we can only work with department table, if we dont have 
multiple tables for every read we will locking the whole table)
3. IF we have huge data in tables we can File group tables

*/

3. Using the below tables
3.1. Create a function called dbo.MapEcentricTestTable that takes in
a name as parameter and returns the ID for the corresponding name
from dbo.EcentricTestTable.

Ans: 
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION  dbo.MapEcentricTestTable 
(
	@name varchar(255)
)
RETURNS int
AS
BEGIN	
	DECLARE @Id Int
	
	SELECT @Id = ID from dbo.EcentricTestTable (nolock) where Name=@name
	
	RETURN @id

END
GO


3.2. How would you optimise the following query taking into account
that any text could be passed as a parameter to the function, not just
‘Test2’?
SELECT *
FROM dbo.EcentricTestTable e
JOIN EcentricTestTable_NEW n ON n.ID = e.ID
WHERE e.ID = dbo.MapEcentricTestTable('Test2')

Ans:  declare @inputparam varchar(250)
set @inputparam='Test3'
SELECT *
FROM dbo.EcentricTestTable e
JOIN EcentricTestTable_NEW n ON n.ID = e.ID
WHERE e.ID = dbo.MapEcentricTestTable(@inputparam)

4 Given the query below:
SELECT CASE WHEN NULL = NULL THEN 'Yes' ELSE 'No' END AS Result
4.1 What will the result of the query be, please explain why?
Ans:
/*
Out Put =  NO
Because null always not equal to another null.
Null is consider to be a memory reference. So each null will take different reference ID.
So NULL will be not equal anytime.
*/

4.2 What, if anything, could influence the original query to produce a
different result?
Ans: SELECT CASE WHEN NULL = NULL THEN 'Yes' ELSE 'No' END AS Result
/*
  repalceing null with isnull check can make  this query work as intended
*/
SELECT CASE WHEN ISNULL(null,'') = ISNULL(null,'') THEN 'Yes' ELSE 'No' END AS Result

4.3 Provide a query that behaves correctly
Ans: SELECT 
CASE 
WHEN ISNULL(null,'')=ISNULL(null,'')
 THEN 'Yes'
  ELSE 'No'
   END AS Result



