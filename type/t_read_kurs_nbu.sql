CREATE TYPE [dbo].[t_read_kurs_nbu]
	AS TABLE
      ( r030 NVARCHAR(3), 
        txt  NVARCHAR(MAX),
        rate MONEY, 
        cc   NVARCHAR(3), 
        exchangedate DATE
      );
