CREATE FUNCTION [dbo].[split_part]
(
	@str NVARCHAR(MAX),
	@substr NVARCHAR(1) = ';',
	@occurrence INT	= 1
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
    -- получить часть теста из строки
	DECLARE @m_str NVARCHAR(MAX) = @str;
	SET @m_str = REPLACE(REPLACE(@m_str, char(10),''), char(13),'');
	IF SUBSTRING(@m_str, LEN(@m_str), 1) != @substr
	     SET @m_str = @m_str + @substr
	
	IF @occurrence > LEN(@m_str) - LEN(REPLACE(@m_str, @substr, ''))
	     RETURN ''

	IF @occurrence = 1
	      SET @m_str = SUBSTRING(@m_str, 1, [dbo].[instr](@m_str, @substr, default, @occurrence) - 1)
    ELSE
	      SET @m_str = SUBSTRING(@m_str, [dbo].[instr](@m_str, @substr, default, @occurrence - 1) + 1, [dbo].[instr](@m_str, @substr, default, @occurrence) - [dbo].[instr](@m_str, @substr, default, @occurrence - 1) - 1)

	RETURN @m_str	
END
