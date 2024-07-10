/****** Script for SelectTopNRows command from SSMS  ******/
DROP TABLE IF EXISTS #temp1;
WITH cte
AS (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS ProcessKey,
           [Event ID] AS EventID,
           [patient ID] AS patientID,
           [Title] AS ActivityTitle,
           [Value] AS ActivityValue,
           CONCAT([Title], ' ', [Value]) AS ActivityName,
           [TimeValue] AS DateTime,
           CAST(REPLACE(SUBSTRING([TimeValue], 1, 10), '/', '') AS INT) AS DateKey,
           CAST(REPLACE(SUBSTRING([TimeValue], 12, 8), ':', '') AS INT) AS TimeKey,
           NULL AS Resource,
           [feature1] AS HospitalName,
           [feature2] AS Gender,
           CAST([feature3] AS INT) AS Age,
           [feature4] AS CauseOfTraumaticInjury,
           [feature5] AS HeightOfFall,
           [feature6] AS PositionOfTheTraumatizedPerson,
           [feature7] AS ArrivalMode,
           [feature8] AS PaymentOfHospitalBilling,
           [feature9] AS Cost,
           Cast([feature10] AS TIME(0)) AS HospitalLengthOfStay_H,
           [feature14] AS HospitalLengthOfStay_Day,
           [feature11] AS ISS,
           [feature12] AS AIS,
           [feature13] AS ICULengthOfStay,
           [feature15] AS CarryOutSurgery,
           [feature16] AS ExternalCauseOfTraumaticInjury,
           [feature17] AS FinalDiagnosisOfInjury1,
           [feature18] AS FinalDiagnosisOfInjury2,
           [feature19] AS FinalDiagnosisOfInjury3,
           [feature20] AS FinalDiagnosisOfInjury4,
           [feature21] AS FinalDiagnosisOfInjury5
    FROM [HospitalDW].[dbo].[Data])
SELECT cte.*,DimTime.Hour24 AS HospitalLengthOfStay_Hour
INTO #temp1
FROM cte LEFT JOIN DimTime ON DimTime.FullTime = cte.HospitalLengthOfStay_H

SELECT * FROM #temp1

--SELECT MIN(Age),MAX(age),AVG(Age)
--FROM #temp1;

DROP TABLE IF EXISTS #temp2
SELECT t.ProcessKey,
       t.EventID,
       t.patientID,
       ISNULL(t.ActivityTitle, 'Unknown') AS ActivityTitle,
       ISNULL(t.ActivityValue, N'نامشخص') AS ActivityValue,
       ISNULL(t.ActivityName, N'نامشخص') AS ActivityName,
       --t.DateTime,
       t.DateKey,
       t.TimeKey,
       t.Resource,
       ISNULL(t.HospitalName, N'نامشخص') AS HospitalName,
       ISNULL(t.Gender, N'نامشخص') AS Gender,
       t.Age,
       CASE
           WHEN Age <= 10 THEN
               1
           WHEN Age > 10
                AND t.Age <= 20 THEN
               2
           WHEN Age > 20
                AND t.Age <= 30 THEN
               3
           WHEN Age > 30
                AND t.Age <= 40 THEN
               4
           WHEN Age > 40
                AND t.Age <= 50 THEN
               5
           WHEN t.Age > 50 THEN
               6
       END AS AgeCategoryID,
       CASE
           WHEN Age <= 10 THEN
               '<10'
           WHEN Age > 10
                AND t.Age <= 20 THEN
               '10-20'
           WHEN Age > 20
                AND t.Age <= 30 THEN
               '20-30'
           WHEN Age > 30
                AND t.Age <= 40 THEN
               '30-40'
           WHEN Age > 40
                AND t.Age <= 50 THEN
               '40-50'
           WHEN t.Age > 50 THEN
               '>50'
       END AS AgeCategoryTitle,
       t.HeightOfFall,
       CAST(t.Cost AS DECIMAL(18, 2)) AS Cost,
       t.HospitalLengthOfStay_Hour,
       t.HospitalLengthOfStay_Day,
       t.ISS,
       t.ICULengthOfStay,
       ISNULL(t.CarryOutSurgery, N'نامشخص') AS CarryOutSurgery,
       ISNULL(t.ExternalCauseOfTraumaticInjury, 'Unknown') AS ExternalCauseOfTraumaticInjury,
       ISNULL(t.FinalDiagnosisOfInjury1, 'Unknown') AS FinalDiagnosisOfInjury1,
       ISNULL(t.FinalDiagnosisOfInjury2, 'Unknown') AS FinalDiagnosisOfInjury2,
       ISNULL(t.FinalDiagnosisOfInjury3, 'Unknown') AS FinalDiagnosisOfInjury3,
       ISNULL(t.FinalDiagnosisOfInjury4, 'Unknown') AS FinalDiagnosisOfInjury4,
       ISNULL(t.FinalDiagnosisOfInjury5, 'Unknown') AS FinalDiagnosisOfInjury5,
       ISNULL(DimAIS.AISKey, 7) AS AISKey,
       ISNULL(DimArrivalMode.ArrivalModeKey, -100) AS ArrivalModeKey,
       ISNULL(DimCauseOfTraumaticInjury.CauseOfTraumaticInjuryKey, -100) AS CauseOfTraumaticInjuryKey,
       ISNULL(DimPaymentOfHospitalBilling.PaymentOfHospitalBillingKey, -100) AS PaymentOfHospitalBillingKey,
       ISNULL(DimPositionOfTheTraumatizedPerson.PositionOfTheTraumatizedPersonKey, -100) AS PositionOfTheTraumatizedPersonKey
	   INTO #temp2
--SELECT COUNT(*)
FROM #temp1 t --42194
    LEFT JOIN dbo.DimAIS
        ON ISNULL(t.AIS,N'نامشخص')= DimAIS.AISTitle
    LEFT JOIN dbo.DimArrivalMode
        ON t.ArrivalMode = DimArrivalMode.ArrivalModeTitle
    LEFT JOIN dbo.DimCauseOfTraumaticInjury
        ON t.CauseOfTraumaticInjury = DimCauseOfTraumaticInjury.CauseOfTraumaticInjuryTitle
    LEFT JOIN dbo.DimPaymentOfHospitalBilling
        ON t.PaymentOfHospitalBilling = DimPaymentOfHospitalBilling.PaymentOfHospitalBillingTitle
    LEFT JOIN dbo.DimPositionOfTheTraumatizedPerson
        ON t.PositionOfTheTraumatizedPerson = DimPositionOfTheTraumatizedPerson.PositionOfTheTraumatizedPersonTitle
	ORDER BY t.ProcessKey

DROP TABLE IF EXISTS dbo.FactProcess 
SELECT * 
INTO FactProcess
FROM #temp2
ORDER BY ProcessKey

--SELECT AgeCategoryTitle,
--       COUNT(*) AS co
--FROM #temp2
--GROUP BY AgeCategoryTitle;
--****************************************
SELECT TOP 10
       *
FROM #temp1;
SELECT DISTINCT
       HospitalName
FROM #temp1; --
SELECT DISTINCT
       CauseOfTraumaticInjury
FROM #temp1; --DimCauseOfTraumaticInjury
SELECT DISTINCT
       HeightOfFall
FROM #temp1; --
SELECT DISTINCT
       PositionOfTheTraumatizedPerson
FROM #temp1; --DimPositionOfTheTraumatizedPerson
SELECT DISTINCT
       ArrivalMode
FROM #temp1; --DimArrivalMode
SELECT DISTINCT
       PaymentOfHospitalBilling
FROM #temp1; --DimPaymentOfHospitalBilling
SELECT DISTINCT
       AIS
FROM #temp1; --DimAIS
SELECT DISTINCT
       ExternalCauseOfTraumaticInjury
FROM #temp1; --
SELECT DISTINCT
       FinalDiagnosisOfInjury1
FROM #temp1; --
SELECT DISTINCT
       FinalDiagnosisOfInjury2
FROM #temp1; --
SELECT DISTINCT
       FinalDiagnosisOfInjury3
FROM #temp1; --
SELECT DISTINCT
       FinalDiagnosisOfInjury4
FROM #temp1; --
SELECT DISTINCT
       FinalDiagnosisOfInjury5
FROM #temp1; --
SELECT DISTINCT
       ISS
FROM #temp1; --
--***********************************************
--Create Dims
--***********************************************
--DimCauseOfTraumaticInjury
SELECT *
INTO DimCauseOfTraumaticInjury
FROM
(
    SELECT -100 AS CauseOfTraumaticInjuryKey,
           N'نامشخص' AS CauseOfTraumaticInjuryTitle
    UNION ALL
    SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS CauseOfTraumaticInjuryID,
           CauseOfTraumaticInjury AS CauseOfTraumaticInjuryTitle
    FROM
    (
        SELECT DISTINCT
               CauseOfTraumaticInjury
        FROM #temp1
        WHERE CauseOfTraumaticInjury IS NOT NULL
    ) a
) b;


--***********************************************
--DimPositionOfTheTraumatizedPerson
SELECT *
INTO DimPositionOfTheTraumatizedPerson
FROM
(
    SELECT -100 AS PositionOfTheTraumatizedPersonKey,
           N'نامشخص' AS PositionOfTheTraumatizedPersonTitle
    UNION ALL
    SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS PositionOfTheTraumatizedPersonID,
           PositionOfTheTraumatizedPerson AS PositionOfTheTraumatizedPersonTitle
    FROM
    (
        SELECT DISTINCT
               PositionOfTheTraumatizedPerson
        FROM #temp1
        WHERE PositionOfTheTraumatizedPerson IS NOT NULL
    ) a
) b;
--***********************************************
--DimArrivalMode
SELECT *
INTO DimArrivalMode
FROM
(
    SELECT -100 AS ArrivalModeKey,
           N'نامشخص' AS ArrivalModeTitle
    UNION ALL
    SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS ArrivalModeID,
           ArrivalMode AS ArrivalModeTitle
    FROM
    (SELECT DISTINCT ArrivalMode FROM #temp1 WHERE ArrivalMode IS NOT NULL) a
) b;

--***********************************************
--DimPaymentOfHospitalBilling
SELECT *
INTO DimPaymentOfHospitalBilling
FROM
(
    SELECT -100 AS PaymentOfHospitalBillingKey,
           N'نامشخص' AS PaymentOfHospitalBillingTitle
    UNION ALL
    SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS PaymentOfHospitalBillingID,
           PaymentOfHospitalBilling AS PaymentOfHospitalBillingTitle
    FROM
    (
        SELECT DISTINCT
               PaymentOfHospitalBilling
        FROM #temp1
        WHERE PaymentOfHospitalBilling IS NOT NULL
    ) a
) b;

--***********************************************
--DimAIS
SELECT *
INTO DimAIS
FROM
(
    SELECT -100 AS AISKey,
           N'نامشخص' AS AISTitle
    UNION ALL
    SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS AISID,
           AIS AS AISTitle
    FROM
    (SELECT DISTINCT AIS FROM #temp1 WHERE AIS IS NOT NULL) a
) b;

DELETE dbo.DimAIS
WHERE AISKey=-100

--***********************************************
BACKUP DATABASE [HospitalDW]
TO  DISK = N'D:\Ho\HospitalDW.bak'
WITH COMPRESSION,
     STATS = 1;
GO


