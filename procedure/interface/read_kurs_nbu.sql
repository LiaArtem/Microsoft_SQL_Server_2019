CREATE PROCEDURE [dbo].[read_kurs_nbu]
	@p_date date,
	@p_format nvarchar(4) = 'json', -- json, xml
	@p_currency nvarchar(3) = '' -- UAH, USD, EUR
AS
BEGIN
   -- Курсы валют НБУ
   DECLARE @p_url           NVARCHAR(255) = '';
   DECLARE @p_response_body NVARCHAR(MAX);
   DECLARE @p_dop_param     NVARCHAR(5) = '';
   DECLARE @p_date_str		NVARCHAR(30);   
   DECLARE @p_XML			XML;
   DECLARE @p_read_kurs_nbu AS [dbo].[t_read_kurs_nbu];

   IF @p_format = 'json' 
		SET @p_dop_param = '&json'

   -- получение даты в текстовом виде
   EXECUTE [dbo].[date_to_str] @p_date = @p_date, @p_format = 'yyyymmdd', @p_rezult = @p_date_str output

   IF @p_currency is null     
       SET @p_url = 'https://bank.gov.ua/NBUStatService/v1/statdirectory/exchange?date=' + @p_date_str + @p_dop_param;
   else
       SET @p_url = 'https://bank.gov.ua/NBUStatService/v1/statdirectory/exchange?valcode=' + @p_currency + '&date=' + @p_date_str + @p_dop_param;  

   -- запрашиваем данные
   EXECUTE [dbo].[CLR_HttpRequest] --[HttpRequest] пришлось убрать так как из-за нее результат пустой если использовать внутри других процедур
     @p_URI = @p_url,
     @p_MethodName = 'GET',
	 @p_RequestBody = '',
	 @p_EncodingCode = 'utf-8',
	 @p_ContentType = '',
	 @p_ResponseText = @p_response_body output 
      
   -- JSON формат
   IF @p_format = 'json' and (SELECT [dbo].[is_valid_json] (@p_response_body)) = 'T'
      BEGIN		
		   INSERT INTO @p_read_kurs_nbu (r030, txt, rate, cc, exchangedate)
		        SELECT [dbo].[lpad] (t.r030,3,'0') as r030,
                        t.txt,
                        [dbo].[str_to_num_func] (t.rate) as rate,
                        t.cc,
                        [dbo].[str_to_date_func] (t.exchangedate, default) as exchangedate
                FROM OPENJSON(@p_response_body)
                WITH (r030 NVARCHAR(3) '$.r030',
                        txt  NVARCHAR(255) '$.txt',
                        rate NVARCHAR(255) '$.rate',
                        cc   NVARCHAR(255) '$.cc',
                        exchangedate NVARCHAR(255) '$.exchangedate') as t
	  END
   
   -- XML формат   
   IF @p_format = 'xml' and (SELECT [dbo].[is_valid_xml] (@p_response_body)) = 'T'
      BEGIN
	    SET @p_XML = CAST([dbo].[str_xml_format](@p_response_body) AS XML);		  	

		   INSERT INTO @p_read_kurs_nbu (r030, txt, rate, cc, exchangedate)
            SELECT [dbo].[lpad](x.n.value('r030[1]','nvarchar(3)'),3,'0') as r030,
				   x.n.value('txt[1]','nvarchar(255)') as txt,
				   [dbo].[str_to_num_func](x.n.value('rate[1]','nvarchar(255)')) as rate,
				   x.n.value('cc[1]','nvarchar(255)') as cc,
				   [dbo].[str_to_date_func] (x.n.value('exchangedate[1]','nvarchar(255)'), default) as exchangedate
              FROM @p_XML.nodes('exchange/currency/.') x(n)		
	  END

   -- возвращаем значение
   SET NOCOUNT ON;
   SELECT * FROM @p_read_kurs_nbu
END