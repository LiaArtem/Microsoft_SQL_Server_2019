CREATE PROCEDURE [dbo].[exec_read_fair_value]
	@p_id int
AS
BEGIN
   -- Справедливая стоимость ЦБ (котировки НБУ) (разворачивание из таблицы BUFF_IMPORT_DATA)
   DECLARE @p_data_type     NVARCHAR(255) = 'FairValue';   
   DECLARE @p_response_body NVARCHAR(MAX);      

   SET NOCOUNT ON;
   SELECT @p_response_body = b.DATA_VALUE
   FROM BUFF_IMPORT_DATA b
   WHERE b.ID = @p_id and b.DATA_TYPE =  @p_data_type and b.IS_ERROR is null;	 
    
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