CREATE TABLE [dbo].[KURS]
(
	[Id] INT PRIMARY KEY NOT NULL DEFAULT (NEXT VALUE FOR dbo.SEQ_KURS),
    [CURRENCY_CODE] NVARCHAR(3) NOT NULL, 
    [KURS_DATE] DATE NOT NULL, 
    [RATE] MONEY NOT NULL, 
    [FORC] INT NOT NULL, 
    [SYS_DATE] DATETIME2 NOT NULL DEFAULT SYSDATETIME()    
    CONSTRAINT [CK_KURS_FORC] CHECK ([FORC]>(0)),
    CONSTRAINT [CK_KURS_RATE] CHECK ([RATE]>(0)), 
    CONSTRAINT [FK_KURS_CURRENCY_CODE] FOREIGN KEY ([CURRENCY_CODE]) REFERENCES [CURRENCY]([CODE])
)

GO

CREATE INDEX [I_KURS_CURR_CODE_AND_DATE] ON [dbo].[KURS] ([CURRENCY_CODE],[KURS_DATE])

GO

CREATE TRIGGER [dbo].[TR_KURS_HIST]
    ON [dbo].[KURS]
    AFTER DELETE, INSERT, UPDATE
    AS
    BEGIN
        IF (ROWCOUNT_BIG() = 0)
            RETURN;

        DECLARE @action as nvarchar(30) = 'INSERT';    
        IF EXISTS(SELECT * FROM DELETED)
            BEGIN
                SET @action = 
                    CASE
                        WHEN EXISTS(SELECT * FROM INSERTED) THEN 'UPDATE'
                        ELSE 'DELETE'      
                    END
            END
        ELSE 
            IF NOT EXISTS(SELECT * FROM INSERTED) 
                SET @action = ''
   
        -- Если добавление или обновление
        IF @action in ('INSERT', 'UPDATE')
            INSERT INTO KURS_HIST (CURRENCY_CODE, KURS_DATE, RATE, FORC, ACTION)
                SELECT CURRENCY_CODE, KURS_DATE, RATE, FORC, @action
                FROM INSERTED
        
        -- Если удаление
        IF @action in ('DELETE')
            INSERT INTO KURS_HIST (CURRENCY_CODE, KURS_DATE, RATE, FORC, ACTION)
              SELECT CURRENCY_CODE, KURS_DATE, RATE, FORC, @action
               FROM DELETED
    END