CREATE FUNCTION [dbo].[CLR_GetHexString]
(
	@assemblyPath NVARCHAR(MAX) -- исходный текст	
)
RETURNS NVARCHAR(MAX)
AS -- Получение HEX кода пути файла для создания CREATE ASSEMBLY
  EXTERNAL NAME [CLRTextConvertEXT].[CLRTextConvertEXT.DefConvert].[GetHexString]