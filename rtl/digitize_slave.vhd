----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    02:18:36 02/13/2013 
-- Design Name: 
-- Module Name:    digitize_slave - Behavioral 
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

entity digitize_slave is
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
end digitize_slave;

architecture Behavioral of digitize_slave is


type state_t is (IDLE, RD_SET, CLR_FOR_DIG, RAMP_FOR_DIG, DONE);
signal state : state_t := IDLE;
signal counter : std_logic_vector(13 downto 0) := (others => '0');
begin

process(CLK)
begin
if rising_edge(CLK) then
	RD_Ena <= '0';
	CLR <= '0';
	Ramp <= '0';
	digitize_done<='0';
	counter <= (others =>'0');
	case state is
		when IDLE => if do_digitize = '1' then state <= RD_SET; 
									RD_Ena <= '1'; 
									RD_S <= digitize_address;-- start from the first after most recent written
						 end if;
		when RD_SET => RD_Ena <= '1'; 
							if counter < 10 then 
									counter <= counter + 1;
							else
									counter <= (others =>'0');
									CLR<='1';
									state <= CLR_FOR_DIG;
							end if;
		when CLR_FOR_DIG => RD_Ena <= '1'; 
									if counter < 10 then 
										counter <= counter + 1;
										CLR<='1';
									else
										counter <= (others =>'0');
										state <= RAMP_FOR_DIG;
									end if;
		when RAMP_FOR_DIG => RD_Ena <= '1'; 
									if counter < 8192 then --? look at how long it should be
										counter <= counter + 1;
										Ramp<='1';
									else
										counter <= (others =>'0');
										state <= DONE;
									end if;
		when DONE => state <= IDLE; digitize_done<='1';
		when others => state <= IDLE;
	end case;
end if;
end process;

end Behavioral;

