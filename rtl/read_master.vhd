----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    01:25:46 02/13/2013 
-- Design Name: 
-- Module Name:    read_master - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity read_master is
port(
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
end read_master;

architecture Behavioral of read_master is

signal do_digitize :  std_logic;
signal internal_digitize_address :  std_logic_vector(4 downto 0);
signal digitize_done :  std_logic;
signal low :  std_logic_vector(2 downto 0);
signal start_low :  std_logic_vector(2 downto 0);
signal bank :  std_logic_vector(1 downto 0);

component digitize_slave 
port(
CLK : in std_logic;
-- interface with master
do_digitize : in std_logic;
digitize_address : in std_logic_vector(4 downto 0);
digitize_done : out std_logic;
-- digitize - select window
RD_Ena : out std_logic;
RD_S : out std_logic_vector(4 downto 0);
-- digitize - ramp control
Ramp : out std_logic;
CLR : out std_logic
);
end component;

signal do_rdout :  std_logic;
signal rdout_done :  std_logic;

component rdout_slave 
port(
CLK : in std_logic;
-- interface with master
do_rdout : in std_logic;
rdout_done : out std_logic;
-- readout - select sample
SEL_Any : out std_logic;
SS_Incr : out std_logic;
-- readout - shift out sample
SRCLK : out std_logic;
SR_Sel : out std_logic;
DOE_in : in std_logic;
new_data_ready : out std_logic;
PData_out  : out std_logic_vector(11 downto 0)
);
end component;

type state_t is (IDLE, SET_WINDOW, DIGITIZE, WAIT_FOR_DIGITIZE, RDOUT, WAIT_FOR_RDOUT, DONE);
signal state : state_t := IDLE;


begin

digitize_address <= internal_digitize_address;

inst_digitize_slave  : digitize_slave 
port map(
CLK => CLK,
-- interface with master
do_digitize => do_digitize,
digitize_address => internal_digitize_address,
digitize_done => digitize_done,
-- digitize - select window
RD_Ena => RD_Ena,
RD_S => RD_S,
-- digitize - ramp control
Ramp => Ramp,
CLR => CLR 
);

inst_rdout_slave : rdout_slave
port map(
CLK => CLK,
-- interface with master
do_rdout => do_rdout,
rdout_done => rdout_done,
-- readout - select sample
SEL_Any => SEL_Any,
SS_Incr => SS_Incr,
-- readout - shift out sample
SRCLK => SRCLK,
SR_Sel => SR_Sel,
-- serial in parallel out
DOE_in => DOE_in,
new_data_ready => new_data_ready,
PData_out => PData_out
);

internal_digitize_address<= bank & low;
process(CLK)
begin
if rising_edge(CLK) then
	do_digitize <= '0';
	do_rdout <= '0';
	read_done <= '0';
	case state is
		when IDLE => if trigger = '1' then state <= SET_WINDOW; 
									bank <= curr_bank; 
									low <= curr_low;-- start from the first after most recent written
									start_low <= curr_low;
						 end if;
		when SET_WINDOW => low <= low +1;
									state <= DIGITIZE;
		when DIGITIZE => do_digitize<='1';
								state <= WAIT_FOR_DIGITIZE;
		when WAIT_FOR_DIGITIZE => if digitize_done = '1' then state <= RDOUT; end if;
		when RDOUT => do_rdout<='1'; 
							state <= WAIT_FOR_RDOUT;
		when WAIT_FOR_RDOUT => if rdout_done = '1' then 
										if low = start_low then state <= DONE;
										else state <= SET_WINDOW;
										end if;
									  end if;
		when DONE => state <= IDLE; read_done<='1';
		when others => state <= IDLE;
	end case;
end if;
end process;


end Behavioral;

