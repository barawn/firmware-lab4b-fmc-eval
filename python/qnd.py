import serial
import time

# Notes:
# The QnD interface *returns* \r\n for a newline, but it recognized
# either '\r' or '\n' as a newline, but not both. If you send \r\n,
# it will see that as 2 newlines.
#
# Also this uses two 'undocumented' commands (i.e. not returned in the
# ? command): disabling the prompt (p) and disabling the local echo
# (e). If you use QnD.close(), it will restore prompt/local echo afterwards,
# but if you just disconnect it you may have to do this yourself (by
# entering P<enter> and E<enter> to restore the prompt and local echo).

class QnD():
    def  __init__(self, portname='/dev/ttyS0', baud=921600):
        self.ser = serial.Serial(portname, baud, timeout=1)
        # Check that it's connected and talking. Do this by putting into a known state.
        self.ser.write("e\nP\n")
        # Wait a millisecond or so.
        time.sleep(0.01)
        # Now flush input buffer.
        self.ser.flushInput()
        # Now send a newline, which should result in "QnD> " being output.
        self.ser.write("\n")
        testStr = self.ser.read(5)
        if testStr != "QnD> ":
            raise IOError("Device not responding")
        # Now disable prompts, which should result in no additional characters.
        self.ser.write("p\n")
        # Done.
    def writeRegister(self, register, value):
        if register > 127 or register < 0:
            raise ValueError("Register out of bounds [00 - 7F]")
        if value > 255 or register < 0:
            raise ValueError("Value out of bounds [00 - FF]")
        hexRegister = '{:02x}'.format(register)
        hexValue = '{:02x}'.format(value)
        toWrite = "W " + hexRegister + " " + hexValue + "\n"
        self.ser.write(toWrite)
    def readRegister(self, register):
        if register > 127:
            raise ValueError("Register out of bounds [00 - 7F]")
        hexRegister = '{:02x}'.format(register)
        toWrite = "R " + hexRegister + "\n"
        self.ser.write(toWrite)
        line = self.ser.readline()
        stripLine = line.rstrip()
        val = int(stripLine, 16)
        return val
    def close(self):
        self.ser.write("P\nE\n")
        self.ser.flushInput()
        self.ser.close()
        
