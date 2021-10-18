CREATE PROCEDURE [dbo].[add_kurs_nbu]
	@p_date date	
AS
BEGIN
    -- Загрузка с внешнего сервиса курсов с записью в таблицу
	-- Получение данных
    CREATE TABLE #tmp (r030 NVARCHAR(MAX), 
                       txt  NVARCHAR(MAX),
                       rate MONEY,
                       cc   NVARCHAR(MAX),
                       exchangedate DATE);
   
    INSERT INTO #tmp
	EXECUTE [dbo].[read_kurs_nbu]
		@p_date = @p_date,
		@p_format = default,
		@p_currency = default;

    -- Обновление таблицы списков валют
    MERGE CURRENCY AS target
    USING (SELECT t.r030, t.txt, t.cc
           FROM #tmp t
          ) AS source (r030, txt, cc)
    ON (target.CODE = source.r030)

    WHEN MATCHED AND target.NAME IS NOT NULL
        THEN UPDATE SET target.NAME = source.txt -- обновление

    WHEN NOT MATCHED
        THEN INSERT (CODE, NAME, SHORT_NAME) VALUES(source.r030, source.txt, source.cc) -- вставка
    ;
    --OUTPUT $action, inserted.*, deleted.*; -- можно вывести измененные строки

    -- Обновление таблицы курсов валют
    MERGE KURS AS target
    USING (SELECT t.r030, t.rate, 1 as forc, t.exchangedate
           FROM #tmp t
          ) AS source (r030, rate, forc, exchangedate)
    ON (target.CURRENCY_CODE = source.r030 AND target.KURS_DATE = source.exchangedate)
    
    WHEN NOT MATCHED
        THEN INSERT (CURRENCY_CODE, KURS_DATE, RATE, FORC) VALUES(source.r030, source.exchangedate, source.rate, source.forc) -- вставка
    ;
   -- удаляем временную таблицу 
   drop table #tmp;
END