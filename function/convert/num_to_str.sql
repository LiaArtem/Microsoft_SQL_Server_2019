CREATE FUNCTION [dbo].[num_to_str]
(
	@p_amount NUMERIC(38,15)   
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
     -- Преобразование числа в текст
     IF @p_amount is null 
         return '';
          
     RETURN FORMAT(@p_amount,'0.0##############')
END
