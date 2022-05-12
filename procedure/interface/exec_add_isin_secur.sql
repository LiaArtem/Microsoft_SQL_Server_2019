CREATE PROCEDURE [dbo].[exec_add_isin_secur]
		@p_id int
AS
BEGIN
  DECLARE @m_error_message NVARCHAR(MAX);   

  BEGIN TRY 
    -- Загрузка с внешнего сервиса Перечень ISIN ЦБ с купонными периодами с записью в таблицу
	-- Получение данных
    CREATE TABLE #tmp (cpcode        NVARCHAR(255),
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
   
    INSERT INTO #tmp
	EXECUTE [dbo].[exec_read_isin_secur]
		@p_id = @p_id;

    ------------------------------------------------------------
    -- Обновление таблицы ISIN_SECUR
    ------------------------------------------------------------
    MERGE ISIN_SECUR AS target
    USING (SELECT DISTINCT 
	              t.cpcode,
                  t.nominal,
	              t.auk_proc,
	              t.pgs_date,
	              t.razm_date,
	              t.cptype,
	              t.cpdescr,
	              t.pay_period,
	              cur.CODE,
	              t.emit_okpo,
	              t.emit_name,
	              t.cptype_nkcpfr,
	              t.cpcode_cfi,
	              t.total_bonds
           FROM #tmp t
		   INNER JOIN CURRENCY cur ON cur.SHORT_NAME = t.val_code
          ) AS source ( isin,
                        nominal,
	                    auk_proc,
	                    pgs_date,
	                    razm_date,
	                    cptype,
	                    cpdescr,
	                    pay_period,
						currency_code,	              
	                    emit_okpo,
	                    emit_name,
	                    cptype_nkcpfr,
	                    cpcode_cfi,
	                    total_bonds
                      )
    ON (target.ISIN = source.isin)
    
    WHEN NOT MATCHED
        THEN INSERT(ISIN,
                    NOMINAL,
	                AUK_PROC,
	                PGS_DATE,
	                RAZM_DATE,
	                CPTYPE,
	                CPDESCR,
	                PAY_PERIOD,
					CURRENCY_CODE,	              
	                EMIT_OKPO,
	                EMIT_NAME,
	                CPTYPE_NKCPFR,
	                CPCODE_CFI,
	                TOTAL_BONDS
				   ) 
		     VALUES (
			        source.isin,
                    source.nominal,
	                source.auk_proc,
	                source.pgs_date,
	                source.razm_date,
	                source.cptype,
	                source.cpdescr,
	                source.pay_period,
					source.currency_code,	              
	                source.emit_okpo,
	                source.emit_name,
	                source.cptype_nkcpfr,
	                source.cpcode_cfi,
	                source.total_bonds
					) -- вставка
    ;

	------------------------------------------------------------
    -- Обновление таблицы ISIN_SECUR_PAY
    ------------------------------------------------------------
    MERGE ISIN_SECUR_PAY AS target
    USING (SELECT sec.ID as isin_secur_id,
				  t.pay_date,
	              t.pay_type,
	              t.pay_val
           FROM #tmp t
		   INNER JOIN ISIN_SECUR sec ON sec.ISIN = t.cpcode
          ) AS source ( isin_secur_id,
	                    pay_date,
	                    pay_type,
	                    pay_val
                      )
    ON (target.ISIN_SECUR_ID = source.isin_secur_id AND target.PAY_DATE = source.pay_date AND target.PAY_TYPE = source.pay_type)
    
    WHEN NOT MATCHED
        THEN INSERT(ISIN_SECUR_ID,
                    PAY_DATE,
	                PAY_TYPE,
	                PAY_VAL
				   ) 
		     VALUES (
			        source.isin_secur_id,
	                source.pay_date,
	                source.pay_type,
	                source.pay_val
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

