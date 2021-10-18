CREATE FUNCTION [dbo].[base64_encode]
(
	@p_text NVARCHAR(MAX)	
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
-- Преобразование в base64
    RETURN (
        SELECT
            CAST(N'' AS XML).value('xs:base64Binary(xs:hexBinary(sql:column("bin")))', 'NVARCHAR(MAX)') as rezult
        FROM (
            SELECT CAST(@p_text AS VARBINARY(MAX)) AS bin
        ) AS bin_sql_server_temp
    )
END
