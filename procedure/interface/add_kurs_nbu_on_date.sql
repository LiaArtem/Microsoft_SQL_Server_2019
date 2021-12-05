CREATE PROCEDURE [dbo].[add_kurs_nbu_on_date]
	@p_date_from date,
	@p_date_to date
AS
-- Загрузка с внешнего сервиса курсов с записью в таблицу за период
	DECLARE @cnt INT = 0;
	DECLARE @cnt_total INT;
	DECLARE @p_date DATE = @p_date_from;
BEGIN
    SELECT @cnt_total = DATEDIFF(day, @p_date_from, @p_date_to);
	WHILE @cnt <= @cnt_total
	BEGIN
	   EXECUTE [dbo].[add_kurs_nbu]
		  @p_date = @p_date

	   SELECT @p_date = DATEADD(day, 1, @p_date);
	   SET @cnt = @cnt + 1;
	END;
END	
