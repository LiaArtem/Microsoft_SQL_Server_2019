CREATE FUNCTION [dbo].[CLR_convert_str_ext]
(
	@p_text NVARCHAR(MAX), -- исходный текст
	@p_char_set_to NVARCHAR(255), -- новая кодировка
	@p_char_set_from NVARCHAR(255)	-- старая кодировка
)
RETURNS NVARCHAR(MAX)
AS -- Преобразование теста из одной в другую кодировку
   EXTERNAL NAME [CLRTextConvertEXT].[CLRTextConvertEXT.DefConvert].[Convert_String]
