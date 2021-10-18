CREATE FUNCTION [dbo].[instr]
(
	@str VARCHAR(8000), 
	@substr VARCHAR(255), 
	@start INT = 1, 
    @occurrence INT	= 1
)
RETURNS INT
AS
  BEGIN
-- Oracle функция INSTR возвращает n-е вхождение подстроки в строке.
-- @strin = является строка для поиска
-- @substr = подстрока для поиска в строке
-- @start = является положение символа в строке, с которого начнется поиск. Если параметр отрицательный, то функция рассчитывает позицию start_position в обратном направлении от конца строки, а затем ищет к началу строки.
-- @occurrence = является n-м вхождением подстроки

    DECLARE @found INT = @occurrence,
            @pos INT = @start;

    WHILE 1=1 
    BEGIN
        -- Find the next occurrence
        SET @pos = CHARINDEX(@substr, @str, @pos);

        -- Nothing found
        IF @pos IS NULL OR @pos = 0
            RETURN @pos;

        -- The required occurrence found
        IF @found = 1
            BREAK;

        -- Prepare to find another one occurrence
        SET @found = @found - 1;
        SET @pos = @pos + 1;
    END

    RETURN @pos;
  END
