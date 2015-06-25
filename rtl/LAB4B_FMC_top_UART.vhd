----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:29:09 02/05/2013 
-- Design Name: 
-- Module Name:    LAB4B_FMC_top - Behavioral 
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
library UNISIM;
use UNISIM.VComponents.all;

entity LAB4B_FMC_top_UART is
port(
--System clock 200MHz
CLOCK_200MHz_N : in std_logic;
CLOCK_200MHz_P : in std_logic;


--Write array controls
WR_Ena : out std_logic; --LA01_P_CC
WR_S : out std_logic_vector(4 downto 0); -- LA00_P_CC, LA00_N_CC, LA03_P, LA03_N, LA08_P

SEL_Any : out std_logic; --LA01_N_CC
CLR : out std_logic; --LA05_P

--Sampling Timing Controls
SSTinP : out std_logic; -- LA02_P
SSTinN : out std_logic; -- LA02_N
PT : out std_logic; -- LA09_P -- chooses tuned or standard dTs
SSTdly : in std_logic; -- LA12_N
MonTiming : in std_logic; -- LA12_P
-- also: Vbs, VdlyN, VdlyP, xROVDD

-- Digitizing addressing/control
RD_Ena : out std_logic; --LA18_P_CC
RD_S : out std_logic_vector(4 downto 0); -- LA23_N, LA23_P, LA17_N_CC, LA17_P_CC,LA13_N
WCLKp : out std_logic; --Wilkinson clock - maybe 100MHz?
WCLKn : out std_logic;

--Digitizing controls
Ramp : out std_logic; -- LA20_N
--and ISEL, Sbbias, RampMon

-- Serial register (dTs, TIMING parameters, MONTIMING output)
Sin : out std_logic; -- LA20_P
SCLK : out std_logic; -- LA09_N
Update : out std_logic; -- LA13_P --Updates the address and data register based on last shifted in data
PCLK : out std_logic; -- LA05_N --Updates the internal registers with last updated address + data
SHout : in std_logic; -- LA08_N
RegCLR : out std_logic; -- LA16_N --Note: RegCLR serves to clear ALL registers in the timing generator

--Sample readout 
SS_Incr : out std_logic; -- LA26_P
SR_Sel : out std_logic; -- LA26_N --Enables the shift or parallel load
SRCLKp : out std_logic; -- LA19_P
SRCLKn : out std_logic; -- LA19_N
DOE : in std_logic; -- LA16_P
DOE_LVDSp : in std_logic; -- LA04_P
DOE_LVDSn : in std_logic; -- LA04_N

 

-- DAC signals to control the following Biases on chip:
-- Vbias, Vbias2, Vbs, VdlyP, VdlyN, xISEL, Sbbias, CMPbias, xROVDD
LTC2620_SCK : out std_logic_vector(1 downto 0); --LA06_N, LA14_P
LTC2620_SDI : out std_logic_vector(1 downto 0); --LA06_P, LA_10N
LTC2620_NCS : out std_logic_vector(1 downto 0); --LA10_P, LA_14N
LTC2620_SDO : in std_logic_vector(1 downto 0); --LA22_N, LA_22P

-- UART signals
CLOCK_66MHz : in std_logic;
USB_1_TX :  in std_logic; 
USB_1_RX : out std_logic; 


TRIGGER_IN : in std_logic;

MONITOR : out std_logic_vector(6 downto 0) -- LA18_N_CC, LA27_P, LA27_N, CLK1_M2C_P, CLK1_M2C_N, CLK0_M2C_P, CLK0_M2C_N

);
end LAB4B_FMC_top_UART;

architecture Behavioral of LAB4B_FMC_top_UART is


signal CLK : std_logic;

component generate_SST 
 port(
CLK : in std_logic;
SSTdbg : out std_logic;
SSTinP : out std_logic;
SSTinN : out std_logic
);
end component;

signal write_register: std_logic;
signal register_address : std_logic_vector(11 downto 0);
signal register_value : std_logic_vector(11 downto 0);
signal s_reg_busy :  std_logic;
signal s_reg_done :  std_logic;


signal internalSin  : std_logic;
signal internalSCLK  : std_logic;
signal internalUpdate : std_logic;
signal internalPCLK  : std_logic;

component serial_register_master is
port(
CLK : in std_logic;
write_register: in std_logic;
register_address : in std_logic_vector(11 downto 0);
register_value : in std_logic_vector(11 downto 0);
s_reg_busy : out std_logic;
s_reg_done : out std_logic;
Sin : out std_logic;
SCLK : out std_logic;
Update : out std_logic;
PCLK : out std_logic
);
end component;

signal update_all_DACs : std_logic;
signal update_all_DACs_from_UART : std_logic;
signal all_internal_DACs_done : std_logic;
signal all_internal_DTs_done : std_logic;

component update_inner_DACs is
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
end component;

signal debug_currentDT :  std_logic_vector(11 downto 0);

component external_DAC_program 
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
end component;


signal internal_WR_S : std_logic_vector(4 downto 0);
signal internal_WR_Ena : std_logic;

signal start_read_0 :  std_logic_vector(2 downto 0);
signal start_read_1 :  std_logic_vector(2 downto 0);
signal start_read_2 :  std_logic_vector(2 downto 0);
signal start_read_3 :  std_logic_vector(2 downto 0);
signal trigger :  std_logic := '0';
signal read_done :  std_logic;
signal curr_bank :  std_logic_vector(1 downto 0);
signal curr_low :  std_logic_vector(2 downto 0);
signal choice_phase_debug :  std_logic_vector(4 downto 0);

component write_master
port(
CLK : in std_logic;
load_internal_done : in std_logic;
PHAB : in std_logic;
read_start : in std_logic;
read_done : in std_logic;
WR_Ena : out std_logic;
WR_S : out std_logic_vector(4 downto 0);
start_read_0 : out std_logic_vector(2 downto 0);
start_read_1 : out std_logic_vector(2 downto 0);
start_read_2 : out std_logic_vector(2 downto 0);
start_read_3: out std_logic_vector(2 downto 0);
curr_bank : out std_logic_vector(1 downto 0);
curr_low : out  std_logic_vector(2 downto 0);
choice_phase_debug : in std_logic_vector(4 downto 0)
);
end component;

signal intWILK : std_logic := '0';
signal SRCLK : std_logic;
signal internalDOE : std_logic;
signal PData_out : std_logic_vector(11 downto 0);
signal new_data_ready : std_logic;
signal digitize_address :  std_logic_vector(4 downto 0);
 
component read_master port(
CLK : in std_logic;
--start_read
trigger : in std_logic;
-- interface with write_master
read_done : out std_logic;
--start_read_0 : in std_logic_vector(2 downto 0);
--start_read_1 : in std_logic_vector(2 downto 0);
--start_read_2 : in std_logic_vector(2 downto 0);
--start_read_3 : in std_logic_vector(2 downto 0);
curr_low : in std_logic_vector(2 downto 0);
curr_bank : in std_logic_vector(1 downto 0);
-- digitize - select window
RD_Ena : out std_logic;
RD_S : out std_logic_vector(4 downto 0);
-- digitize - ramp control
Ramp : out std_logic;
CLR : out std_logic;
-- readout - select sample
SEL_Any : out std_logic;
SS_Incr : out std_logic;
-- readout - shift out sample
SRCLK : out std_logic;
SR_Sel : out std_logic;
DOE_in : in std_logic;
new_data_ready : out std_logic;
PData_out  : out std_logic_vector(11 downto 0);
digitize_address : out std_logic_vector(4 downto 0)
);
end component;


signal CONTROL0 :  STD_LOGIC_VECTOR(35 DOWNTO 0);
signal CONTROL1 :  STD_LOGIC_VECTOR(35 DOWNTO 0);
signal CONTROL2 :  STD_LOGIC_VECTOR(35 DOWNTO 0);

component MY_ICON
  PORT (
    CONTROL0 : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0);
    CONTROL1 : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0);
    CONTROL2 : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0));

end component;

signal TRIG0 :  STD_LOGIC_VECTOR(255 DOWNTO 0);

component TOP_ILA
  PORT (
    CONTROL : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0);
    CLK : IN STD_LOGIC;
    TRIG0 : IN STD_LOGIC_VECTOR(255 DOWNTO 0));

end component;

signal subtract_pedestal : std_logic;
signal update_pedestals : std_logic;
signal show_pedestals :  std_logic;

signal started_triggers : std_logic := '0';

component readout_builder_v2 is
port(
CLK : in std_logic;
--start_readout : in std_logic; --shouldn't be necessary, if everything works in lockstep
new_data_ready : in std_logic;
digitize_address : in std_logic_vector(4 downto 0);
PData_in :  in std_logic_vector(11 downto 0);
subtract_pedestal : in std_logic;
update_pedestals : in std_logic;
show_pedestals : in std_logic;
event_data : out  std_logic_vector(11 downto 0);
event_address : out  std_logic_vector(4 downto 0);
write_event_out : out  std_logic;
write_event_out_finished : out  std_logic
);
end component;

component clock_for4Gsa
port
 (-- Clock in ports
  CLK_IN1_P         : in     std_logic;
  CLK_IN1_N         : in     std_logic;
  -- Clock out ports
  CLK_OUT1          : out    std_logic
 );
end component;

signal do_trigger : std_logic;
signal do_trigger_delayed : std_logic;
signal ext_trigger_reg : std_logic;
signal ext_trigger_reg2 : std_logic;
signal internal_RD_Ena : std_logic;
signal internal_RD_S :  std_logic_vector(4 downto 0); 
signal internal_Ramp : std_logic;
signal internal_CLR : std_logic;
signal internal_SEL_Any : std_logic;
signal internal_SS_Incr : std_logic;
signal internal_SR_Sel : std_logic;

signal write_event_out : std_logic := '0';
signal write_event_out_finished : std_logic := '0';

signal pos_array :  std_logic_vector(9 downto 0) := (others => '0'); 
type arr is array (0 to 1023) of std_logic_vector(11 downto 0);
signal data_arr : arr;
signal event_data :  std_logic_vector(11 downto 0) := (others => '0'); 

type addr_arr is array (0 to 1023) of std_logic_vector(4 downto 0);
signal data_addr_arr : addr_arr;
signal event_address :  std_logic_vector(4 downto 0) := (others => '0'); 

type reg_arr_type is array (0 to 1023) of std_logic_vector(7 downto 0);
signal reg_arr : reg_arr_type;
signal reg_address :  std_logic_vector(6 downto 0) := (others => '0'); 
signal register_bank :  std_logic_vector(2 downto 0) := (others => '0'); 


signal user_data_from_interface :  std_logic_vector(7 downto 0); 
signal user_data_to_interface :  std_logic_vector(7 downto 0); 
signal user_data_rd : std_logic;
signal user_data_wr : std_logic;


component qnd_uart_interface 
	port(
    CLK : in std_logic;
    TX : out std_logic;
    RX: in std_logic;
	 user_address_o  : out std_logic_vector(6 downto 0);
	 user_data_i : in std_logic_vector(7 downto 0);
	 user_data_o : out std_logic_vector(7 downto 0);
	 user_rd_o : out std_logic;
	 user_wr_o : out std_logic;
	 debug_o : out  std_logic_vector(17 downto 0)
    );
end component;

signal SSTdbg : std_logic;
signal ext_DACs_from_UART : ext_DACs_from_UART_type;
signal DACs_from_UART : DACs_from_UART_type;
signal DT : DT_type;
signal update_DTs_from_UART : std_logic;

signal update_DACs_from_UART : std_logic;
signal trigger_from_UART : std_logic;
signal choice_phase_from_UART : std_logic_vector(4 downto 0);
signal subtract_pedestal_from_UART : std_logic;
signal update_pedestal_from_UART : std_logic;
signal show_pedestal_from_UART : std_logic;

begin

--PT <= '0'; -- nominal delays.
PT <= reg_arr(32)(0); -- controlled by bit 0 of register 32

--1. "Native" clock of 200MHz
map_IBUFG_CLOCK200MHz : IBUFGDS port map(I => CLOCK_200MHz_P, IB => CLOCK_200MHz_N, O => CLK);

--2. "Faster" clock of 312.5MHz - for 4Gsa/s
--clock_for4Gsa_inst : clock_for4Gsa
--  port map
--   (-- Clock in ports
--    CLK_IN1_P => CLOCK_200MHz_P,
--    CLK_IN1_N => CLOCK_200MHz_N,
--    -- Clock out ports
--    CLK_OUT1 => CLK);
	 
inst_generate_SST: generate_SST port map(
CLK => CLK,
SSTdbg => SSTdbg,
SSTinP => SSTinP,
SSTinN => SSTinN
);
--SSTinP <= '0';
--SSTinN <= '1';



inst_serial_register_master:  serial_register_master port map(
CLK => CLK,
write_register => write_register,
register_address => register_address,
register_value => register_value,
s_reg_busy => s_reg_busy,
s_reg_done => s_reg_done,
Sin => internalSin,
SCLK => internalSCLK,
Update => internalUpdate,
PCLK => internalPCLK
);

Sin <= internalSin;
SCLK <= internalSCLK;
Update <= internalUpdate;
PCLK <= internalPCLK;


inst_update_inner_DACs: update_inner_DACs 
port map(
CLK => CLK,
update_all_DACs => update_all_DACs,
write_register => write_register,
register_address => register_address,
register_value => register_value,
s_reg_busy => s_reg_busy,
s_reg_done => s_reg_done,
all_internal_DACs_done => all_internal_DACs_done,
do_trigger => do_trigger,
choice_phase_debug => choice_phase_debug,
subtract_pedestal_debug => subtract_pedestal,
update_pedestals_debug => update_pedestals,
show_pedestals_debug => show_pedestals,

update_DTs_from_UART => update_DTs_from_UART,
DT => DT,
all_internal_DTs_done => all_internal_DTs_done, -- now not used


DACs_from_UART => DACs_from_UART,

update_DACs_from_UART => update_DACs_from_UART,
trigger_from_UART => trigger_from_UART,
choice_phase_from_UART => choice_phase_from_UART,
subtract_pedestal_from_UART => subtract_pedestal_from_UART,
update_pedestal_from_UART => update_pedestal_from_UART,
show_pedestal_from_UART => show_pedestal_from_UART,


CONTROL => CONTROL1,

debug_currentDT => debug_currentDT
);


inst_external_DAC_program: external_DAC_program 
port map(
-- DAC signals to control the following Biases on chip:
-- Vbias, Vbias2, Vbs, VdlyP, VdlyN, xISEL, Sbbias, CMPbias, xROVDD
CLK => CLK,
update_all_DACs => update_all_DACs,
LTC2620_SCK =>LTC2620_SCK,
LTC2620_SDI =>LTC2620_SDI,
LTC2620_NCS =>LTC2620_NCS,
LTC2620_SDO =>LTC2620_SDO,

ext_DACs_from_UART => ext_DACs_from_UART,

CONTROL =>CONTROL2
);

WR_Ena <= internal_WR_Ena;
--WR_S <= internal_WR_S;


WR_S(4) <= internal_WR_S(0); -- The MSb is the one that needs to change every clock cycle!
WR_S(3 downto 0) <= internal_WR_S(4 downto 1);

inst_write_master: write_master port map(
CLK => CLK,
load_internal_done => all_internal_DACs_done,
PHAB  => MonTiming,
read_start => trigger,
read_done => read_done,
WR_Ena => internal_WR_Ena,
WR_S => internal_WR_S,
start_read_0 => start_read_0,
start_read_1 => start_read_1,
start_read_2 => start_read_2,
start_read_3 => start_read_3,
curr_low => curr_low,
curr_bank => curr_bank,
choice_phase_debug => choice_phase_debug
);


RD_Ena <= internal_RD_Ena;
--RD_S <= internal_RD_S;


RD_S(4) <= internal_RD_S(0); -- Same bit scrambling as in the write!!! - internal keeps the "natural" order
RD_S(3 downto 0) <= internal_RD_S(4 downto 1);


Ramp <= internal_Ramp;
CLR <= internal_CLR;
SEL_Any <= internal_SEL_Any;
SS_Incr <= internal_SS_Incr;
SR_Sel <= internal_SR_Sel;

inst_read_master: read_master port map(
CLK => CLK,
--start_read
trigger => trigger,
-- interface with write_master
read_done =>  read_done,
--start_read_0 => start_read_0,
--start_read_1 => start_read_1,
--start_read_2 => start_read_2,
--start_read_3 => start_read_3,
curr_low => curr_low,
curr_bank => curr_bank,
-- digitize - select window
RD_Ena => internal_RD_Ena,
RD_S => internal_RD_S,
-- digitize - ramp control
Ramp => internal_Ramp,
CLR => internal_CLR,
-- readout - select sample
SEL_Any => internal_SEL_Any,
SS_Incr => internal_SS_Incr,
-- readout - shift out sample
SRCLK =>SRCLK,
SR_Sel => internal_SR_Sel,
-- serial in parallel out
DOE_in => internalDOE,
new_data_ready => new_data_ready,
PData_out => PData_out,
digitize_address => digitize_address
);

--readout_builder

readout_builder_inst : readout_builder_v2
port map(
CLK => CLK,
--start_readout : in std_logic; --shouldn't be necessary, if everything works in lockstep
new_data_ready => new_data_ready,
digitize_address => digitize_address,
PData_in => PData_out,
subtract_pedestal => subtract_pedestal, -- from VIO
update_pedestals => update_pedestals, -- from VIO
show_pedestals => show_pedestals, -- from VIO
event_data => event_data,
event_address => event_address,
write_event_out => write_event_out,
write_event_out_finished => write_event_out_finished
);

--
--
--process(CLK)
--begin
--	if rising_edge(CLK) then
--		if write_event_out = '0' then
--			if new_data_ready= '1' then
--				if pos_array<1023 then
--					data_arr(conv_integer(pos_array))<= PData_out;
--					data_addr_arr(conv_integer(pos_array))<= digitize_address;
--					pos_array <= pos_array +1;
--				else
--					pos_array <= (others =>'0');
--					write_event_out <='1';
--				end if;
--			end if;
--		else
--			if pos_array<1023 then
--				event_data<=data_arr(conv_integer(pos_array));
--				event_address<=data_addr_arr(conv_integer(pos_array));
--				pos_array <= pos_array +1;
--			else
--				pos_array <= (others =>'0');
--				write_event_out <='0';
--			end if;
--		end if;
--	end if;
--end process;

-- Wilinson clock generation:
process(CLK)
begin
if rising_edge(CLK) then
	intWILK<= not intWILK; -- Wilkinson clock - 100MHz
end if;
end process;

wilk_buf: OBUFDS 
generic map (
IOSTANDARD => "LVDS_25")
  port map(
    I => intWILK, 
	 O  => WCLKp,
    OB => WCLKn
  );

shiftout_buf: OBUFDS 
generic map (
IOSTANDARD => "LVDS_25")
  port map(
    I => SRCLK, 
	 O  => SRCLKp,
    OB => SRCLKn
  );
  
DOE_buf: IBUFDS
generic map (
IOSTANDARD => "LVDS_25")
	port map(
	I => DOE_LVDSp,
	IB => DOE_LVDSn,
	O => internalDOE
	);
	
--Unconnected outputs: set temporarily to default ton allow bitfile generation:
MONITOR(2) <= do_trigger;
MONITOR(1) <= internal_WR_S(0);
MONITOR(6 downto 3) <= (others => '0');
MONITOR(0) <= SSTdbg;

RegCLR <= '0';


process(CLK)
begin
if rising_edge(CLK) then
	ext_trigger_reg <= TRIGGER_IN;
	ext_trigger_reg2 <= ext_trigger_reg;
	do_trigger_delayed <= do_trigger;
	if started_triggers = '0' then
		if (do_trigger= '1' and do_trigger_delayed = '0') or (ext_trigger_reg = '1' and ext_trigger_reg2 = '0') then
			trigger<='1';
--			started_triggers <= '1';
		else
			trigger<='0';
		end if;
--	else
--		if write_event_out_finished = '1' then
--			trigger<= '1';
--		else
--			trigger <='0';
--		end if;
	end if;
end if;
end process;

-- for debugging only: generate trigger
--
--process(CLK)
--variable count_trigger : std_logic_vector(11 downto 0) := (others => '0');
--variable triggered : std_logic := '0';
--begin
--if rising_edge(CLK) then
--	if count_trigger < 4095 then
--		count_trigger := count_trigger+1;
--	elsif triggered = '0' then
--		trigger<='1';
--		triggered := '1';
--	else
--		trigger <= '0';
--	end if;
--end if;
--end process;


-- for debugging only: generate programming

process(CLK)
variable DAC_done : std_logic := '0';
begin
if rising_edge(CLK) then
	if DAC_done = '0' then
		update_all_DACs<='1';
		DAC_done := '1';
	else
--		update_all_DACs <= '0';
		update_all_DACs <= update_all_DACs_from_UART;
	end if;
end if;
end process;




-- Debugging through Chipscope
inst_MY_ICON : MY_ICON
  port map (
    CONTROL0 => CONTROL0,
    CONTROL1 => CONTROL1,
    CONTROL2 => CONTROL2);


inst_TOP_ILA : TOP_ILA
  port map (
    CONTROL => CONTROL0,
    CLK => CLK,
    TRIG0 => TRIG0);
TRIG0(0) <=write_register;
TRIG0(12 downto 1) <=register_address;
TRIG0(24 downto 13) <=register_value;
TRIG0(25) <=s_reg_busy;
TRIG0(26) <=s_reg_done;
TRIG0(27) <=internalSin;
TRIG0(28) <=internalSCLK;
TRIG0(29) <=internalUpdate;
TRIG0(30) <=internalPCLK;
TRIG0(31) <=SHout;
TRIG0(32) <=SSTdly;
TRIG0(33) <=MonTiming;

--NEW 
TRIG0(34) <=do_trigger;
--READ_MASTER
TRIG0(35) <=read_done;
TRIG0(38 downto 36) <=curr_low;
TRIG0(40 downto 39) <=curr_bank;
TRIG0(41) <=internal_RD_Ena;
TRIG0(46 downto 42) <=internal_RD_S;
TRIG0(47) <=internal_Ramp;
TRIG0(48) <=internal_CLR ;
TRIG0(49) <=internal_SEL_Any ;
TRIG0(50) <=internal_SS_Incr;
TRIG0(51) <=internal_SR_Sel;
TRIG0(52) <=internalDOE;
TRIG0(53) <=new_data_ready;
TRIG0(65 downto 54) <=PData_out;
--WRITE_MASTER
TRIG0(66) <=all_internal_DACs_done;
TRIG0(67) <=internal_WR_Ena;
TRIG0(72 downto 68) <=internal_WR_S;
TRIG0(73) <=SRCLK;
TRIG0(74) <=DOE;
TRIG0(75) <=write_event_out;
TRIG0(87 downto 76) <=event_data;
TRIG0(92 downto 88) <=event_address;
TRIG0(93) <= SSTdbg;



-- UART implementation and register mapping
qnd : qnd_uart_interface 
--	generic map (CLOCK => 200000000)
	port map(
	CLK => CLOCK_66MHz,
	TX => USB_1_RX,
	RX => USB_1_TX,
	user_address_o => reg_address,
	user_data_o => user_data_from_interface,
	user_data_i => user_data_to_interface,
	user_rd_o => user_data_rd,
	user_wr_o => user_data_wr,
	debug_o => open
	);

						
-- USER INTERFACE SECTION
	process(CLOCK_66MHz)
	begin
		if rising_edge(CLOCK_66MHz) then
			if user_data_wr ='1' then
				if reg_address = "1111111" then -- set register bank
					register_bank <= user_data_from_interface(2 downto 0); -- 8 banks of 127 values (address 127 only used to set bank
				else
					reg_arr(conv_integer(register_bank & reg_address)) <= user_data_from_interface;
				end if;
--			elsif user_data_rd = '1' then
--				user_data_to_interface <= reg_arr(conv_integer(register_bank & reg_address));			
			end if;
				user_data_to_interface <= reg_arr(conv_integer(register_bank & reg_address));			
		end if;
	end process;

	process(reg_arr) -- mapping from memory to internal values
	 
	begin
		update_DACs_from_UART <=  reg_arr(0)(0); --0th bit is update DAC
		trigger_from_UART <= reg_arr(1)(0); -- 0th bit is start triggers
		choice_phase_from_UART <=reg_arr(2)(4 downto 0);
		subtract_pedestal_from_UART <= reg_arr(3)(0); 
		update_pedestal_from_UART <= reg_arr(4)(0); 
		show_pedestal_from_UART<= reg_arr(5)(0); 
		DACs_from_UART(0)<= reg_arr(7)(3 downto 0) & reg_arr(6); --  the dacs are "little endian" : Least significant parts with lower addresses ("first")
		DACs_from_UART(1)<= reg_arr(9)(3 downto 0) & reg_arr(8); 
		DACs_from_UART(2)<= reg_arr(11)(3 downto 0) & reg_arr(10); 
		DACs_from_UART(3)<= reg_arr(13)(3 downto 0) & reg_arr(12); 
		DACs_from_UART(4)<= reg_arr(15)(3 downto 0) & reg_arr(14); 
		DACs_from_UART(5)<= reg_arr(17)(3 downto 0) & reg_arr(16); 
		DACs_from_UART(6)<= reg_arr(19)(3 downto 0) & reg_arr(18); 
		DACs_from_UART(7)<= reg_arr(21)(3 downto 0) & reg_arr(20); 
		DACs_from_UART(8)<= reg_arr(23)(3 downto 0) & reg_arr(22); 
		DACs_from_UART(9)<= reg_arr(25)(3 downto 0) & reg_arr(24); 
		DACs_from_UART(10)<= reg_arr(27)(3 downto 0) & reg_arr(26); 
		DACs_from_UART(11)<= reg_arr(29)(3 downto 0) & reg_arr(28); 
		DACs_from_UART(12)<= reg_arr(31)(3 downto 0) & reg_arr(30); 
		
		update_all_DACs_from_UART <=		reg_arr(128)(0);
		for i in 0 to 15  loop
		ext_DACs_from_UART(i) <= reg_arr(130+2*i)(3 downto 0) & reg_arr(129+2*i);
		end loop;
		for i in 0 to 62  loop
		DT(i)	<= reg_arr(257+2*i)(3 downto 0) & reg_arr(256+2*i); --first 63 DTs
		end loop;
		for i in 0 to 62  loop
		DT(i+63)	<= reg_arr(257+128+2*i)(3 downto 0) & reg_arr(256+128+2*i); --second 63 DTs
		end loop;
		DT(126) <= reg_arr(513)(3 downto 0) & reg_arr(512); --last 2 DTs
		DT(127) <= reg_arr(515)(3 downto 0) & reg_arr(514); --last 2 DTs
		
		update_DTs_from_UART<=  reg_arr(516)(0); --0th bit is update DT
	end process;
	
	


end Behavioral;

