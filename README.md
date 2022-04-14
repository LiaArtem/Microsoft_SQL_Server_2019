# Microsoft_SQL_Server_2019
Microsoft SQL Server 2019 integration with WEB-services (GET, POST - JSON, XML, CSV)
and send e-mail (T-SQL - tables, view, triggers, sequences, types, functions, procedures,
SQL CLR C#, assembly (CLR) scalar-functions, OLE Automation Stored Procedures)

Разворачивание проекта:
- {любой каталог}\DatabaseTestDB\ в папку перести проект
- распаковать второй проект {любой каталог}\CLRTextConvertEXT\
- скопировать файл CLRTextConvertEXT.dll в папку C:\CLR\
- .\settings\ выполнить скрипты из проекта
  - sql_settings_GRANT_OLE_and_CLR.sql

- sql скрипты для загрузки данных в таблицы
  - .\sql_add_DB\*

Дополнительно:
  - sql_settings_DBMail.sql

Дополнительно если нужно отдельно обновить:
  - sql_settings_CLR_EXTERNAL.sql

Если нет .NET 4.5.2 скачать и установить.
https://dotnet.microsoft.com/en-us/download/visual-studio-sdks?utm_source=getdotnetsdk&utm_medium=referral
