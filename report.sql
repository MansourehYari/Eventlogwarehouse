/*----- Report 3 -----*/
  --- هر بیمار چقدر هزینه داشته است
Select distinct [patientID],Cost      
FROM [HospitalDW].[dbo].[FactProcess]


Select distinct [patientID],Cost      
FROM [HospitalDW].[dbo].[FactProcess]
Where 
Cost>10000000000


/*----- Report 4 ------*/

 Select patientID,Count(*)
 FROM [HospitalDW].[dbo].[FactProcess]
 Where
  ActivityTitle like N'%MRI%'
 Group By patientID
 Having Count(*)>=3


 --- هر بیمار چقدر ام آر آی داشته است
 Select patientID,Count(*)
 FROM [HospitalDW].[dbo].[FactProcess]
 Where
  ActivityTitle like N'%MRI%'
 Group By patientID
 --Having Count(*)>=3


 /*------- Report 5 -----*/
  
  Select *
  FROM [HospitalDW].[dbo].[FactProcess] F
  Left Join DimDate D ON F.DateKey=D.DateKey
  Where
     ActivityTitle like N'%MRI%'
	 --And F.ActivityValue like N'%دست%'
	 And D.PersianYearMonthInt>=139505
	 And D.PersianYearMonthInt<=139906
 


/*------بیمارانی که رادیوگرافی دست برایشان انجام شده است*/
SELECT  *
FROM [HospitalDW].[dbo].[FactProcess]
Where
 ActivityTitle  like '%Radiography%'
 And
 ActivityValue like N'%دست%'
   












