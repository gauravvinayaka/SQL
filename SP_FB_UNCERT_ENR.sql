USE [IR_DW]
GO

/****** Object:  StoredProcedure [dbo].[SP_FB_UNCERT_ENR_IRDW]    Script Date: 8/8/2017 1:32:13 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




--<Authors>              : <Gaurav Vinayaka>
--<Create date>          : <05/05/2017>
--<Altered date>         : <07/27/2017>
--<Altered date1>        : <08/01/2017>
--<Altered date2>        : <08/02/2017>
--<Altered date3>        : <08/02/2017>
--<Altered date4>        : <08/08/2017>
--<Altered date5>        : <08/10/2017>
--<Altered date6>        : <08/18/2017>
--<Purpose >             : <This is a new procedure that is created to display and compare Fall Uncertified Enrollment Numbers> 
--<Description>          : <Used to fetch Applied/Admitted for Factbook BY NEW FIRST-TIME FRESHMEN,AFRICAN AMERICAN,HISPANIC,CLASS RANK,UNDERGRADUATE TRANSFERS,NEW GRADUATE STUDENTS,DEGREES AWARDED,SEMESTER CREDIT HOURS,HEADCOUNT ENROLLMENT,ENROLLMENT BY HOME>
--<Altered Description>  : <Added %Change column in these blocks : NEW FIRST-TIME FRESHMEN,AFRICAN AMERICAN,HISPANIC,UNDERGRADUATE TRANSFERS,NEW GRADUATE STUDENTS,DEGREES AWARDED,SEMESTER CREDIT HOURS,HEADCOUNT ENROLLMENT,ENROLLMENT BY HOME>
--<Altered Description1> : <New logic for SEMESTER CREDIT HOURS block to match the counts>
--<Altered Description2> : <Added the RETENTION/GRADUATION RATE block>
--<Altered Description3> : <Added the %Change in RETENTION/GRADUATION RATE block>
--<Altered Description4> : <Added the order by clause to CLASS RANK,DEGREES AWARDED,SEMESTER CREDIT HOURS,HEADCOUNT ENROLLMENT,ENROLLMENT BY HOME blocks>
--<Altered Description5> : <Added replace functions to blocks to convert a number to a numeric, comma-separated formatted string>
--<Altered Description6> : <Added #Change column to CLASS RANK and RETENTION/GRADUATION RATE block>


 ALTER PROCEDURE [dbo].[SP_FB_UNCERT_ENR_IRDW]
 @Term int,
 @reportType varchar(20)
  
  AS
 
   BEGIN
 
    SET NOCOUNT ON;
   
-------------------------------------------------------------NEW FIRST-TIME FRESHMEN--------------------------------------------------------------------------------------------------------------------------------------		
IF @reportType = 'UNCERTNEWFRESH'--<08/10/2017>

BEGIN

Select 'Applications' as 'NEW FIRST-TIME FRESHMEN',replace(convert(varchar,convert(money,y.Last_Term),1),'.00','') as 'Last_Term',replace(convert(varchar,convert(money,y.Current_Term),1),'.00','') as 'Current_Term',
replace(convert(varchar,cast((y.Current_Term - y.Last_Term) as money),1),'.00','') as '#Change', 
cast(round((((CAST(y.Current_Term AS FLOAT)-CAST(y.Last_Term AS FLOAT))/(CAST(y.Last_Term AS FLOAT)))* 100),2) as varchar(10)) + '%' as '%Change'
from
(
SELECT    Case 
            when [ACADEMIC_PERIOD_ALL_SF_COMBINED] = @Term then 'Current_Term'
            when [ACADEMIC_PERIOD_ALL_SF_COMBINED] = @Term-10 then 'Last_Term'
         End      ACADEMIC_PERIOD_ALL_SF_COMBINED
      ,[APPLICATION_COUNT] Applied
  FROM [IR_DW].[dbo].[vw_dw_Applied_Admitted_Enrolled_F]
  where STUDENT_LEVEL ='UG'
  and STUDENT_POPULATION ='N'
  and ACADEMIC_PERIOD_ALL_SF_COMBINED between @Term-10 and @Term
  and ACADEMIC_PERIOD_ALL_SF_COMBINED like '%2') x  
  pivot
  (
  sum(Applied)
  for  ACADEMIC_PERIOD_ALL_SF_COMBINED in ([Current_Term] , [Last_Term])
  )y


  Union

Select 'Admitted' as 'NEW FIRST-TIME FRESHMEN', replace(convert(varchar,convert(money,y.Last_Term),1),'.00','') as 'Last_Term',replace(convert(varchar,convert(money,y.Current_Term),1),'.00','') as 'Current_Term',
replace(convert(varchar,cast((y.Current_Term - y.Last_Term) as money),1),'.00','') as '#Change', 
cast(round((((CAST(y.Current_Term AS FLOAT)-CAST(y.Last_Term AS FLOAT))/(CAST(y.Last_Term AS FLOAT)))* 100),2) as varchar(10)) + '%' as '%Change'
from
(
SELECT    Case 
            when [ACADEMIC_PERIOD_ALL_SF_COMBINED] = @Term then 'Current_Term'
            when [ACADEMIC_PERIOD_ALL_SF_COMBINED] = @Term-10 then 'Last_Term'
         End      ACADEMIC_PERIOD_ALL_SF_COMBINED 
      ,[ADMITTED_COUNT] Admitted
  FROM [IR_DW].[dbo].[vw_dw_Applied_Admitted_Enrolled_F]
  where STUDENT_LEVEL ='UG'
  and STUDENT_POPULATION ='N'
  and ACADEMIC_PERIOD_ALL_SF_COMBINED between @Term-10 and @Term
  and ACADEMIC_PERIOD_ALL_SF_COMBINED like '%2') x  
  pivot
  (
  sum(Admitted)
  for  ACADEMIC_PERIOD_ALL_SF_COMBINED in ([Current_Term] , [Last_Term])
  )y

  Union

Select 'Enrolled' as 'NEW FIRST-TIME FRESHMEN',replace(convert(varchar,convert(money,y.Last_Term),1),'.00','') as 'Last_Term',replace(convert(varchar,convert(money,y.Current_Term),1),'.00','') as 'Current_Term',
replace(convert(varchar,cast((y.Current_Term - y.Last_Term) as money),1),'.00','') as '#Change', 
cast(round((((CAST(y.Current_Term AS FLOAT)-CAST(y.Last_Term AS FLOAT))/(CAST(y.Last_Term AS FLOAT)))* 100),2) as varchar(10)) + '%' as '%Change'
from
(
SELECT    Case 
            when [ACADEMIC_PERIOD] = concat(@Term,'7') then 'Current_Term'
            when [ACADEMIC_PERIOD] = concat(@Term-10,'7') then 'Last_Term'
         End      ACADEMIC_PERIOD
      ,[ENROLLMENT_COUNT]Enrolled
  FROM [IR_DW].[dbo].[dw_Enrollment_F] e inner join dim_Student_Level sl on e.STUDENT_LEVEL_KEY = sl.STUDENT_LEVEL_KEY
  inner join dim_Student_Population sp on e.STUDENT_POPULATION_KEY = sp.STUDENT_POPULATION_KEY
  inner join dim_College c on e.COLLEGE_KEY = c.COLLEGE_KEY
  inner join dim_time dt  on e.time_key = dt.time_key
  where sl.STUDENT_LEVEL = 'UG' 
  and sp.STUDENT_POPULATION = 'N'
  and dt.ACADEMIC_PERIOD  between concat(@Term-10,'7') and concat(@Term,'7')
  and dt.ACADEMIC_PERIOD like '%7') x  
  pivot
  (
  sum(Enrolled)
  for  ACADEMIC_PERIOD in ([Current_Term] , [Last_Term])
  )y

END

-------------------------------------------------------------AFRICAN AMERICAN----------------------------------------------------------------------------------------------------------------------------------------	
ELSE IF @reportType = 'UNCERTAFRAMR'--<08/10/2017>

BEGIN

Select 'African American** Applied' as 'AFRICAN AMERICAN',replace(convert(varchar,convert(money,y.Last_Term),1),'.00','') as 'Last_Term',replace(convert(varchar,convert(money,y.Current_Term),1),'.00','') as 'Current_Term',
replace(convert(varchar,cast((y.Current_Term - y.Last_Term) as money),1),'.00','') as '#Change', 
cast(round((((CAST(y.Current_Term AS FLOAT)-CAST(y.Last_Term AS FLOAT))/(CAST(y.Last_Term AS FLOAT)))* 100),2) as varchar(10)) + '%' as '%Change'
from
(
SELECT    Case 
            when [ACADEMIC_PERIOD_ALL_SF_COMBINED] = @Term then 'Current_Term'
            when [ACADEMIC_PERIOD_ALL_SF_COMBINED] = @Term-10 then 'Last_Term'
         End      ACADEMIC_PERIOD_ALL_SF_COMBINED
      ,[APPLICATION_COUNT] Applied
  FROM [IR_DW].[dbo].[vw_dw_Applied_Admitted_Enrolled_F]
  where STUDENT_LEVEL ='UG'
  and STUDENT_POPULATION ='N'
   and ETHNICITY in ('AAM','B')
  and ACADEMIC_PERIOD_ALL_SF_COMBINED between @Term-10 and @Term
  and ACADEMIC_PERIOD_ALL_SF_COMBINED like '%2') x  
  pivot
  (
  sum(Applied)
  for  ACADEMIC_PERIOD_ALL_SF_COMBINED in ([Current_Term] , [Last_Term])
  )y

  Union

Select 'African American** Admitted' as 'Category',replace(convert(varchar,convert(money,y.Last_Term),1),'.00','') as 'Last_Term',replace(convert(varchar,convert(money,y.Current_Term),1),'.00','') as 'Current_Term',
replace(convert(varchar,cast((y.Current_Term - y.Last_Term) as money),1),'.00','') as '#Change', 
cast(round((((CAST(y.Current_Term AS FLOAT)-CAST(y.Last_Term AS FLOAT))/(CAST(y.Last_Term AS FLOAT)))* 100),2) as varchar(10)) + '%' as '%Change'
from
(
SELECT    Case 
            when [ACADEMIC_PERIOD_ALL_SF_COMBINED] = @Term then 'Current_Term'
            when [ACADEMIC_PERIOD_ALL_SF_COMBINED] = @Term-10 then 'Last_Term'
         End      ACADEMIC_PERIOD_ALL_SF_COMBINED
      ,[ADMITTED_COUNT] Admitted
  FROM [IR_DW].[dbo].[vw_dw_Applied_Admitted_Enrolled_F]
  where STUDENT_LEVEL ='UG'
  and STUDENT_POPULATION ='N'
  and ETHNICITY in ('AAM','B')
  and ACADEMIC_PERIOD_ALL_SF_COMBINED between @Term-10 and @Term
  and ACADEMIC_PERIOD_ALL_SF_COMBINED like '%2') x  
  pivot
  (
  sum(Admitted)
  for  ACADEMIC_PERIOD_ALL_SF_COMBINED in ([Current_Term] , [Last_Term])
  )y

  Union

Select 'African American** Enrolled' as 'Category',replace(convert(varchar,convert(money,y.Last_Term),1),'.00','') as 'Last_Term',replace(convert(varchar,convert(money,y.Current_Term),1),'.00','') as 'Current_Term',
replace(convert(varchar,cast((y.Current_Term - y.Last_Term) as money),1),'.00','') as '#Change', 
cast(round((((CAST(y.Current_Term AS FLOAT)-CAST(y.Last_Term AS FLOAT))/(CAST(y.Last_Term AS FLOAT)))* 100),2) as varchar(10)) + '%' as '%Change'
from
(
SELECT    Case 
            when [ACADEMIC_PERIOD] = concat(@Term,'7') then 'Current_Term'
            when [ACADEMIC_PERIOD] = concat(@Term-10,'7') then 'Last_Term'
         End      ACADEMIC_PERIOD
      ,[ENROLLMENT_COUNT]Enrolled
  FROM [IR_DW].[dbo].[dw_Enrollment_F] e inner join dim_Student_Level sl on e.STUDENT_LEVEL_KEY = sl.STUDENT_LEVEL_KEY
  inner join dim_Student_Population sp on e.STUDENT_POPULATION_KEY = sp.STUDENT_POPULATION_KEY
  inner join dim_Ethnicity y on e.ETHNICITY_KEY = y.ETHNICITY_KEY
  inner join dim_College c on e.COLLEGE_KEY = c.COLLEGE_KEY
  inner join dim_time dt  on e.time_key = dt.time_key
  where sl.STUDENT_LEVEL = 'UG' 
  and sp.STUDENT_POPULATION = 'N'
  and Y.ETHNICITY in ('AAM','B')
  and dt.ACADEMIC_PERIOD  between concat(@Term-10,'7') and concat(@Term,'7')
  and dt.ACADEMIC_PERIOD like '%7') x  
  pivot
  (
  sum(Enrolled)
  for  ACADEMIC_PERIOD in ([Current_Term] , [Last_Term])
  )y


END
----------------------------------------------------------------HISPANIC--------------------------------------------------------------------------------------------------------------------------------------------------------
ELSE IF @reportType = 'UNCERTHISPANIC'--<08/10/2017>
BEGIN

Select 'Hispanic Applied' as 'HISPANIC',replace(convert(varchar,convert(money,y.Last_Term),1),'.00','') as 'Last_Term',replace(convert(varchar,convert(money,y.Current_Term),1),'.00','') as 'Current_Term',
replace(convert(varchar,cast((y.Current_Term - y.Last_Term) as money),1),'.00','') as '#Change', 
cast(round((((CAST(y.Current_Term AS FLOAT)-CAST(y.Last_Term AS FLOAT))/(CAST(y.Last_Term AS FLOAT)))* 100),2) as varchar(10)) + '%' as '%Change'
from
(
SELECT    Case 
            when [ACADEMIC_PERIOD_ALL_SF_COMBINED] = @Term then 'Current_Term'
            when [ACADEMIC_PERIOD_ALL_SF_COMBINED] = @Term-10 then 'Last_Term'
         End      ACADEMIC_PERIOD_ALL_SF_COMBINED
      ,[APPLICATION_COUNT] Applied
  FROM [IR_DW].[dbo].[vw_dw_Applied_Admitted_Enrolled_F]
  where STUDENT_LEVEL ='UG'
  and STUDENT_POPULATION ='N'
    and ETHNICITY = 'HI'
  and ACADEMIC_PERIOD_ALL_SF_COMBINED between @Term-10 and @Term
  and ACADEMIC_PERIOD_ALL_SF_COMBINED like '%2') x  
  pivot
  (
  sum(Applied)
  for  ACADEMIC_PERIOD_ALL_SF_COMBINED in ([Current_Term] , [Last_Term])
  )y

  Union

Select 'Hispanic Admitted' as 'Category',replace(convert(varchar,convert(money,y.Last_Term),1),'.00','') as 'Last_Term',replace(convert(varchar,convert(money,y.Current_Term),1),'.00','') as 'Current_Term',
replace(convert(varchar,cast((y.Current_Term - y.Last_Term) as money),1),'.00','') as '#Change', 
cast(round((((CAST(y.Current_Term AS FLOAT)-CAST(y.Last_Term AS FLOAT))/(CAST(y.Last_Term AS FLOAT)))* 100),2) as varchar(10)) + '%' as '%Change'
from
(
SELECT    Case 
            when [ACADEMIC_PERIOD_ALL_SF_COMBINED] = @Term then 'Current_Term'
            when [ACADEMIC_PERIOD_ALL_SF_COMBINED] = @Term-10 then 'Last_Term'
         End      ACADEMIC_PERIOD_ALL_SF_COMBINED
      ,[ADMITTED_COUNT] Admitted
  FROM [IR_DW].[dbo].[vw_dw_Applied_Admitted_Enrolled_F]
  where STUDENT_LEVEL ='UG'
  and STUDENT_POPULATION ='N'
  and ETHNICITY = 'HI'
  and ACADEMIC_PERIOD_ALL_SF_COMBINED between @Term-10 and @Term
  and ACADEMIC_PERIOD_ALL_SF_COMBINED like '%2') x  
  pivot
  (
  sum(Admitted)
  for  ACADEMIC_PERIOD_ALL_SF_COMBINED in ([Current_Term] , [Last_Term])
  )y

  Union


Select 'Hispanic Enrolled' as 'Category',replace(convert(varchar,convert(money,y.Last_Term),1),'.00','') as 'Last_Term',replace(convert(varchar,convert(money,y.Current_Term),1),'.00','') as 'Current_Term',
replace(convert(varchar,cast((y.Current_Term - y.Last_Term) as money),1),'.00','') as '#Change', 
cast(round((((CAST(y.Current_Term AS FLOAT)-CAST(y.Last_Term AS FLOAT))/(CAST(y.Last_Term AS FLOAT)))* 100),2) as varchar(10)) + '%' as '%Change'
from
(
SELECT    Case 
            when [ACADEMIC_PERIOD] = concat(@Term,'7') then 'Current_Term'
            when [ACADEMIC_PERIOD] = concat(@Term-10,'7') then 'Last_Term'
         End      ACADEMIC_PERIOD
      ,[ENROLLMENT_COUNT]Enrolled
  FROM [IR_DW].[dbo].[dw_Enrollment_F] e inner join dim_Student_Level sl on e.STUDENT_LEVEL_KEY = sl.STUDENT_LEVEL_KEY
			inner join dim_Student_Population sp on e.STUDENT_POPULATION_KEY = sp.STUDENT_POPULATION_KEY
			inner join dim_Ethnicity y on e.ETHNICITY_KEY = y.ETHNICITY_KEY
			inner join dim_College c on e.COLLEGE_KEY = c.COLLEGE_KEY
			inner join dim_time dt  on e.time_key = dt.time_key
			where sl.STUDENT_LEVEL = 'UG' 
			and sp.STUDENT_POPULATION = 'N'
			and Y.ETHNICITY = 'HI'
  and dt.ACADEMIC_PERIOD  between concat(@Term-10,'7') and concat(@Term,'7')
  and dt.ACADEMIC_PERIOD like '%7') x  
  pivot
  (
  sum(Enrolled)
  for  ACADEMIC_PERIOD in ([Current_Term] , [Last_Term])
  )y

END


-----------------------------------------------------------------CLASS RANK-------------------------------------------------------------------------------------------------------------------------------------------------------------------
ELSE IF @reportType = 'UNCERTCLASSRANK' --<08/18/2017>
BEGIN
declare @Term int = 20172
select [CLASS RANK***],[Last_Term] , [Current_Term] ,'' as #Change, [%Change] from 
(select distinct dt1.[CLASS RANK***],
cast(Round(((CAST(dt1.Last_Term AS FLOAT))*1),2) as varchar(10)) + '%'  as 'Last_Term',
cast(Round(((CAST(dt2.Current_term AS FLOAT))*1),2) as varchar(10)) + '%'  as 'Current_Term',
cast(round(((CAST(dt2.Current_Term AS FLOAT)-CAST(dt1.Last_Term AS FLOAT))*1),2) as varchar(10)) + '%'  as '%Change' from 
(SELECT distinct    CASE
                       WHEN HSRANK IN ( 'T5', 'T10')            THEN 'Top 10%'
                       WHEN HSRANK IN ( 'T15', 'T20', 'T25')    THEN 'Top 11 - 25%'
                       WHEN HSRANK = 'Q2'                       THEN '2nd Quarter'
                       WHEN HSRANK = 'Q3'                       THEN '3rd Quarter'
                       WHEN HSRANK = 'Q4'                       THEN '4th Quarter'
                       ELSE HSRANK
                   END AS 'CLASS RANK***',
                        round( Count(*) OVER (PARTITION BY CASE
                                              WHEN HSRANK IN ( 'T5', 'T10')            THEN 'Top 10%'
                                              WHEN HSRANK IN ( 'T15', 'T20', 'T25')    THEN 'Top 11 - 25%'
                                              WHEN HSRANK = 'Q2'                       THEN '2nd Quarter'
                                              WHEN HSRANK = 'Q3'                       THEN '3rd Quarter'
                                              WHEN HSRANK = 'Q4'                       THEN '4th Quarter'
                                              ELSE HSRANK
                                          END)*100/Cast(Count(*) OVER (PARTITION BY ACADEMIC_PERIOD) AS float), 2) as 'Last_Term',hsrank
           FROM dw_Enrollment_F t1
                 JOIN [IR_DW].[dbo].[vw_dim_HSRank] t2 ON t1.HSRANK_KEY = t2.HSRANK_KEY
                 JOIN dim_Time t3 ON t3.TIME_KEY = t1.TIME_KEY
                 JOIN dim_Student_Level t4 ON t4.STUDENT_LEVEL_KEY = t1.STUDENT_LEVEL_KEY
                 JOIN dim_Student_Population t5 ON t5.STUDENT_POPULATION_KEY = t1.STUDENT_POPULATION_KEY
            WHERE STUDENT_LEVEL = 'UG'
                  AND STUDENT_POPULATION = 'N'
                  AND ACADEMIC_PERIOD_ALL = @Term-10
                  AND HSRANK != 'U') dt1 inner join
				  
(SELECT distinct    CASE
                       WHEN HSRANK IN ( 'T5', 'T10')            THEN 'Top 10%'
                       WHEN HSRANK IN ( 'T15', 'T20', 'T25')    THEN 'Top 11 - 25%'
                       WHEN HSRANK = 'Q2'                       THEN '2nd Quarter'
                       WHEN HSRANK = 'Q3'                       THEN '3rd Quarter'
                       WHEN HSRANK = 'Q4'                       THEN '4th Quarter'
                       ELSE HSRANK
                   END AS 'CLASS RANK***',
                        round( Count(*) OVER (PARTITION BY CASE
                                              WHEN HSRANK IN ( 'T5', 'T10')            THEN 'Top 10%'
                                              WHEN HSRANK IN ( 'T15', 'T20', 'T25')    THEN 'Top 11 - 25%'
                                              WHEN HSRANK = 'Q2'                       THEN '2nd Quarter'
                                              WHEN HSRANK = 'Q3'                       THEN '3rd Quarter'
                                              WHEN HSRANK = 'Q4'                       THEN '4th Quarter'
                                              ELSE HSRANK
                                          END)*100/Cast(Count(*) OVER (PARTITION BY ACADEMIC_PERIOD) AS float), 2) as  'Current_Term' , hsrank
           FROM dw_Enrollment_F t1
                 JOIN [IR_DW].[dbo].[vw_dim_HSRank] t2 ON t1.HSRANK_KEY = t2.HSRANK_KEY
                 JOIN dim_Time t3 ON t3.TIME_KEY = t1.TIME_KEY
                 JOIN dim_Student_Level t4 ON t4.STUDENT_LEVEL_KEY = t1.STUDENT_LEVEL_KEY
                 JOIN dim_Student_Population t5 ON t5.STUDENT_POPULATION_KEY = t1.STUDENT_POPULATION_KEY
            WHERE STUDENT_LEVEL = 'UG'
                  AND STUDENT_POPULATION = 'N'
                  AND ACADEMIC_PERIOD_ALL = @Term
                  AND HSRANK != 'U') dt2 on dt1.hsrank = dt2.hsrank)a

				  order by
 case when a.[CLASS RANK***] = 'Top 10%' then 1 
      when a.[CLASS RANK***] = 'Top 11 - 25%' then 2 
	  when a.[CLASS RANK***] = '2nd Quarter' then 3 
	  when a.[CLASS RANK***] = '3rd Quarter' then 4 
	  when a.[CLASS RANK***] = '4th Quarter' then 5 END




END


--------------------------------------------------------UNDERGRADUATE TRANSFERS--------------------------------------------------------------------------------------------------------------------------------------	
ELSE IF @reportType = 'UNCERTUNDERGRAD'--<08/10/2017>
BEGIN

Select 'Applications' as 'UNDERGRADUATE TRANSFERS',replace(convert(varchar,convert(money,y.Last_Term),1),'.00','') as 'Last_Term',replace(convert(varchar,convert(money,y.Current_Term),1),'.00','') as 'Current_Term',
replace(convert(varchar,cast((y.Current_Term - y.Last_Term) as money),1),'.00','') as '#Change', 
cast(round((((CAST(y.Current_Term AS FLOAT)-CAST(y.Last_Term AS FLOAT))/(CAST(y.Last_Term AS FLOAT)))* 100),2) as varchar(10)) + '%' as '%Change'
from
(
SELECT    Case 
            when [ACADEMIC_PERIOD_ALL_SF_COMBINED] = @Term then 'Current_Term'
            when [ACADEMIC_PERIOD_ALL_SF_COMBINED] = @Term-10 then 'Last_Term'
         End      ACADEMIC_PERIOD_ALL_SF_COMBINED
      ,[APPLICATION_COUNT] Applied
  FROM [IR_DW].[dbo].[vw_dw_Applied_Admitted_Enrolled_F]
  where STUDENT_LEVEL ='UG'
  and STUDENT_POPULATION ='T'
  and ACADEMIC_PERIOD_ALL_SF_COMBINED between @Term-10 and @Term
  and ACADEMIC_PERIOD_ALL_SF_COMBINED like '%2') x  
  pivot
  (
  sum(Applied)
  for  ACADEMIC_PERIOD_ALL_SF_COMBINED in ([Current_Term] , [Last_Term])
  )y

  Union

Select 'Admitted' as 'UNDERGRADUATE TRANSFERS',replace(convert(varchar,convert(money,y.Last_Term),1),'.00','') as 'Last_Term',replace(convert(varchar,convert(money,y.Current_Term),1),'.00','') as 'Current_Term',
replace(convert(varchar,cast((y.Current_Term - y.Last_Term) as money),1),'.00','') as '#Change', 
cast(round((((CAST(y.Current_Term AS FLOAT)-CAST(y.Last_Term AS FLOAT))/(CAST(y.Last_Term AS FLOAT)))* 100),2) as varchar(10)) + '%' as '%Change'
from
(
SELECT    Case 
            when [ACADEMIC_PERIOD_ALL_SF_COMBINED] = @Term then 'Current_Term'
            when [ACADEMIC_PERIOD_ALL_SF_COMBINED] = @Term-10 then 'Last_Term'
         End      ACADEMIC_PERIOD_ALL_SF_COMBINED
      ,[ADMITTED_COUNT] Admitted
  FROM [IR_DW].[dbo].[vw_dw_Applied_Admitted_Enrolled_F]
  where STUDENT_LEVEL ='UG'
  and STUDENT_POPULATION ='T'
  and ACADEMIC_PERIOD_ALL_SF_COMBINED between @Term-10 and @Term
  and ACADEMIC_PERIOD_ALL_SF_COMBINED like '%2') x  
  pivot
  (
  sum(Admitted)
  for  ACADEMIC_PERIOD_ALL_SF_COMBINED in ([Current_Term] , [Last_Term])
  )y

  Union

Select 'Enrolled' as 'UNDERGRADUATE TRANSFERS',replace(convert(varchar,convert(money,y.Last_Term),1),'.00','') as 'Last_Term',replace(convert(varchar,convert(money,y.Current_Term),1),'.00','') as 'Current_Term',
replace(convert(varchar,cast((y.Current_Term - y.Last_Term) as money),1),'.00','') as '#Change', 
cast(round((((CAST(y.Current_Term AS FLOAT)-CAST(y.Last_Term AS FLOAT))/(CAST(y.Last_Term AS FLOAT)))* 100),2) as varchar(10)) + '%' as '%Change'
from
(
SELECT    Case 
            when [ACADEMIC_PERIOD] = concat(@Term,'7') then 'Current_Term'
            when [ACADEMIC_PERIOD] = concat(@Term-10,'7') then 'Last_Term'
         End      ACADEMIC_PERIOD
      ,[ENROLLMENT_COUNT]Enrolled
  FROM [IR_DW].[dbo].[dw_Enrollment_F] e inner join dim_Student_Level sl on e.STUDENT_LEVEL_KEY = sl.STUDENT_LEVEL_KEY
  inner join dim_Student_Population sp on e.STUDENT_POPULATION_KEY = sp.STUDENT_POPULATION_KEY
  inner join dim_College c on e.COLLEGE_KEY = c.COLLEGE_KEY
  inner join dim_time dt  on e.time_key = dt.time_key
  where sl.STUDENT_LEVEL = 'UG' 
  and sp.STUDENT_POPULATION = 'T'
  and dt.ACADEMIC_PERIOD  between concat(@Term-10,'7') and concat(@Term,'7')
  and dt.ACADEMIC_PERIOD like '%7') x  
  pivot
  (
  sum(Enrolled)
  for  ACADEMIC_PERIOD in ([Current_Term] , [Last_Term])
  )y

END
 -------------------------------------------------------NEW GRADUATE STUDENTS----------------------------------------------------------------------------------------------------------------------------------------------------------------------
ELSE IF @reportType = 'UNCERTGRAD'--<08/10/2017>

BEGIN

Select 'Total Applied' as 'Category',replace(convert(varchar,convert(money,y.Last_Term),1),'.00','') as 'Last_Term',replace(convert(varchar,convert(money,y.Current_Term),1),'.00','') as 'Current_Term',
replace(convert(varchar,cast((y.Current_Term - y.Last_Term) as money),1),'.00','') as '#Change', 
cast(round((((CAST(y.Current_Term AS FLOAT)-CAST(y.Last_Term AS FLOAT))/(CAST(y.Last_Term AS FLOAT)))* 100),2) as varchar(10)) + '%' as '%Change'
from
(
SELECT    Case
            when [ACADEMIC_PERIOD_ALL_SF_COMBINED] = @Term then 'Current_Term'
            when [ACADEMIC_PERIOD_ALL_SF_COMBINED] = @Term-10 then 'Last_Term'
         End      ACADEMIC_PERIOD_ALL_SF_COMBINED
      ,[APPLICATION_COUNT] Applied
  FROM [IR_DW].[dbo].[vw_dw_Applied_Admitted_Enrolled_F] 
                     where   STUDENT_LEVEL = 'GR'
                     and STUDENT_POPULATION = 'N'
  and ACADEMIC_PERIOD_ALL_SF_COMBINED between @Term-10 and @Term
  and ACADEMIC_PERIOD_ALL_SF_COMBINED like '%2') x 
  pivot
  (
  sum(Applied)
  for  ACADEMIC_PERIOD_ALL_SF_COMBINED in ([Current_Term] , [Last_Term])
  )y
 
  Union
 
Select 'Total Admitted' as 'Category',replace(convert(varchar,convert(money,y.Last_Term),1),'.00','') as 'Last_Term',replace(convert(varchar,convert(money,y.Current_Term),1),'.00','') as 'Current_Term',
replace(convert(varchar,cast((y.Current_Term - y.Last_Term) as money),1),'.00','') as '#Change', 
cast(round((((CAST(y.Current_Term AS FLOAT)-CAST(y.Last_Term AS FLOAT))/(CAST(y.Last_Term AS FLOAT)))* 100),2) as varchar(10)) + '%' as '%Change'
from
(
SELECT    Case
            when [ACADEMIC_PERIOD_ALL_SF_COMBINED] = @Term then 'Current_Term'
            when [ACADEMIC_PERIOD_ALL_SF_COMBINED] = @Term-10 then 'Last_Term'
         End      ACADEMIC_PERIOD_ALL_SF_COMBINED
      ,[ADMITTED_COUNT] Admitted
  FROM [IR_DW].[dbo].[vw_dw_Applied_Admitted_Enrolled_F]
                     where   STUDENT_LEVEL = 'GR'
                     and STUDENT_POPULATION = 'N'
  and ACADEMIC_PERIOD_ALL_SF_COMBINED between @Term-10 and @Term
  and ACADEMIC_PERIOD_ALL_SF_COMBINED like '%2') x 
  pivot
  (
  sum(Admitted)
  for  ACADEMIC_PERIOD_ALL_SF_COMBINED in ([Current_Term] , [Last_Term])
  )y
 
  Union
 
Select 'Total New Graduate Enrolled' as 'Category',replace(convert(varchar,convert(money,y.Last_Term),1),'.00','') as 'Last_Term',replace(convert(varchar,convert(money,y.Current_Term),1),'.00','') as 'Current_Term',
replace(convert(varchar,cast((y.Current_Term - y.Last_Term) as money),1),'.00','') as '#Change', 
cast(round((((CAST(y.Current_Term AS FLOAT)-CAST(y.Last_Term AS FLOAT))/(CAST(y.Last_Term AS FLOAT)))* 100),2) as varchar(10)) + '%' as '%Change'
from
(
SELECT    Case
            when [ACADEMIC_PERIOD] = concat(@Term,'7') then 'Current_Term'
            when [ACADEMIC_PERIOD] = concat(@Term-10,'7') then 'Last_Term'
         End      ACADEMIC_PERIOD
      ,[ENROLLMENT_COUNT]Enrolled
  FROM [IR_DW].[dbo].[dw_Enrollment_F] e inner join dim_Student_Level sl on e.STUDENT_LEVEL_KEY = sl.STUDENT_LEVEL_KEY
  inner join dim_Student_Population sp on e.STUDENT_POPULATION_KEY = sp.STUDENT_POPULATION_KEY
  inner join dim_College c on e.COLLEGE_KEY = c.COLLEGE_KEY
  inner join dim_time dt  on e.time_key = dt.time_key
  where sl.STUDENT_LEVEL = 'GR'
  and sp.STUDENT_POPULATION = 'N'
  and dt.ACADEMIC_PERIOD  between concat(@Term-10,'7') and concat(@Term,'7')
  and dt.ACADEMIC_PERIOD like '%7') x 
  pivot
  (
  sum(Enrolled)
  for  ACADEMIC_PERIOD in ([Current_Term] , [Last_Term])
  )y
   Union
 
Select 'Total Graduate Enrolled' as 'Category',replace(convert(varchar,convert(money,y.Last_Term),1),'.00','') as 'Last_Term',replace(convert(varchar,convert(money,y.Current_Term),1),'.00','') as 'Current_Term',
replace(convert(varchar,cast((y.Current_Term - y.Last_Term) as money),1),'.00','') as '#Change', 
cast(round((((CAST(y.Current_Term AS FLOAT)-CAST(y.Last_Term AS FLOAT))/(CAST(y.Last_Term AS FLOAT)))* 100),2) as varchar(10)) + '%' as '%Change'
from
(
SELECT    Case
            when [ACADEMIC_PERIOD] = concat(@Term,'7') then 'Current_Term'
            when [ACADEMIC_PERIOD] = concat(@Term-10,'7') then 'Last_Term'
         End      ACADEMIC_PERIOD
      ,[ENROLLMENT_COUNT]Enrolled
  FROM [IR_DW].[dbo].[dw_Enrollment_F] e inner join dim_Student_Level sl on e.STUDENT_LEVEL_KEY = sl.STUDENT_LEVEL_KEY
  inner join dim_Student_Population sp on e.STUDENT_POPULATION_KEY = sp.STUDENT_POPULATION_KEY
  inner join dim_College c on e.COLLEGE_KEY = c.COLLEGE_KEY
  inner join dim_time dt  on e.time_key = dt.time_key
  where sl.STUDENT_LEVEL = 'GR'
  and dt.ACADEMIC_PERIOD  between concat(@Term-10,'7') and concat(@Term,'7')
  and dt.ACADEMIC_PERIOD like '%7') x 
  pivot
  (
  sum(Enrolled)
  for  ACADEMIC_PERIOD in ([Current_Term] , [Last_Term])
  )y

END

-------------------------------------------------------RETENTION/GRADUATION RATE----------------------------------------------------------------------------------------------------------------------------------------------------------------------
IF @reportType = 'UNCERTRETGRAD'--<08/18/2017>

BEGIN
declare @Term int = 20172;
WITH tbl AS 
(Select dt1.Year,dt1.y1ret as [1-Year Retention],dt2.y2ret as [2-Year Retention],dt4.y4grad as [4-Year Retention],dt5.y5grad as [5-Year Retention],dt6.y6grad as [6-Year Retention] from
(select case WHEN (CONVERT(INT,SUBSTRING(ACADEMIC_PERIOD_all,1,4))) =LEFT(@Term,4)-2 then LEFT(@Term,1)-2 WHEN (CONVERT(INT,SUBSTRING(ACADEMIC_PERIOD_all,1,4))) =LEFT(@Term,4)-1 then LEFT(@Term,1)-1 else (CONVERT(INT,SUBSTRING(ACADEMIC_PERIOD_all,1,4)))  end  as 'Year',
                                  cast(convert(varchar,(Convert(Money,SUM(rg.RET1_FF),1)/Convert(Money,SUM(rg.COHORT_COUNT),1))*100,1) as varchar(10)) as  y1ret
								
								  from vw_Retention_Graduation_F rg
                                  inner join dim_Time t
                                  on rg.TIME_KEY = t.TIME_KEY
                                  inner join dim_Part_Full pf
                                  on rg.PART_FULL_KEY=pf.PART_FULL_KEY
                                  inner join dim_Student_Level sl
                                  on rg.STUDENT_LEVEL_KEY=SL.STUDENT_LEVEL_KEY
                                  inner join dim_Student_Population sp
                                  on rg.STUDENT_POPULATION_KEY=sp.STUDENT_POPULATION_KEY
                                  inner join dim_College c
                                  on rg.COLLEGE_KEY = c.COLLEGE_KEY
                                  WHERE t.ACADEMIC_PERIOD_ALL between @Term-20 and @Term-10
                                  AND pf.PART_FULL = 'F'
                                  AND sl.STUDENT_LEVEL = 'UG'
                                  AND sp.STUDENT_POPULATION = 'N'
                                  GROUP BY (CONVERT(INT,SUBSTRING(ACADEMIC_PERIOD_all,1,4)) ) ) dt1 inner join
(select case WHEN (CONVERT(INT,SUBSTRING(ACADEMIC_PERIOD_all,1,4))) =LEFT(@Term,4)-3 then LEFT(@Term,1)-2 WHEN (CONVERT(INT,SUBSTRING(ACADEMIC_PERIOD_all,1,4))) =LEFT(@Term,4)-2 then LEFT(@Term,1)-1 else (CONVERT(INT,SUBSTRING(ACADEMIC_PERIOD_all,1,4)))  end  as 'Year',
                                  cast(convert(varchar,(Convert(Money,SUM(rg.RET2_FF),1)/Convert(Money,SUM(rg.COHORT_COUNT),1))*100,1) as varchar(10))  as  y2ret         
                                  from vw_Retention_Graduation_F rg
                                  inner join dim_Time t
                                  on rg.TIME_KEY = t.TIME_KEY
                                  inner join dim_Part_Full pf
                                  on rg.PART_FULL_KEY=pf.PART_FULL_KEY
                                  inner join dim_Student_Level sl
                                  on rg.STUDENT_LEVEL_KEY=SL.STUDENT_LEVEL_KEY
                                  inner join dim_Student_Population sp
                                  on rg.STUDENT_POPULATION_KEY=sp.STUDENT_POPULATION_KEY
                                  inner join dim_College c
                                  on rg.COLLEGE_KEY = c.COLLEGE_KEY
                                  WHERE t.ACADEMIC_PERIOD_ALL between @Term-30 and @Term-20
                                  AND pf.PART_FULL = 'F'
                                  AND sl.STUDENT_LEVEL = 'UG'
                                  AND sp.STUDENT_POPULATION = 'N'
                                  GROUP BY (CONVERT(INT,SUBSTRING(ACADEMIC_PERIOD_all,1,4)) ) ) dt2 on dt1.Year = dt2.year
					              inner join
(select case WHEN (CONVERT(INT,SUBSTRING(ACADEMIC_PERIOD_all,1,4))) =LEFT(@Term,4)-5 then LEFT(@Term,1)-2 WHEN (CONVERT(INT,SUBSTRING(ACADEMIC_PERIOD_all,1,4))) =LEFT(@Term,4)-4 then LEFT(@Term,1)-1 else (CONVERT(INT,SUBSTRING(ACADEMIC_PERIOD_all,1,4)))  end  as 'Year',
                                  cast(convert(varchar,(Convert(Money,SUM(rg.GRAD4_FF),1)/Convert(Money,SUM(rg.COHORT_COUNT),1))*100,1) as varchar(10))  as y4grad         
                                  from vw_Retention_Graduation_F rg
                                  inner join dim_Time t
                                  on rg.TIME_KEY = t.TIME_KEY
                                  inner join dim_Part_Full pf
                                  on rg.PART_FULL_KEY=pf.PART_FULL_KEY
                                  inner join dim_Student_Level sl
                                  on rg.STUDENT_LEVEL_KEY=SL.STUDENT_LEVEL_KEY
                                  inner join dim_Student_Population sp
                                  on rg.STUDENT_POPULATION_KEY=sp.STUDENT_POPULATION_KEY
                                  inner join dim_College c
                                  on rg.COLLEGE_KEY = c.COLLEGE_KEY
                                  WHERE t.ACADEMIC_PERIOD_ALL between @Term-50 and @Term-40
                                  AND pf.PART_FULL = 'F'
                                  AND sl.STUDENT_LEVEL = 'UG'
                                  AND sp.STUDENT_POPULATION = 'N'
                                  GROUP BY (CONVERT(INT,SUBSTRING(ACADEMIC_PERIOD_all,1,4)) ) ) dt4 on dt2.Year = dt4.year
					              inner join
(select case WHEN (CONVERT(INT,SUBSTRING(ACADEMIC_PERIOD_all,1,4))) =LEFT(@Term,4)-6 then LEFT(@Term,1)-2 WHEN (CONVERT(INT,SUBSTRING(ACADEMIC_PERIOD_all,1,4))) =LEFT(@Term,4)-5 then LEFT(@Term,1)-1 else (CONVERT(INT,SUBSTRING(ACADEMIC_PERIOD_all,1,4)))  end  as 'Year',
                                  cast(convert(varchar,(Convert(Money,SUM(rg.GRAD5_FF),1)/Convert(Money,SUM(rg.COHORT_COUNT),1))*100,1) as varchar(10))  as y5grad        
                                  from vw_Retention_Graduation_F rg
                                  inner join dim_Time t
                                  on rg.TIME_KEY = t.TIME_KEY
                                  inner join dim_Part_Full pf
                                  on rg.PART_FULL_KEY=pf.PART_FULL_KEY
                                  inner join dim_Student_Level sl
                                  on rg.STUDENT_LEVEL_KEY=SL.STUDENT_LEVEL_KEY
                                  inner join dim_Student_Population sp
                                  on rg.STUDENT_POPULATION_KEY=sp.STUDENT_POPULATION_KEY
                                  inner join dim_College c
                                  on rg.COLLEGE_KEY = c.COLLEGE_KEY
                                  WHERE t.ACADEMIC_PERIOD_ALL between @Term-60 and @Term-50
                                  AND pf.PART_FULL = 'F'
                                  AND sl.STUDENT_LEVEL = 'UG'
                                  AND sp.STUDENT_POPULATION = 'N'
                                  GROUP BY (CONVERT(INT,SUBSTRING(ACADEMIC_PERIOD_all,1,4)) ) ) dt5 on dt4.Year = dt5.year
				                  inner join
(select case WHEN (CONVERT(INT,SUBSTRING(ACADEMIC_PERIOD_all,1,4))) =LEFT(@Term,4)-7 then LEFT(@Term,1)-2 WHEN (CONVERT(INT,SUBSTRING(ACADEMIC_PERIOD_all,1,4))) =LEFT(@Term,4)-6 then LEFT(@Term,1)-1 else (CONVERT(INT,SUBSTRING(ACADEMIC_PERIOD_all,1,4)))  end  as 'Year',
                                  cast(convert(varchar,(Convert(Money,SUM(rg.GRAD6_FF),1)/Convert(Money,SUM(rg.COHORT_COUNT),1))*100,1) as varchar(10))  as  y6grad         
                                  from vw_Retention_Graduation_F rg
                                  inner join dim_Time t
                                  on rg.TIME_KEY = t.TIME_KEY
                                  inner join dim_Part_Full pf
                                  on rg.PART_FULL_KEY=pf.PART_FULL_KEY
                                  inner join dim_Student_Level sl
                                  on rg.STUDENT_LEVEL_KEY=SL.STUDENT_LEVEL_KEY
                                  inner join dim_Student_Population sp
                                  on rg.STUDENT_POPULATION_KEY=sp.STUDENT_POPULATION_KEY
                                  inner join dim_College c
                                  on rg.COLLEGE_KEY = c.COLLEGE_KEY
                                  WHERE t.ACADEMIC_PERIOD_ALL between @Term-70 and @Term-60
                                  AND pf.PART_FULL = 'F'
                                  AND sl.STUDENT_LEVEL = 'UG'
                                  AND sp.STUDENT_POPULATION = 'N'
                                  GROUP BY (CONVERT(INT,SUBSTRING(ACADEMIC_PERIOD_all,1,4)) ) ) dt6 on dt5.Year = dt6.year 

)

select RetGradrate,cast([0] as varchar)+'%' as 'Last_Term',cast([1] as varchar)+'%' as 'Current_Term', 
'' as #Change, cast((cast([1] as float)-cast([0] as float)) as varchar(10)) + '%' as '%Change' 

  from (
  select year, RetGradrate, value
  from tbl
  unpivot
  (
    value
    for RetGradrate in ([1-year retention], [2-Year Retention], [4-Year Retention], [5-Year Retention], [6-Year Retention])
  ) AS unpiv
  
) src
pivot
(
  max(value)
  for year in ([0], [1])
) piv

END
 ----------------------------------------------------------DEGREES AWARDED------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 
 ELSE IF @reportType = 'UNCERTDEG'--<08/10/2017>
 BEGIN

select [Category],[Last_Term] , [Current_Term] , [#Change],[%Change] from 
(
 Select [Category],replace(convert(varchar,convert(money,y.Last_Term),1),'.00','') as 'Last_Term',replace(convert(varchar,convert(money,y.Current_Term),1),'.00','') as 'Current_Term',
replace(convert(varchar,cast((y.Current_Term - y.Last_Term) as money),1),'.00','') as '#Change', 
cast(round((((CAST(y.Current_Term AS FLOAT)-CAST(y.Last_Term AS FLOAT))/(CAST(y.Last_Term AS FLOAT)))* 100),2) as varchar(10)) + '%' as '%Change'
from

  (
 
 Select
  Category,
Case
        when year = substring(CAST (@Term- 10  as Varchar(10)),1,4) then 'Current_Term'
            when year = substring(CAST (@Term - 20 as Varchar(10)),1,4) then 'Last_Term'
			END AS ACAD_YEAR , a.enroll 
		
			from
  (
  select case when ac.AWARD_CATEGORY = '42' or  ac.AWARD_CATEGORY = '44' Then 'Graduate' 
  When ac.AWARD_CATEGORY = '24' THEN 'Undergraduate' 
  When ac.AWARD_CATEGORY = '31' THEN 'Law'
  END AS Category , (CONVERT(Varchar(10),SUBSTRING(ACADEMIC_PERIOD,1,4))) as year , count(*) as enroll
 FROM [IR_DW].[dbo].[dw_Degree_F] df
			inner join dim_Degree d
			on df.DEGREE_KEY = d.DEGREE_KEY
            INNER JOIN dim_College c
            ON df.COLLEGE_KEY= c.COLLEGE_KEY
            inner join dim_Time t
            on df.TIME_KEY = t.TIME_KEY
            inner join dim_Award_Category ac
            on df.AWARD_CATEGORY_KEY= ac.AWARD_CATEGORY_KEY
					Where ACADEMIC_YEAR in (substring(CAST(@Term-20 AS VARCHAR(10)),1,4) , substring(CAST(@Term-10 as VARCHAR(10)),1,4))
								and df.AWARD_CATEGORY_KEY not in( '1','4') 
			and d.DEGREE Not In ('ND','CER') and ac.AWARD_CATEGORY in ('42','24','31','44')
					group by ac.AWARD_CATEGORY, (CONVERT(Varchar(10),SUBSTRING(ACADEMIC_PERIOD,1,4)))
					) a

) src 
PIVOT 
(

Sum(Enroll) FOR ACAD_YEAR in ([Current_Term] , [Last_Term]) 
)y


union
 Select [Category],replace(convert(varchar,convert(money,y.Last_Term),1),'.00','') as 'Last_Term',replace(convert(varchar,convert(money,y.Current_Term),1),'.00','') as 'Current_Term',
replace(convert(varchar,cast((y.Current_Term - y.Last_Term) as money),1),'.00','') as '#Change', 
cast(round((((CAST(y.Current_Term AS FLOAT)-CAST(y.Last_Term AS FLOAT))/(CAST(y.Last_Term AS FLOAT)))* 100),2) as varchar(10)) + '%' as '%Change'
from
  (
 
 Select
  Category,
Case
        when year = substring(CAST (@Term- 10  as Varchar(10)),1,4) then 'Current_Term'
            when year = substring(CAST (@Term - 20 as Varchar(10)),1,4) then 'Last_Term'
			END AS ACAD_YEAR , a.enroll 
		
			from
  (
  select 'Total Degrees Awarded' AS Category , (CONVERT(Varchar(10),SUBSTRING(ACADEMIC_PERIOD,1,4))) as year , count(*) as enroll
 FROM [IR_DW].[dbo].[dw_Degree_F] df
			inner join dim_Degree d
			on df.DEGREE_KEY = d.DEGREE_KEY
            INNER JOIN dim_College c
            ON df.COLLEGE_KEY= c.COLLEGE_KEY
            inner join dim_Time t
            on df.TIME_KEY = t.TIME_KEY
            inner join dim_Award_Category ac
            on df.AWARD_CATEGORY_KEY= ac.AWARD_CATEGORY_KEY
					Where ACADEMIC_YEAR in (substring(CAST(@Term-20 AS VARCHAR(10)),1,4) , substring(CAST(@Term-10 as VARCHAR(10)),1,4))
					and df.AWARD_CATEGORY_KEY not in( '1','4') 
			and d.DEGREE Not In ('ND','CER') and ac.AWARD_CATEGORY in ('42','24','31','44')
					group by (CONVERT(Varchar(10),SUBSTRING(ACADEMIC_PERIOD,1,4)))
					) a

) src 
PIVOT 
(

Sum(Enroll) FOR ACAD_YEAR in ([Current_Term] , [Last_Term]) 
)y
) a
order by
 case when a.[Category] = 'Undergraduate' then 1
      when a.[Category] = 'Graduate' then 2
	  when a.[Category] = 'Law' then 3
	  when a.[Category] = 'Total Degrees Awarded' then 4 END


 END
 ----------------------------------------------------------SEMESTER CREDIT HOURS-------------------------------------------------------------------------------------------------------------------------
  ELSE IF @reportType = 'UNCERTSCH'--<08/10/2017>
 BEGIN

select [Category],[Last_Term] , [Current_Term] , [#Change],[%Change] from 
(
 Select [Category],replace(convert(varchar,convert(money,y.Last_Term),1),'.00','') as 'Last_Term',replace(convert(varchar,convert(money,y.Current_Term),1),'.00','') as 'Current_Term',
replace(convert(varchar,cast((y.Current_Term - y.Last_Term) as money),1),'.00','') as '#Change', 
cast(round((((CAST(y.Current_Term AS FLOAT)-CAST(y.Last_Term AS FLOAT))/(CAST(y.Last_Term AS FLOAT)))* 100),2) as varchar(10)) + '%' as '%Change'
from
  (
 
 Select
  Category,
    Case
        when year = substring(CAST (@Term as Varchar(10)),1,4) then 'Current_Term'
            when year = substring(CAST (@Term - 10 as Varchar(10)),1,4) then 'Last_Term'
			END AS ACAD_YEAR , a.credit 
		
		
			from
  (
  select case when cl.COURSE_LEVEL = 'GR' Then 'Graduate' 
  When cl.COURSE_LEVEL= 'UG' THEN 'Undergraduate' 
  When cl.COURSE_LEVEL = 'LW' THEN 'Law'
  END AS Category , (CONVERT(INT,SUBSTRING(ACADEMIC_PERIOD,1,4))) as year , sum(v.course_credits) as credit
 
 FROM [IR_DW].[dbo].[vw_Course_Registration_F] v
			INNER JOIN dim_College c
            ON V.COLLEGE_KEY= c.COLLEGE_KEY
            inner join dim_Time t
            on V.TIME_KEY = t.TIME_KEY
			inner join dim_Course_Level cl 
			on V.COURSE_LEVEL_KEY = cl.COURSE_LEVEL_KEY
					Where ACADEMIC_PERIOD_ALL in (@Term-10 , @Term)
					group by cl.COURSE_LEVEL, (CONVERT(INT,SUBSTRING(ACADEMIC_PERIOD,1,4)))
					) a

) src 
PIVOT 
(

Sum(credit) FOR ACAD_YEAR in ([Current_Term] , [Last_Term]) 
)y

union

 Select [Category],replace(convert(varchar,convert(money,y.Last_Term),1),'.00','') as 'Last_Term',replace(convert(varchar,convert(money,y.Current_Term),1),'.00','') as 'Current_Term',
replace(convert(varchar,cast((y.Current_Term - y.Last_Term) as money),1),'.00','') as '#Change', 
cast(round((((CAST(y.Current_Term AS FLOAT)-CAST(y.Last_Term AS FLOAT))/(CAST(y.Last_Term AS FLOAT)))* 100),2) as varchar(10)) + '%' as '%Change'
from
  (
 
 Select
  Category,
    Case
        when year = substring(CAST (@Term as Varchar(10)),1,4) then 'Current_Term'
            when year = substring(CAST (@Term - 10 as Varchar(10)),1,4) then 'Last_Term'
			END AS ACAD_YEAR , a.credit
		
		
			from
  (
  select 'Total SCH' Category , (CONVERT(INT,SUBSTRING(ACADEMIC_PERIOD,1,4))) as year , sum(v.course_credits) as credit
 
 FROM [IR_DW].[dbo].[vw_Course_Registration_F] v
			INNER JOIN dim_College c
            ON V.COLLEGE_KEY= c.COLLEGE_KEY
            inner join dim_Time t
            on V.TIME_KEY = t.TIME_KEY
			inner join dim_Course_Level cl 
			on V.COURSE_LEVEL_KEY = cl.COURSE_LEVEL_KEY
					Where ACADEMIC_PERIOD_ALL in (@Term-10 , @Term)
					group by cl.COURSE_LEVEL, (CONVERT(INT,SUBSTRING(ACADEMIC_PERIOD,1,4)))
					) a

) src 
PIVOT 
(

Sum(credit) FOR ACAD_YEAR in ([Current_Term] , [Last_Term]) 
)y
) a
order by
 case when a.[Category] = 'Undergraduate' then 1
      when a.[Category] = 'Graduate' then 2
	  when a.[Category] = 'Law' then 3
	  when a.[Category] = 'Total SCH' then 4 END


END
 ---------------------------------------------------------HEADCOUNT ENROLLMENT-------------------------------------------------------------------------------------------------------------------------------------------------------------------
   ELSE IF @reportType = 'UNCERTHEADENR'--<08/10/2017>
 
BEGIN

select [Category],[Last_Term] , [Current_Term] , [#Change],[%Change] from 
(
 Select [Category],replace(convert(varchar,convert(money,y.Last_Term),1),'.00','') as 'Last_Term',replace(convert(varchar,convert(money,y.Current_Term),1),'.00','') as 'Current_Term',
replace(convert(varchar,cast((y.Current_Term - y.Last_Term) as money),1),'.00','') as '#Change', 
cast(round((((CAST(y.Current_Term AS FLOAT)-CAST(y.Last_Term AS FLOAT))/(CAST(y.Last_Term AS FLOAT)))* 100),2) as varchar(10)) + '%' as '%Change'
from
  (
 
 Select
  Category,
    Case
        when year = substring(CAST (@Term- 10  as Varchar(10)),1,4) then 'Current_Term'
            when year = substring(CAST (@Term - 20 as Varchar(10)),1,4) then 'Last_Term'
			END AS ACAD_YEAR , a.enroll 
		
		
			from
  (
  select case when sl.STUDENT_LEVEL = 'GR' Then 'Graduate' 
  When sl.STUDENT_LEVEL = 'UG' THEN 'Undergraduate' 
  When sl.STUDENT_LEVEL = 'LW' THEN 'Law'
  END AS Category , (CONVERT(INT,SUBSTRING(ACADEMIC_PERIOD,1,4)))-1 as year , count(*) as enroll
 
 FROM [IR_DW].[dbo].[dw_enrollment_F] d
        INNER JOIN dim_College c
        ON d.COLLEGE_KEY= c.COLLEGE_KEY
        inner join dim_Time t
        on d.TIME_KEY = t.TIME_KEY
        inner join dim_Student_Level sl
        on d.STUDENT_LEVEL_KEY = sl.STUDENT_LEVEL_KEY
					Where ACADEMIC_PERIOD_ALL = @Term-10 or ACADEMIC_PERIOD_ALL = @Term
					group by sl.STUDENT_LEVEL, (CONVERT(INT,SUBSTRING(ACADEMIC_PERIOD,1,4)))-1
					) a

) src 
PIVOT 
(

Sum(Enroll) FOR ACAD_YEAR in ([Current_Term] , [Last_Term]) 
)y

union

 Select [Category],replace(convert(varchar,convert(money,y.Last_Term),1),'.00','') as 'Last_Term',replace(convert(varchar,convert(money,y.Current_Term),1),'.00','') as 'Current_Term',
replace(convert(varchar,cast((y.Current_Term - y.Last_Term) as money),1),'.00','') as '#Change', 
cast(round((((CAST(y.Current_Term AS FLOAT)-CAST(y.Last_Term AS FLOAT))/(CAST(y.Last_Term AS FLOAT)))* 100),2) as varchar(10)) + '%' as '%Change'
from
  (
 
 Select
  Category,
    Case
        when year = substring(CAST (@Term- 10  as Varchar(10)),1,4) then 'Current_Term'
            when year = substring(CAST (@Term - 20 as Varchar(10)),1,4) then 'Last_Term'
			END AS ACAD_YEAR , a.enroll 
		
		
			from
  (

  select 'Total Enrollment' AS Category , (CONVERT(INT,SUBSTRING(ACADEMIC_PERIOD,1,4)))-1 as year , count(*) as enroll
 
 FROM [IR_DW].[dbo].[dw_enrollment_F] d
        INNER JOIN dim_College c
        ON d.COLLEGE_KEY= c.COLLEGE_KEY
        inner join dim_Time t
        on d.TIME_KEY = t.TIME_KEY
        inner join dim_Student_Level sl
        on d.STUDENT_LEVEL_KEY = sl.STUDENT_LEVEL_KEY
					Where ACADEMIC_PERIOD_ALL = @Term-10 or ACADEMIC_PERIOD_ALL = @Term
					group by sl.STUDENT_LEVEL, (CONVERT(INT,SUBSTRING(ACADEMIC_PERIOD,1,4)))-1
					) a

) src 
PIVOT 
(

Sum(Enroll) FOR ACAD_YEAR in ([Current_Term] , [Last_Term]) 
)y
) a
order by
 case when a.[Category] = 'Undergraduate' then 1
      when a.[Category] = 'Graduate' then 2
	  when a.[Category] = 'Law' then 3
	  when a.[Category] = 'Total Enrollment' then 4 END
END
----------------------------------------------------------ENROLLMENT BY HOME-------------------------------------------------------------------------------------------------------------------------------------------------------------------

   ELSE IF @reportType = 'UNCERTHOME'--<08/10/2017>
BEGIN

select [Category],[Last_Term] , [Current_Term] , [#Change],[%Change] from 
(
 Select [Category],replace(convert(varchar,convert(money,y.Last_Term),1),'.00','') as 'Last_Term',replace(convert(varchar,convert(money,y.Current_Term),1),'.00','') as 'Current_Term',
replace(convert(varchar,cast((y.Current_Term - y.Last_Term) as money),1),'.00','') as '#Change', 
cast(round((((CAST(y.Current_Term AS FLOAT)-CAST(y.Last_Term AS FLOAT))/(CAST(y.Last_Term AS FLOAT)))* 100),2) as varchar(10)) + '%' as '%Change'
from
  (
 
 Select
  Category,
    Case
        when year = substring(CAST (@Term- 10  as Varchar(10)),1,4) then 'Current_Term'
            when year = substring(CAST (@Term - 20 as Varchar(10)),1,4) then 'Last_Term'
			END AS ACAD_YEAR , a.enroll 
		
		
			from
  (
  select case when dh.HOME = 'F' Then 'Foreign' 
  When dh.HOME = 'O' THEN 'Out-Of State' 
  When dh.Home = 'I' THEN 'Texas'
  WHEN dh.Home = 'U' THEN 'Unknown'
  END AS Category , (CONVERT(INT,SUBSTRING(ACADEMIC_PERIOD,1,4)))-1 as year , count(*) as enroll
 
 FROM [IR_DW].[dbo].[dw_enrollment_F] d
				    inner join dim_Time t
                    on d.TIME_KEY = t.TIME_KEY
                    inner join dim_Home dh
				    on d.HOME_KEY = dh.HOME_KEY
                    inner join dim_Student_Level sl
                    on d.STUDENT_LEVEL_KEY = sl.STUDENT_LEVEL_KEY
					Where ACADEMIC_PERIOD_ALL = @Term-10 or ACADEMIC_PERIOD_ALL = @Term
					group by dh.HOME, (CONVERT(INT,SUBSTRING(ACADEMIC_PERIOD,1,4)))-1
					) a

) src 
PIVOT 
(

Sum(Enroll) FOR ACAD_YEAR in ([Current_Term] , [Last_Term]) 
)y

union

 Select [Category],replace(convert(varchar,convert(money,y.Last_Term),1),'.00','') as 'Last_Term',replace(convert(varchar,convert(money,y.Current_Term),1),'.00','') as 'Current_Term',
replace(convert(varchar,cast((y.Current_Term - y.Last_Term) as money),1),'.00','') as '#Change', 
cast(round((((CAST(y.Current_Term AS FLOAT)-CAST(y.Last_Term AS FLOAT))/(CAST(y.Last_Term AS FLOAT)))* 100),2) as varchar(10)) + '%' as '%Change'
from
  (
 
 Select
  Category,
    Case
        when year = substring(CAST (@Term- 10  as Varchar(10)),1,4) then 'Current_Term'
            when year = substring(CAST (@Term - 20 as Varchar(10)),1,4) then 'Last_Term'
			END AS ACAD_YEAR , a.enroll 
		
		
			from
  (

  select 'Total Enrollment' AS Category , (CONVERT(INT,SUBSTRING(ACADEMIC_PERIOD,1,4)))-1 as year , count(*) as enroll
 
 FROM [IR_DW].[dbo].[dw_enrollment_F] d
				    inner join dim_Time t
                    on d.TIME_KEY = t.TIME_KEY
                    inner join dim_Home dh
				    on d.HOME_KEY = dh.HOME_KEY
                    inner join dim_Student_Level sl
                    on d.STUDENT_LEVEL_KEY = sl.STUDENT_LEVEL_KEY
					Where ACADEMIC_PERIOD_ALL = @Term-10 or ACADEMIC_PERIOD_ALL = @Term
					group by  (CONVERT(INT,SUBSTRING(ACADEMIC_PERIOD,1,4)))-1
					) a

) src 
PIVOT 
(

Sum(Enroll) FOR ACAD_YEAR in ([Current_Term] , [Last_Term]) 
)y
)a

order by
 case when a.[Category] = 'Foreign' then 1 
      when a.[Category] = 'Out-Of State' then 2 
	  when a.[Category] = 'Texas' then 3 
	  when a.[Category] = 'Unknown' then 4 
	  when a.[Category] = 'Total Enrollment' then 5 END

END

END



GO


