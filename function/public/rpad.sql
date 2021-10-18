CREATE FUNCTION [dbo].[rpad]
(
    @string NVARCHAR(MAX), -- Initial string
    @length INT,           -- Size of final string
    @pad NVARCHAR(MAX)     -- Pad string
)
RETURNS VARCHAR(MAX)
AS
BEGIN
    -- RPAD дополняет с правой части строки определенный набор символов (при не нулевом @string).
    RETURN @string + SUBSTRING(REPLICATE(@pad, @length),1,@length - LEN(@string));
END
