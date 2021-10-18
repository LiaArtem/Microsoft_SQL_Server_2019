CREATE FUNCTION [dbo].[str_to_num_func]
(
	@p_text NVARCHAR(MAX)	
)
RETURNS NUMERIC(38, 15)
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
	
    RETURN TRY_CONVERT(NUMERIC(38, 15), @m_text)
END