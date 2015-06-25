----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    02:40:43 02/13/2013 
-- Design Name: 
-- Module Name:    rdout_slave - Behavioral 
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

entity rdout_slave is
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
end rdout_slave;

architecture Behavioral of rdout_slave is


type state_t is (IDLE, SET_SEL_ANY, LOAD_SAMPLE_U, LOAD_SAMPLE_D, SHIFT_OUT_U, SHIFT_OUT_D, SS_INCR_U, DONE);
signal state : state_t := IDLE;
signal counter : std_logic_vector(11 downto 0) := (others => '0');
signal count_samples : std_logic_vector(8 downto 0) := (others => '0');
signal counter_pulse : std_logic_vector(3 downto 0) := (others => '0');


signal ser_to_par : std_logic_vector(11 downto 0) := (others => '0');

begin

process(CLK)
begin
if rising_edge(CLK) then
	SEL_Any <= '0';
	SR_Sel <= '1'; -- Should be par load
	SS_Incr <= '0'; --careful! do not default it ! This guarantees one increment per each 128 samples
	rdout_done <= '0';
	SRCLK <='0';
	new_data_ready <= '0';
--	counter <= (others =>'0');
	case state is
		when IDLE => SS_Incr <= '0'; 
						if do_rdout = '1' then state <= SET_SEL_ANY;  end if;
		when SET_SEL_ANY => SEL_Any <='1';  
									if counter < 10 then --waits for SEL_ANY settling
										counter <= counter + 1;
									else		
										counter <= (others => '0');
										state <= LOAD_SAMPLE_U; 
									end if;
		when LOAD_SAMPLE_U => SEL_Any <= '1'; 
									SRCLK <='1';  
									if counter_pulse < 1 then --slow down to 50 MHz
										counter_pulse <= counter_pulse + 1;
									else		
										counter_pulse <= (others => '0');
										state <= LOAD_SAMPLE_D; 
									end if;
		when LOAD_SAMPLE_D => SEL_Any <= '1'; 
--									if counter < 10 then --for change in SR_Sel
									if counter < 1 then --to debug "ramp effect"
										counter <= counter + 1;
										SR_Sel <= '1'; --has 10 clocks to stabilize
										SRCLK <='0';
									elsif counter < 20 then
										counter <= counter + 1;
										SR_Sel <= '0'; 
									else
										SR_Sel <= '0'; 
										counter <= (others =>'0');
										state <= SHIFT_OUT_U;
									end if;
		when SHIFT_OUT_U => 	SEL_Any <= '1';
									SR_Sel <= '0'; 
									SRCLK <='1';
-- Uncomment below if you want a 50MHz readout - as opposed to 100MHz.
										if counter_pulse < 1 then --slow down to 50 MHz
											ser_to_par<= ser_to_par(10 downto 0) & DOE_in; -- presupposes MSb out first -- note: sampling on rising edge of first shift - 12 shifts
											counter_pulse <= counter_pulse + 1;
										else
											counter_pulse <= (others => '0');
											state <= SHIFT_OUT_D;
										end if;
		when SHIFT_OUT_D => 	SEL_Any <= '1';
									SR_Sel <= '0'; 
									SRCLK <='0';
-- Uncomment below if you want a 50MHz readout - as opposed to 100MHz.
									if counter_pulse < 1 then --slow down to 50 MHz
											counter_pulse <= counter_pulse + 1;
									else
										counter_pulse <= (others => '0');
										if counter < 11 then 
--										if counter < 15 then  -- see what's inside the shift register!
											counter <= counter + 1;
											state <= SHIFT_OUT_U;
										else
											counter <= (others =>'0');
											state <= SS_INCR_U;
										end if;
										end if;
		when SS_INCR_U => 	SEL_Any <= '1';
									SR_Sel <= '1'; 
									SR_Sel <= '1'; --has 10 clocks to stabilize - the actual shift occurs in LOAD_SAMPLE_U
									if counter < 10 then --for change in SS_Incr and SR_Sel
										counter <= counter + 1;
										SS_Incr <= '1';
									else
										counter <= (others =>'0');
										PData_out <= ser_to_par;
										new_data_ready <= '1';
										if count_samples < 127 then 
													count_samples <= count_samples + 1;
													state <= LOAD_SAMPLE_U;  
										else 
											count_samples <= (others =>'0');
											state <= DONE;  
										end if;
									end if;					
		when DONE => state <= IDLE; rdout_done<='1';
		when others => state <= IDLE;
	end case;
end if;
end process;

end Behavioral;

