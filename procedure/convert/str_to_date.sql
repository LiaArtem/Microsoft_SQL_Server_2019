CREATE PROCEDURE [dbo].[str_to_date]
	@p_text   NVARCHAR(MAX), 
	@p_format NVARCHAR(100) = 'dd.mm.yyyy',
	@p_rezult DATE OUTPUT
AS
BEGIN
	-- Преобразование теста в дату
	DECLARE @m_format INT;

	IF (@p_text is null or @p_text = '') 
	    RETURN null;

	-- T-SQL syntax
	SET @m_format = CASE @p_format   
					WHEN 'mm/dd/yy' THEN 1     
					WHEN 'yy.mm.dd' THEN 2     
					WHEN 'dd/mm/yy' THEN 3     
					WHEN 'dd.mm.yy' THEN 4     
					WHEN 'dd-mm-yy' THEN 5     
					WHEN 'dd-Mon-yy' THEN 6     
					WHEN 'Mon dd, yy' THEN 7     
					WHEN 'mm-dd-yy' THEN 10     
					WHEN 'yy/mm/dd' THEN 11     
					WHEN 'yymmdd' THEN 12     
					WHEN 'yyyy-mm-dd' THEN 23
					WHEN 'mm/dd/yyyy' THEN 101     
					WHEN 'yyyy.mm.dd' THEN 102     
					WHEN 'dd/mm/yyyy' THEN 103     
					WHEN 'dd.mm.yyyy' THEN 104     
					WHEN 'dd-mm-yyyy' THEN 105     
					WHEN 'dd Mon yyyy' THEN 106     
					WHEN 'Mon dd, yyyy' THEN 107     
					WHEN 'mm-dd-yyyy' THEN 110
					WHEN 'yyyy/mm/dd' THEN 111
					WHEN 'yyyymmdd' THEN 112
					ELSE 0
					END   	 

	IF @m_format = 0
		RAISERROR('Не найден формат для преобразования = %s', 1, 2, @p_format) WITH SETERROR;
		
	IF TRY_CONVERT(date, @p_text, @m_format) is null	  
	   RAISERROR('Невозможно преобразовать в дату = %s', 1, 2, @p_text) WITH SETERROR;
	
	SET @p_rezult = CONVERT(date, @p_text, @m_format);    
END
