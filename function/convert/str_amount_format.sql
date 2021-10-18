CREATE FUNCTION [dbo].[str_amount_format]
(
	@p_number MONEY,
	@p_count_comma INT = 2
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
    -- Преобразование суммы в текстовый формат числа
    DECLARE @p_rezult NVARCHAR(255);

    if @p_number is null 
        return '';

    if @p_count_comma = 0  SET @p_rezult = format(@p_number,'### ### ### ### ##0') else
    if @p_count_comma = 1  SET @p_rezult = format(@p_number,'### ### ### ### ##0.0') else
    if @p_count_comma = 2  SET @p_rezult = format(@p_number,'### ### ### ### ##0.00') else
    if @p_count_comma = 3  SET @p_rezult = format(@p_number,'### ### ### ### ##0.000') else
    if @p_count_comma >= 4  SET @p_rezult = format(@p_number,'### ### ### ### ##0.0000')    

    return @p_rezult;
END
