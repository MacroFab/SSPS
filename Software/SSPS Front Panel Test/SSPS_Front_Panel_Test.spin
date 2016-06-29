CON
        _clkmode = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq = 6_000_000


        DISP_CLK  = 3
        DISP_LAT  = 4
        DISP_DAT  = 5

        LCD_DAT   = 0
        LCD_STB   = 1
        LCD_SCK   = 2

        ENCDR_A   = 6
        ENCDR_B   = 7

        SW_1      = 8
        SW_2      = 9
        SW_3      = 10
        

VAR
   
OBJ
  LCD: "CU16025-UW6J.spin"
  
PUB MAIN  | i

  LCD.START(LCD_STB, LCD_SCK, LCD_DAT)

  DIRA[DISP_CLK]~~
  DIRA[DISP_LAT]~~
  DIRA[DISP_DAT]~~

  OUTA[DISP_CLK] := 0
  OUTA[DISP_LAT] := 0
  OUTA[DISP_DAT] := 0

  repeat
    repeat 8
      repeat i from 0 to 15
       
        OUTA[DISP_CLK] := 0
        OUTA[DISP_DAT] := 1
        OUTA[DISP_CLK] := 1 

    OUTA[DISP_CLK] := 0
    OUTA[DISP_LAT] := 1
    OUTA[DISP_LAT] := 0

    waitcnt(cnt+clkfreq*2) 

    repeat 8
      repeat i from 0 to 15
       
        OUTA[DISP_CLK] := 0
        OUTA[DISP_DAT] := 0
        OUTA[DISP_CLK] := 1 

    OUTA[DISP_CLK] := 0
    OUTA[DISP_LAT] := 1
    OUTA[DISP_LAT] := 0

    waitcnt(cnt+clkfreq*2) 
  repeat

return