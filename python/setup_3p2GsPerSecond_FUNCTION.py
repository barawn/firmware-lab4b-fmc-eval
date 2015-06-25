#!/usr/bin/python
#
# This script contains the high and low level functions for working with the LAB4B devboards using the UART interface
# from Patrick.
#
# ----------------------------------------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------------------------------------
#
# ----------------------------------
# List Of "UART low-level" functions
# ----------------------------------
#
# ->  selectUARTbank( UARTbank )                                               : select a bank ( valid banks are 0 ... 4 )
# ->  toggleUARTbit( UARTbank , UARTaddr , label )                             : turn a bit on and then turn it off (lowest order bit of 1 register)
# ->  writeUARTbit( UARTbank , UARTaddr , value )                              : write a 0 or 1 to a UART bit (lowest order bit of 1 register)
# ->  writeUARTbyte( UARTbank , UARTaddr_LSB , value )                         : write a VALUE to a UART byte (1 register)
# ->  writeUARTword( UARTbank , UARTaddr_MSB , UARTaddr_LSB , value )          : write a VALUE to UART word (2 registers)
# ->  fillUARTbank( UARTbank , value , verbose )                               : write a VALUE or a VALUE LIST to all 63 taps in a specifed bank (for setting individual tap VdlyN)
# ->  reportUARTbit( UARTbank , UARTaddr , label )                             : report the VALUE of a bit
# ->  reportUARTbyte( UARTbank , UARTaddr , label )                            : report the VALUE of a UART byte (1 register)
# ->  reportUARTword( UARTbank , UARTaddr_MSB , UARTaddr_LSB , label )         : report the VALUE of a UART word (2 registers)
# ->  reportUARTbank( UARTbank )                                               : report the VALUES in the specified UART bank
# ->  readUARTbit( UARTbank , UARTaddr , label , verbose )                     : return the VALUE of a UART bit                [verbose=TRUE, also report value]
# ->  readUARTbyte( UARTbank , UARTaddr , label , verbose )                    : return the VALUE of a UART byte (1 register)  [verbose=TRUE, also report value]
# ->  readUARTword( UARTbank , UARTaddr_MSB , UARTaddr_LSB , label , verbose ) : return the VALUE of a UART word (2 registers) [verbose=TRUE, also report value]
#
# ---------------------------------------------
# List Of "DevBoard-Level Report/Set" Functions
# ---------------------------------------------
#
# ->  ReportBoard( ) : report all settings for the board
#
# ->  InitDevBoard1( CommonMode_True_IndividualTapMode_False_Flag ) : initialize board to DevBoard1 defaults, FLAG=True for Common VdlyN mode / =False for individual tap VdlyN mode
# ->  InitDevBoard2( CommonMode_True_IndividualTapMode_False_Flag ) : initialize board to DevBoard2 defaults, FLAG=True for Common VdlyN mode / =False for individual tap VdlyN mode
# ->  InitExtDACs_DevBoard1( ) : load external DACs to DevBoard1 defaults
# ->  InitExtDACs_DevBoard2( ) : load external DACs to DevBoard2 defaults
# ->  InitIntDACs_DevBoard1( ) : load internal DACs to DevBoard1 defaults
# ->  InitIntDACs_DevBoard2( ) : load internal DACs to DevBoard2 defaults
#
# ->  CommonVdlyNMode( value )                       : switch to Common VdlyN mode, setting the VdlyN to VALUE
# ->  IndividualVdlyNMode( value , verbose )         : switch to individual taps VdlyN mode, setting all taps VdlyN values to VALUE
#
# ->  loadConstantIntoIndividualDelayLineTaps( value , LoadLAB4B_True_LoadUARTOnly_False_Flag , verbose )                     : load all taps VdlyN values to VALUE, but do *NOT* change the current VdlyN mode!
# ->  loadSlopeLineIntoIndividualDelayLineTaps( start_value , end_value ,  LoadLAB4B_True_LoadUARTOnly_False_Flag , verbose ) : load all taps with a linear trend going from start to end, but do *NOT* change the current VdlyN mode!
# ->  reportIndividualTaps( )                                                                                                 : report the values of VdlyN for all of the individual taps
# ->  reportTapVdlyNs( )                                                                                                      : short report of the VdlyN values for all the individual taps
#
# ->  GotoCommonVdlyNMode( )                         : switch to Common VdlyN mode, do *NOT* reset the current VdlyN value
# ->  GotoIndividualVdlyNMode( )                     : switch to individual taps VdlyN mode, but do *NOT* change any of the taps VdlyN values
#
# ---------------------------------------------
# List Of "Button-Pressing/Load DACs" Functions
# ---------------------------------------------
#
# ->  PressExtDAQLoad( )   : actually load the external DACs from the values in the registers
# ->  PressIntDAQLoad( )   : actually load the internal DACS from the values in the registers
# ->  PressTapLoad( )      : actually load the individual VdlyN values from the registers into the LAB4B chip
#
# -------------------------------------------------
# List Of "Pedestal Substraction Control" Functions
# -------------------------------------------------
#
# ->  PedSubOff( )         : turn off pedestal substract mode
# ->  PedSubOn( )          : turn on pedestal substract mode
# ->  UpdatePedOff( )      : stop storing data in the pedestal memory (required in order to see any waveforms in ChipScope window)
# ->  UpdatePedOn( )       : store data in the pedestal memory
#
# -------------------------------------------------
# List Of "Report Individual DAC Setting" Functions
# -------------------------------------------------
#
# ->  ReportIntDACs( )     : report on the values in the internal DAC registers
# ->  ReportExtDACs( )     : report on the values in the external DAC registers
#
# ->  ReportWRSTB( )       : report the register values for the WRSTB tap selection
# ->  ReportS1( )          : report the register values for the S1 tap selection
# ->  ReportS2( )          : report the register values for the S2 tap selection
# ->  ReportPHASE( )       : report the register values for the PHASE tap selection
# ->  ReportSSPin( )       : report the register values for the SSPin tap selection
# ->  ReportTimeReg( )     : report the register value for the TimReg (monitor signal output) selection
# ->  ReportChoicePhase( ) : report the register value for the WRSTB->FPGA clock phase (values go from 0 to 20)
#
# ->  ReportVbias( )       : report the register value for Vbias (bias voltage for the sample->intermediate cap array transfer)
# ->  ReportVbias2( )      : report the register value for Vbias2 (bias voltage for the intermediate->main cap array transfer)
# ->  ReportVdlyNMode( )   : report the source for the VdlyN (either Common or Individual Taps)
# ->  ReportVdlyN( )       : report the register value for VdlyN (value for CommonDT mode!)
# ->  ReportVdlyP( )       : report the register value for VdlyP
# ->  ReportROVDD( )       : report the register value for XROVDD (ROVDD = ~1.2V + this voltage, so max for this register is around 0x800)
# ->  ReportSBbias( )      : report the register value for SBbias
# ->  ReportCMPbias( )     : report the register value for CMPbias
# ->  ReportXISE( )        : report the register value for XISE (controls rate of Wilkinson ramp)
#
# ->  ReportCommonDT( )    : report the register value for CommonDT (single value loaded into all individual tap VdlyN for tuning)
#
# ------------------------------------------------------------------
# List Of "Set Individual DAC Setting To DevBoard Default" Functions
# ------------------------------------------------------------------
#
# ->  SetWRSTBtoDevBoardDefault( devboard )       : set WRSTB to the default value for the specified board (either 1 or 2)
# ->  SetS1toDevBoardDefault( devboard )          : set S1 to the default value for the specified board (either 1 or 2)
# ->  SetS2toDevBoardDefault( devboard )          : set S2 to the default value for the specified board (either 1 or 2)
# ->  SetPHASEtoDevBoardDefault( devboard )       : set PHASE to the default value for the specified board (either 1 or 2)
# ->  SetSSPintoDevBoardDefault( devboard )       : set SSPin to the default value for the specified board (either 1 or 2)
# ->  SetChoicePhasetoDevBoardDefault( devboard ) : set ChoicePhase to the default value for the specified board (either 1 or 2)
#
# ----------------------------------------------
# List Of "Set Individual DAC Setting" Functions
# ----------------------------------------------
#
# ->  SetWRSTB( leading , trailing ) : set WRSTB value
# ->  SetS1( leading , trailing )    : set S1 value
# ->  SetS2( leading , trailing )    : set S2 value
# ->  SetPHASE( leading , trailing ) : set PHASE value
# ->  SetSSPin( leading , trailing ) : set SSPin value
# ->  SetChoicePhase( value )        : set ChoicePhase value
# ->  SetTimeReg( value )            : set TimeReg value
#
# ->  SetVbias( value )              : set Vbias (bias voltage for the sample->intermediate cap array transfer)
# ->  SetVbias2( value )             : set Vbias2 (bias voltage for the intermediate->main cap array transfer)
# ->  SetVdlyN( value )              : set VdlyN (either Common or Individual Taps)
# ->  SetVdlyP( value )              : set VdlyP (value for CommonDT mode!)
# ->  SetROVDD( value )              : set XROVDD (ROVDD = ~1.2V + this voltage, so max for this register is around 0x800)
# ->  SetCMPbias( value )            : set CMPbias
# ->  SetSBbias( value )             : set SBbias
# ->  SetXISE( value )               : set XISE (controls rate of Wilkenson ramp)
#
# ->  SetCommonDT( value )           : set and load the CommonDT (single value loaded into all individual tap VdlyN for tuning)
#
# ----------------------------------------------------------------------------------------------------------------------

import qnd
import serial
import time
import sys

device = qnd.QnD( '/dev/com4' )

def selectUARTbank( UARTbank ) :

    device.writeRegister( int(0x7f)     , UARTbank )
    print "selectUARTbank        : UART(%1.1d-0x____) - select UARTbank %1.1d " % ( UARTbank , UARTbank )

    return

def toggleUARTbit( UARTbank , UARTaddr , label ) :

    device.writeRegister( int(0x7f)     , UARTbank )
    device.writeRegister( int(UARTaddr) ,  1 )                # turn on the bit
    device.writeRegister( int(UARTaddr) ,  0 )                # and then turn off the bit

    print "toggleUARTbit         : UART(%1.1d-0x__%2.2x) - %s " % ( UARTbank , UARTaddr , label )

    return

def writeUARTbit( UARTbank , UARTaddr , value ) :

    device.writeRegister( int(0x7f)     , UARTbank )
    device.writeRegister( int(UARTaddr) ,  value )

    return

def writeUARTbyte( UARTbank , UARTaddr_LSB , value ) :

    byte = int(value) & 0x00ff

    addr = int(UARTaddr_LSB)

    device.writeRegister( int(0x7f) , UARTbank )
    device.writeRegister(    addr   , byte     )

    return

def writeUARTword( UARTbank , UARTaddr_MSB , UARTaddr_LSB , value ) :

    least_significant_byte = int(value) & 0x00ff
    most_significant_byte  = ( int(value) & 0x0f00 ) >> 8

    least_significant_addr = int(UARTaddr_LSB)
    most_significant_addr  = int(UARTaddr_MSB)

    device.writeRegister( int(0x7f)              , UARTbank               )
    device.writeRegister( least_significant_addr , least_significant_byte )
    device.writeRegister( most_significant_addr  , most_significant_byte  )

    return

def readUARTbit( UARTbank , UARTaddr , label , verbose ) :

    addr = int(UARTaddr)

    device.writeRegister( int(0x7f) , UARTbank )
    value = device.readRegister( addr )

    if ( verbose ) :
       print "readUARTbit           : UART(%1.1d-0x__%2.2x) - %s = 0x%2.2X" % ( UARTbank, UARTaddr , label , value )

    return value

def readUARTbyte( UARTbank , UARTaddr , label , verbose ) :

    addr = int(UARTaddr)

    device.writeRegister( int(0x7f) , UARTbank )
    value = device.readRegister( addr )

    if ( verbose ) :
       print "readUARTbyte          : UART(%1.1d-0x__%2.2x) - %s = 0x%3.3X" % ( UARTbank, UARTaddr , label , value )

    return value

def readUARTword( UARTbank , UARTaddr_MSB , UARTaddr_LSB , label , verbose ) :

    least_significant_addr = int(UARTaddr_LSB)
    most_significant_addr  = int(UARTaddr_MSB)

    device.writeRegister( int(0x7f) , UARTbank )
    least_significant_byte = device.readRegister( least_significant_addr )
    most_significant_byte  = device.readRegister( most_significant_addr  )
    value = ( most_significant_byte << 8 ) | least_significant_byte

    if ( verbose ) :
       print "readUARTword          : UART(%1.1d-0x%2.2x%2.2x) - %s = 0x%3.3X" % ( UARTbank , UARTaddr_MSB , UARTaddr_LSB , label , value )

    return value

def reportUARTbit( UARTbank , UARTaddr , label ) :

    addr = int(UARTaddr)

    device.writeRegister( int(0x7f) , UARTbank )
    value = device.readRegister( addr )

    print "reportUARTbit         : UART(%1.1d-0x__%2.2x) - %s = 0x%2.2X" % ( UARTbank, UARTaddr , label , value )

    return

def reportUARTbyte( UARTbank , UARTaddr , label ) :

    addr = int(UARTaddr)

    device.writeRegister( int(0x7f) , UARTbank )
    value = device.readRegister( addr )

    print "reportUARTbyte        : UART(%1.1d-0x__%2.2x) - %s = 0x%3.3X" % ( UARTbank, UARTaddr , label , value )

    return

def reportUARTword( UARTbank , UARTaddr_MSB , UARTaddr_LSB , label ) :

    least_significant_addr = int(UARTaddr_LSB)
    most_significant_addr  = int(UARTaddr_MSB)

    device.writeRegister( int(0x7f) , UARTbank )
    least_significant_byte = device.readRegister( least_significant_addr )
    most_significant_byte  = device.readRegister( most_significant_addr  )
    value = ( most_significant_byte << 8 ) | least_significant_byte

    print "reportUARTword        : UART(%1.1d-0x%2.2x%2.2x) - %s = 0x%3.3X" % ( UARTbank , UARTaddr_MSB , UARTaddr_LSB , label , value )

    return

def reportUARTbank( UARTbank ) :

    if ( ( UARTbank == 0 ) or ( UARTbank == 1 ) or ( UARTbank == 2 ) or ( UARTbank == 3 ) or ( UARTbank == 4 ) ) :

       for entry in range( 0 , 63 ) :

           least_significant_addr = int(entry)*2 + 0
           most_significant_addr  = int(entry)*2 + 1

           if ( ( UARTbank == 2 ) or ( UARTbank == 3 ) ) :
              device.writeRegister( int(0x7f) , UARTbank )           # select the bank
              readback_least_significant_byte = device.readRegister( least_significant_addr )
              readback_most_significant_byte  = device.readRegister( most_significant_addr )
              readback_value = ( readback_most_significant_byte << 8 ) | readback_least_significant_byte
           else :
              if ( UARTbank == 4 ) :
                 if ( entry < 2 ) :
                    device.writeRegister( int(0x7f) , UARTbank )        # select the bank
                    readback_least_significant_byte = device.readRegister( least_significant_addr )
                    readback_most_significant_byte  = device.readRegister( most_significant_addr )
                    readback_value = ( readback_most_significant_byte << 8 ) | readback_least_significant_byte
                 else :
                    readback_value = 0
              else :
                 device.writeRegister( int(0x7f) , UARTbank )        # select the bank
                 readback_least_significant_byte = device.readRegister( least_significant_addr )
                 readback_most_significant_byte  = device.readRegister( most_significant_addr )
                 readback_value = ( readback_most_significant_byte << 8 ) | readback_least_significant_byte

           if ( ( UARTbank == 2 ) or ( UARTbank == 3 ) or ( UARTbank == 4 ) ) :
              tap_gap       = entry + ( UARTbank-2 )*63
              timebin_start = entry + ( UARTbank-2 )*63
              timebin_end   = entry + ( UARTbank-2 )*63 + 1
              if ( ( UARTbank == 2 ) or ( UARTbank == 3 ) ) :
                 print "reportUARTbank        : UART(%1.1d-0x%2.2x%2.2x) - -> tap %3d 0x%3.3X" % \
                       ( UARTbank , most_significant_addr , least_significant_addr , timebin_start , readback_value )
              else :
                 if ( entry < 2 ) :
                    print "reportUARTbank        : UART(%1.1d-0x%2.2x%2.2x) - -> tap %3d 0x%3.3X" % \
                          ( UARTbank , most_significant_addr , least_significant_addr , timebin_start , readback_value )
           else :
              print "reportUARTbank        : UART(%1.1d-0x%2.2x%2.2x) - -> 0x%4.4X" % \
                    ( UARTbank , most_significant_addr , least_significant_addr , readback_value )
               
    else :

       print "reportUARTbank        : UART(%1.1d-0x____) - ERROR : invalid UART bank %1.1d" % ( UARTbank , UARTbank )

    return

def fillUARTbank( UARTbank , value , verbose ) :

    if ( not verbose ) :
       if ( isinstance(value,int) ) :
          print "fillUARTbank          : UART(%1.1d-0x____) - setting all tap gaps in bank %1.1d -> 0x%3.3X" % ( UARTbank , UARTbank, value )
       else :
          print "fillUARTbank          : UART(%1.1d-0x____) - setting all tap gaps in bank %1.1d -> from list of length = %3.3d" % ( UARTbank , UARTbank, len(value) )

    else :
       print "fillUARTbank          : UART(%1.1d-0x____) -----------------------------------------------------------------------------" % ( UARTbank )

    if ( ( UARTbank == 2 ) or ( UARTbank == 3 ) ) :

       device.writeRegister( int(0x7f) , UARTbank )           # select the bank

       for entry in range( 0 , 63 ) :
           tap_gap       = entry + ( UARTbank-2 )*63
           timebin_start = entry + ( UARTbank-2 )*63
           timebin_end   = entry + ( UARTbank-2 )*63 + 1
           least_significant_addr = int(entry)*2 + 0
           most_significant_addr  = int(entry)*2 + 1
           if ( isinstance(value,int) ) :
              this_value = int( value )
           else :
              this_value = int( value[timebin_start] )
           least_significant_byte = this_value & 0x00ff                          # decompose value into least and most significant bytes
           most_significant_byte  = ( this_value & 0x0f00 ) >> 8  
           device.writeRegister( least_significant_addr , least_significant_byte )
           device.writeRegister( most_significant_addr  , most_significant_byte  )
           readback_least_significant_byte = 0
           readback_most_significant_byte  = 0
           readback_least_significant_byte = device.readRegister( least_significant_addr )
           readback_most_significant_byte  = device.readRegister( most_significant_addr )
           readback_value    = ( readback_most_significant_byte << 8 ) | readback_least_significant_byte
           if ( readback_value == this_value ) :
              if ( verbose ) :
                 print "fillUARTbank          : UART(%1.1d-0x%2.2x%2.2x) - tap gap %3.3d (from %3.3d to %3.3d) -> set 0x%3.3X - readback = 0x%3.3X" % ( UARTbank , most_significant_addr , least_significant_addr , tap_gap , timebin_start , timebin_end , this_value , readback_value )
           else :
              print "fillUARTbank          : UART(%1.1d-0x%2.2x%2.2x) - tap gap %3.3d (from %3.3d to %3.3d) -> set 0x%3.3X - ERROR : readback = 0x%3.3X" % ( UARTbank , most_significant_addr , least_significant_addr , tap_gap , timebin_start , timebin_end , this_value , readback_value )

    elif ( UARTbank == 4 ) :

       device.writeRegister( int(0x7f) , UARTbank )           # select the bank

       for entry in range( 0 , 2 ) :
           tap_gap       = entry + ( UARTbank-2 )*63
           timebin_start = entry + ( UARTbank-2 )*63
           timebin_end   = entry + ( UARTbank-2 )*63 + 1
           least_significant_addr = int(entry)*2 + 0
           most_significant_addr  = int(entry)*2 + 1
           if ( isinstance(value,int) ) :
              this_value = int( value )
           else :
              this_value = int( value[timebin_start] )
           least_significant_byte = this_value & 0x00ff                          # decompose value into least and most significant bytes
           most_significant_byte  = ( this_value & 0x0f00 ) >> 8  
           device.writeRegister( least_significant_addr , least_significant_byte )
           device.writeRegister( most_significant_addr  , most_significant_byte  )
           readback_least_significant_byte = device.readRegister( least_significant_addr )
           readback_most_significant_byte  = device.readRegister( most_significant_addr )
           readback_value    = ( readback_most_significant_byte << 8 ) | readback_least_significant_byte
           if ( readback_value == this_value ) :
              if ( verbose ) :
                 print "fillUARTbank          : UART(%1.1d-0x%2.2x%2.2x) - tap gap %3.3d (from %3.3d to %3.3d) -> set 0x%3.3X - readback = 0x%3.3X" % ( UARTbank , most_significant_addr , least_significant_addr , tap_gap , timebin_start , timebin_end , this_value , readback_value )
           else :
              print "fillUARTbank          : UART(%1.1d-0x%2.2x%2.2x) - tap gap %3.3d (from %3.3d to %3.3d) -> set 0x%3.3X - ERROR : readback = 0x%3.3X" % ( UARTbank , most_significant_addr , least_significant_addr , tap_gap , timebin_start , timebin_end , this_value , readback_value )

    else :

       print "fillUARTbank          : UART(%1.1d-0x____) - ERROR : invalid UART bank %1.1d" % ( UARTbank , UARTbank )

    return

def reportIndividualTaps( ) :

    print "reportIndividualTaps  : UART(_-0x__0x__) - ->     bank 2    |     bank 3    |     bank 4    |"
 
    for entry in range( 0 , 63 ) :

        readback_value = [ ]

        for UARTbank in range( 2 , 5 ) :

            tap_gap       = entry + ( UARTbank-2 )*63

            timebin_start = entry + ( UARTbank-2 )*63
            timebin_end   = entry + ( UARTbank-2 )*63 + 1

            least_significant_addr = int(entry)*2 + 0
            most_significant_addr  = int(entry)*2 + 1

            if ( ( UARTbank == 2 ) or ( UARTbank == 3 ) ) :
               device.writeRegister( int(0x7f) , UARTbank )           # select the bank
               readback_least_significant_byte = device.readRegister( least_significant_addr )
               readback_most_significant_byte  = device.readRegister( most_significant_addr )
               readback_value.extend( [ ( readback_most_significant_byte << 8 ) | readback_least_significant_byte ] )
            else :
               if ( entry < 2 ) :
                  device.writeRegister( int(0x7f) , UARTbank )        # select the bank
                  readback_least_significant_byte = device.readRegister( least_significant_addr )
                  readback_most_significant_byte  = device.readRegister( most_significant_addr )
                  readback_value.extend( [ ( readback_most_significant_byte << 8 ) | readback_least_significant_byte ] )
               else :
                  readback_value.extend( [ 0 ] )

        if ( entry < 2 ) :
           print "reportIndividualTaps  : UART(_-0x%2.2x0x%2.2x) - -> tap %3d 0x%3.3X | tap %3d 0x%3.3X | tap %3d 0x%3.3X |" % \
                 ( most_significant_addr , least_significant_addr , entry , readback_value[0] , entry+63 , readback_value[1] , entry+63*2 , readback_value[2] )
        else :
           print "reportIndividualTaps  : UART(_-0x%2.2x0x%2.2x) - -> tap %3d 0x%3.3X | tap %3d 0x%3.3X | tap --- ----- |"   % \
                 ( most_significant_addr , least_significant_addr , entry , readback_value[0] , entry+63 , readback_value[1]  )

    return

def reportTapVdlyNs( ) :

    number_of_columns = 16
    print "reportTapVdlyNs       : ->      | " ,
    for entry in range ( 0 , number_of_columns ) :
        print " 0x%2.2X " % ( entry ) ,

    for tap_gap in range( 0 , 128 ) :

        UARTbank = 2 + int(tap_gap / 63)
        entry    = (tap_gap % 63)

        timebin_start = entry + ( UARTbank-2 )*63
        timebin_end   = entry + ( UARTbank-2 )*63 + 1

        least_significant_addr = int(entry)*2 + 0
        most_significant_addr  = int(entry)*2 + 1

#       print "DEBUG - tap_gap = %d --> UARTbank = %d / entry = %d --> lsa = 0x%2.2x / msa = 0x%2.2x" % \
#             ( tap_gap , UARTbank , entry , least_significant_addr , most_significant_addr )

        if ( ( UARTbank == 2 ) or ( UARTbank == 3 ) ) :
           device.writeRegister( int(0x7f) , UARTbank )           # select the bank
           readback_least_significant_byte = device.readRegister( least_significant_addr )
           readback_most_significant_byte  = device.readRegister( most_significant_addr )
           readback_value = ( readback_most_significant_byte << 8 ) | readback_least_significant_byte
        else :
           if ( entry < 2 ) :
              device.writeRegister( int(0x7f) , UARTbank )        # select the bank
              readback_least_significant_byte = device.readRegister( least_significant_addr )
              readback_most_significant_byte  = device.readRegister( most_significant_addr )
              readback_value = ( readback_most_significant_byte << 8 ) | readback_least_significant_byte
           else :
              readback_value = 0

        if ( ( tap_gap % number_of_columns ) == 0 ) :
           print
           print "reportTapVdlyNs       : -> 0x%2.2X |" % ( int(tap_gap / number_of_columns) ) ,
        print " 0x%3.3X" % ( readback_value ) ,

    print

    return

def loadSlopeLineIntoIndividualDelayLineTaps( start_value , end_value ,  LoadLAB4B_True_LoadUARTOnly_False_Flag , verbose ) :

    slope = ( end_value - start_value ) / ( 128.0 - 1.0 )
    value = [ ]
    for entry in range( 0 , 128 ) :
        value.extend( [ start_value + slope*entry ] )
    fillUARTbank( 2 , value , verbose )              # set individual delay line taps for timegaps 0   to   62 to VdlyN = value[0]  to value[62]
    fillUARTbank( 3 , value , verbose )              # set individual delay line taps for timegaps 63  to  125 to VdlyN = value[63] to value[125]
    fillUARTbank( 4 , value , verbose )              # set individual delay line taps for timegaps 126 and 127 to VdlyN = value[126] and value [127]

    if ( LoadLAB4B_True_LoadUARTOnly_False_Flag ) :
       toggleUARTbit( 1 , 0x00 , "load_ext" )        # load external DACs as this also loads the delay line taps  : toggle by writing a 1 and then a 0
#      toggleUARTbit( 4 , 0x04 , "load_taps" )       # load the delay line tap DACs : toggle by writing a 1 and then a 0 (if FLAG says do that!)

    selectUARTbank( 0 )

    return

def loadConstantIntoIndividualDelayLineTaps( value , LoadLAB4B_True_LoadUARTOnly_False_Flag , verbose ) :

    fillUARTbank( 2 , value , verbose )              # set individual delay line taps for timegaps 0   to   63 to VdlyN = value
    fillUARTbank( 3 , value , verbose )              # set individual delay line taps for timegaps 64  to  126 to VdlyN = value
    fillUARTbank( 4 , value , verbose )              # set individual delay line taps for timegaps 127 and 128 to VdlyN = value

    if ( LoadLAB4B_True_LoadUARTOnly_False_Flag ) :
       toggleUARTbit( 1 , 0x00 , "load_ext" )        # load external DACs as this also loads the delay line taps  : toggle by writing a 1 and then a 0
#      toggleUARTbit( 4 , 0x04 , "load_taps" )       # load the delay line tap DACs : toggle by writing a 1 and then a 0 (if FLAG says do that!)

    selectUARTbank( 0 )

    return

def ReportVdlyNMode( ) :

    reportUARTword( 1 , 0x12 , 0x11 , "Vbs     " )   # report set point for Vbs just to be sure!
    reportUARTbit( 0 , 0x20 , "VdlySrc " )           # report setting bit for VdlySrc
    VdlySrcBit = readUARTbit( 0 , 0x20 , "VdlySrc " , False )
    if ( VdlySrcBit == 0 ) :
       print "ReportVdlyNMode       : ______________ - CommonVdlyN mode"
    else :
       print "ReportVdlyNMode       : ______________ - IndividualVdlyN mode"
       reportTapVdlyNs( )

    selectUARTbank( 0 )

    return

def CommonVdlyNMode( value ) :

    if ( value < 0 ) :
        DevBoard = abs(value)
        if ( value == -1 ) :
             value = 0x620
        elif ( value == -2 ) :
             value = 0x628
        else :
             value = 0x628
        print "CommonVdlyNMode       : ---------------------------------------------------"
        print "CommonVdlyNMode       : setting common VdlyN mode at 0x%3.3X (DevBoard %d)" % ( value , DevBoard )
        print "CommonVdlyNMode       : ---------------------------------------------------"
    else :
        print "CommonVdlyNMode       : ---------------------------------------------------"
        print "CommonVdlyNMode       : setting common VdlyN mode at 0x%3.3X" % value
        print "CommonVdlyNMode       : ---------------------------------------------------"

    writeUARTword( 1 , 0x04 , 0x03 , value )         # VdlyN
    reportUARTword( 1 , 0x04 , 0x03 , "VdlyN   " )   # report VdlyN set point just to be sure

    writeUARTword( 1 , 0x12 , 0x11 , 0x0000 )        # set Vbs to 0 mV; otherwise, the common mode does not work
    reportUARTword( 1 , 0x12 , 0x11 , "Vbs     " )   # report setpoint for Vbs just to be sure!
    toggleUARTbit( 1 , 0x00 , "load_ext" )           # load internal+external DACs: toggle by writing a 1 and then a 0

    writeUARTbit( 0 , 0x20 , 0 )                     # VdlyN source : common line (0) / individual taps (1) 
    reportUARTbit( 0 , 0x20 , "VdlySrc " )

    selectUARTbank( 0 )

    return

def IndividualVdlyNMode( value , verbose ) :

    if ( value < 0 ) :
        DevBoard = abs(value)
        if ( value == -1 ) :
             value = 0x620
        elif ( value == -2 ) :
             value = 0x628
        else :
             value = 0x628
        print "IndividualVdlyNMode   : ---------------------------------------------------"
        print "IndividualVdlyNMode   : setting individual VdlyN mode at 0x%3.3X (DevBoard %d)" % ( value , DevBoard )
        print "IndividualVdlyNMode   : ---------------------------------------------------"
    else :
        print "IndividualVdlyNMode   : ---------------------------------------------------"
        print "IndividualVdlyNMode   : setting individual VdlyN mode at 0x%3.3X" % value
        print "IndividualVdlyNMode   : ---------------------------------------------------"

    loadConstantIntoIndividualDelayLineTaps( value , True , verbose )

    writeUARTword( 1 , 0x12 , 0x11 , 0x0510 )        # set Vbs to 0.8V; otherwise, individual taps are not biased
    reportUARTword( 1 , 0x12 , 0x11 , "Vbs     " )   # report set point for Vbs just to be sure!
    toggleUARTbit( 1 , 0x00 , "load_ext" )           # load internal+external DACs : toggle by writing a 1 and then a 0

    writeUARTbit( 0 , 0x20 , 1 )                     # VdlyN source : common line (0) / individual taps (1) 
    reportUARTbit( 0 , 0x20 , "VdlySrc " )

    selectUARTbank( 0 )

    return

def GotoCommonVdlyNMode( ) :

    writeUARTword( 1 , 0x12 , 0x11 , 0x0000 )        # set Vbs to 0 mV; otherwise, the common mode does not work
    reportUARTword( 1 , 0x12 , 0x11 , "Vbs     " )   # report setpoint for Vbs just to be sure!
    toggleUARTbit( 1 , 0x00 , "load_ext" )           # load internal+external DACs: toggle by writing a 1 and then a 0

    writeUARTbit( 0 , 0x20 , 0 )                     # VdlyN source : common line (0) / individual taps (1) 
    reportUARTbit( 0 , 0x20 , "VdlySrc " )

    selectUARTbank( 0 )

    return

def GotoIndividualVdlyNMode( ) :

    writeUARTword( 1 , 0x12 , 0x11 , 0x0510 )        # set Vbs to 0.8V; otherwise, individual taps are not biased
    reportUARTword( 1 , 0x12 , 0x11 , "Vbs     " )   # report set point for Vbs just to be sure!
    toggleUARTbit( 1 , 0x00 , "load_ext" )           # load internal+external DACs : toggle by writing a 1 and then a 0

    writeUARTbit( 0 , 0x20 , 1 )                     # VdlyN source : common line (0) / individual taps (1) 
    reportUARTbit( 0 , 0x20 , "VdlySrc " )

    reportTapVdlyNs( )

    selectUARTbank( 0 )

    return

def ReportBoard( ) :

    ReportIntDACs( )
    ReportExtDACs( )
    ReportVdlyNMode( )
    ReportCommonDT( )

    selectUARTbank( 0 )

    return

def InitDevBoard2( CommonMode_True_IndividualTapMode_False_Flag ) :

#   - BANK 0 : the internal DACs

    print "InitDevBoard2         : ------------------------------"
    print "InitDevBoard2         : setting internal DACs (BANK 0)"
    print "InitDevBoard2         : ------------------------------"

    InitIntDACs_DevBoard2( )

#   - BANK 1 : the external DACs

    print "InitDevBoard2         : ------------------------------"
    print "InitDevBoard2         : setting external DACs (BANK 1)"
    print "InitDevBoard2         : ------------------------------"

    InitExtDACs_DevBoard2( )

#   - BANK 2 , 3 , and 4 : the internal DACs

    if ( CommonMode_True_IndividualTapMode_False_Flag ) :

       print "InitDevBoard2         : -----------------------------------------------------------------------"
       print "InitDevBoard2         : using common VdlyN mode - not setting individual tap DACs (BANKS 2,3,4)"
       print "InitDevBoard2         : -----------------------------------------------------------------------"

       CommonVdlyNMode( -2 )                         # load common VdlyN for devboard 2

    else :

       print "InitDevBoard2         : ------------------------------------------------------------------------"
       print "InitDevBoard2         : using individual tap DACs - loading individual tap DACs (BANKS 2,3,4)"
       print "InitDevBoard2         : ------------------------------------------------------------------------"

       IndividualVdlyNMode( -2 , False )             # load individual taps for devboard 2, do *NOT* be verbose with output as taps are set

    selectUARTbank( 0 )

    return

def InitDevBoard1( CommonMode_True_IndividualTapMode_False_Flag ) :

#   - BANK 0 : the internal DACs

    print "InitDevBoard1         : ------------------------------"
    print "InitDevBoard1         : setting internal DACs (BANK 0)"
    print "InitDevBoard1         : ------------------------------"

    InitIntDACs_DevBoard1( )

#   - BANK 1 : the external DACs

    print "InitDevBoard1         : ------------------------------"
    print "InitDevBoard1         : setting external DACs (BANK 1)"
    print "InitDevBoard1         : ------------------------------"

    InitExtDACs_DevBoard1( )

#   - BANK 2 , 3 , and 4 : the internal DACs

    if ( CommonMode_True_IndividualTapMode_False_Flag ) :

       print "InitDevBoard1         : -----------------------------------------------------------------------"
       print "InitDevBoard1         : using common VdlyN mode - not setting individual tap DACs (BANKS 2,3,4)"
       print "InitDevBoard1         : -----------------------------------------------------------------------"

       CommonVdlyNMode( -1 )                         # load common VdlyN for devboard 1

    else :

       print "InitDevBoard1         : ------------------------------------------------------------------------"
       print "InitDevBoard1         : using individual tap DACs - loading individual tap DACs (BANKS 2,3,4)"
       print "InitDevBoard1         : ------------------------------------------------------------------------"

       IndividualVdlyNMode( -1 , False )             # load individual taps for devboard 1, do *NOT* be verbose with output as taps are set

    selectUARTbank( 0 )

    return

def ReportExtDACs( ) :

    reportUARTword( 1 , 0x02 , 0x01 , "Vbias   " )   # Vbias
    reportUARTword( 1 , 0x14 , 0x13 , "Vbias2  " )   # Vbias2

    reportUARTword( 1 , 0x04 , 0x03 , "VdlyN   " )   # VdlyN
    reportUARTword( 1 , 0x06 , 0x05 , "VdlyP   " )   # VdlyP

    reportUARTword( 1 , 0x10 , 0x0F , "XROVDD  " )   # XROVDD

    reportUARTword( 1 , 0x16 , 0x15 , "CMPbias " )   # CMPbias
    reportUARTword( 1 , 0x18 , 0x17 , "SBbias  " )   # SBbias

    reportUARTword( 1 , 0x1C , 0x1B , "XISE    " )   # XISE

    reportUARTword( 1 , 0x12 , 0x11 , "Vbs     " )   # Vbs

    reportUARTword( 1 , 0x08 , 0x07 , "SPARE1  " )   # SPARE1
    reportUARTword( 1 , 0x0C , 0x0B , "SPARE2  " )   # SPARE2
    reportUARTword( 1 , 0x20 , 0x1F , "SPARE3  " )   # SPARE3

    selectUARTbank( 0 )

    return

def InitExtDACs_DevBoard2( ) :

    print "InitExtDACs_DevBoard2 : ---------------------------------------------------"
    print "InitExtDACs_DevBoard2 : setting external DACs for DevBoard 2 (BANK 1)"
    print "InitExtDACs_DevBoard2 : ---------------------------------------------------"

    writeUARTword( 1 , 0x02 , 0x01 , 0x0440 )        # Vbias
    writeUARTword( 1 , 0x14 , 0x13 , 0x0400 )        # Vbias2

    writeUARTword( 1 , 0x04 , 0x03 , 0x0628 )        # VdlyN
    writeUARTword( 1 , 0x06 , 0x05 , 0x0AA8 )        # VdlyP

    writeUARTword( 1 , 0x10 , 0x0F , 0x0FFF )        # XROVDD

    writeUARTword( 1 , 0x16 , 0x15 , 0x0500 )        # CMPbias
    writeUARTword( 1 , 0x18 , 0x17 , 0x0546 )        # SBbias

    writeUARTword( 1 , 0x1C , 0x1B , 0x0900 )        # XISE

    writeUARTword( 1 , 0x12 , 0x11 , 0x0000 )        # Vbs (for common VdlyN mode, this must be 0V!)

    writeUARTword( 1 , 0x08 , 0x07 , 0x0000 )        # SPARE1
    writeUARTword( 1 , 0x0C , 0x0B , 0x0000 )        # SPARE2
    writeUARTword( 1 , 0x20 , 0x1F , 0x0000 )        # SPARE3

    ReportExtDACs( )

    toggleUARTbit( 1 , 0x00 , "load_ext" )           # load internal+external DACs : toggle by writing a 1 and then a 0

    selectUARTbank( 0 )

    return

def InitExtDACs_DevBoard1( ) :

    print "InitExtDACs_DevBoard1 : ---------------------------------------------------"
    print "InitExtDACs_DevBoard1 : setting external DACs for DevBoard 1 (BANK 1)"
    print "InitExtDACs_DevBoard1 : ---------------------------------------------------"

    writeUARTword( 1 , 0x02 , 0x01 , 0x0440 )        # Vbias
    writeUARTword( 1 , 0x14 , 0x13 , 0x0400 )        # Vbias2

    writeUARTword( 1 , 0x04 , 0x03 , 0x0620 )        # VdlyN
    writeUARTword( 1 , 0x06 , 0x05 , 0x0AA8 )        # VdlyP

    writeUARTword( 1 , 0x10 , 0x0F , 0x0800 )        # XROVDD

    writeUARTword( 1 , 0x16 , 0x15 , 0x0500 )        # CMPbias
    writeUARTword( 1 , 0x18 , 0x17 , 0x0546 )        # SBbias

    writeUARTword( 1 , 0x1C , 0x1B , 0x0800 )        # XISE

    writeUARTword( 1 , 0x12 , 0x11 , 0x0000 )        # Vbs (for common VdlyN mode, this must be 0V!)
  
    writeUARTword( 1 , 0x08 , 0x07 , 0x0000 )        # SPARE1
    writeUARTword( 1 , 0x0C , 0x0B , 0x0000 )        # SPARE2
    writeUARTword( 1 , 0x20 , 0x1F , 0x0000 )        # SPARE3

    ReportExtDACs( )

    toggleUARTbit( 1 , 0x00 , "load_ext" )           # load internal+external DACs : toggle by writing a 1 and then a 0

    selectUARTbank( 0 )

    return

def ReportIntDACs( ) :

    reportUARTword( 0 , 0x07 , 0x06 , "LWRSTB  " )   # LWRSTB
    reportUARTword( 0 , 0x09 , 0x08 , "TWRSTB  " )   # TWRSTB

    reportUARTword( 0 , 0x0F , 0x0E , "LS1     " )   # LS1
    reportUARTword( 0 , 0x11 , 0x10 , "TS1     " )   # TS1

    reportUARTword( 0 , 0x13 , 0x12 , "LS2     " )   # LS2
    reportUARTword( 0 , 0x15 , 0x14 , "TS2     " )   # TS2

    reportUARTword( 0 , 0x17 , 0x16 , "LPHASE  " )   # LPHASE
    reportUARTword( 0 , 0x19 , 0x18 , "TPHASE  " )   # TPHASE

    reportUARTword( 0 , 0x1B , 0x1A , "LSSPin  " )   # LSSPin
    reportUARTword( 0 , 0x1D , 0x1C , "TSSPin  " )   # TSSPin

    reportUARTword( 0 , 0x1F , 0x1E , "TimeReg " )   # TimeReg

    reportUARTbyte( 0 , 0x02 , "ChoicePh" )          # ChoicePhase

    reportUARTbyte( 0 , 0x03 , "PedSub  " )          # pedestal subtraction : off            (0) / on                  (1)
    reportUARTbyte( 0 , 0x04 , "PedUpd  " )          # updating pedestal    : no             (0) / yes                 (1)
    reportUARTbyte( 0 , 0x05 , "PedRead " )          # reading pedestal     : no - read data (0) / yes - read pedestal (1)

    selectUARTbank( 0 )

    return

def InitIntDACs_DevBoard2( ) :

    print "InitIntDACs_DevBoard2 : ---------------------------------------------------"
    print "InitIntDACs_DevBoard2 : setting internal DACs for DevBoard 2 (BANK 0)"
    print "InitIntDACs_DevBoard2 : ---------------------------------------------------"

    writeUARTword( 0 , 0x07 , 0x06 , 0x0054 )        # LWRSTB
    writeUARTword( 0 , 0x09 , 0x08 , 0x0012 )        # TWRSTB
                                           
    writeUARTword( 0 , 0x0F , 0x0E , 0x001C )        # LS1
    writeUARTword( 0 , 0x11 , 0x10 , 0x0047 )        # TS1
                                           
    writeUARTword( 0 , 0x13 , 0x12 , 0x005B )        # LS2
    writeUARTword( 0 , 0x15 , 0x14 , 0x0004 )        # TS2
                                           
    writeUARTword( 0 , 0x17 , 0x16 , 0x0006 )        # LPHASE
    writeUARTword( 0 , 0x19 , 0x18 , 0x0020 )        # TPHASE
                                           
    writeUARTword( 0 , 0x1B , 0x1A , 0x0060 )        # LSSPin
    writeUARTword( 0 , 0x1D , 0x1C , 0x0010 )        # TSSPin
                                           
    writeUARTword( 0 , 0x1F , 0x1E , 0x0064 )        # TimeReg

    writeUARTbyte( 0 , 0x02 , 15 )                   # ChoicePhase

    writeUARTbyte( 0 , 0x03 , 0 )                    # pedestal subtraction : turn off (0)      / turn on (1)
    writeUARTbyte( 0 , 0x04 , 0 )                    # update pedestal      : do not update (0) / update (1)
    writeUARTbyte( 0 , 0x05 , 0 )                    # show pedestal        : readout data (0)  / readout pedestal (1)

    ReportIntDACs( )

# why...?
#    toggleUARTbit( 0 , 0x01 , "do_trig " )           # do trigger           : toggle by writing a 1 and then a 0
# This will screw everything up.

    toggleUARTbit( 0 , 0x00 , "load_int" )           # load internal DACs   : toggle by writing a 1 and then a 0

    selectUARTbank( 0 )

    return

def InitIntDACs_DevBoard1( ) :

    print "InitIntDACs_DevBoard1 : ---------------------------------------------------"
    print "InitIntDACs_DevBoard1 : setting internal DACs for DevBoard 1 (BANK 0)"
    print "InitIntDACs_DevBoard1 : ---------------------------------------------------"

    writeUARTword( 0 , 0x07 , 0x06 , 0x0054 )        # LWRSTB
    writeUARTword( 0 , 0x09 , 0x08 , 0x0012 )        # TWRSTB
                                           
    writeUARTword( 0 , 0x0F , 0x0E , 0x001C )        # LS1
    writeUARTword( 0 , 0x11 , 0x10 , 0x0047 )        # TS1
                                           
    writeUARTword( 0 , 0x13 , 0x12 , 0x005B )        # LS2
    writeUARTword( 0 , 0x15 , 0x14 , 0x0004 )        # TS2
                                           
    writeUARTword( 0 , 0x17 , 0x16 , 0x0006 )        # LPHASE
    writeUARTword( 0 , 0x19 , 0x18 , 0x0020 )        # TPHASE
                                           
    writeUARTword( 0 , 0x1B , 0x1A , 0x0060 )        # LSSPin
    writeUARTword( 0 , 0x1D , 0x1C , 0x0007 )        # TSSPin
                                           
    writeUARTword( 0 , 0x1F , 0x1E , 0x0064 )        # TimeReg

    writeUARTbyte( 0 , 0x02 , 14 )                   # ChoicePhase

    writeUARTbyte( 0 , 0x03 , 0 )                    # pedestal subtraction : turn off (0)      / turn on (1)
    writeUARTbyte( 0 , 0x04 , 0 )                    # update pedestal      : do not update (0) / update (1)
    writeUARTbyte( 0 , 0x05 , 0 )                    # show pedestal        : readout data (0)  / readout pedestal (1)

    ReportIntDACs( )

#    toggleUARTbit( 0 , 0x01 , "do_trig " )           # do trigger           : toggle by writing a 1 and then a 0
    toggleUARTbit( 0 , 0x00 , "load_int" )           # load internal DACs   : toggle by writing a 1 and then a 0

    selectUARTbank( 0 )

    return

def PressIntDAQLoad( ) :

    toggleUARTbit( 0 , 0x00 , "load_int" )           # load internal DACs   : toggle by writing a 1 and then a 0

    selectUARTbank( 0 )

    return

def PressExtDAQLoad( ) :

    toggleUARTbit( 1 , 0x00 , "load_ext" )           # load external DACs   : toggle by writing a 1 and then a 0

    selectUARTbank( 0 )

    return

def PressTapLoad( ) :

    toggleUARTbit( 4 , 0x04 , "load_taps" )          # load the delay line tap DACs : toggle by writing a 1 and then a 0

    selectUARTbank( 0 )

    return

def SetWRSTBtoDevBoardDefault( devboard ) :

    if ( devboard == -1 ) :
       leading  = 0x0054     # LWRSTB
       trailing = 0x0012     # TWRSTB
    elif ( devboard == -2 ) :
       leading  = 0x0054     # LWRSTB
       trailing = 0x0012     # TWRSTB
    else :
       leading  = 0x0054     # LWRSTB
       trailing = 0x0012     # TWRSTB

    writeUARTword( 0 , 0x07 , 0x06 , leading )       # LWRSTB
    writeUARTword( 0 , 0x09 , 0x08 , trailing )      # TWRSTB

    reportUARTword( 0 , 0x07 , 0x06 , "LWRSTB  " )   # report setpoint for LWRSTB just in case
    reportUARTword( 0 , 0x09 , 0x08 , "TWRSTB  " )   # report setpoint for TWRSTB just in case
    toggleUARTbit( 0 , 0x00 , "load_int" )           # load internal DACs   : toggle by writing a 1 and then a 0

    selectUARTbank( 0 )

    return

def ReportWRSTB( ) :

    reportUARTword( 0 , 0x07 , 0x06 , "LWRSTB  " )   # report setpoint for LWRSTB just in case
    reportUARTword( 0 , 0x09 , 0x08 , "TWRSTB  " )   # report setpoint for TWRSTB just in case
    selectUARTbank( 0 )

    return

def SetWRSTB( leading , trailing ) :

    writeUARTword( 0 , 0x07 , 0x06 , leading )       # LWRSTB
    writeUARTword( 0 , 0x09 , 0x08 , trailing )      # TWRSTB

    reportUARTword( 0 , 0x07 , 0x06 , "LWRSTB  " )   # report setpoint for LWRSTB just in case
    reportUARTword( 0 , 0x09 , 0x08 , "TWRSTB  " )   # report setpoint for TWRSTB just in case
    toggleUARTbit( 0 , 0x00 , "load_int" )           # load internal DACs   : toggle by writing a 1 and then a 0

    selectUARTbank( 0 )

    return

def SetS1toDevBoardDefault( devboard ) :

    if ( devboard == -1 ) :
       leading  = 0x001C     # LS1
       trailing = 0x0047     # TS1
    elif ( devboard == -2 ) :
       leading  = 0x001C     # LS1
       trailing = 0x0047     # TS1
    else :
       leading  = 0x001C     # LS1
       trailing = 0x0047     # TS1

    writeUARTword( 0 , 0x0F , 0x0E , leading )       # LS1
    writeUARTword( 0 , 0x11 , 0x10 , trailing )      # TS1

    reportUARTword( 0 , 0x0F , 0x0E , "LS1     " )   # report setpoint for LS1 just to be sure
    reportUARTword( 0 , 0x11 , 0x10 , "TS1     " )   # report setpoint for TS1 just to be sure
    toggleUARTbit( 0 , 0x00 , "load_int" )           # load internal DACs   : toggle by writing a 1 and then a 0

    selectUARTbank( 0 )

    return

def ReportS1( ) :

    reportUARTword( 0 , 0x0F , 0x0E , "LS1     " )   # report setpoint for LS1 just to be sure
    reportUARTword( 0 , 0x11 , 0x10 , "TS1     " )   # report setpoint for TS1 just to be sure
    selectUARTbank( 0 )

    return

def SetS1( leading , trailing ) :

    writeUARTword( 0 , 0x0F , 0x0E , leading )       # LS1
    writeUARTword( 0 , 0x11 , 0x10 , trailing )      # TS1

    reportUARTword( 0 , 0x0F , 0x0E , "LS1     " )   # report setpoint for LS1 just to be sure
    reportUARTword( 0 , 0x11 , 0x10 , "TS1     " )   # report setpoint for TS1 just to be sure
    toggleUARTbit( 0 , 0x00 , "load_int" )           # load internal DACs   : toggle by writing a 1 and then a 0

    selectUARTbank( 0 )

    return

def SetS2toDevBoardDefault( devboard ) :

    if ( devboard == -1 ) :
       leading  = 0x005B     # LS2
       trailing = 0x0004     # TS2
    elif ( devboard == -2 ) :
       leading  = 0x005B     # LS2
       trailing = 0x0004     # TS2
    else :
       leading  = 0x005B     # LS2
       trailing = 0x0004     # TS2

    writeUARTword( 0 , 0x13 , 0x12 , leading )       # LS2
    writeUARTword( 0 , 0x15 , 0x14 , trailing )      # TS2
                                           
    reportUARTword( 0 , 0x13 , 0x12 , "LS2     " )   # report setpoint for LS2 just to be sure
    reportUARTword( 0 , 0x15 , 0x14 , "TS2     " )   # report setpoint for TS2 just to be sure
    toggleUARTbit( 0 , 0x00 , "load_int" )           # load internal DACs   : toggle by writing a 1 and then a 0

    selectUARTbank( 0 )

    return

def ReportS2( ) :

    reportUARTword( 0 , 0x13 , 0x12 , "LS2     " )   # report setpoint for LS2 just to be sure
    reportUARTword( 0 , 0x15 , 0x14 , "TS2     " )   # report setpoint for TS2 just to be sure
    selectUARTbank( 0 )

    return

def SetS2( leading , trailing ) :

    writeUARTword( 0 , 0x13 , 0x12 , leading )       # LS2
    writeUARTword( 0 , 0x15 , 0x14 , trailing )      # TS2
                                           
    reportUARTword( 0 , 0x13 , 0x12 , "LS2     " )   # report setpoint for LS2 just to be sure
    reportUARTword( 0 , 0x15 , 0x14 , "TS2     " )   # report setpoint for TS2 just to be sure
    toggleUARTbit( 0 , 0x00 , "load_int" )           # load internal DACs   : toggle by writing a 1 and then a 0

    selectUARTbank( 0 )

    return

def SetPHASEtoDevBoardDefault( devboard ) :

    if ( devboard == -1 ) :
       leading  = 0x0006     # LPHASE
       trailing = 0x0020     # TPHASE
    elif ( devboard == -2 ) :
       leading  = 0x0006     # LPHASE
       trailing = 0x0020     # TPHASE
    else :
       leading  = 0x0006     # LPHASE
       trailing = 0x0020     # TPHASE

    writeUARTword( 0 , 0x17 , 0x16 , leading )       # LPHASE
    writeUARTword( 0 , 0x19 , 0x18 , trailing )      # TPHASE
                                           
    reportUARTword( 0 , 0x17 , 0x16 , "LPHASE  " )   # report setpoint for LPHASE just to be sure
    reportUARTword( 0 , 0x19 , 0x18 , "TPHASE  " )   # report setpoint for TPHASE just to be sure
    toggleUARTbit( 0 , 0x00 , "load_int" )           # load internal DACs   : toggle by writing a 1 and then a 0

    selectUARTbank( 0 )

    return

def ReportPHASE( ) :

    reportUARTword( 0 , 0x17 , 0x16 , "LPHASE  " )   # report setpoint for LPHASE just to be sure
    reportUARTword( 0 , 0x19 , 0x18 , "TPHASE  " )   # report setpoint for TPHASE just to be sure
    selectUARTbank( 0 )

    return

def SetPHASE( leading , trailing ) :

    writeUARTword( 0 , 0x17 , 0x16 , leading )       # LPHASE
    writeUARTword( 0 , 0x19 , 0x18 , trailing )      # TPHASE
                                           
    reportUARTword( 0 , 0x17 , 0x16 , "LPHASE  " )   # report setpoint for LPHASE just to be sure
    reportUARTword( 0 , 0x19 , 0x18 , "TPHASE  " )   # report setpoint for TPHASE just to be sure
    toggleUARTbit( 0 , 0x00 , "load_int" )           # load internal DACs   : toggle by writing a 1 and then a 0

    selectUARTbank( 0 )

    return

def SetSSPintoDevBoardDefault( devboard ) :

    if ( devboard == -1 ) :
       leading  = 0x0060     # LSSPin
       trailing = 0x0007     # TSSPin
    elif ( devboard == -2 ) :
       leading  = 0x0060     # LSSPin
       trailing = 0x0010     # TSSPin
    else :
       leading  = 0x0060     # LSSPin
       trailing = 0x0010     # TSSPin

    writeUARTword( 0 , 0x1B , 0x1A , leading )       # LSSPin
    writeUARTword( 0 , 0x1D , 0x1C , trailing )      # TSSPin
                                           
    reportUARTword( 0 , 0x1B , 0x1A , "LSSPin  " )   # report setpoint for LSSPin just to be sure
    reportUARTword( 0 , 0x1D , 0x1C , "TSSPin  " )   # report setpoint for TSSPin just to be sure
    toggleUARTbit( 0 , 0x00 , "load_int" )           # load internal DACs   : toggle by writing a 1 and then a 0

    selectUARTbank( 0 )

    return

def ReportSSPin( ) :

    reportUARTword( 0 , 0x1B , 0x1A , "LSSPin  " )   # report setpoint for LSSPin just to be sure
    reportUARTword( 0 , 0x1D , 0x1C , "TSSPin  " )   # report setpoint for TSSPin just to be sure
    selectUARTbank( 0 )

    return

def SetSSPin( leading , trailing ) :

    writeUARTword( 0 , 0x1B , 0x1A , leading )       # LSSPin
    writeUARTword( 0 , 0x1D , 0x1C , trailing )      # TSSPin
                                           
    reportUARTword( 0 , 0x1B , 0x1A , "LSSPin  " )   # report setpoint for LSSPin just to be sure
    reportUARTword( 0 , 0x1D , 0x1C , "TSSPin  " )   # report setpoint for TSSPin just to be sure
    toggleUARTbit( 0 , 0x00 , "load_int" )           # load internal DACs   : toggle by writing a 1 and then a 0

    selectUARTbank( 0 )

    return

def ReportTimeReg( ) :

    reportUARTword( 0 , 0x1F , 0x1E , "TimeReg " )   # report setpoint for TimeReg just to be sure
    selectUARTbank( 0 )

    return

def SetTimeReg( value ) :

    writeUARTword( 0 , 0x1F , 0x1E , value )         # TimeReg

    reportUARTword( 0 , 0x1F , 0x1E , "TimeReg " )   # report setpoint for TimeReg just to be sure
    toggleUARTbit( 0 , 0x00 , "load_int" )           # load internal DACs   : toggle by writing a 1 and then a 0

    selectUARTbank( 0 )

    return

def SetChoicePhasetoDevBoardDefault( devboard ) :

    if ( devboard == -1 ) :
        value = 14
    elif ( devboard == -2 ) :
        value = 15
    else :
        value = 14

    writeUARTbyte( 0 , 0x02 , (value&0x00ff) )       # ChoicePhase (should be between 0 and 20, inclusive)

    reportUARTbyte( 0 , 0x02 , "ChoicePh" )          # report setpoint for ChoicePhase just to be sure
    toggleUARTbit( 0 , 0x00 , "load_int" )           # load internal DACs   : toggle by writing a 1 and then a 0

    selectUARTbank( 0 )

    return

def ReportChoicePhase( ) :

    reportUARTbyte( 0 , 0x02 , "ChoicePh" )          # report setpoint for ChoicePhase just to be sure
    selectUARTbank( 0 )

    return

def SetChoicePhase( value ) :

    writeUARTbyte( 0 , 0x02 , (value&0x00ff) )       # ChoicePhase (should be between 0 and 20, inclusive)

    reportUARTbyte( 0 , 0x02 , "ChoicePh" )          # report setpoint for ChoicePhase just to be sure
    toggleUARTbit( 0 , 0x00 , "load_int" )           # load internal DACs   : toggle by writing a 1 and then a 0

    selectUARTbank( 0 )

    return

def ReportVbias( ) :

    reportUARTword( 1 , 0x02 , 0x01 , "Vbias   " )   # report setpoint for Vbias just to be sure
    selectUARTbank( 0 )

    return

def SetVbias( value ) :

    writeUARTword( 1 , 0x02 , 0x01 , value )         # Vbias

    reportUARTword( 1 , 0x02 , 0x01 , "Vbias   " )   # report setpoint for Vbias just to be sure
    toggleUARTbit( 1 , 0x00 , "load_ext" )           # load external DACs   : toggle by writing a 1 and then a 0
                                           
    selectUARTbank( 0 )

    return

def ReportVbias2( ) :

    reportUARTword( 1 , 0x14 , 0x13 , "Vbias2  " )   # report setpoint for Vbias2 just to be sure
    selectUARTbank( 0 )

    return

def SetVbias2( value ) :

    writeUARTword( 1 , 0x14 , 0x13 , value )         # Vbias2

    reportUARTword( 1 , 0x14 , 0x13 , "Vbias2  " )   # report setpoint for Vbias2 just to be sure
    toggleUARTbit( 1 , 0x00 , "load_ext" )           # load external DACs   : toggle by writing a 1 and then a 0
                                           
    selectUARTbank( 0 )

    return

def ReportVdlyN( ) :

    reportUARTword( 1 , 0x04 , 0x03 , "VdlyN   " )   # report setpoint for VdlyN just to be sure
    selectUARTbank( 0 )

    return

def SetVdlyN( value ) :

    if ( value < 0 ) :
       DevBoard = abs(value)
       if ( value == -1 ) :
            value = 0x620
       elif ( value == -2 ) :
            value = 0x628
       else :
            value = 0x628

    writeUARTword( 1 , 0x04 , 0x03 , value )         # VdlyN

    reportUARTword( 1 , 0x04 , 0x03 , "VdlyN   " )   # report setpoint for VdlyN just to be sure
    toggleUARTbit( 1 , 0x00 , "load_ext" )           # load external DACs   : toggle by writing a 1 and then a 0
                                           
    selectUARTbank( 0 )

    return

def ReportVdlyP( ) :

    reportUARTword( 1 , 0x06 , 0x05 , "VdlyP   " )   # report setpoint for VdlyP just to be sure
    selectUARTbank( 0 )

    return

def SetVdlyP( value ) :

    if ( value < 0 ) :
        DevBoard = abs(value)
        if ( value == -1 ) :
             value = 0xAA8
        elif ( value == -2 ) :
             value = 0xAA8
        else :
             value = 0xAA8

    writeUARTword( 1 , 0x06 , 0x05 , value )         # VdlyP

    reportUARTword( 1 , 0x06 , 0x05 , "VdlyP   " )   # report setpoint for VdlyP just to be sure
    toggleUARTbit( 1 , 0x00 , "load_ext" )           # load external DACs   : toggle by writing a 1 and then a 0
                                           
    selectUARTbank( 0 )

    return

def ReportCMPbias( ) :

    reportUARTword( 1 , 0x16 , 0x15 , "CMPbias " )   # report setpoint for CMPbias just to be sure
    selectUARTbank( 0 )

    return

def SetCMPbias( value ) :

    writeUARTword( 1 , 0x16 , 0x15 , value )         # CMPbias

    reportUARTword( 1 , 0x16 , 0x15 , "CMPbias " )   # report setpoint for CMPbias just to be sure
    toggleUARTbit( 1 , 0x00 , "load_ext" )           # load external DACs   : toggle by writing a 1 and then a 0

    selectUARTbank( 0 )

    return

def ReportSBbias( ) :

    reportUARTword( 1 , 0x18 , 0x17 , "SBbias  " )   # report setpoint for SBbias just to be sure
    selectUARTbank( 0 )

    return

def SetSBbias( value ) :

    writeUARTword( 1 , 0x18 , 0x17 , value )         # SBbias

    reportUARTword( 1 , 0x18 , 0x17 , "SBbias  " )   # report setpoint for SBbias just to be sure
    toggleUARTbit( 1 , 0x00 , "load_ext" )           # load external DACs   : toggle by writing a 1 and then a 0

    selectUARTbank( 0 )

    return

def ReportXISE( ) :

    reportUARTword( 1 , 0x1C , 0x1B , "XISE    " )   # report setpoint for XISE just to be sure
    selectUARTbank( 0 )

    return

def SetXISE( value ) :

    writeUARTword( 1 , 0x1C , 0x1B , value )         # XISE

    reportUARTword( 1 , 0x1C , 0x1B , "XISE    " )   # report setpoint for XISE just to be sure
    toggleUARTbit( 1 , 0x00 , "load_ext" )           # load external DACs   : toggle by writing a 1 and then a 0

    selectUARTbank( 0 )

    return

def ReportROVDD( ) :

    reportUARTword( 1 , 0x10 , 0x0F , "XROVDD  " )   # report setpoint for XROVDD just to be sure
    selectUARTbank( 0 )

    return

def SetROVDD( value ) :

    writeUARTword( 1 , 0x10 , 0x0F , value )         # XROVDD
    reportUARTword( 1 , 0x10 , 0x0F , "XROVDD  " )   # report setpoint for XROVDD just to be sure
    toggleUARTbit( 1 , 0x00 , "load_ext" )           # load external DACs   : toggle by writing a 1 and then a 0

    selectUARTbank( 0 )

    return

def ReportCommonDT( ) :

    reportUARTword( 4 , 0x06 , 0x05 , "CommonDT" )   # report setpoint for CommondDT just in case
    selectUARTbank( 0 )

    return

def SetCommonDT( value ) :

    writeUARTword( 4 , 0x06 , 0x05 , value )         # Common_dT

    reportUARTword( 4 , 0x06 , 0x05 , "CommonDT" )   # report setpoint for CommondDT just in case
    toggleUARTbit( 0 , 0x00 , "load_int" )           # load internal DACs   : toggle by writing a 1 and then a 0

    selectUARTbank( 0 )

    return

def PedSubOff( ) :

    writeUARTbyte( 0 , 0x03 , 0 )                    # pedestal subtraction : turn off (0) / turn on (1)
    reportUARTbyte( 0 , 0x03 , "PedSub  " )          # pedestal subtraction : off      (0) / on      (1)
    toggleUARTbit( 0 , 0x00 , "load_int" )           # load internal DACs   : toggle by writing a 1 and then a 0

    selectUARTbank( 0 )

    return

def PedSubOn( ) :

    writeUARTbyte( 0 , 0x03 , 1 )                    # pedestal subtraction : turn off (0) / turn on (1)
    reportUARTbyte( 0 , 0x03 , "PedSub  " )          # pedestal subtraction : off      (0) / on      (1)
    toggleUARTbit( 0 , 0x00 , "load_int" )           # load internal DACs   : toggle by writing a 1 and then a 0

    selectUARTbank( 0 )

    return

def UpdatePedOff( ) :

    writeUARTbyte( 0 , 0x04 , 0 )                    # update pedestal      : do not update (0) / update (1)
    reportUARTbyte( 0 , 0x04 , "PedUpd  " )          # updating pedestal    : no            (0) / yes    (1)
    toggleUARTbit( 0 , 0x00 , "load_int" )           # load internal DACs   : toggle by writing a 1 and then a 0

    selectUARTbank( 0 )

    return

def UpdatePedOn( ) :

    writeUARTbyte( 0 , 0x04 , 1 )                    # update pedestal      : do not update (0) / update (1)
    reportUARTbyte( 0 , 0x04 , "PedUpd  " )          # updating pedestal    : no            (0) / yes    (1)
    toggleUARTbit( 0 , 0x00 , "load_int" )           # load internal DACs   : toggle by writing a 1 and then a 0

    selectUARTbank( 0 )

    return

def Usage( ) :

    usage( )

    return

def usage( ) :

    print "# ----------------------------------------------------------------------------------------------------------------------"
    print "#"
    print "# ----------------------------------"
    print "# List Of \"UART low-level\" Functions"
    print "# ----------------------------------"
    print "#"
    print "# ->  selectUARTbank( UARTbank )                                               : select a bank ( valid banks are 0 ... 4 )"
    print "# ->  toggleUARTbit( UARTbank , UARTaddr , label )                             : turn a bit on and then turn it off (lowest order bit of 1 register)"
    print "# ->  writeUARTbit( UARTbank , UARTaddr , value )                              : write a 0 or 1 to a UART bit (lowest order bit of 1 register)"
    print "# ->  writeUARTbyte( UARTbank , UARTaddr_LSB , value )                         : write a VALUE to a UART byte (1 register)"
    print "# ->  writeUARTword( UARTbank , UARTaddr_MSB , UARTaddr_LSB , value )          : write a VALUE to UART word (2 registers)"
    print "# ->  fillUARTbank( UARTbank , value , verbose )                               : write a VALUE or a VALUE LIST to all 63 taps in a specifed bank (for setting individual tap VdlyN)"
    print "# ->  reportUARTbit( UARTbank , UARTaddr , label )                             : report the VALUE of a bit"
    print "# ->  reportUARTbyte( UARTbank , UARTaddr , label )                            : report the VALUE of a UART byte (1 register)"
    print "# ->  reportUARTword( UARTbank , UARTaddr_MSB , UARTaddr_LSB , label )         : report the VALUE of a UART word (2 registers)"
    print "# ->  reportUARTbank( UARTbank )                                               : report the VALUES in the specified UART bank"
    print "# ->  readUARTbit( UARTbank , UARTaddr , label , verbose )                     : return the VALUE of a UART bit                [verbose=TRUE, also report value]"
    print "# ->  readUARTbyte( UARTbank , UARTaddr , label , verbose )                    : return the VALUE of a UART byte (1 register)  [verbose=TRUE, also report value]"
    print "# ->  readUARTword( UARTbank , UARTaddr_MSB , UARTaddr_LSB , label , verbose ) : return the VALUE of a UART word (2 registers) [verbose=TRUE, also report value]"
    print "#"
    print "# ---------------------------------------------"
    print "# List Of \"DevBoard-Level Report/Set\" Functions"
    print "# ---------------------------------------------"
    print "#"
    print "# ->  ReportBoard( ) : report all settings for the board"
    print "#"
    print "# ->  InitDevBoard1( CommonMode_True_IndividualTapMode_False_Flag ) : initialize board to DevBoard1 defaults, FLAG=True for Common VdlyN mode / =False for individual tap VdlyN mode"
    print "# ->  InitDevBoard2( CommonMode_True_IndividualTapMode_False_Flag ) : initialize board to DevBoard2 defaults, FLAG=True for Common VdlyN mode / =False for individual tap VdlyN mode"
    print "#"
    print "# ->  InitExtDACs_DevBoard1( ) : load external DACs to DevBoard1 defaults"
    print "# ->  InitExtDACs_DevBoard2( ) : load external DACs to DevBoard2 defaults"
    print "# ->  InitIntDACs_DevBoard1( ) : load internal DACs to DevBoard1 defaults"
    print "# ->  InitIntDACs_DevBoard2( ) : load internal DACs to DevBoard2 defaults"
    print "#"
    print "# ->  CommonVdlyNMode( value )                       : switch to Common VdlyN mode"
    print "# ->  IndividualVdlyNMode( value , verbose )         : switch to individual taps VdlyN mode, setting all taps VdlyN values to VALUE"
    print "#"
    print "# ->  loadConstantIntoIndividualDelayLineTaps( value , LoadLAB4B_True_LoadUARTOnly_False_Flag , verbose )                     : load all taps VdlyN values to VALUE, but do *NOT* change the current VdlyN mode!"
    print "# ->  loadSlopeLineIntoIndividualDelayLineTaps( start_value , end_value ,  LoadLAB4B_True_LoadUARTOnly_False_Flag , verbose ) : load all taps with a linear trend going from start to end, but do *NOT* change the current VdlyN mode!"
    print "# ->  reportIndividualTaps( )                                                                                                 : report the values of VdlyN for all of the individual taps"
    print "# ->  reportTapVdlyNs( )                                                                                                      : short report of the VdlyN values for all the individual taps"
    print "#"
    print "# ->  GotoCommonVdlyNMode( )                         : switch to Common VdlyN mode, do *NOT* reset the current VdlyN value"
    print "# ->  GotoIndividualVdlyNMode( )                     : switch to individual taps VdlyN mode, but do *NOT* change any of the taps VdlyN values"
    print "#"
    print "# ---------------------------------------------"
    print "# List Of \"Button-Pressing/Load DACs\" Functions"
    print "# ---------------------------------------------"
    print "#"
    print "# ->  PressExtDAQLoad( )   : actually load the external DACs from the values in the registers"
    print "# ->  PressIntDAQLoad( )   : actually load the internal DACS from the values in the registers"
    print "# ->  PressTapLoad( )      : actually load the individual VdlyN values from the registers into the LAB4B chip"
    print "#"
    print "# -------------------------------------------------"
    print "# List Of \"Pedestal Substraction Control\" Functions"
    print "# -------------------------------------------------"
    print "#"
    print "# ->  PedSubOff( )         : turn off pedestal substract mode"
    print "# ->  PedSubOn( )          : turn on pedestal substract mode"
    print "# ->  UpdatePedOff( )      : stop storing data in the pedestal memory (required in order to see any waveforms in ChipScope window)"
    print "# ->  UpdatePedOn( )       : store data in the pedestal memory"
    print "#"
    print "# -------------------------------------------------"
    print "# List Of \"Report Individual DAC Setting\" Functions"
    print "# -------------------------------------------------"
    print "#"
    print "# ->  ReportIntDACs( )     : report on the values in the internal DAC registers"
    print "# ->  ReportExtDACs( )     : report on the values in the external DAC registers"
    print "#"
    print "# ->  ReportWRSTB( )       : report the register values for the WRSTB tap selection"
    print "# ->  ReportS1( )          : report the register values for the S1 tap selection"
    print "# ->  ReportS2( )          : report the register values for the S2 tap selection"
    print "# ->  ReportPHASE( )       : report the register values for the PHASE tap selection"
    print "# ->  ReportSSPin( )       : report the register values for the SSPin tap selection"
    print "# ->  ReportTimeReg( )     : report the register value for the TimReg (monitor signal output) selection"
    print "# ->  ReportChoicePhase( ) : report the register value for the WRSTB->FPGA clock phase (values go from 0 to 20)"
    print "#"
    print "# ->  ReportVbias( )       : report the register value for Vbias (bias voltage for the sample->intermediate cap array transfer)"
    print "# ->  ReportVbias2( )      : report the register value for Vbias2 (bias voltage for the intermediate->main cap array transfer)"
    print "# ->  ReportVdlyNMode( )   : report the source for the VdlyN (either Common or Individual Taps)"
    print "# ->  ReportVdlyN( )       : report the register value for VdlyN (value for CommonDT mode!)"
    print "# ->  ReportVdlyP( )       : report the register value for VdlyP"
    print "# ->  ReportROVDD( )       : report the register value for XROVDD (ROVDD = ~1.2 + this voltage, max is around 0x800)"
    print "# ->  ReportSBbias( )      : report the register value for SBbias"
    print "# ->  ReportCMPbias( )     : report the register value for CMPbias"
    print "# ->  ReportXISE( )        : report the register value for XISE (controls rate of Wilkinson ramp)"
    print "#"
    print "# ->  ReportCommonDT( )    : report the register value for CommonDT (single value loaded into all individual tap VdlyN for tuning)"
    print "#"
    print "# ------------------------------------------------------------------"
    print "# List Of \"Set Individual DAC Setting To DevBoard Default\" Functions"
    print "# ------------------------------------------------------------------"
    print "#"
    print "# ->  SetWRSTBtoDevBoardDefault( devboard )       : set WRSTB to the default value for the specified board (either 1 or 2)"
    print "# ->  SetS1toDevBoardDefault( devboard )          : set S1 to the default value for the specified board (either 1 or 2)"
    print "# ->  SetS2toDevBoardDefault( devboard )          : set S2 to the default value for the specified board (either 1 or 2)"
    print "# ->  SetPHASEtoDevBoardDefault( devboard )       : set PHASE to the default value for the specified board (either 1 or 2)"
    print "# ->  SetSSPintoDevBoardDefault( devboard )       : set SSPin to the default value for the specified board (either 1 or 2)"
    print "# ->  SetChoicePhasetoDevBoardDefault( devboard ) : set ChoicePhase to the default value for the specified board (either 1 or 2)"
    print "#"
    print "# ----------------------------------------------"
    print "# List Of \"Set Individual DAC Setting\" Functions"
    print "# ----------------------------------------------"
    print "#"
    print "# ->  SetWRSTB( leading , trailing ) : set WRSTB value"
    print "# ->  SetS1( leading , trailing )    : set S1 value"
    print "# ->  SetS2( leading , trailing )    : set S2 value"
    print "# ->  SetPHASE( leading , trailing ) : set PHASE value"
    print "# ->  SetSSPin( leading , trailing ) : set SSPin value"
    print "# ->  SetChoicePhase( value )        : set ChoicePhase value"
    print "# ->  SetTimeReg( value )            : set TimeReg value"
    print "#"
    print "# ->  SetVbias( value )              : set Vbias (bias voltage for the sample->intermediate cap array transfer)"
    print "# ->  SetVbias2( value )             : set Vbias2 (bias voltage for the intermediate->main cap array transfer)"
    print "# ->  SetVdlyN( value )              : set VdlyN (either Common or Individual Taps)"
    print "# ->  SetVdlyP( value )              : set VdlyP (value for CommonDT mode!)"
    print "# ->  SetROVDD( value )              : set XROVDD (ROVDD = ~1.2V + this voltage, so max for this register is around 0x800)"
    print "# ->  SetCMPbias( value )            : set CMPbias"
    print "# ->  SetSBbias( value )             : set SBbias"
    print "# ->  SetXISE( value )               : set XISE (controls rate of Wilkenson ramp)"
    print "#"
    print "# ->  SetCommonDT( value )           : set and load the CommonDT (single value loaded into all individual tap VdlyN for tuning)"
    print "#"
    print "# ----------------------------------------------------------------------------------------------------------------------"

    return

def main( ) :

    InitDevBoard2( True )                                # initialize for DevBoard2 with Common VdlyN mode

if __name__ == "__main__":
    main()

