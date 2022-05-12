CREATE PROCEDURE [dbo].[get_error_info]
   @rezult NVARCHAR(MAX) OUTPUT
AS
BEGIN
  -- Описание ошибки
 SELECT TOP 1 @rezult = 
    'ErrorNumber:' + ISNULL(CONVERT(NVARCHAR(MAX), ERROR_NUMBER()),'') + ' ' + 
    'ErrorSeverity:' + ISNULL(CONVERT(NVARCHAR(MAX), ERROR_SEVERITY()),'') + ' ' + 
    'ErrorState:' + ISNULL(CONVERT(NVARCHAR(MAX), ERROR_STATE()),'') + ' ' + 
    'ErrorProcedure:' + ISNULL(CONVERT(NVARCHAR(MAX), ERROR_PROCEDURE()),'') + ' ' + 
    'ErrorLine:' + ISNULL(CONVERT(NVARCHAR(MAX), ERROR_LINE()),'') + ' ' + 
    'ErrorMessage:' + ISNULL(CONVERT(NVARCHAR(MAX), ERROR_MESSAGE()),'');
END