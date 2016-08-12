CON
        _clkmode  = xtal1 + pll16x 'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq  = 6_000_000

        SCL = 10
        SDA = 9

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

VAR

        long data
        byte UNIBBLE
        byte LNIBBLE
        word count 
        

OBJ

  I2C : "Basic_I2C_Driver_1"

PUB MAIN

        DIRA[SCL]~~ 
        DIRA[SDA]~~
        I2C.Initialize(SCL,SDA)
        data.byte[0] := CODE_LOAD
        data.byte[4] := %00000000
        waitcnt(clkfreq*5 +cnt)              
        repeat
          
           UNIBBLE := count >> 8
           LNIBBLE := count
           data.byte[1] := UNIBBLE
           data.byte[2] := LNIBBLE
           I2C.WritePage(POS_ADD, i2c#NoAddr, @data, 3)
           count := count + 1000
           waitcnt(clkfreq/100000+cnt)
     