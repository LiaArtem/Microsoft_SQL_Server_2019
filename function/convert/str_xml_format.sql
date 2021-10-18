CREATE FUNCTION [dbo].[str_xml_format]
(
	@p_text NVARCHAR(MAX)	
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
    -- Преобразование в правильный текстовый формат XML для дальнейшего преобразования.
	-- xml в MSSQL всегда в UTF-16
	RETURN REPLACE(REPLACE(REPLACE(CAST(@p_text AS NVARCHAR(MAX)),N'utf-8',N'utf-16'),N'.0,',N','),N'.00,',N',');
END
