CREATE PROCEDURE [dbo].[read_fair_value]
	@p_date date	
AS
BEGIN
   -- Справедливая стоимость ЦБ (котировки НБУ)
   DECLARE @p_url           NVARCHAR(255) = '';
   DECLARE @p_response_body NVARCHAR(MAX);   
   DECLARE @p_date_str		NVARCHAR(30);   

   -- получение даты в текстовом виде
   EXECUTE [dbo].[date_to_str] @p_date = @p_date, @p_format = 'yyyymmdd', @p_rezult = @p_date_str output

   SET @p_url = 'https://bank.gov.ua/files/Fair_value/' + SUBSTRING(@p_date_str, 1, 6) + '/' + @p_date_str + '_fv.txt';

   -- запрашиваем данные
   EXECUTE [dbo].[CLR_HttpRequest] --[HttpRequest] пришлось убрать так как из-за нее результат пустой если использовать внутри других процедур
     @p_URI = @p_url,
     @p_MethodName = 'GET',
     @p_RequestBody = '',
     @p_EncodingCode = 'windows-1251',
	 @p_ContentType = '',
	 @p_ResponseText = @p_response_body output     
    
	 -- возвращаем значение
     SET NOCOUNT ON;
	 SELECT f.*
	 FROM (
		 SELECT ROW_NUMBER() OVER(ORDER BY (select null)) AS RowNumber, 		   
		        [dbo].[str_to_date_func]([dbo].[split_part] (t.value, default, 1), default) as calc_date,
		        [dbo].[split_part] (t.value, default, 2) as cpcode,
		        [dbo].[split_part] (t.value, default, 3) as ccy,	   
		        [dbo].[str_to_num_func]([dbo].[split_part] (t.value, default, 4)) as fair_value,
		        [dbo].[str_to_num_func]([dbo].[split_part] (t.value, default, 5)) as ytm,	   
		        [dbo].[str_to_num_func]([dbo].[split_part] (t.value, default, 6)) as clean_rate,
		        [dbo].[str_to_num_func]([dbo].[split_part] (t.value, default, 7)) as cor_coef,	   
		        [dbo].[str_to_date_func]([dbo].[split_part] (t.value, default, 8), default) as maturity,
		        [dbo].[str_to_num_func]([dbo].[split_part] (t.value, default, 9)) as cor_coef_cash,	   
		        [dbo].[str_to_num_func]([dbo].[split_part] (t.value, default, 10)) as notional,
		        [dbo].[str_to_num_func]([dbo].[split_part] (t.value, default, 11)) as avr_rate,	   
		        [dbo].[str_to_num_func]([dbo].[split_part] (t.value, default, 12)) as option_value,
		        [dbo].[str_to_num_func]([dbo].[split_part] (t.value, default, 13)) as intrinsic_value,	   
		        [dbo].[str_to_num_func]([dbo].[split_part] (t.value, default, 14)) as time_value,
		        [dbo].[str_to_num_func]([dbo].[split_part] (t.value, default, 15)) as delta_per,	   
		        [dbo].[str_to_num_func]([dbo].[split_part] (t.value, default, 16)) as delta_equ,
				[dbo].[split_part] (t.value, default, 17) as dop
		 FROM STRING_SPLIT(@p_response_body, char(13)) as t
		 ) f
     WHERE f.RowNumber > 1 and f.calc_date is not null
END