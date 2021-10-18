CREATE PROCEDURE [dbo].[str_to_num]
	@p_text NVARCHAR(MAX),
	@p_rezult NUMERIC(38, 15) OUTPUT
AS
  BEGIN
-- Преобразование теста с число
    DECLARE @m_text NVARCHAR(MAX);    

	IF (@p_text is null or @p_text = '') 
	    RETURN null;

    SET @m_text = replace(@p_text,',','.');
    SET @m_text = replace(@p_text,' ','');
    SET @m_text = replace(@p_text,char(13),'');
    SET @m_text = replace(@p_text,char(10),'');
	
    IF TRY_CONVERT(NUMERIC(38, 15), @m_text) is null	  
	   RAISERROR('Невозможно преобразовать в число = %s', 1, 2, @p_text) WITH SETERROR;
	
	SET @p_rezult = CONVERT(NUMERIC(38, 15), @m_text);    
  END