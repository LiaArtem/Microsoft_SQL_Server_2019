CREATE PROCEDURE [dbo].[send_email]
	@profile_name nvarchar(max), -- Профиль администратора почтовых рассылок
	@recipients	  nvarchar(max), -- Адрес получателя
	@body		  nvarchar(max), -- Текст письма
	@subject      nvarchar(max), -- Тема
	@query	      nvarchar(max) = ''  -- SQL Запрос (например SELECT TOP 10 name FROM sys.objects)
AS
   -- Отправка e-mail
   -- Если что-то не в порядке, сначала нужно посмотреть на статус письма + лог
   -- SELECT * FROM msdb.dbo.sysmail_allitems
   -- SELECT * FROM msdb.dbo.sysmail_event_log  
   -- Успешно отправленные письма
   -- SELECT sent_account_id, sent_date FROM msdb.dbo.sysmail_sentitems
   -- Остальные параметры MSDN - sp_send_dbmail (Transact-SQL)
   -- https://docs.microsoft.com/en-us/previous-versions/sql/sql-server-2008-r2/ms190307(v=sql.105)?redirectedfrom=MSDN

   -- Отправка
	EXECUTE msdb.dbo.sp_send_dbmail		
			@profile_name = @profile_name,		
			@recipients = @recipients,	
			@body = @body,		
			@subject = @subject,
			@query = @query
		    ;
