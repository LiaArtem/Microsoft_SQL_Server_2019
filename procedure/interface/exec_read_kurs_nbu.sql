CREATE PROCEDURE [dbo].[exec_read_kurs_nbu]
	@p_id int
AS
BEGIN
   -- Курсы валют НБУ (разворачивание из таблицы BUFF_IMPORT_DATA)
   DECLARE @p_data_type     NVARCHAR(255) = 'KursIn';
   DECLARE @p_response_body NVARCHAR(MAX);   
   DECLARE @p_XML			XML;
   DECLARE @p_read_kurs_nbu AS [dbo].[t_read_kurs_nbu];

   SET NOCOUNT ON;
   SELECT @p_response_body = b.DATA_VALUE
   FROM BUFF_IMPORT_DATA b
   WHERE b.ID = @p_id and b.DATA_TYPE =  @p_data_type and b.IS_ERROR is null;	 
      
   -- JSON формат
   IF (SELECT [dbo].[is_valid_json] (@p_response_body)) = 'T'
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
   IF (SELECT [dbo].[is_valid_xml] (@p_response_body)) = 'T'
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