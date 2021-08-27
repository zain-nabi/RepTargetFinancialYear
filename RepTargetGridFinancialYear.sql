USE [CRM]
GO
/****** Object:  StoredProcedure [dbo].[proc_RepTargetsNewBiz_GetRepTargetsNewBizGrid]    Script Date: 2021/08/27 9:45:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================\

-- exec sp_RepTargetsNewBizGrid 2012

ALTER PROCEDURE [dbo].[proc_RepTargetsNewBiz_GetRepTargetsNewBizGrid]
	-- Add the parameters for the stored procedure here
	@FinancialYear int,@UserID int=null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

declare @Where varchar(100)
declare @FinancialYearString varchar(4)
set @FinancialYearString=Convert(varchar(4),@FinancialYear)
	
if @UserID is not null
	set @Where=' where TritonSecurity..Users.UserID='+Convert(varchar(10),@UserID)+' '
else set @Where=''

     -- Insert statements for procedure here
execute ('SELECT  DISTINCT ROW_NUMBER() OVER (Order by RevisedReps.RevRepCode) RepTargetsNewBizID,RevisedReps.RevRepCode, COALESCE(RevisedReps.BranchName,TritonSecurity.dbo.Branches.BranchName,RepCodes.AlternateBranchCode) as BranchName, ISNULL(SUBSTRING(TritonSecurity.dbo.Users.Name, 1, CHARINDEX('' '', 
                      TritonSecurity.dbo.Users.Name)), RepCodes.AlternateName) AS Name, ISNULL(RevisedReps.Jul, 0) AS Jul, ISNULL(RevisedReps.Aug, 0) AS Aug, ISNULL(RevisedReps.Sep, 0) AS Sep, 
                      ISNULL(RevisedReps.Oct, 0) AS Oct, ISNULL(RevisedReps.Nov, 0) AS Nov, ISNULL(RevisedReps.Dec, 0) AS Dec, ISNULL(RevisedReps.Jan, 0) AS Jan, ISNULL(RevisedReps.Feb, 0) AS Feb, 
                      ISNULL(RevisedReps.Mar, 0) AS Mar, ISNULL(RevisedReps.Apr, 0) AS Apr, ISNULL(RevisedReps.May, 0) AS May, ISNULL(RevisedReps.Jun, 0) AS Jun, ISNULL(RevisedReps.Total, 0) AS Total, 
                      TritonSecurity.dbo.Users.Name AS Expr1, ISNULL(TritonSecurity.dbo.Branches.RepSalesOrder, case when RevisedReps.RevRepCode like ''%other%'' then 20 else 5 end) AS RepSalesOrder, FWRepMaps.FWCode,TritonSecurity.dbo.Users.UserID, ISNULL(RevisedReps.RevRepBranchID,TritonSecurity.dbo.Branches.BranchID) AS BranchID
                      
FROM         (SELECT     UserRoleBranchDepartmentID, UserID,  BranchID, DepartmentID, SignatoryTitle
                       FROM          UserRoleBranchDepartmentMap AS UserRoleBranchDepartmentMap_1
                       WHERE       RoleID in (2,15,20)) AS UserRoleBranchDepartmentMap RIGHT OUTER JOIN
                      TritonSecurity.dbo.Users ON UserRoleBranchDepartmentMap.UserID = TritonSecurity.dbo.Users.UserID RIGHT OUTER JOIN
                          (SELECT   DISTINCT  RevRepCode, SUM(ISNULL(Target, 0)) AS Target
                            FROM          RepTargetsNewBiz AS RepTargetsNewBiz_10
                            WHERE      (FinancialYear = ' + @FinancialYearString + ')
                            GROUP BY RevRepCode) AS Total RIGHT OUTER JOIN
                          (SELECT DISTINCT RevRepCode, BranchName, RT.BranchID as RevRepBranchID,
						   MAX(case when RT.FinancialMonth = 1 then ISNULL(RT.Target,0) end) AS Jul,
						   MAX(case when RT.FinancialMonth = 2 then ISNULL(RT.Target,0) end) AS Aug,
						   MAX(case when RT.FinancialMonth = 3 then ISNULL(RT.Target,0) end) AS Sep,
						   MAX(case when RT.FinancialMonth = 4 then ISNULL(RT.Target,0) end) AS Oct,
						   MAX(case when RT.FinancialMonth = 5 then ISNULL(RT.Target,0) end) AS Nov,
						   MAX(case when RT.FinancialMonth = 6 then ISNULL(RT.Target,0) end) AS [Dec],
						   MAX(case when RT.FinancialMonth = 7 then ISNULL(RT.Target,0) end) AS Jan,
						   MAX(case when RT.FinancialMonth = 8 then ISNULL(RT.Target,0) end) AS Feb,
						   MAX(case when RT.FinancialMonth = 9 then ISNULL(RT.Target,0) end) AS Mar,
						   MAX(case when RT.FinancialMonth = 10 then ISNULL(RT.Target,0) end) AS Apr,
						   MAX(case when RT.FinancialMonth = 11 then ISNULL(RT.Target,0) end) AS May,
						   MAX(case when RT.FinancialMonth = 12 then ISNULL(RT.Target,0) end) AS Jun,
						   SUM(RT.Target) OVER(PARTITION BY RT.RevRepCode) Total
                            FROM          RepTargetsNewBiz RT
							LEFT JOIN TritonSecurity.dbo.Branches ON TritonSecurity.dbo.Branches.BranchID =  RT.BranchID
                            WHERE      (FinancialYear = ' + @FinancialYearString + ' AND DeletedOn IS NULL) GROUP BY  RevRepCode, BranchName, RT.BranchID, Target ) AS RevisedReps LEFT OUTER JOIN
                      RepCodes INNER JOIN
                      FWRepMaps ON RepCodes.RepCodeID = FWRepMaps.RepCodeID ON RevisedReps.RevRepCode = FWRepMaps.FWCode ON 
                      Total.RevRepCode = RevisedReps.RevRepCode ON TritonSecurity.dbo.Users.UserID = RepCodes.UserID LEFT OUTER JOIN
                      TritonSecurity.dbo.Branches ON UserRoleBranchDepartmentMap.BranchID = TritonSecurity.dbo.Branches.BranchID 
                      
                                                         
ORDER BY RepSalesOrder, RevisedReps.RevRepCode')                             
                      
--ORDER BY ISNULL(TritonSecurity.dbo.Branches.RepSalesOrder, (CASE WHEN CHARINDEX(''other'', RevisedReps.RevRepCode, 1) = 5 THEN 10 ELSE
--                          (SELECT     repsalesorder
--                            FROM          TritonSecurity..Branches
--                            WHERE      BranchName = SUBSTRING(RevisedReps.RevRepCode, 1, 3)) END)), RevisedReps.RevRepCode')
                            
          
END


