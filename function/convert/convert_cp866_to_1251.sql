CREATE FUNCTION [dbo].[convert_cp866_to_1251]
(
	@instr varchar(8000)	
)
RETURNS varchar(8000)
AS
BEGIN
  -- Преобразование теста из cp866 в другую кодировку win1251 (для небольших объемов текста)
  declare @res varchar(8000)
  set @res = ''
  if not (@instr is null) begin
    declare @i as int
    declare @n as int
    declare @char_code_866 as int
    declare @char_code_1251 as int
    set @n = datalength(@instr)
    set @i = 1

    while @i<=@n begin
      set @char_code_866  = ascii(substring(@instr, @i, 1))
      select @char_code_1251 = 
        case   @char_code_866
          when  15 then 164
          when  20 then 182
          when  21 then 167
          when 128 then 192
          when 129 then 193
          when 130 then 194
          when 131 then 195
          when 132 then 196
          when 133 then 197
          when 134 then 198
          when 135 then 199
          when 136 then 200
          when 137 then 201
          when 138 then 202
          when 139 then 203
          when 140 then 204
          when 141 then 205
          when 142 then 206
          when 143 then 207
          when 144 then 208
          when 145 then 209
          when 146 then 210
          when 147 then 211
          when 148 then 212
          when 149 then 213
          when 150 then 214
          when 151 then 215
          when 152 then 216
          when 153 then 217
          when 154 then 218
          when 155 then 219
          when 156 then 220
          when 157 then 221
          when 158 then 222
          when 159 then 223
          when 160 then 224
          when 161 then 225
          when 162 then 226
          when 163 then 227
          when 164 then 228
          when 165 then 229
          when 166 then 230
          when 167 then 231
          when 168 then 232
          when 169 then 233
          when 170 then 234
          when 171 then 235
          when 172 then 236
          when 173 then 237
          when 174 then 238
          when 175 then 239
          when 176 then  45
          when 177 then  45
          when 178 then  45
          when 179 then 166
          when 180 then  43
          when 181 then 166
          when 182 then 166
          when 183 then 172
          when 184 then 172
          when 185 then 166
          when 186 then 166
          when 187 then 172
          when 188 then  45
          when 189 then  45
          when 190 then  45
          when 191 then 172
          when 192 then  76
          when 193 then  43
          when 194 then  84
          when 195 then  43
          when 196 then  45
          when 197 then  43
          when 198 then 166
          when 199 then 166
          when 200 then  76
          when 201 then 227
          when 202 then 166
          when 203 then  84
          when 204 then 166
          when 205 then  61
          when 206 then  43
          when 207 then 166
          when 208 then 166
          when 209 then  84
          when 210 then  84
          when 211 then  76
          when 212 then  76
          when 213 then  45
          when 214 then 227
          when 215 then  43
          when 216 then  43
          when 217 then  45
          when 218 then  45
          when 219 then  45
          when 220 then  45
          when 221 then 166
          when 222 then 166
          when 223 then  45
          when 224 then 240
          when 225 then 241
          when 226 then 242
          when 227 then 243
          when 228 then 244
          when 229 then 245
          when 230 then 246
          when 231 then 247
          when 232 then 248
          when 233 then 249
          when 234 then 250
          when 235 then 251
          when 236 then 252
          when 237 then 253
          when 238 then 254
          when 239 then 255
          when 240 then 168
          when 241 then 184
          when 242 then 170
          when 243 then 186
          when 244 then 175
          when 245 then 191
          when 246 then 161
          when 247 then 162
          when 248 then 176
          when 249 then 149
          when 250 then 183
          when 251 then 118
          when 252 then 185
          when 253 then 164
          when 254 then 166
          when 255 then 160

          else
            @char_code_866
        end

      set @res = @res + char(@char_code_1251)
      set @i = @i + 1
    end
  end
  return @res
END
