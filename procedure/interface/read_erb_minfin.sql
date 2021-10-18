CREATE PROCEDURE [dbo].[read_erb_minfin]
	@p_categoryCode nvarchar(2) = '', 
	@p_identCode nvarchar(100) = '',
	@p_lastName nvarchar(100) = '',
	@p_firstName nvarchar(100) = '',
	@p_middleName nvarchar(100) = '',
	@p_birthdate date = '',
	@p_type_cust_code nvarchar(1)	
AS
      -- НАИС - поиск контрагента в ЕРД (едином реестре должников)
      -- Получить данные
      -- select * from read_erb_minfin(p_identcode => '33270581', p_type_cust_code => '2')    
      -- select * from read_erb_minfin(p_identCode => '2985108376', p_type_cust_code => '1')
	  -- select * from read_erb_minfin(p_lastName       => 'Бондарчук',
	  --	                           p_firstName      => 'Ігор',
	  --                               p_middleName     => 'Володимирович',
	  --                               p_birthDate      => '23.09.1981',
	  --                               p_type_cust_code => '1')
      DECLARE @p_url           nvarchar(255);
      DECLARE @p_response_body nvarchar(max);
      DECLARE @p_request_body  nvarchar(max);
      DECLARE @p_num           int = 1;
      DECLARE @p_erb_minfin	   AS [dbo].[t_erb_minfin]; 
	  DECLARE @p_date_str	   NVARCHAR(30);
	  DECLARE @p_errMsg		   nvarchar(max);	
BEGIN
      SET @p_url = 'https://erb.minjust.gov.ua/listDebtorsEndpoint';

      -- получение даты в текстовом виде
	  IF @p_birthdate is not null
           EXECUTE [dbo].[date_to_str] @p_date = @p_birthDate, @p_format = 'yyyy-mm-dd', @p_rezult = @p_date_str output

      -- физ. лица
      IF @p_type_cust_code = '1'
          SET @p_request_body = (
  			 SELECT
				'1' AS searchType, 
				'1' AS paging, 
				@p_lastName AS "filter.LastName", 
				@p_firstName AS "filter.FirstName", 
				@p_middleName AS "filter.MiddleName", 
				case when @p_birthDate is null then null else @p_date_str + 'T00:00:00.000Z' end AS "filter.BirthDate",
				@p_identCode AS "filter.IdentCode", 
				@p_categoryCode AS "filter.categoryCode"
			  FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
			  );
      ELSE
      -- юр. лица        
          SET @p_request_body = (
  			 SELECT
				'2' AS searchType, 				
				@p_lastName AS "filter.FirmName", 
				@p_identCode AS "filter.FirmEdrpou", 
				@p_categoryCode AS "filter.categoryCode"
			  FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
			  );
      
      -- запрашиваем данные
      EXECUTE [dbo].[CLR_HttpRequest]
		 @p_URI = @p_url,
		 @p_MethodName = 'POST',
		 @p_RequestBody = @p_request_body,
		 @p_EncodingCode = 'utf-8',
		 @p_ContentType = 'application/json; charset=UTF-8',
		 @p_ResponseText = @p_response_body output           
       
      IF (SELECT [dbo].[is_valid_json] (@p_response_body)) = 'T'
	     BEGIN	
            SELECT t.isSuccess,
				   t.num_rows,
				   [dbo].[get_datetime](t.requestDate) as requestDate,
				   t.isOverflow,
				   t.errMsg,
				   ---------------------------------------------------------
				   y.num_id,
				   y.root_id,
    			   y.lastname,
				   y.firstname,
				   y.middlename,
				   [dbo].[get_datetime](y.birthdate) as birthdate,
				   y.publisher,
				   y.departmentcode,
				   y.departmentname,
				   y.departmentphone,
				   y.executor,
				   y.executorphone,
				   y.executoremail,
				   y.deductiontype,
				   y.vpnum,
				   y.okpo,
				   y.full_name
              INTO #temp_table_read_erb_minfin_json     
              FROM OPENJSON(@p_response_body)
              WITH (isSuccess   NVARCHAR(MAX) '$.isSuccess',
                    num_rows    NUMERIC       '$.rows',
                    requestDate NVARCHAR(255) '$.requestDate',
                    isOverflow  NVARCHAR(MAX) '$.isOverflow',
					errMsg	    NVARCHAR(MAX) '$.errMsg',
                    [results]   NVARCHAR(MAX) AS JSON
                    ) as t
               OUTER APPLY OPENJSON(t.results, '$')
               WITH (num_id   NUMERIC '$.ID',
                     root_id  NUMERIC '$.rootID',
                     lastname NVARCHAR(max) '$.lastName',
					 firstName NVARCHAR(max) '$.firstName',
					 middleName NVARCHAR(max) '$.middleName',
					 birthDate NVARCHAR(255) '$.birthDate',
					 publisher NVARCHAR(max) '$.publisher',
					 departmentCode NVARCHAR(max) '$.departmentCode',
					 departmentName NVARCHAR(max) '$.departmentName',
					 departmentPhone NVARCHAR(max) '$.departmentPhone',
					 executor NVARCHAR(max) '$.executor',
					 executorPhone NVARCHAR(max) '$.executorPhone',
					 executorEmail NVARCHAR(max) '$.executorEmail',
					 deductionType NVARCHAR(max) '$.deductionType',
					 vpNum NVARCHAR(max) '$.vpNum',
					 okpo NVARCHAR(max) '$.code',
					 full_name NVARCHAR(max) '$.name'
                     ) as y

		  SET NOCOUNT ON;
		  SET @p_errMsg = (SELECT max(t.errMsg) FROM #temp_table_read_erb_minfin_json t);

          IF @p_errMsg is not null             
			 RAISERROR('%s == %s', 1, 2, @p_request_body, @p_errMsg) WITH SETERROR;

          -- наполняем данными из временной таблицы
          INSERT INTO @p_erb_minfin
               SELECT * FROM #temp_table_read_erb_minfin_json t
               
          -- удаляем временную таблицу 
          drop table #temp_table_read_erb_minfin_json

	  END

   -- возвращаем значение
   SET NOCOUNT ON;
   SELECT * FROM @p_erb_minfin

END