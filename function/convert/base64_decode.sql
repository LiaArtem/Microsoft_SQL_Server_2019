CREATE FUNCTION [dbo].[base64_decode]
(
	@p_text NVARCHAR(MAX)	
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
-- Преобразование из base64
    RETURN (
        SELECT CAST(CAST(N'' AS XML).value('xs:base64Binary(sql:variable("@p_text"))', 'VARBINARY(MAX)') AS NVARCHAR(MAX)) as rezult
    )	
END
