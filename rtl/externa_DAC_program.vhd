----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:42:16 02/11/2013 
-- Design Name: 
-- Module Name:    externa_DAC_program - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

use work.package_types.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity external_DAC_program is
port(

-- DAC signals to control the following Biases on chip:
-- Vbias, Vbias2, Vbs, VdlyP, VdlyN, xISEL, Sbbias, CMPbias, xROVDD
CLK: in std_LOGIC;
update_all_DACs : in std_logic;
LTC2620_SCK : out std_logic_vector(1 downto 0); --LA06_N, LA14_P
LTC2620_SDI : out std_logic_vector(1 downto 0); --LA06_P, LA_10N
LTC2620_NCS : out std_logic_vector(1 downto 0); --LA10_P, LA_14N
LTC2620_SDO : in std_logic_vector(1 downto 0); --LA22_N, LA_22P


ext_DACs_from_UART : in ext_DACs_from_UART_type;

CONTROL :  inout STD_LOGIC_VECTOR(35 DOWNTO 0)
);
end external_DAC_program;





architecture Behavioral of external_DAC_program is


 

type state_t is (IDLE, ACCESS_NEW_DAC, NEW_REGISTER_WRITE, WAIT_FOR_DONE);
signal state_0 : state_t := IDLE;
signal state_1 : state_t := IDLE;

type reg_array_4 is array (0 to 7) of std_logic_vector(3 downto 0);
type reg_array_12 is array (0 to 7) of std_logic_vector(11 downto 0);
signal wr_reg_array_0 : reg_array_12;
signal wr_reg_array_1 : reg_array_12;
signal addr_reg_array_0 : reg_array_4;
signal addr_reg_array_1 : reg_array_4;
signal chiscope_update_DACs : std_logic;
signal currentDAC_0 : std_logic_vector(3 downto 0) := "0000";
signal currentDAC_1 : std_logic_vector(3 downto 0) := "0000";

signal write_register : std_logic_vector(1 downto 0);
signal s_reg_busy : std_logic_vector(1 downto 0);
signal s_reg_done : std_logic_vector(1 downto 0);
signal register_value_0 : std_logic_vector(11 downto 0);
signal register_value_1 : std_logic_vector(11 downto 0);
signal register_address_0 : std_logic_vector(3 downto 0);
signal register_address_1 : std_logic_vector(3 downto 0);

component ext_DAC_single port(
CLK : in std_logic;
write_register: in std_logic;
register_address : in std_logic_vector(3 downto 0); --Note: command implictly update and turn on 1 DAC
register_value : in std_logic_vector(11 downto 0);
s_reg_busy : out std_logic;
s_reg_done : out std_logic;
LTC2620_SCK : out std_logic; --LA06_N, LA14_P
LTC2620_SDI : out std_logic; --LA06_P, LA_10N
LTC2620_NCS : out std_logic; --LA10_P, LA_14N
LTC2620_SDO : in std_logic --LA22_N, LA_22P
);
end component;


--- Debugging
signal  ASYNC_OUT :  STD_LOGIC_VECTOR(255 DOWNTO 0);

component VIO_DAC
  PORT (
    CONTROL : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0);
    ASYNC_OUT : OUT STD_LOGIC_VECTOR(255 DOWNTO 0));
end component;


begin

-- Mapping of addresses to the 8 * 2 DACs
addr_reg_array_0(0) <= X"0"; --Vbias
addr_reg_array_0(1) <= X"1"; --VdlyN
addr_reg_array_0(2) <= X"2"; --VdlyP
addr_reg_array_0(3) <= X"3"; --SPARE1
addr_reg_array_0(4) <= X"4"; --NC
addr_reg_array_0(5) <= X"5"; --SPARE2
addr_reg_array_0(6) <= X"6"; --NC
addr_reg_array_0(7) <= X"7"; --XRovdd

addr_reg_array_1(0) <= X"0"; --Vbs
addr_reg_array_1(1) <= X"1"; --Vbias2
addr_reg_array_1(2) <= X"2"; --CMPbias
addr_reg_array_1(3) <= X"3"; --SBbias
addr_reg_array_1(4) <= X"4"; --NC
addr_reg_array_1(5) <= X"5"; --XISE
addr_reg_array_1(6) <= X"6"; --NC
addr_reg_array_1(7) <= X"7"; --SPARE3



dac_0: process(CLK)
begin
if rising_edge(CLK) then
	write_register(0) <= '0';
	case state_0 is
	when IDLE => 	if (update_all_DACs = '1') or (chiscope_update_DACs = '1') then state_0 <= ACCESS_NEW_DAC; end if;
	when ACCESS_NEW_DAC => 	state_0 <= NEW_REGISTER_WRITE;
									register_value_0<= wr_reg_array_0(conv_integer(currentDAC_0));
									register_address_0<= addr_reg_array_0(conv_integer(currentDAC_0));
	when NEW_REGISTER_WRITE => state_0 <= WAIT_FOR_DONE;
										write_register(0) <= '1';
	when WAIT_FOR_DONE => if s_reg_done(0) = '1' then 
											if currentDAC_0 < 7 then
													currentDAC_0 <= currentDAC_0 +1;
													state_0 <= ACCESS_NEW_DAC;
											else 
													currentDAC_0 <= (others => '0');
													state_0 <= IDLE;
											end if;
								 end if;
	when others => state_0 <= IDLE;
	end case;
end if;
end process;

dac_1: process(CLK)
begin
if rising_edge(CLK) then
	write_register(1) <= '0';
	case state_1 is
	when IDLE => 	if (update_all_DACs = '1') or (chiscope_update_DACs = '1') then state_1 <= ACCESS_NEW_DAC; end if;
	when ACCESS_NEW_DAC => 	state_1 <= NEW_REGISTER_WRITE;
									register_value_1<= wr_reg_array_1(conv_integer(currentDAC_1));
									register_address_1<= addr_reg_array_1(conv_integer(currentDAC_1));
	when NEW_REGISTER_WRITE => state_1 <= WAIT_FOR_DONE;
										write_register(1) <= '1';
	when WAIT_FOR_DONE => if s_reg_done(1) = '1' then 
											if currentDAC_1 < 7 then
													currentDAC_1 <= currentDAC_1 +1;
													state_1 <= ACCESS_NEW_DAC;
											else 
													currentDAC_1 <= (others => '0');
													state_1 <= IDLE;
											end if;
								 end if;
	when others => state_1 <= IDLE;
	end case;
end if;
end process;


inst_ext_DAC_single_1: ext_DAC_single port map(
CLK => CLK,
write_register => write_register(0),
register_address => register_address_0,
register_value => register_value_0,
s_reg_busy => s_reg_busy(0),
s_reg_done => s_reg_done(0),
LTC2620_SCK => LTC2620_SCK(0),
LTC2620_SDI => LTC2620_SDI(0),
LTC2620_NCS => LTC2620_NCS(0),
LTC2620_SDO => LTC2620_SDO(0)
);


inst_ext_DAC_single_2: ext_DAC_single port map(
CLK => CLK,
write_register => write_register(1),
register_address => register_address_1,
register_value => register_value_1,
s_reg_busy => s_reg_busy(1),
s_reg_done => s_reg_done(1),
LTC2620_SCK => LTC2620_SCK(1),
LTC2620_SDI => LTC2620_SDI(1),
LTC2620_NCS => LTC2620_NCS(1),
LTC2620_SDO => LTC2620_SDO(1)
);

-- Debug
inst_VIO_DAC : VIO_DAC
  port map (
    CONTROL => CONTROL,
    ASYNC_OUT => ASYNC_OUT);
chiscope_update_DACs<= ASYNC_OUT(0);
--wr_reg_array_0(0)<=ASYNC_OUT(12 downto 1); --Vbias
--wr_reg_array_0(1)<=ASYNC_OUT(24 downto 13); --VdlyN
--wr_reg_array_0(2)<=ASYNC_OUT(36 downto 25); --VdlyP
--wr_reg_array_0(3)<=ASYNC_OUT(48 downto 37); --SPARE1
--wr_reg_array_0(4)<= (others =>'0'); --NC
--wr_reg_array_0(5)<=ASYNC_OUT(60 downto 49); --SPARE2
--wr_reg_array_0(6)<= (others =>'0'); --NC
--wr_reg_array_0(7)<=ASYNC_OUT(72 downto 61); --XRovdd
--
--wr_reg_array_1(0)<=ASYNC_OUT(84 downto 73); --Vbs
--wr_reg_array_1(1)<=ASYNC_OUT(96 downto 85); --Vbias2
--wr_reg_array_1(2)<=ASYNC_OUT(108 downto 97); --CMPbias
--wr_reg_array_1(3)<=ASYNC_OUT(120 downto 109); --SBbias
--wr_reg_array_1(4)<= (others =>'0'); --NC
--wr_reg_array_1(5)<=ASYNC_OUT(132 downto 121); --XISE
--wr_reg_array_1(6)<= (others =>'0'); --NC
--wr_reg_array_1(7)<=ASYNC_OUT(144 downto 133); --SPARE3
-- ASYNC_OUT 144 to 256 still free

-- For simulation only
--wr_reg_array_0(0)<= "101010101010";
--wr_reg_array_0(1)<= "110011001100";
--wr_reg_array_0(2)<= "111100001111";
--wr_reg_array_0(3)<= "111111000000";
--wr_reg_array_0(4)<= "000000000000";
--wr_reg_array_0(5)<= "111111111111";
--wr_reg_array_0(6)<= "000000000000";
--wr_reg_array_0(7)<= "000000111111";
--
--wr_reg_array_1(0)<= "101010101010";
--wr_reg_array_1(1)<= "110011001100";
--wr_reg_array_1(2)<= "111100001111";
--wr_reg_array_1(3)<= "111111000000";
--wr_reg_array_1(4)<= "000000000000";
--wr_reg_array_1(5)<= "111111111111";
--wr_reg_array_1(6)<= "000000000000";
--wr_reg_array_1(7)<= "000000111111";


--wr_reg_array_0(0)<=ASYNC_OUT(12 downto 1); --Vbias
--wr_reg_array_0(1)<=ASYNC_OUT(24 downto 13); --VdlyN
--wr_reg_array_0(2)<=ASYNC_OUT(36 downto 25); --VdlyP
--wr_reg_array_0(3)<=ASYNC_OUT(48 downto 37); --SPARE1
--wr_reg_array_0(4)<= (others =>'0'); --NC
--wr_reg_array_0(5)<=ASYNC_OUT(60 downto 49); --SPARE2
--wr_reg_array_0(6)<= (others =>'0'); --NC
--wr_reg_array_0(7)<=ASYNC_OUT(72 downto 61); --XRovdd
--
--wr_reg_array_1(0)<=ASYNC_OUT(84 downto 73); --Vbs
--wr_reg_array_1(1)<=ASYNC_OUT(96 downto 85); --Vbias2
--wr_reg_array_1(2)<=ASYNC_OUT(108 downto 97); --CMPbias
--wr_reg_array_1(3)<=ASYNC_OUT(120 downto 109); --SBbias
--wr_reg_array_1(4)<= (others =>'0'); --NC
--wr_reg_array_1(5)<=ASYNC_OUT(132 downto 121); --XISE
--wr_reg_array_1(6)<= (others =>'0'); --NC
--wr_reg_array_1(7)<=ASYNC_OUT(144 downto 133); --SPARE3


wr_reg_array_0(0)<=ext_DACs_from_UART(0);
wr_reg_array_0(1)<=ext_DACs_from_UART(1);
wr_reg_array_0(2)<=ext_DACs_from_UART(2);
wr_reg_array_0(3)<=ext_DACs_from_UART(3);
wr_reg_array_0(4)<=ext_DACs_from_UART(4);
wr_reg_array_0(5)<=ext_DACs_from_UART(5);
wr_reg_array_0(6)<=ext_DACs_from_UART(6);
wr_reg_array_0(7)<=ext_DACs_from_UART(7);


wr_reg_array_1(0)<=ext_DACs_from_UART(8);
wr_reg_array_1(1)<=ext_DACs_from_UART(9);
wr_reg_array_1(2)<=ext_DACs_from_UART(10);
wr_reg_array_1(3)<=ext_DACs_from_UART(11);
wr_reg_array_1(4)<=ext_DACs_from_UART(12);
wr_reg_array_1(5)<=ext_DACs_from_UART(13);
wr_reg_array_1(6)<=ext_DACs_from_UART(14);
wr_reg_array_1(7)<=ext_DACs_from_UART(15);


end Behavioral;

