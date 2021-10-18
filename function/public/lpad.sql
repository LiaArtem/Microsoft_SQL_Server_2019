CREATE FUNCTION [dbo].[lpad]
(
    @string NVARCHAR(MAX), -- Initial string
    @length INT,           -- Size of final string
    @pad NVARCHAR(MAX)     -- Pad string
)
RETURNS VARCHAR(MAX)
AS
BEGIN
    -- LPAD добавляет с левой части строки определенный набор символов (при не нулевом @string).
    RETURN SUBSTRING(REPLICATE(@pad, @length),1,@length - LEN(@string)) + @string;
END