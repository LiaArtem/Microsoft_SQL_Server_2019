/*
Шаблон скрипта после развертывания							
--------------------------------------------------------------------------------------
 В данном файле содержатся инструкции SQL, которые будут добавлены в скрипт построения.		
 Используйте синтаксис SQLCMD для включения файла в скрипт после развертывания.			
 Пример:      :r .\myfile.sql								
 Используйте синтаксис SQLCMD для создания ссылки на переменную в скрипте после развертывания.		
 Пример:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/
--Run scripts 
BEGIN 
    PRINT 'Добавление кодов валют' 
    begin transaction;
    
    PRINT 'UAH-Гривня'    
    INSERT INTO [dbo].[CURRENCY] ([CODE] ,[NAME] ,[SHORT_NAME]) 
    SELECT '980','Гривня','UAH'
	WHERE NOT EXISTS (SELECT 1 FROM [dbo].[CURRENCY] WHERE CODE = '980');

    PRINT 'USD-Долар США'    
    INSERT INTO [dbo].[CURRENCY] ([CODE] ,[NAME] ,[SHORT_NAME]) 
    SELECT '840','Долар США','USD'
	WHERE NOT EXISTS (SELECT 1 FROM [dbo].[CURRENCY] WHERE CODE = '840');

    PRINT 'EUR-Євро'    
    INSERT INTO [dbo].[CURRENCY] ([CODE] ,[NAME] ,[SHORT_NAME]) 
    SELECT '978','Євро','EUR'
	WHERE NOT EXISTS (SELECT 1 FROM [dbo].[CURRENCY] WHERE CODE = '978');

    PRINT 'GBP-Фунт стерлінгів'    
    INSERT INTO [dbo].[CURRENCY] ([CODE] ,[NAME] ,[SHORT_NAME]) 
    SELECT '826','Фунт стерлінгів','GBP'
	WHERE NOT EXISTS (SELECT 1 FROM [dbo].[CURRENCY] WHERE CODE = '826');

    commit transaction;
END