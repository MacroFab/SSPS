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

  byte encdr_state0,encdr_state1,encdr_state2,encdr_state3

  long test_value0, test_value1, test_value2, test_value3
  
   
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

  INIT_ENCDR

  repeat
    {repeat 8
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

    waitcnt(cnt+clkfreq*2)}

    RUN_ENCDR

    if(test_value0 => 0 AND test_value0 < 10)
      LCD.MOVE(1,2)
      LCD.STR(STRING("   "))
      LCD.DEC(test_value0)
    elseif(test_value0 < 0 AND test_value0 > -10) 
      LCD.MOVE(1,2)
      LCD.STR(STRING("  "))
      LCD.DEC(test_value0)
    elseif(test_value0 => 10 AND test_value0 < 100) 
      LCD.MOVE(1,2)
      LCD.STR(STRING("  "))
      LCD.DEC(test_value0)
    elseif(test_value0 =< -10 AND test_value0 > -100) 
      LCD.MOVE(1,2)
      LCD.STR(STRING(" "))
      LCD.DEC(test_value0)
    elseif(test_value0 => 100) 
      LCD.MOVE(1,2)
      LCD.STR(STRING(" "))
      LCD.DEC(test_value0)
    elseif(test_value0 =< -100) 
      LCD.MOVE(1,2)
      LCD.DEC(test_value0)
    else
      LCD.MOVE(1,2) 
      LCD.DEC(test_value0)   

    
  repeat

  return

PUB INIT_ENCDR

  DIRA[ENCDR_A]~
  DIRA[ENCDR_B]~

  encdr_state0 := %00

  return

PUB RUN_ENCDR | encdr_new0, encdr_new1, encdr_new2, encdr_new3 

  encdr_new0 := INA[ENCDR_A]
  encdr_new0 := encdr_new0 << 1
  encdr_new0 := encdr_new0 + INA[ENCDR_B]

  CASE  encdr_state0
    %00 :
      if(encdr_new0 == %01)      'CW
        encdr_state0 := %01
        test_value0++
        
      elseif(encdr_new0 == %11)  'CCW
        encdr_state0 := %11
        test_value0--
        
      else
        encdr_state0 := %00

    %01 :              
      if(encdr_new0 == %11)      'CW
        encdr_state0 :=  %11
        test_value0++
        
      elseif(encdr_new0 == %00)  'CCW
        encdr_state0 := %00
        test_value0--
        
      else
        encdr_state0 := %01

    %11 :
      if(encdr_new0 == %00)      'CW
        encdr_state0 := %00
        test_value0++
        
      elseif(encdr_new0 == %01)  'CCW
        encdr_state0 := %01
        test_value0--
        
      else
        encdr_state0 := %11

    OTHER :
      encdr_state0 := encdr_state0


  encdr_new1 := INA[ENCDR_A]
  encdr_new1 := encdr_new1 << 1
  encdr_new1 := encdr_new1 + INA[ENCDR_B]

  CASE  encdr_state1
    %00 :
      if(encdr_new1 == %01)      'CW
        encdr_state1 := %01
        test_value1++
        
      elseif(encdr_new1 == %11)  'CCW
        encdr_state1 := %11
        test_value1--
        
      else
        encdr_state1 := %00

    %01 :              
      if(encdr_new1 == %11)      'CW
        encdr_state1 :=  %11
        test_value1++
        
      elseif(encdr_new1 == %00)  'CCW
        encdr_state1 := %00
        test_value1--
        
      else
        encdr_state1 := %01

    %11 :
      if(encdr_new1 == %00)      'CW
        encdr_state1 := %00
        test_value1++
        
      elseif(encdr_new1 == %01)  'CCW
        encdr_state1 := %01
        test_value1--
        
      else
        encdr_state1 := %11

    OTHER :
      encdr_state1 := encdr_state1


  encdr_new2 := INA[ENCDR_A]
  encdr_new2 := encdr_new2 << 1
  encdr_new2 := encdr_new2 + INA[ENCDR_B]

  CASE  encdr_state2
    %00 :
      if(encdr_new2 == %01)      'CW
        encdr_state2 := %01
        test_value2++
        
      elseif(encdr_new2 == %11)  'CCW
        encdr_state2 := %11
        test_value2--
        
      else
        encdr_state2 := %00

    %01 :              
      if(encdr_new2 == %11)      'CW
        encdr_state2 :=  %11
        test_value2++
        
      elseif(encdr_new2 == %00)  'CCW
        encdr_state2 := %00
        test_value2--
        
      else
        encdr_state2 := %01

    %11 :
      if(encdr_new2 == %00)      'CW
        encdr_state2 := %00
        test_value2++
        
      elseif(encdr_new2 == %01)  'CCW
        encdr_state2 := %01
        test_value2--
        
      else
        encdr_state2 := %11

    OTHER :
      encdr_state2 := encdr_state2


  encdr_new3 := INA[ENCDR_A]
  encdr_new3 := encdr_new3 << 1
  encdr_new3 := encdr_new3 + INA[ENCDR_B]

  CASE  encdr_state3
    %00 :
      if(encdr_new3 == %01)      'CW
        encdr_state3 := %01
        test_value3++
        
      elseif(encdr_new3 == %11)  'CCW
        encdr_state3 := %11
        test_value3--
        
      else
        encdr_state3 := %00

    %01 :              
      if(encdr_new3 == %11)      'CW
        encdr_state3 :=  %11
        test_value3++
        
      elseif(encdr_new3 == %00)  'CCW
        encdr_state3 := %00
        test_value3--
        
      else
        encdr_state3 := %01

    %11 :
      if(encdr_new3 == %00)      'CW
        encdr_state3 := %00
        test_value3++
        
      elseif(encdr_new3 == %01)  'CCW
        encdr_state3 := %01
        test_value3--
        
      else
        encdr_state3 := %11

    OTHER :
      encdr_state3 := encdr_state3 
    

  return