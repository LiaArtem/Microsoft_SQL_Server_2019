CREATE PROCEDURE [dbo].[add_kurs_nbu_ssis]
AS
   DECLARE @m_CURRENCY_CODE nvarchar(3), @m_CURRENCY_CODE_EXT nvarchar(3), @m_KURS_DATE date, @m_RATE money, @m_FORC int, @m_HASH_COLIMN VARBINARY(64), @m_Id int
   DECLARE @m_error_message nvarchar(255)
   DECLARE @tbl TABLE (ID int)

   DECLARE my_cur CURSOR FOR 
     SELECT cur.CODE AS CURRENCY_CODE, t.CURRENCY_CODE, t.KURS_DATE, t.RATE, t.FORC, t.HASH_COLIMN
     FROM KURS_SSIS t  
	 LEFT OUTER JOIN CURRENCY cur on (t.CURRENCY_CODE = cur.SHORT_NAME)     
     WHERE t.ID is null    
BEGIN
    -- Загрузка с внешнего сервиса SSIS курсов с записью в таблицу
    OPEN my_cur
    FETCH NEXT FROM my_cur INTO @m_CURRENCY_CODE, @m_CURRENCY_CODE_EXT, @m_KURS_DATE, @m_RATE, @m_FORC, @m_HASH_COLIMN
   
    WHILE @@FETCH_STATUS = 0 -- пока не закончатся строки в курсоре
    BEGIN
      BEGIN TRANSACTION      
      BEGIN TRY        
        IF @m_CURRENCY_CODE IS NULL
          BEGIN
            SET @m_error_message = CONCAT('Не найден код валюты CURRENCY.CODE = ', @m_CURRENCY_CODE_EXT);
            THROW 51000, @m_error_message, 1;
          END

        SELECT @m_Id = MAX(k.Id)
        FROM KURS k
        WHERE k.CURRENCY_CODE = @m_CURRENCY_CODE and k.KURS_DATE = @m_KURS_DATE;	            

        IF @m_Id IS NULL        
           BEGIN
              INSERT INTO KURS (CURRENCY_CODE, KURS_DATE, RATE, FORC)   
              OUTPUT inserted.Id INTO @tbl
                 VALUES (@m_CURRENCY_CODE, @m_KURS_DATE, @m_RATE, @m_FORC);
              
              SELECT @m_Id = ID FROM @tbl; -- так как IDENT_CURRENT('KURS'); возвращает пустоту

              UPDATE KURS_SSIS
              SET ID = @m_Id,
                  EVENT_CODE = 'I', 
                  ERROR_CODE = 0, 
                  ERROR_MESSAGE = NULL
              WHERE HASH_COLIMN = @m_HASH_COLIMN; 
           END
        ELSE
              UPDATE KURS_SSIS
              SET ID = @m_Id,
                  EVENT_CODE = 'U', 
                  ERROR_CODE = 0,
                  ERROR_MESSAGE = NULL
              WHERE HASH_COLIMN = @m_HASH_COLIMN;        
        
        COMMIT TRANSACTION;
      END TRY
      BEGIN CATCH
        ROLLBACK TRANSACTION; 

        UPDATE KURS_SSIS
        SET ERROR_CODE = ERROR_NUMBER(), 
            ERROR_MESSAGE = ERROR_MESSAGE()
        WHERE HASH_COLIMN = @m_HASH_COLIMN;        
      END CATCH

      --считываем следующую строку курсора
      FETCH NEXT FROM my_cur INTO @m_CURRENCY_CODE, @m_CURRENCY_CODE_EXT, @m_KURS_DATE, @m_RATE, @m_FORC, @m_HASH_COLIMN
    END
   
    CLOSE my_cur
    DEALLOCATE my_cur
    
END