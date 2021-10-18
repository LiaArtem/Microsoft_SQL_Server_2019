CREATE FUNCTION [dbo].[is_valid_json]
(
	@p_text NVARCHAR(MAX)	
)
RETURNS CHAR(1)
AS
BEGIN
-- Проверка валидности JSON
  RETURN CASE WHEN ISJSON(@p_text) > 0
          THEN 'T'
          ELSE 'F'
          END
END
