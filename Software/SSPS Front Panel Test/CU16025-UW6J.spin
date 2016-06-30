CON

  'CU16025-UW6J

  'Author: Parker Dillmann       
        
        
VAR
  'Pin assignment
  byte STB
  byte SCK
  byte SI

   
OBJ

PUB START(LCD_STB, LCD_SCK, LCD_DAT)

  STB := LCD_STB
  SCK := LCD_SCK
  SI  := LCD_DAT

  'Init I/O
  OUTA[STB] := 1
  OUTA[SCK] := 0
  OUTA[SI]  := 0
  
  DIRA[STB]~~                                           
  DIRA[SCK]~~
  DIRA[SI] ~~

  INST4 (%00000110,0)
  INST4 (%00001100,0)
  INST4 (%00010100,0)
  INST4 (%00110000,0)
  INST4 (%00000000,1)

  CLEAR
  
  return                                    

PUB INST4 (LCD_DATA, RS)


  OUTA[STB]  := 0       
  LCD_DATA ><= 8                'Flip data around MSB first!           

  OUTA[SCK] := 0

  repeat 5                      '5 Synchronious Bits
    OUTA[SI]  := 1          
    OUTA[SCK] := 1
    OUTA[SCK] := 0
                      
  OUTA[SI]  := 0                'W BIT = 0        
  OUTA[SCK] := 1
  OUTA[SCK] := 0

  OUTA[SI]  := RS               'RS BIT         
  OUTA[SCK] := 1
  OUTA[SCK] := 0

  OUTA[SI]  := 0                'Last Zero   
  OUTA[SCK] := 1
  OUTA[SCK] := 0

  REPEAT 8 
    OUTA[SI] := LCD_DATA
    OUTA[SCK] := 1
    OUTA[SCK] := 0
    LCD_DATA >>= 1

  OUTA[STB]  := 1
  
  return

PRI CHAR (LCD_DATA)

  INST4(LCD_DATA,1)

  return

PUB CLEAR       
  INST4 (%0000_0001, 0)

  return                                                                            

PUB MOVE (X,Y) | ADR
  'X : Horizontal Position : 1 to 16
  'Y : Line Number         : 1 or 2
  ADR := (Y-1) * 64
  ADR += (X-1) + 128
  INST4 (ADR,0)

  return

PUB STR (STRINGPTR)


  REPEAT STRSIZE(STRINGPTR)
    INST4(BYTE[STRINGPTR++],1)

  return
                              
PUB DEC (VALUE) | TEMP

  IF (VALUE < 0)
    -VALUE
    STR(STRING("-"))
        
  TEMP := 1_000_000_000

  REPEAT 10
    IF (VALUE => TEMP)
      CHAR(VALUE / TEMP + "0")
      VALUE //= TEMP
      RESULT~~
    ELSEIF (RESULT OR TEMP == 1)
      CHAR("0")
    TEMP /= 10

  return   

PUB HEX (VALUE, DIGITS)

  VALUE <<= (8 - DIGITS) << 2
  REPEAT DIGITS
    CHAR(LOOKUPZ((VALUE <-= 4) & $F : "0".."9", "A".."F"))

  return

PUB BIN (VALUE, DIGITS)

  VALUE <<= 32 - DIGITS
  REPEAT DIGITS
    CHAR((VALUE <-= 1) & 1 + "0")
    
  return         