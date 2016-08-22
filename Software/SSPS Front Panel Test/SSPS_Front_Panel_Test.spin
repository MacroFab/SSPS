CON
        _clkmode = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq = 6_000_000

        POS_ADD   = %00111000
        NEG_ADD   = %00111010

        'user codes for the MAX5217
        NO_OP = %0000_0000      'No Operation
        CODE_LOAD = %00000001  'Write and load data to the CODE and DAC registers
        CODE = %0000_0010       'Write data to the CODE register
        LOAD = %0000_0011       'Load current CODE register contento to the DAC register
        CODE_LOAD_m = %0000_0101'Write multiple CODE_LOADs
        CODE_m = %0000_0110     'Write multiple CODES
        USER_CONFIG = %0000_1000'User Configuration command
        SW_RESET = %0000_1001   'Software Reset
        SW_CLEAR = %0000_1010   'Software clear

        
        SCL = 11
        SDA = 12

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

  byte encdr_state0, encdr_state1

  long test_value0, test_value1

  long print_value0


  long data
  word value
  word count  

  long encoder_stack[100]
   
OBJ
  LCD: "CU16025-UW6J.spin"
  I2C : "Basic_I2C_Driver_1"

  
PUB MAIN  | i

  I2C.Initialize(SCL,SDA) 

  LCD.START(LCD_STB, LCD_SCK, LCD_DAT)

  DIRA[DISP_CLK]~~
  DIRA[DISP_LAT]~~
  DIRA[DISP_DAT]~~

  OUTA[DISP_CLK] := 0
  OUTA[DISP_LAT] := 0
  OUTA[DISP_DAT] := 0

  'Load Code LOAD with correct value for DAC. 
  data.byte[0] := CODE_LOAD
                                                                                    
  data.byte[1] := %0000_0000
  data.byte[2] := %0000_0000 
  
  'data.byte[1] := value.byte[1]
  'data.byte[2] := value.byte[0]
  
  I2C.WritePage(POS_ADD, i2c#NoAddr, @data, 3)
  I2C.WritePage(NEG_ADD, i2c#NoAddr, @data, 3)

  cognew(RUN_ENCDR,@encoder_stack)   

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

    print_value0 := test_value0

    data.byte[1] := print_value0.byte[1]
    data.byte[2] := print_value0.byte[0]

    I2C.WritePage(POS_ADD, i2c#NoAddr, @data, 3)


    LCD.MOVE(1,1)
    LCD.BIN(print_value0,16)
    
    if(print_value0 => 0 AND print_value0 < 10)
      LCD.MOVE(1,2)
      LCD.STR(STRING("   "))
      LCD.DEC(print_value0)
    elseif(print_value0 < 0 AND print_value0 > -10) 
      LCD.MOVE(1,2)
      LCD.STR(STRING("  "))
      LCD.DEC(print_value0)
    elseif(print_value0 => 10 AND print_value0 < 100) 
      LCD.MOVE(1,2)
      LCD.STR(STRING("  "))
      LCD.DEC(print_value0)
    elseif(print_value0 =< -10 AND print_value0 > -100) 
      LCD.MOVE(1,2)
      LCD.STR(STRING(" "))
      LCD.DEC(print_value0)
    elseif(print_value0 => 100) 
      LCD.MOVE(1,2)
      LCD.STR(STRING(" "))
      LCD.DEC(print_value0)
    elseif(print_value0 =< -100) 
      LCD.MOVE(1,2)
      LCD.DEC(print_value0)
    else
      LCD.MOVE(1,2) 
      LCD.DEC(print_value0)   

    
  repeat

  return

PUB INIT_ENCDR

  DIRA[ENCDR_A]~
  DIRA[ENCDR_B]~

  encdr_state0  := INA[ENCDR_A]
  encdr_state0  := encdr_state0  << 1
  encdr_state0  := encdr_state0  + INA[ENCDR_B]

  encdr_state1  := INA[ENCDR_A]
  encdr_state1  := encdr_state1  << 1
  encdr_state1  := encdr_state1  + INA[ENCDR_B]

  return

PUB RUN_ENCDR | encdr_new0, encdr_new1

  INIT_ENCDR
  
  repeat    
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

  return