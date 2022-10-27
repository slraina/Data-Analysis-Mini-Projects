-- Creating Database 
create schema creditcard;
use creditcard;

-- Load data using "Table data import wizard" (in case of smaller database) 

-- Checking the table details
SELECT * FROM bankchurners;

-- NOW Start quering the Database

-- Attrited Customers wrt to age range
SELECT CASE WHEN Customer_Age < 20 then "0-20"
			WHEN Customer_Age between 20 and 30 then "20-30"
            WHEN Customer_Age between 30 and 40 then "30-40"
			WHEN Customer_Age between 40 and 50 then "40-50"
            WHEN Customer_Age between 50 and 60 then "50-60"
			WHEN Customer_Age between 60 and 70 then "60-70"
            WHEN Customer_Age between 70 and 80 then "70-80"
            WHEN Customer_Age > 80 then "Above 80" END AS Age_Range,Count(*) as No_of_Customers
from bankchurners where Attrition_Flag = "Attrited Customer" group by Age_Range order by Age_Range;

-- AVG AGE OF CUSTOMERS by GENDER AND ATTRITION FLAG
SELECT Attrition_Flag, Gender, AVg(Customer_Age) from bankchurners group by Gender, Attrition_Flag;

-- EXISTING CUSTOMERS 
SELECT Gender, Count(*) FROM bankchurners WHERE Attrition_Flag = 'Existing Customer' group by Gender order by Gender;
-- ATTRITED CUSTOMERS 
SELECT Gender, Count(*) FROM bankchurners WHERE Attrition_Flag = 'Attrited Customer' group by Gender; 

-- Customers by Education level 
Select Education_Level, Attrition_Flag, Count(*) as No_of_People From bankchurners Group by Education_Level,Attrition_Flag	 ;

-- Marital statues and Attrition Flag
SELECT Marital_Status, Attrition_Flag, Count(*) as People_Count FROM bankchurners Group by Marital_Status, Attrition_Flag order by Marital_Status ;

-- Income Category 
SELECT Income_Category, Attrition_Flag, count(*) as No_of_People FROM bankchurners Group by Income_Category, Attrition_Flag order by Income_Category;

-- Months on Book 
SELECT Case when Months_on_book < 20 then "0-20"
			when Months_on_book between 20 and 30 then "20-30"
			when Months_on_book between 30 and 40 then "30-40"
			when Months_on_book between 40 and 50 then "40-50"
			when Months_on_book between 50 and 60 then "50-60"
			when Months_on_book > 60 then "Above 60" END as MBOOK,
Count(*) FROM bankchurners where Attrition_Flag = "Attrited Customer" Group by MBOOK Order by MBOOK;

-- Card Type 
SELECT Card_Category, Attrition_Flag, Count(*) FROM bankchurners Group by Card_Category, Attrition_Flag Order by Card_Category;

-- Inactive Users
SELECT Months_Inactive_12_mon, Attrition_Flag, Count(*) FROM bankchurners Group by Months_Inactive_12_mon, Attrition_Flag Order by Months_Inactive_12_mon;

-- Avg Utilization Ratio of Users
SELECT concat(round(AVG(Avg_Utilization_Ratio)*100,2),"%") as AVG_POPLn_UTILIZn, Attrition_Flag FROM bankchurners Group by Attrition_Flag Order by Avg_Utilization_Ratio;

-- Role of Dependents in Attrition 
SELECT Dependent_count, Attrition_Flag,Count(*) FROM bankchurners Group by Dependent_count,Attrition_Flag Order by Dependent_count;

-- Relation_Count
SELECT Total_Relationship_Count, Attrition_Flag,Count(*) FROM bankchurners Group by Total_Relationship_Count,Attrition_Flag Order by Total_Relationship_Count;

-- Total Revolving Balance
Select CASE WHEN Total_Revolving_Bal < 500 THEN "0-500"
			WHEN Total_Revolving_Bal between 500 and 1000 THEN "500-1000"
			WHEN Total_Revolving_Bal between 1000 and 1500 THEN "1000-1500"
			WHEN Total_Revolving_Bal between 1500 and 2000 THEN "1500-2000"
			WHEN Total_Revolving_Bal between 2000 and 2500 THEN "2000-2500"
			WHEN Total_Revolving_Bal between 2500 and 3000 THEN "2500-3000"
			WHEN Total_Revolving_Bal > 3000 THEN  "Above 3000" end as BAL,
Attrition_Flag, Count(*) as COUNT from bankchurners group by BAL, Attrition_Flag ORDER BY 1 ;

