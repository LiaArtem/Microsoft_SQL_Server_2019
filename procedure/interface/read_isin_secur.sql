CREATE PROCEDURE [dbo].[read_isin_secur]
	@p_format nvarchar(4) = 'json' -- json, xml	
AS
BEGIN
   -- Перечень ISIN ЦБ с купонными периодами
   DECLARE @p_url           NVARCHAR(255) = '';
   DECLARE @p_response_body NVARCHAR(MAX);
   DECLARE @p_dop_param     NVARCHAR(5) = '';
   DECLARE @p_XML			XML;
   DECLARE @p_read_isin_secur AS TABLE (cpcode        NVARCHAR(255),
	                                    nominal       NUMERIC,
	                                    auk_proc      NUMERIC,
	                                    pgs_date      DATE,
	                                    razm_date     DATE,
	                                    cptype        NVARCHAR(255),
	                                    cpdescr       NVARCHAR(255),
	                                    pay_period    NUMERIC,
	                                    val_code      NVARCHAR(3),
	                                    emit_okpo     NVARCHAR(255),
	                                    emit_name     NVARCHAR(255),
	                                    cptype_nkcpfr NVARCHAR(255),
	                                    cpcode_cfi    NVARCHAR(255),
	                                    total_bonds   NUMERIC,
	                                    pay_date      DATE,
	                                    pay_type      NUMERIC,
	                                    pay_val       NUMERIC,
	                                    pay_array     NVARCHAR(5)
                                        );

   IF @p_format = 'json' 
		SET @p_dop_param = '?json'
   
   SET @p_url = 'https://bank.gov.ua/depo_securities' + @p_dop_param;

   -- запрашиваем данные
   /*
   EXECUTE [dbo].[HttpRequest]
     @URI = @p_url,
     @MethodName = N'Get',
     @RequestBody = default,
     @SoapAction = default,
     @UserName = default,
     @Password = default,
     @ResponseText = @p_response_body output,
     @ExportToFile = default
   */
   -- пришлось убрать так как из-за нее результат пустой если использовать внутри других процедур
   EXECUTE [dbo].[CLR_HttpRequest]
     @p_URI = @p_url,
     @p_MethodName = 'GET',
	 @p_RequestBody = '',
	 @p_EncodingCode = 'utf-8',
	 @p_ContentType = '',
	 @p_ResponseText = @p_response_body output 
      
   -- JSON формат
   IF @p_format = 'json' and (SELECT [dbo].[is_valid_json] (@p_response_body)) = 'T'
      BEGIN	
            SELECT t.cpcode,
				   t.nominal,
                   [dbo].[str_to_num_func](t.auk_proc) as auk_proc,
                   [dbo].[str_to_date_func] (t.pgs_date,'yyyy.mm.dd') as pgs_date,
                   [dbo].[str_to_date_func] (t.razm_date,'yyyy.mm.dd') as razm_date,
				   t.cptype as cptype,
                   t.cpdescr as cpdescr,
                   t.pay_period as pay_period,
                   t.val_code as val_code,
                   t.emit_okpo as emit_okpo,
                   t.emit_name as emit_name,
                   t.cptype_nkcpfr as cptype_nkcpfr,
                   t.cpcode_cfi as cpcode_cfi,
                   t.total_bonds as total_bonds,
                   ---------------------------------------------------------
                   [dbo].[str_to_date_func] (y.pay_date,'yyyy.mm.dd') as pay_date,
                   y.pay_type as pay_type,
                   [dbo].[str_to_num_func](y.pay_val) as pay_val,
	               y.pay_array as pay_array
              INTO #temp_table_read_isin_secur_json     
              FROM OPENJSON(@p_response_body)
              WITH (cpcode    NVARCHAR(255) '$.cpcode',
                    nominal   NUMERIC '$.nominal',
                    auk_proc  NVARCHAR(255) '$.auk_proc',
                    pgs_date  NVARCHAR(255) '$.pgs_date',
                    razm_date NVARCHAR(255) '$.razm_date',
                    cptype    NVARCHAR(255) '$.cptype',
                    cpdescr   NVARCHAR(255) '$.cpdescr',
                    pay_period NUMERIC      '$.pay_period',
                    val_code  NVARCHAR(3)   '$.val_code',
                    emit_okpo NVARCHAR(255) '$.emit_okpo',
                    emit_name NVARCHAR(255) '$.emit_name',
                    cptype_nkcpfr NVARCHAR(255) '$.cptype_nkcpfr',
                    cpcode_cfi NVARCHAR(255) '$.cpcode_cfi',                                                
	                total_bonds NVARCHAR(255) '$.pay_period',
                    [payments] NVARCHAR(MAX) AS JSON
                    ) as t
               CROSS APPLY OPENJSON(t.payments, '$')
               WITH (pay_date   NVARCHAR(255) '$.pay_date',
                     pay_type   NUMERIC       '$.pay_type',
                     pay_val    NVARCHAR(255) '$.pay_val',
                     pay_array  NVARCHAR(255) '$.array'
                     ) as y

          -- наполняем данными из временной таблицы
          INSERT INTO @p_read_isin_secur
               SELECT * FROM #temp_table_read_isin_secur_json t
               
          -- удаляем временную таблицу 
          drop table #temp_table_read_isin_secur_json

	  END
   
   -- XML формат   
   IF @p_format = 'xml' and (SELECT [dbo].[is_valid_xml] (@p_response_body)) = 'T'
      BEGIN
	    SET @p_XML = CAST([dbo].[str_xml_format](@p_response_body) AS XML);		  	

            SELECT x.n.value('cpcode[1]','nvarchar(255)') as cpcode,
				   x.n.value('nominal[1]','numeric') as nominal,
                   [dbo].[str_to_num_func](x.n.value('auk_proc[1]','nvarchar(255)')) as auk_proc,
                   [dbo].[str_to_date_func] (x.n.value('pgs_date[1]','nvarchar(255)'),'yyyy.mm.dd') as pgs_date,
                   [dbo].[str_to_date_func] (x.n.value('razm_date[1]','nvarchar(255)'),'yyyy.mm.dd') as razm_date,
				   x.n.value('cptype[1]','nvarchar(255)') as cptype,
                   x.n.value('cpdescr[1]','nvarchar(255)') as cpdescr,
                   x.n.value('pay_period[1]','numeric') as pay_period,
                   x.n.value('val_code[1]','nvarchar(3)') as val_code,
                   x.n.value('emit_okpo[1]','nvarchar(255)') as emit_okpo,
                   x.n.value('emit_name[1]','nvarchar(255)') as emit_name,
                   x.n.value('cptype_nkcpfr[1]','nvarchar(255)') as cptype_nkcpfr,
                   x.n.value('cpcode_cfi[1]','nvarchar(255)') as cpcode_cfi,
                   x.n.value('pay_period[1]','numeric') as total_bonds,
                   ---------------------------------------------------------
                   [dbo].[str_to_date_func] (y.n.value('pay_date[1]','nvarchar(255)'),'yyyy.mm.dd') as pay_date,
                   y.n.value('pay_type[1]','numeric') as pay_type,
                   [dbo].[str_to_num_func](y.n.value('pay_val[1]','nvarchar(255)')) as pay_val,
	               y.n.value('array[1]','nvarchar(5)') as pay_array
              INTO #temp_table_read_isin_secur_xml     
              FROM @p_XML.nodes('securities/security/.') x(n)
              CROSS APPLY x.n.nodes('payments/payment/.') y(n)

          -- наполняем данными из временной таблицы
          INSERT INTO @p_read_isin_secur
               SELECT * FROM #temp_table_read_isin_secur_xml t
               
          -- удаляем временную таблицу 
          drop table #temp_table_read_isin_secur_xml
	  END

   -- возвращаем значение
   SET NOCOUNT ON;
   SELECT * FROM @p_read_isin_secur
END