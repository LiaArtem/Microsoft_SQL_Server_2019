CREATE PROCEDURE [dbo].[exec_add_fair_value]
	@p_id int
AS
BEGIN
  DECLARE @m_error_message NVARCHAR(MAX);   

  BEGIN TRY 
    -- Загрузка с внешнего сервиса Справедливая стоимость ЦБ (котировки НБУ) с записью в таблицу
	-- Получение данных
    CREATE TABLE #tmp (RowNumber INT, 		   
		               calc_date DATE,
		               cpcode NVARCHAR(30),
		               ccy NVARCHAR(3),
   		               fair_value NUMERIC(38,16),
		               ytm NUMERIC(38,16),
		               clean_rate NUMERIC(38,16),
		               cor_coef NUMERIC(38,16),
		               maturity DATE,
		               cor_coef_cash NUMERIC(38,16),
		               notional NUMERIC(38,16),
		               avr_rate NUMERIC(38,16),
		               option_value NUMERIC(38,16),
		               intrinsic_value NUMERIC(38,16),
		               time_value NUMERIC(38,16),
		               delta_per NUMERIC(38,16),
		               delta_equ NUMERIC(38,16),
				       dop NVARCHAR(255)
                      );
   
    INSERT INTO #tmp
	EXECUTE [dbo].[exec_read_fair_value]
		@p_id = @p_id;

    -- Обновление таблицы
    MERGE FAIR_VALUE AS target
    USING (SELECT t.calc_date, 
   				  t.cpcode, 
				  cur.CODE, 
				  t.fair_value, 
				  t.ytm, 
				  t.clean_rate, 
				  t.cor_coef, 
				  t.maturity, 
			  	  t.cor_coef_cash, 
				  t.notional, 
				  t.avr_rate, 
				  t.option_value, 
				  t.intrinsic_value, 
				  t.time_value, 
				  t.delta_per, 
				  t.delta_equ, 
				  t.dop
           FROM #tmp t
		   INNER JOIN CURRENCY cur ON cur.SHORT_NAME = t.ccy
          ) AS source ( calc_date, 
   					    isin, 
						currency_code, 
						fair_value, 
						ytm, 
						clean_rate, 
						cor_coef, 
						maturity, 
						cor_coef_cash, 
						notional, 
						avr_rate, 
						option_value, 
						intrinsic_value, 
						time_value, 
						delta_per, 
						delta_equ, 
						dop
                      )
    ON (target.CALC_DATE = source.calc_date AND target.ISIN = source.isin AND target.CURRENCY_CODE = source.currency_code)
    
    WHEN NOT MATCHED
        THEN INSERT(CALC_DATE, 
   					ISIN, 
					CURRENCY_CODE, 
					FAIR_VALUE, 
					YTM, 
					CLEAN_RATE, 
					COR_COEF, 
					MATURITY, 
					COR_COEF_CASH, 
					NOTIONAL, 
					AVR_RATE, 
					OPTION_VALUE, 
					INTRINSIC_VALUE, 
					TIME_VALUE, 
					DELTA_PER, 
					DELTA_EQU, 
					DOP
				   ) 
		     VALUES (
		            source.calc_date,
		            source.isin,
		            source.currency_code,
   		            source.fair_value,
		            source.ytm,
		            source.clean_rate,
		            source.cor_coef,
		            source.maturity,
		            source.cor_coef_cash,
		            source.notional,
		            source.avr_rate,
		            source.option_value,
		            source.intrinsic_value,
		            source.time_value,
		            source.delta_per,
		            source.delta_equ,
				    source.dop
					) -- вставка
    ;
   -- удаляем временную таблицу 
   drop table #tmp;
   -- обновляем статус
   UPDATE BUFF_IMPORT_DATA
   SET IS_ERROR = 'F', ERROR_MESSAGE = null
   WHERE ID = @p_id;
 
 END TRY  
 BEGIN CATCH  
   -- обновляем статус
   EXECUTE [dbo].[get_error_info] @rezult = @m_error_message;

   UPDATE BUFF_IMPORT_DATA
   SET IS_ERROR = 'T', ERROR_MESSAGE = @m_error_message
   WHERE ID = @p_id;
 END CATCH;
END
