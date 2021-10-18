CREATE FUNCTION [dbo].[str_amount]
(
	@p_amount MONEY,
    @p_suffix NVARCHAR(3) = ''
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
    -- Преобразование суммы в текст             
    -- p_suffix - UAH, USD, EUR, GBP, CHF, RUB - валюта
    -- p_suffix - _WH - цiлих, сотих
    -- p_suffix - _WR - для %
    DECLARE @Res NVARCHAR(255), @a1 NVARCHAR(40), @a2 NCHAR(3), @b1 NCHAR(1), @b2 NCHAR(1), @b3 NCHAR(1)
    DECLARE @i int
    DECLARE @temp_amount money = @p_amount

    if @p_suffix = ''
         SET @temp_amount = floor(abs(@temp_amount))

    SET @a1 = Convert(NVARCHAR(255), abs(@temp_amount))    
    SET @i = CharIndex('.', @a1)
    if @i > 0
        SET @a1 = Substring(@a1,1,@i-1)

    -- единицы
    SET @a1 = Replicate(' ',20) + @a1
    SET @a2 = Right(@a1,3)
    SET @b1 = Substring(@a2, 1, 1)
    SET @b2 = Substring(@a2, 2, 1)
    SET @b3 = Substring(@a2, 3, 1)

    if @p_suffix in ('', '_WR')
        SET @Res = ' '
    
    if @b3 = '1' and @b2 != '1' 
        begin
         if @p_suffix = 'UAH' SET @Res = ' гривня' else
         if @p_suffix = 'USD' SET @Res = ' долар США' else
         if @p_suffix = 'EUR' SET @Res = ' євро' else
         if @p_suffix = 'GBP' SET @Res = ' англійських Фунт стерлінгів' else
         if @p_suffix = 'CHF' SET @Res = ' швейцарський франк' else
         if @p_suffix = 'RUB' SET @Res = ' російський рубль' else
         if @p_suffix = '_WH' SET @Res = ' цiлих'
       end
    else if @b3 in ('2','3','4') and @b2 != '1' 
        begin
         if @p_suffix = 'UAH' SET @Res = ' гривні' else
         if @p_suffix = 'USD' SET @Res = ' долари США' else
         if @p_suffix = 'EUR' SET @Res = ' євро' else
         if @p_suffix = 'GBP' SET @Res = ' англійських Фунти стерлінгів' else
         if @p_suffix = 'CHF' SET @Res = ' швейцарських франки' else
         if @p_suffix = 'RUB' SET @Res = ' російських рубля' else
         if @p_suffix = '_WH' SET @Res = ' цiлих'
       end        
    else 
        begin
         if @p_suffix = 'UAH' SET @Res = ' гривень' else
         if @p_suffix = 'USD' SET @Res = ' доларiв США' else
         if @p_suffix = 'EUR' SET @Res = ' євро' else
         if @p_suffix = 'GBP' SET @Res = ' англійських Фунтів стерлінгів' else
         if @p_suffix = 'CHF' SET @Res = ' швейцарських франків' else
         if @p_suffix = 'RUB' SET @Res = ' російських рублів' else
         if @p_suffix = '_WH' SET @Res = ' цiлих'
       end

    if @temp_amount = 0 SET @Res = ' нуль' + @Res    
    if @temp_amount >= 1
       BEGIN
            if @b2 = '1' 
              begin
                if @b3 = '0' SET @Res = ' десять' + @Res else
                if @b3 = '1' SET @Res = ' одинадцать' + @Res else
                if @b3 = '2' SET @Res = ' дванадцять' + @Res else
                if @b3 = '3' SET @Res = ' тринадцать' + @Res else
                if @b3 = '4' SET @Res = ' чотирнадцять' + @Res else
                if @b3 = '5' SET @Res = ' п''ятнадцять' + @Res else
                if @b3 = '6' SET @Res = ' шiстнадцять' + @Res else
                if @b3 = '7' SET @Res = ' сiмнадцять' + @Res else
                if @b3 = '8' SET @Res = ' вiсiмнадцять' + @Res else
                if @b3 = '9' SET @Res = ' дев''ятнадцять' + @Res
              end
            else
              begin
                if @p_suffix in ('UAH', '_WR')
                   BEGIN
                    if @b3 = '1' SET @Res = ' одна' + @Res else
                    if @b3 = '2' SET @Res = ' двi' + @Res else
                    if @b3 = '3' SET @Res = ' три' + @Res else
                    if @b3 = '4' SET @Res = ' чотири' + @Res else
                    if @b3 = '5' SET @Res = ' п''ять' + @Res else
                    if @b3 = '6' SET @Res = ' шiсть' + @Res else
                    if @b3 = '7' SET @Res = ' сiм' + @Res else
                    if @b3 = '8' SET @Res = ' вiсiм' + @Res else
                    if @b3 = '9' SET @Res = ' дев''ять' + @Res
                   END
                else
                   BEGIN
                    if @b3 = '1' SET @Res = ' один' + @Res else
                    if @b3 = '2' SET @Res = ' два' + @Res else
                    if @b3 = '3' SET @Res = ' три' + @Res else
                    if @b3 = '4' SET @Res = ' чотири' + @Res else
                    if @b3 = '5' SET @Res = ' п''ять' + @Res else
                    if @b3 = '6' SET @Res = ' шiсть' + @Res else
                    if @b3 = '7' SET @Res = ' сiм' + @Res else
                    if @b3 = '8' SET @Res = ' вiсiм' + @Res else
                    if @b3 = '9' SET @Res = ' дев''ять' + @Res
                   END

                if @b2 = '2' SET @Res = ' двадцять' + @Res else
                if @b2 = '3' SET @Res = ' тридцять' + @Res else
                if @b2 = '4' SET @Res = ' сорок' + @Res else
                if @b2 = '5' SET @Res = ' п''ятдесят' + @Res else
                if @b2 = '6' SET @Res = ' шiстдесят' + @Res else
                if @b2 = '7' SET @Res = ' сiмдесят' + @Res else
                if @b2 = '8' SET @Res = ' вiсiмдесят' + @Res else
                if @b2 = '9' SET @Res = ' дев''яносто' + @Res
              end
                if @b1 = '1' SET @Res = ' сто' + @Res else
                if @b1 = '2' SET @Res = ' двiстi' + @Res else
                if @b1 = '3' SET @Res = ' триста' + @Res else
                if @b1 = '4' SET @Res = ' чотириста' + @Res else
                if @b1 = '5' SET @Res = ' п''ятсот' + @Res else
                if @b1 = '6' SET @Res = ' шiстсот' + @Res else
                if @b1 = '7' SET @Res = ' сiмсот' + @Res else
                if @b1 = '8' SET @Res = ' вiсiмсот' + @Res else
                if @b1 = '9' SET @Res = ' дев''ятсот' + @Res
       END

    -- тисячи
    if @temp_amount >= 1000
       BEGIN
            SET @a1 = Substring(@a1,1,datalength(@a1)-3)
            SET @a2 = Right(@a1,3)
            SET @b1 = Substring(@a2,1,1)
            SET @b2 = Substring(@a2,2,1)
            SET @b3 = Substring(@a2,3,1)

            if @b3 = '0' and @b2 = '0' and @b1 = '0'
             SET @res = @res
            else
            begin
             if @b3 = '1' and @b2 != '1' 
              SET @Res = ' тисяча' + @Res 
             else if @b3 in ('2','3','4') and @b2 != '1' 
              SET @Res = ' тисячi' + @Res
             else if @a2 != '   '
              SET @Res = ' тисяч' + @Res
            end
            if @b2 = '1' 
              begin
                if @b3 = '0' SET @Res = ' десять' + @Res else
                if @b3 = '1' SET @Res = ' одинадцать' + @Res else
                if @b3 = '2' SET @Res = ' дванадцять' + @Res else
                if @b3 = '3' SET @Res = ' тринадцать' + @Res else
                if @b3 = '4' SET @Res = ' чотирнадцять' + @Res else
                if @b3 = '5' SET @Res = ' п''ятнадцять' + @Res else
                if @b3 = '6' SET @Res = ' шiстнадцять' + @Res else
                if @b3 = '7' SET @Res = ' сiмнадцять' + @Res else
                if @b3 = '8' SET @Res = ' вiсiмнадцять' + @Res else
                if @b3 = '9' SET @Res = ' дев''ятнадцять' + @Res
              end
            else
              begin
                if @b3 = '1' SET @Res = ' одна' + @Res else
                if @b3 = '2' SET @Res = ' двi' + @Res else
                if @b3 = '3' SET @Res = ' три' + @Res else
                if @b3 = '4' SET @Res = ' чотири' + @Res else
                if @b3 = '5' SET @Res = ' п''ять' + @Res else
                if @b3 = '6' SET @Res = ' шiсть' + @Res else
                if @b3 = '7' SET @Res = ' сiм' + @Res else
                if @b3 = '8' SET @Res = ' вiсiм' + @Res else
                if @b3 = '9' SET @Res = ' дев''ять' + @Res

                if @b2 = '2' SET @Res = ' двадцять' + @Res else
                if @b2 = '3' SET @Res = ' тридцять' + @Res else
                if @b2 = '4' SET @Res = ' сорок' + @Res else
                if @b2 = '5' SET @Res = ' п''ятдесят' + @Res else
                if @b2 = '6' SET @Res = ' шiстдесят' + @Res else
                if @b2 = '7' SET @Res = ' сiмдесят' + @Res else
                if @b2 = '8' SET @Res = ' вiсiмдесят' + @Res else
                if @b2 = '9' SET @Res = ' дев''яносто' + @Res
              end
                if @b1 = '1' SET @Res = ' сто' + @Res else
                if @b1 = '2' SET @Res = ' двiстi' + @Res else
                if @b1 = '3' SET @Res = ' триста' + @Res else
                if @b1 = '4' SET @Res = ' чотириста' + @Res else
                if @b1 = '5' SET @Res = ' п''ятсот' + @Res else
                if @b1 = '6' SET @Res = ' шiстсот' + @Res else
                if @b1 = '7' SET @Res = ' сiмсот' + @Res else
                if @b1 = '8' SET @Res = ' вiсiмсот' + @Res else
                if @b1 = '9' SET @Res = ' дев''ятсот' + @Res
       END

    -- миллионы
    if @temp_amount >= 1000000
       BEGIN            
            SET @a1 = Substring(@a1,1,datalength(@a1)-3)
            SET @a2 = Right(@a1,3)
            SET @b1 = Substring(@a2,1,1)
            SET @b2 = Substring(@a2,2,1)
            SET @b3 = Substring(@a2,3,1)
            if @b3 = '0' and @b2 = '0' and @b1 = '0'
             SET @res = @res
            else
            begin
            if @b3 = '1' and @b2 != '1' 
             SET @Res = ' мiльйон' + @Res
            else if @b3 in ('2','3','4') and @b2 != '1' 
             SET @Res = ' мiльйона' + @Res
            else if @a2 != '   '
             SET @Res = ' мiльйонiв' + @Res
            end
            if @b2 = '1' 
              begin
                if @b3 = '0' SET @Res = ' десять' + @Res else
                if @b3 = '1' SET @Res = ' одинадцать' + @Res else
                if @b3 = '2' SET @Res = ' дванадцять' + @Res else
                if @b3 = '3' SET @Res = ' тринадцать' + @Res else
                if @b3 = '4' SET @Res = ' чотирнадцять' + @Res else
                if @b3 = '5' SET @Res = ' п''ятнадцять' + @Res else
                if @b3 = '6' SET @Res = ' шiстнадцять' + @Res else
                if @b3 = '7' SET @Res = ' сiмнадцять' + @Res else
                if @b3 = '8' SET @Res = ' вiсiмнадцять' + @Res else
                if @b3 = '9' SET @Res = ' дев''ятнадцять' + @Res
              end
            else
              begin
                if @b3 = '1' SET @Res = ' один' + @Res else
                if @b3 = '2' SET @Res = ' два' + @Res else
                if @b3 = '3' SET @Res = ' три' + @Res else
                if @b3 = '4' SET @Res = ' чотири' + @Res else
                if @b3 = '5' SET @Res = ' п''ять' + @Res else
                if @b3 = '6' SET @Res = ' шiсть' + @Res else
                if @b3 = '7' SET @Res = ' сiм' + @Res else
                if @b3 = '8' SET @Res = ' вiсiм' + @Res else
                if @b3 = '9' SET @Res = ' дев''ять' + @Res

                if @b2 = '2' SET @Res = ' двадцять' + @Res else
                if @b2 = '3' SET @Res = ' тридцять' + @Res else
                if @b2 = '4' SET @Res = ' сорок' + @Res else
                if @b2 = '5' SET @Res = ' п''ятдесят' + @Res else
                if @b2 = '6' SET @Res = ' шiстдесят' + @Res else
                if @b2 = '7' SET @Res = ' сiмдесят' + @Res else
                if @b2 = '8' SET @Res = ' вiсiмдесят' + @Res else
                if @b2 = '9' SET @Res = ' дев''яносто' + @Res
              end
                if @b1 = '1' SET @Res = ' сто' + @Res else
                if @b1 = '2' SET @Res = ' двiстi' + @Res else
                if @b1 = '3' SET @Res = ' триста' + @Res else
                if @b1 = '4' SET @Res = ' чотириста' + @Res else
                if @b1 = '5' SET @Res = ' п''ятсот' + @Res else
                if @b1 = '6' SET @Res = ' шiстсот' + @Res else
                if @b1 = '7' SET @Res = ' сiмсот' + @Res else
                if @b1 = '8' SET @Res = ' вiсiмсот' + @Res else
                if @b1 = '9' SET @Res = ' дев''ятсот' + @Res
       END

    -- миллиарды
    if @temp_amount >= 1000000000
       BEGIN
            SET @a1 = Substring(@a1,1,datalength(@a1)-3)
            SET @a2 = Right(@a1,3)
            SET @b1 = Substring(@a2,1,1)
            SET @b2 = Substring(@a2,2,1)
            SET @b3 = Substring(@a2,3,1)
            if @b3 = '0' and @b2 = '0' and @b1 = '0'
             SET @res = @res
            else
            begin
            if @b3 = '1' and @b2 != '1' 
             SET @Res = ' мiльярд' + @Res
            else if @b3 in ('2','3','4') and @b2 != '1' 
             SET @Res = ' мiльярда' + @Res
            else if @a2 != '   '
             SET @Res = ' мiльярдiв' + @Res
            end
            if @b2 = '1' 
              begin
                if @b3 = '0' SET @Res = ' десять' + @Res else
                if @b3 = '1' SET @Res = ' одинадцать' + @Res else
                if @b3 = '2' SET @Res = ' дванадцять' + @Res else
                if @b3 = '3' SET @Res = ' тринадцать' + @Res else
                if @b3 = '4' SET @Res = ' чотирнадцять' + @Res else
                if @b3 = '5' SET @Res = ' п''ятнадцять' + @Res else
                if @b3 = '6' SET @Res = ' шiстнадцять' + @Res else
                if @b3 = '7' SET @Res = ' сiмнадцять' + @Res else
                if @b3 = '8' SET @Res = ' вiсiмнадцять' + @Res else
                if @b3 = '9' SET @Res = ' дев''ятнадцять' + @Res
              end
            else
              begin
                if @b3 = '1' SET @Res = ' один' + @Res else
                if @b3 = '2' SET @Res = ' два' + @Res else
                if @b3 = '3' SET @Res = ' три' + @Res else
                if @b3 = '4' SET @Res = ' чотири' + @Res else
                if @b3 = '5' SET @Res = ' п''ять' + @Res else
                if @b3 = '6' SET @Res = ' шiсть' + @Res else
                if @b3 = '7' SET @Res = ' сiм' + @Res else
                if @b3 = '8' SET @Res = ' вiсiм' + @Res else
                if @b3 = '9' SET @Res = ' дев''ять' + @Res

                if @b2 = '2' SET @Res = ' двадцять' + @Res else
                if @b2 = '3' SET @Res = ' тридцять' + @Res else
                if @b2 = '4' SET @Res = ' сорок' + @Res else
                if @b2 = '5' SET @Res = ' п''ятдесят' + @Res else
                if @b2 = '6' SET @Res = ' шiстдесят' + @Res else
                if @b2 = '7' SET @Res = ' сiмдесят' + @Res else
                if @b2 = '8' SET @Res = ' вiсiмдесят' + @Res else
                if @b2 = '9' SET @Res = ' дев''яносто' + @Res
              end
                if @b1 = '1' SET @Res = ' сто' + @Res else
                if @b1 = '2' SET @Res = ' двiстi' + @Res else
                if @b1 = '3' SET @Res = ' триста' + @Res else
                if @b1 = '4' SET @Res = ' чотириста' + @Res else
                if @b1 = '5' SET @Res = ' п''ятсот' + @Res else
                if @b1 = '6' SET @Res = ' шiстсот' + @Res else
                if @b1 = '7' SET @Res = ' сiмсот' + @Res else
                if @b1 = '8' SET @Res = ' вiсiмсот' + @Res else
                if @b1 = '9' SET @Res = ' дев''ятсот' + @Res
       END    

    DECLARE @mb NCHAR(50), @bb NCHAR(50)
    SET @mb = 'абвгґдеєжзиіїйклмнопрстуфхцчшщьюя'''
    SET @bb = 'АБВГҐДЕЄЖЗИІЇЙКЛМНОПРСТУФХЦЧШЩЬЮЯ'''
    SET @i = CharIndex(substring(@Res,1,1),@mb)
    SET @Res = Substring(@bb,@i,1) + Substring(@Res,2,255)
    SET @Res = upper(Substring(@Res,1,1)) + Substring(@Res,2, 254)
    
    DECLARE @kop NVARCHAR(2)
    DECLARE @mkop money
    DECLARE @suffix NVARCHAR(20)
    SET @kop = right(convert(NVARCHAR(255),abs(@temp_amount)),2)
    SET @mkop = convert(money,@kop)

    if @p_suffix = 'UAH'
            SET @suffix = case
                             when @mkop = 0 then ' копійок'
                             when @mkop > 10 and @mkop < 20 then ' копійок'
                             when right(@kop,1) = '1' then ' копійка'
                             when right(@kop,1) > '1' and right(@kop,1) < '5' then ' копійки'
                             else ' копійок'
                          end
    else
    if @p_suffix =  'USD'
            SET @suffix = case
                             when @mkop = 0 then ' центiв'
                             when @mkop > 10 and @mkop < 20 then ' центiв'
                             when right(@kop,1) = '1' then ' цент'
                             when right(@kop,1) > '1' and right(@kop,1) < '5' then ' центи'
                             else ' центiв'
                          end
    else
    if @p_suffix = 'EUR'         
            SET @suffix = case
                             when @mkop = 0 then ' євроцентiв'
                             when @mkop > 10 and @mkop < 20 then ' євроцентiв'
                             when right(@kop,1) = '1' then ' євроцент'
                             when right(@kop,1) > '1' and right(@kop,1) < '5' then ' євроценти'
                             else ' євроцентiв'
                          end        
    else
    if @p_suffix = 'GBP'
            SET @suffix = case
                             when @mkop = 0 then ' пенсiв'
                             when @mkop > 10 and @mkop < 20 then ' пенсiв'
                             when right(@kop,1) = '1' then ' пенс'
                             when right(@kop,1) > '1' and right(@kop,1) < '5' then ' пенси'
                             else ' пенсiв'
                          end
    else
    if @p_suffix = 'CHF'
            SET @suffix = case
                             when @mkop = 0 then ' сантимiв'
                             when @mkop > 10 and @mkop < 20 then ' сантимiв'
                             when right(@kop,1) = '1' then ' сантим'
                             when right(@kop,1) > '1' and right(@kop,1) < '5' then ' сантими'
                             else ' сантимiв'
                          end
    else
    if @p_suffix = 'RUB'
            SET @suffix = case
                             when @mkop = 0 then ' копійок'
                             when @mkop > 10 and @mkop < 20 then ' копійок'
                             when right(@kop,1) = '1' then ' копійка'
                             when right(@kop,1) > '1' and right(@kop,1) < '5' then ' копійки'
                             else ' копійок'
                          end
    else
    if @p_suffix = '_WH'
            SET @suffix = ' сотих';
    
    if @p_suffix in ('', '_WR')
        SET @Res = @Res
    else
        SET @Res = @Res + ' ' + @kop + @suffix

    SET @Res = trim(upper(Substring(Ltrim(@Res),1,1)) + Substring(ltrim(@Res),2, 254))
 
    return @Res;

END
