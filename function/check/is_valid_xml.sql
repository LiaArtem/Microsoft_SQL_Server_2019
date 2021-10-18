CREATE FUNCTION [dbo].[is_valid_xml]
(
	@p_text NVARCHAR(MAX)	
)
RETURNS CHAR(1)
AS
BEGIN   
-- Проверка валидности XML
  RETURN CASE WHEN TRY_CAST([dbo].[str_xml_format](@p_text) AS XML) IS NOT NULL
          THEN 'T'
          ELSE 'F' 
          END
END