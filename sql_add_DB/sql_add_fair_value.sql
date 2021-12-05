USE [DatabaseTestDB]
GO

DECLARE @RC int
DECLARE @p_date date = getdate() - 2;

-- TODO: Set parameter values here.

EXECUTE @RC = [dbo].[add_fair_value] 
   @p_date
GO


