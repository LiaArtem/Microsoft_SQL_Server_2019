alter database DatabaseTestDB set trustworthy on
go

-- net. 4.5.2 для ms sql 2017 - если добавлять внешнюю CLR через SSMS
CREATE ASSEMBLY CLRTextConvert
    FROM 'C:\CLR\CLRTextConvertEXT.dll'
    WITH PERMISSION_SET = UNSAFE

go