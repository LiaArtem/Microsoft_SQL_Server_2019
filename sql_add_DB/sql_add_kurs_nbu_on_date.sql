USE [DatabaseTestDB]
GO

DECLARE	@return_value int
DECLARE @date DATE;
DECLARE @date2 DATE;

SELECT @date = [dbo].[str_to_date_func] ('01.01.2020', default);
SELECT @date2 = [dbo].[str_to_date_func] ('31.12.2020', default);

EXEC	@return_value = [dbo].[add_kurs_nbu_on_date]
		@p_date_from = @date,
		@p_date_to = @date2

SELECT	'Return Value' = @return_value

GO
