-- Сначала включим Service broker - он необходим для создания очередей писем, используемых DBMail
IF (SELECT is_broker_enabled FROM sys.databases WHERE [name] = 'msdb') = 0
	ALTER DATABASE msdb SET ENABLE_BROKER WITH ROLLBACK AFTER 10 SECONDS
GO
-- Включим непосредственно систему DBMail
sp_configure 'Database Mail XPs', 1
GO
RECONFIGURE
GO

-- Далее нужно проверить, запущена ли служба DBMail:
EXECUTE msdb.dbo.sysmail_help_status_sp
GO

--И если она не запущена (ее статус не «STARTED»), то запустить ее запросом
EXECUTE msdb.dbo.sysmail_start_sp
GO

-- Теперь нужно создать SMTP-аккаунт для отсылки писем, создать профиль администратора
-- почтовых рассылок и подключить SMTP-аккаунт к этому профилю
-- Создадим SMTP-аккаунт для отсылки писем
EXECUTE msdb.dbo.sysmail_add_account_sp
		@account_name = 'admin@test.ua', -- Название аккаунта
		@description = N'Почтовый аккаунт admin@test.ua', -- Краткое описание аккаунта
		@email_address = 'admin@test.ua', -- Почтовый адрес
		@display_name = N'Администратор test.ua', -- Имя, отображаемое в письме в поле "От:"
		@replyto_address = 'no-reply@please.no-reply', -- Адрес, на который получателю письма нужно отправлять ответ, Если ответа не требуется, обычно пишут "no-reply"
		@mailserver_name = 'smtp.test.ua', -- Домен или IP-адрес SMTP-сервера
		@port = 25, -- Порт SMTP-сервера, обычно 25
		@username = 'admin', -- Имя пользователя. Некоторые почтовые системы требуют указания всего адреса почтового ящика вместо одного имени пользователя
		@password = 'MyPassword', -- Пароль к почтовому ящику
		@enable_ssl = 1;  -- Защита SSL при подключении, большинство SMTP-серверов сейчас требуют SSL

-- Создадим профиль администратора почтовых рассылок
EXECUTE msdb.dbo.sysmail_add_profile_sp
		@profile_name = 'MySite Admin Mailer';

-- Подключим SMTP-аккаунт к созданному профилю
EXECUTE msdb.dbo.sysmail_add_profileaccount_sp
		@profile_name = 'MySite Admin Mailer',
		@account_name = 'admin@test.ua',
		@sequence_number = 1; -- Указатель номера SMTP-аккаунта в профиле

-- Установим права доступа к профилю для роли DatabaseMailUserRole базы MSDB
EXECUTE msdb.dbo.sysmail_add_principalprofile_sp
		@profile_name = 'MySite Admin Mailer',
		@principal_id = 0,
		@is_default = 1;

--Тестовое письмо
--Осуществить отправку тестового письма может любой пользователь из группы sysadmin, владелец базы (db_owner) MSDB или пользователь с ролью DatabaseMailUserRole.
--Для добавления пользователю роли DatabaseMailUserRole используется стандартная процедура sp_addrolemember:
sp_addrolemember
		@rolename = 'DatabaseMailUserRole',
		@membername = '<имя_пользователя>';
GO

