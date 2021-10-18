CREATE PROCEDURE [dbo].[HttpRequest]
     @URI           VARCHAR(MAX) = N''     
    ,@MethodName    [sysname] = N'Post'
    ,@RequestBody   NVARCHAR(MAX) = N''             -- Тело запроса
    ,@SoapAction    VARCHAR(500) = N''              -- Для запуска веб-сервисов Soap
    ,@UserName      [sysname] = N''                 -- Не обязательный. Domain\UserName или UserName 
    ,@Password      [sysname] = N''                 -- Не обязательный
    ,@ResponseText  NVARCHAR(MAX) output            -- Тело ответа
    ,@ExportToFile  NVARCHAR(MAX) = N''             -- Если передать этот параметр, после выполнения запроса данные ответа сохраняются в файл.
/*With ENCRYPTION*/ -- включить шифрование тела процедуры
AS
-- Mahmood Khezrian
-- Sp For Get Data (Page Html Or Webservice Result) From Web.
-- Method (Get - Post , ....) and Soap WebService
    Set NoCount ON;
    Declare @ErrorCode  int
    Set @ErrorCode = -1
    /*Begin Transaction HttpRequest*/
    Begin Try
        if (@MethodName = '')
            RaisError (N'Необходимо указать имя метода.',16,1);

        if (Patindex(N'%{RandomFileName}%',@ExportToFile)>0) Begin
            Declare @FileName [sysname]
            Set @FileName = Format(GetDate(),N'yyyyMMddHHmmss')+N'_'+Replace(NewID(),'-','')
            Set @ExportToFile = Replace(@ExportToFile,N'{RandomFileName}',@FileName)
        End--if
        Set @RequestBody = REPLACE(@RequestBody,'&','&amp;')
        Set @ResponseText = N'FAILED'

        Declare @objXmlHttp int
        Declare @hResult int
        Declare @source varchar(255), @desc varchar(255) 

        Set @ErrorCode = -100
        Exec @hResult = sp_OACreate N'MSXML2.ServerXMLHTTP', @objXmlHttp OUT
        IF (@hResult <> 0 ) Begin
            Exec sp_OAGetErrorInfo @objXmlHttp, @source OUT, @desc OUT
            Select hResult = convert(varbinary(4), @hResult), 
                        source = @source, 
                        description = @desc, 
                        FailPoint = N'Create failed MSXML2.ServerXMLHTTP', 
                        MedthodName = @MethodName 
            RaisError (N'Create failed MSXML2.ServerXMLHTTP.',16,1);
        End--if

        Set @ErrorCode = -2
        -- open the destination URI with Specified method 
        Exec @hResult = sp_OAMethod @objXmlHttp, N'open', Null, @MethodName, @URI, N'false', @UserName, @Password
        if (@hResult <> 0 ) Begin
            Exec sp_OAGetErrorInfo @objXmlHttp, @source OUT, @desc OUT
            Select hResult = convert(varbinary(4), @hResult), 
                source = @source, 
                description = @desc, 
                FailPoint = N'Open failed', 
                MedthodName = @MethodName 
            RaisError (N'Open failed.',16,1);
        End--if

        Set @ErrorCode = -300
        -- Set Timeout 
        --Exec @hResult = sp_OAMethod @objXmlHttp, N'setTimeouts', Null, 5000,5000,15000,30000
        Exec @hResult = sp_OAMethod @objXmlHttp, N'setTimeouts', Null, 10000,10000,30000,60000
        if (@hResult <> 0 ) Begin
            Exec sp_OAGetErrorInfo @objXmlHttp, @source OUT, @desc OUT
            Select hResult = convert(varbinary(4), @hResult), 
                source = @source, 
                description = @desc, 
                FailPoint = N'SetTimeouts failed', 
                MedthodName = @MethodName 
            RaisError (N'SetTimeouts failed.',16,1);
        End--if

        Set @ErrorCode = -400
        -- set request headers 
        Exec @hResult = sp_OAMethod @objXmlHttp, N'setRequestHeader', Null, N'Content-Type', 'text/xml;charset=UTF-8'
        if (@hResult <> 0 ) Begin
            Exec sp_OAGetErrorInfo @objXmlHttp, @source OUT, @desc OUT
            Select      hResult = convert(varbinary(4), @hResult), 
                source = @source, 
                description = @desc, 
                FailPoint = N'SetRequestHeader failed', 
                MedthodName = @MethodName 
            RaisError (N'SetRequestHeader (Content-Type) failed.',16,1);
        End--if

        Set @ErrorCode = -500
        -- set soap action 
        if (IsNull(@SoapAction,'')!='') Begin
            Exec @hResult = sp_OAMethod @objXmlHttp, N'setRequestHeader', Null, N'SOAPAction', @SoapAction 
            IF (@hResult <> 0 ) Begin
                Exec sp_OAGetErrorInfo @objXmlHttp, @source OUT, @desc OUT
                Select hResult = convert(varbinary(4), @hResult), 
                    source = @source, 
                    description = @desc, 
                    FailPoint = N'SetRequestHeader (SOAPAction) failed', 
                    MedthodName = @MethodName 
                RaisError (N'SetRequestHeader failed.',16,1);
            End--if
        End--if

        Set @ErrorCode = -600
        --Content-Length
        Declare @len int
        set @len = len(@RequestBody) 
        Exec @hResult = sp_OAMethod @objXmlHttp, N'setRequestHeader', Null, N'Content-Length', @len 
        IF (@hResult <> 0 ) Begin
            Exec sp_OAGetErrorInfo @objXmlHttp, @source OUT, @desc OUT
            Select hResult = convert(varbinary(4), @hResult), 
                source = @source, 
                description = @desc, 
                FailPoint = N'SetRequestHeader (Content-Length) failed', 
                MedthodName = @MethodName 
            RaisError (N'SetRequestHeader failed.',16,1);
        End--if

        -- if you have headers in a Table called RequestHeader you can go through them with this 
        /* 
        Set @ErrorCode = -700
        Declare @HeaderKey varchar(500), @HeaderValue varchar(500) 
        Declare RequestHeader CURSOR
        LOCAL FAST_FORWARD 
        FOR
              Select      HeaderKey, HeaderValue 
              FROM RequestHeaders 
              WHERE       Method = @MethodName 
        OPEN RequestHeader 
        FETCH NEXT FROM RequestHeader 
        INTO @HeaderKey, @HeaderValue 
        WHILE @@FETCH_STATUS = 0 
        BEGIN
            Set @ErrorCode = -800
              --Select @HeaderKey, @HeaderValue, @MethodName 
              Exec @hResult = sp_OAMethod @objXmlHttp, 'setRequestHeader', Null, @HeaderKey, @HeaderValue 
              IF @hResult <> 0 
              BEGIN
                    Set @ErrorCode = -900
                    Exec sp_OAGetErrorInfo @objXmlHttp, @source OUT, @desc OUT
                    Select      hResult = convert(varbinary(4), @hResult), 
                          source = @source, 
                          description = @desc, 
                          FailPoint = 'SetRequestHeader failed', 
                          MedthodName = @MethodName 
                    RaisError (N'SetRequestHeader failed.',16,1);
              END
              FETCH NEXT FROM RequestHeader 
              INTO @HeaderKey, @HeaderValue 
        END
        CLOSE RequestHeader 
        DEALLOCATE RequestHeader 
        */ 

        Set @ErrorCode = -1000
        -- send the request 
        Exec @hResult = sp_OAMethod @objXmlHttp, N'send', Null, @RequestBody 
        IF (@hResult <> 0 ) Begin
            Exec sp_OAGetErrorInfo @objXmlHttp, @source OUT, @desc OUT
            Select hResult = convert(varbinary(4), @hResult), 
                source = @source, 
                description = @desc, 
                FailPoint = N'Send failed', 
                MedthodName = @MethodName 
            RaisError (N'Send failed.',16,1);
        End--if
        Declare @StatusText varchar(1000), @Status varchar(1000) 
        
        Set @ErrorCode = -1100
        -- Get status text 
        Exec sp_OAGetProperty @objXmlHttp, N'StatusText', @StatusText out
        Exec sp_OAGetProperty @objXmlHttp, N'Status', @Status out
        --Select @Status As Status, @StatusText As statusText, @MethodName As MethodName -- убираем не нужный select
        -- Get response text 
        Declare @Json Table (Result ntext)
        Declare @Xml xml

        Set @ErrorCode = -1200
        Insert  @Json(Result)
        Exec @hResult = dbo.sp_OAGetProperty @objXmlHttp, N'ResponseText'

        Set @ErrorCode = -1300
        --Exec @hResult = dbo.sp_OAGetProperty @objXmlHttp, N'ResponseText', @ResponseText out
        IF (@hResult <> 0 ) Begin
            Exec sp_OAGetErrorInfo @objXmlHttp, @source OUT, @desc OUT
            Select hResult = convert(varbinary(4), @hResult), 
                source = @source, 
                description = @desc, 
                FailPoint = N'ResponseText failed', 
                MedthodName = @MethodName 
            RaisError (N'ResponseText failed.',16,1);
        END--if
        
        Set @ErrorCode = -1400
        --Set @ResponseText=Replicate(Convert(varchar(max),N'1'),1000000)
        if (IsNull(@SoapAction,'')!='') Begin
            Select @Xml=CAST(Replace(Replace(Replace(Cast(Result As nvarchar(max)),N'utf-8',N'utf-16'),N'.0,',N','),N'.00,',N',') As XML)
            From @Json
            
            Set @ErrorCode = -1500
            Select @ResponseText = x.Rec.query(N'./*').value('.',N'nvarchar(max)')
            From @Xml.nodes(N'.') as x(Rec)
            
        End--if 
        Else Begin
            Select @ResponseText= Result From @Json
        End--Else

        Set @ErrorCode = -1600
        --Export To File
        if (IsNull(@ExportToFile,'')!='') Begin
            Declare @objToFile int
            Declare @FileID     int

            Set @ErrorCode = -1700
            --Create Object
            Exec @hResult = sp_OACreate 'Scripting.FileSystemObject', @objToFile OUT 
            IF (@hResult <> 0 ) Begin
                Exec sp_OAGetErrorInfo @objXmlHttp, @source OUT, @desc OUT
                Select hResult = convert(varbinary(4), @hResult), 
                            source = @source, 
                            description = @desc, 
                            FailPoint = N'Create failed Scripting.FileSystemObject', 
                            MedthodName = @MethodName 
                RaisError (N'Create failed Scripting.FileSystemObject.',16,1);
            End--if

            Set @ErrorCode = -1800
            --Create Or Open File
            Exec @hResult = sp_OAMethod @objToFile, 'OpenTextFile'  , @FileID OUT, @ExportToFile,2,1,-1
            if (@hResult <> 0 ) Begin
                Exec sp_OAGetErrorInfo @objXmlHttp, @source OUT, @desc OUT
                Select hResult = convert(varbinary(4), @hResult), 
                    source = @source, 
                    description = @desc, 
                    FailPoint = N'OpenTextFile failed', 
                    MedthodName = @MethodName 
                RaisError (N'OpenTextFile failed.',16,1);
            End--if

            Set @ErrorCode = -1900
            --Write Data To File
            Exec @hResult = sp_OAMethod  @FileID, 'Write', Null, @ResponseText
            if (@hResult <> 0 ) Begin
                Exec sp_OAGetErrorInfo @objXmlHttp, @source OUT, @desc OUT
                Select hResult = convert(varbinary(4), @hResult), 
                    source = @source, 
                    description = @desc, 
                    FailPoint = N'Write To File failed', 
                    MedthodName = @MethodName 
                RaisError (N'Write To File failed.',16,1);
            End--if

            Set @ErrorCode = -2000
            --Close File
            Exec sp_OAMethod  @FileID, 'Close'
            --Delete Objects
            Exec sp_OADestroy @FileID 
            Exec sp_OADestroy @objToFile 
            
        End--if

        Set @ErrorCode = 0
        /*If (@@TranCount > 0)
            Commit Transaction HttpRequest*/
    End Try
    Begin Catch
        /*If (@@TranCount > 0)
            Rollback Transaction HttpRequest*/
    End Catch
    Exec sp_OADestroy @objXmlHttp
    Return @ErrorCode

/*
---------------------------------
--Example For Run Soap WebService - SOAP
DECLARE @RC int
DECLARE @URI varchar(max)
DECLARE @MethodName sysname
DECLARE @RequestBody nvarchar(max)
DECLARE @SoapAction varchar(500)
DECLARE @UserName sysname=''
DECLARE @Password sysname=''
DECLARE @ResponseText nvarchar(max)
DECLARE @intA   nvarchar(10)
DECLARE @intB   nvarchar(10)
Set @intA = N'100'
Set @intB = N'200'
Set @URI = N'http://www.dneonline.com/calculator.asmx'
Set @MethodName = N'POST'
Set @RequestBody = 
N'<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
            xmlns:xsd="http://www.w3.org/2001/XMLSchema" 
            xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
        <soap:Body>
        <Add xmlns="http://tempuri.org/"><intA>'+@intA+'</intA><intB>'+@intB+'</intB></Add>
        </soap:Body>
    </soap:Envelope>'
Set @SoapAction = N'http://tempuri.org/Add'
EXECUTE @RC = [dbo].[HttpRequest] 
   @URI
  ,@MethodName
  ,@RequestBody
  ,@SoapAction
  ,@UserName
  ,@Password
  ,@ResponseText OUTPUT
Print @ResponseText
Print Len(@ResponseText)
Go
---------------------------------
--Example For Feach Data From Website - GET in file
DECLARE @RC int
DECLARE @URI varchar(max)
DECLARE @MethodName sysname
DECLARE @RequestBody nvarchar(max)
DECLARE @SoapAction varchar(500)
DECLARE @UserName sysname
DECLARE @Password sysname
DECLARE @ResponseText nvarchar(max)
Declare @ExportToFile   nvarchar(max)
Set @URI = N'https://stackoverflow.com/questions/17407338/how-can-i-make-http-request-from-sql-server'
Set @MethodName = N'GET'
Set @RequestBody = N''
Set @SoapAction = N''
Set @ExportToFile = N'C:\Temp\Export\{RandomFileName}.html'
EXECUTE @RC = [dbo].[HttpRequest] 
   @URI
  ,@MethodName
  ,@RequestBody
  ,@SoapAction
  ,@UserName
  ,@Password
  ,@ResponseText OUTPUT
  ,@ExportToFile
*/