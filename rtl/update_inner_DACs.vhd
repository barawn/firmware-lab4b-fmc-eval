----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:43:09 02/11/2013 
-- Design Name: 
-- Module Name:    update_inner_DACs - Behavioral 
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

entity update_inner_DACs is
port(
CLK : in std_logic;
update_all_DACs : in std_logic;
write_register: out std_logic;
register_address : out std_logic_vector(11 downto 0);
register_value : out std_logic_vector(11 downto 0);
s_reg_busy : in std_logic;
s_reg_done : in std_logic;
all_internal_DACs_done : out std_logic;
do_trigger : out std_logic;
choice_phase_debug : out std_logic_vector(4 downto 0);
subtract_pedestal_debug : out std_logic;
update_pedestals_debug : out std_logic;
show_pedestals_debug : out std_logic;

update_DTs_from_UART : in std_logic;
DT : in DT_type;
all_internal_DTs_done : out std_logic;

DACs_from_UART : in DACs_from_UART_type;
update_DACs_from_UART : in std_logic;
trigger_from_UART : in std_logic;
choice_phase_from_UART : in std_logic_vector(4 downto 0);
subtract_pedestal_from_UART : in std_logic;
update_pedestal_from_UART : in std_logic;
show_pedestal_from_UART : in std_logic;
CONTROL :  inout STD_LOGIC_VECTOR(35 DOWNTO 0);
debug_currentDT : out std_logic_vector(11 downto 0)
);
end update_inner_DACs;

architecture Behavioral of update_inner_DACs is

type state_t is (IDLE, ACCESS_NEW_DAC, NEW_REGISTER_WRITE, WAIT_FOR_DONE, ACCESS_NEW_DT, NEW_REGISTER_WRITE_DT, WAIT_FOR_DONE_DT);

signal state : state_t := IDLE;

type reg_array is array (0 to 12) of std_logic_vector(11 downto 0);
signal wr_reg_array : reg_array;
signal addr_reg_array : reg_array;
signal chiscope_update_DACs : std_logic;
signal chiscope_update_DTs : std_logic;
signal currentDAC : std_logic_vector(3 downto 0) := "0000";
signal currentDT : std_logic_vector(11 downto 0) := (others => '0');
signal commonDT : std_logic_vector(11 downto 0);

--- Debugging
signal  ASYNC_OUT :  STD_LOGIC_VECTOR(255 DOWNTO 0);

component VIO_DAC
  PORT (
    CONTROL : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0);
    ASYNC_OUT : OUT STD_LOGIC_VECTOR(255 DOWNTO 0));
end component;

begin

-- Mapping of addresses to the 13 timing registers -- Check correctness!!
addr_reg_array(0) <= X"080"; --LWRSTRB
addr_reg_array(1) <= X"081"; --TWRSTRB
addr_reg_array(2) <= X"082"; --LSSTdly
addr_reg_array(3) <= X"083"; --TSSTdly
addr_reg_array(4) <= X"084"; --LS1
addr_reg_array(5) <= X"085"; --TS1
addr_reg_array(6) <= X"086"; --LS2
addr_reg_array(7) <= X"087"; --TS2
addr_reg_array(8) <= X"088"; --LPHASE
addr_reg_array(9) <= X"089"; --TPHASE
addr_reg_array(10) <= X"F8A"; --LSSPin -- Note: this also clears SR and SS - should NOT be the last
addr_reg_array(11) <= X"08B"; --TSSPin 
addr_reg_array(12) <= X"08C"; --TimReg: CLRPHASE, SSPP, SSPSST, NC, NC, Sel2, Sel1, Sel0 -- Note: this also resets SR and SS clears
										--							X		 X					 0     0     0   -> A1
										--							X		 X					 0     0     1   -> B1
										--							X		 X					 0     1     0   -> A2
										--							X		 X					 0     1     1   -> B2
										--							0		 X					 1     0     0   -> PHASE
										--							1		 0					 1     0     0   -> SSPout
										--							1		 1					 1     0     0   -> SSTout
										--							X		 X					 1     0     1   -> PHAB
										--							X		 X					 1     1     0   -> SSPin
										--							X		 X					 1     1     1   -> WRSTRB


process(CLK)
begin
if rising_edge(CLK) then
	write_register <= '0';
	all_internal_DACs_done <= '0';
	all_internal_DTs_done <= '0';
	case state is
--	when IDLE => 	if (update_all_DACs = '1') or (chiscope_update_DACs = '1') then state <= ACCESS_NEW_DAC; end if;
	when IDLE => 	if (update_all_DACs = '1') or (chiscope_update_DACs = '1') or (update_DACs_from_UART = '1') then state <= ACCESS_NEW_DAC; 
--						elsif (update_DTs_from_UART = '1') then state <= ACCESS_NEW_DT;  -- now it always does the whole thing....
						end if;
	when ACCESS_NEW_DAC => 	state <= NEW_REGISTER_WRITE;
									register_value<= wr_reg_array(conv_integer(currentDAC));
									register_address<= addr_reg_array(conv_integer(currentDAC));
	when NEW_REGISTER_WRITE => state <= WAIT_FOR_DONE;
										write_register <= '1';
	when WAIT_FOR_DONE => if s_reg_done = '1' then 
											if currentDAC < 12 then
													currentDAC <= currentDAC +1;
													state <= ACCESS_NEW_DAC;
											else 
													currentDAC <= (others => '0');
													currentDT <= (others => '0'); --should not be necessary
													all_internal_DACs_done <= '1';
--													state <= IDLE;
													state <= ACCESS_NEW_DT;
											end if;
								 end if;
	when ACCESS_NEW_DT => 	state <= NEW_REGISTER_WRITE_DT;
									register_value<= DT(conv_integer(currentDT)); --now all hardcoded
--									register_value<= x"628";
--									register_value<= commonDT;
									register_address<= currentDT;
	when NEW_REGISTER_WRITE_DT => state <= WAIT_FOR_DONE_DT;
										write_register <= '1';
	when WAIT_FOR_DONE_DT => if s_reg_done = '1' then 
											if currentDT < 127 then
													currentDT <= currentDT +1;
													state <= ACCESS_NEW_DT;
											else 
													currentDT <= (others => '0');
													all_internal_DTs_done <= '1';
													state <= IDLE;
											end if;
								 end if;
	when others => state <= IDLE;
	end case;
end if;
end process;


debug_currentDT <= currentDT;

inst_VIO_DAC : VIO_DAC
  port map (
    CONTROL => CONTROL,
    ASYNC_OUT => ASYNC_OUT);
chiscope_update_DACs<= ASYNC_OUT(0);


commonDT<=ASYNC_OUT(176 downto 165);

--wr_reg_array(0)<=ASYNC_OUT(12 downto 1);
--wr_reg_array(1)<=ASYNC_OUT(24 downto 13);
--wr_reg_array(2)<=ASYNC_OUT(36 downto 25);
--wr_reg_array(3)<=ASYNC_OUT(48 downto 37);
--wr_reg_array(4)<=ASYNC_OUT(60 downto 49);
--wr_reg_array(5)<=ASYNC_OUT(72 downto 61);
--wr_reg_array(6)<=ASYNC_OUT(84 downto 73);
--wr_reg_array(7)<=ASYNC_OUT(96 downto 85);
--wr_reg_array(8)<=ASYNC_OUT(108 downto 97);
--wr_reg_array(9)<=ASYNC_OUT(120 downto 109);
--wr_reg_array(10)<=ASYNC_OUT(132 downto 121);
--wr_reg_array(11)<=ASYNC_OUT(144 downto 133);
--wr_reg_array(12)<=ASYNC_OUT(156 downto 145);
--do_trigger <= ASYNC_OUT(157);
--choice_phase_debug  <= ASYNC_OUT(162 downto 158);
--subtract_pedestal_debug <= ASYNC_OUT(163);
--update_pedestals_debug  <= ASYNC_OUT(164);
--show_pedestals_debug <= ASYNC_OUT(165);
-- ASYNC_OUT 166 to 256 still free


wr_reg_array(0)<=DACs_from_UART(0);
wr_reg_array(1)<=DACs_from_UART(1);
wr_reg_array(2)<=DACs_from_UART(2);
wr_reg_array(3)<=DACs_from_UART(3);
wr_reg_array(4)<=DACs_from_UART(4);
wr_reg_array(5)<=DACs_from_UART(5);
wr_reg_array(6)<=DACs_from_UART(6);
wr_reg_array(7)<=DACs_from_UART(7);
wr_reg_array(8)<=DACs_from_UART(8);
wr_reg_array(9)<=DACs_from_UART(9);
wr_reg_array(10)<=DACs_from_UART(10);
wr_reg_array(11)<=DACs_from_UART(11);
wr_reg_array(12)<=DACs_from_UART(12);
do_trigger <= trigger_from_UART;
choice_phase_debug  <= choice_phase_from_UART;
subtract_pedestal_debug <= subtract_pedestal_from_UART;
update_pedestals_debug  <= update_pedestal_from_UART;
show_pedestals_debug <= show_pedestal_from_UART;

end Behavioral;

