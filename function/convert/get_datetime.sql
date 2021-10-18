CREATE FUNCTION [dbo].[get_datetime]
(
	@p_text VARCHAR(100)	
)
RETURNS DATETIME2
AS
BEGIN
    -- Преобразование текста в дату и время
    DECLARE @m_date datetime2;

    if @p_text in ('null', 'nul') 
           RETURN null

    if len(@p_text) > 20    
        SET @m_date = CONVERT( DATETIME2, @p_text, 126 ); -- 'YYYY-MM-DD"T"hh24:mi:ss.FF9"Z"'

    else if len(@p_text) = 20    
        SET @m_date = CONVERT( DATETIME2, @p_text, 120 ); -- 'YYYY-MM-DD"T"hh24:mi:ss"Z"'        
        
    else if len(@p_text) = 17    
        SET @m_date = CONVERT( DATETIME2, replace(@p_text, 'Z', ':00'), 120 ); -- 'YYYY-MM-DD"T"hh24:mi"Z"'

	RETURN @m_date
END
