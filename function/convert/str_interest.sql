CREATE FUNCTION [dbo].[str_interest]
(
	@p_amount NUMERIC(38,8) -- точность 8 знаков
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
    -- Преобразование процента с тест (0,5678999% (нуль цiлих i п'ять мiльйонiв шiстсот сiмдесят вiсiм тисяч дев'ятсот дев'яносто дев'ять десятимільйонних процента))
    DECLARE @p_result      NVARCHAR(255) = '';       
    DECLARE @mFractionDR   BIGINT;
    DECLARE @tFractionDR   NVARCHAR(255);
    DECLARE @FractionType  NVARCHAR(255);
    DECLARE @mFractionCC   BIGINT;
    DECLARE @tFractionCC   NVARCHAR(255);
    DECLARE @FractionL     NVARCHAR(1);    
    --    
    SET @mFractionCC = convert(BIGINT, @p_amount); -- выделяем целую часть       
    SET @tFractionCC = convert(NVARCHAR(255), @mFractionCC);
    ---------------------------------------------------------
    SET @mFractionDR = (@p_amount - @mFractionCC)*100000000; -- выделяем дробную часть *100000000
    SET @tFractionDR = dbo.num_to_str(@mFractionDR); -- преобразуем в текст
    SET @tFractionDR = Right(Replicate('0', 10) + @tFractionDR, 10); -- дополнить до 8-ми
    SET @tFractionDR = substring(@tFractionDR, 1, len(@tFractionDR)-2); -- убираем .0    
    SET @tFractionDR = left(@tFractionDR, len(replace(@tFractionDR, '0', ' '))) -- убираем лишние 0 справа    
    SET @mFractionDR = convert(BIGINT, @tFractionDR) -- получение дробной суммы
    ---------------------------------------------------------
    if len(@tFractionDR) = 1 SET @FractionType = 'десятих'; else
    if len(@tFractionDR) = 2 SET @FractionType = 'сотих'; else
    if len(@tFractionDR) = 3 SET @FractionType = 'тисячних'; else
    if len(@tFractionDR) = 4 SET @FractionType = 'десятитисячних'; else
    if len(@tFractionDR) = 5 SET @FractionType = 'стотисячних'; else
    if len(@tFractionDR) = 6 SET @FractionType = 'мільйонних'; else
    if len(@tFractionDR) = 7 SET @FractionType = 'десятимільйонних'; else
    if len(@tFractionDR) = 8 SET @FractionType = 'стомільйонних';

    -- если дробной части нет
    IF @mFractionDR = 0
     BEGIN
      SET @p_result = dbo.num_to_str(@p_amount) + '% (' + dbo.str_amount(@p_amount, default);
      --
      SET @FractionL = substring(@tFractionCC, len(@tFractionCC), 1);           
      IF (@FractionL in ('0','5','6','7','8','9') or @p_amount in (11,12,13,14,15,16,17,18,19)) 
            SET @p_result = @p_result + ' процентiв)';
      ELSE IF @FractionL = '1' 
            SET @p_result = @p_result + ' процент)';
      ELSE IF @FractionL in ('2','3','4') 
            SET @p_result = @p_result + ' процента)';
      ELSE
         SET @p_result = @p_result + ' процента)';      
     END
    ELSE
     BEGIN
      SET @p_result = dbo.num_to_str(@p_amount) + '% (' + dbo.str_amount(@mFractionCC, '_WR');

      IF @tFractionCC = '1' -- если целая часть = 1
          SET @p_result = @p_result + ' цiла i ' + lower(dbo.str_amount(@mFractionDR, '_WR')) + ' ' + @FractionType;
      ELSE
          SET @p_result = @p_result + ' цiлих i ' + lower(dbo.str_amount(@mFractionDR, '_WR')) + ' ' + @FractionType;      

      SET @p_result = @p_result + ' процента)';
     END    

    SET @p_result = lower(@p_result);
    
    -- замена
    IF @FractionType is not null and substring(@tFractionDR, len(@tFractionDR), 1) = '1' and substring(@tFractionDR, len(@tFractionDR) - 1, 2) != '11'              
      BEGIN
        if len(@tFractionDR) = 1 SET @p_result = replace(@p_result, 'десятих', 'десята'); else
        if len(@tFractionDR) = 2 SET @p_result = replace(@p_result, 'сотих', 'сота'); else
        if len(@tFractionDR) = 3 SET @p_result = replace(@p_result, 'тисячних', 'тисячна'); else
        if len(@tFractionDR) = 4 SET @p_result = replace(@p_result, 'десятитисячних', 'десятитисячна'); else
        if len(@tFractionDR) = 5 SET @p_result = replace(@p_result, 'стотисячних', 'стотисячна'); else
        if len(@tFractionDR) = 6 SET @p_result = replace(@p_result, 'мільйонних', 'мільйонна'); else
        if len(@tFractionDR) = 7 SET @p_result = replace(@p_result, 'десятимільйонних', 'десятимільйонна'); else
        if len(@tFractionDR) = 8 SET @p_result = replace(@p_result, 'стомільйонних', 'стомільйонна');        
      END      

    RETURN replace(trim(substring(@p_result, 1, 255)), '.', ',');	
END
