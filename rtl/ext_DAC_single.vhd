----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:19:59 02/11/2013 
-- Design Name: 
-- Module Name:    ext_DAC_single - Behavioral 
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

entity ext_DAC_single is
port(
CLK : in std_logic;
write_register: in std_logic;
register_address : in std_logic_vector(3 downto 0); --Note: command implictly update and turn on 1 DAC
register_value : in std_logic_vector(11 downto 0);
s_reg_busy : out std_logic;
s_reg_done : out std_logic;
LTC2620_SCK : out std_logic; 
LTC2620_SDI : out std_logic; 
LTC2620_NCS : out std_logic; 
LTC2620_SDO : in std_logic
);
end ext_DAC_single;

architecture Behavioral of ext_DAC_single is


constant command : std_logic_vector(3 downto 0) := "0011"; -- Command corresponds to write 1 DAC and update it

type state_t is (IDLE,  WRITE_WORD,  UPDATE_D_A_REG,  DONE);
signal state : state_t := IDLE; 


signal intShReg : std_logic_vector(23 downto 0);
signal counter : std_logic_vector(7 downto 0) := (others => '0');
signal present_count : std_logic_vector(7 downto 0);
signal counter_period : std_logic_vector(3 downto 0);

signal intSCLK : std_logic;
begin


process(CLK)
begin
if rising_edge(CLK) then
case state is 
	when IDLE =>if write_register = '1' then state<=WRITE_WORD; end if;
		s_reg_busy <= '0';
		s_reg_done <= '0';
		LTC2620_NCS <= '0';		
	when WRITE_WORD => if counter = present_count then state<=UPDATE_D_A_REG; end if;
		s_reg_busy <= '1';
		s_reg_done <= '0';
		LTC2620_NCS <= '0';		
	when UPDATE_D_A_REG => if counter = present_count then state<=DONE; end if;
		s_reg_busy <= '1';
		s_reg_done <= '0';
		LTC2620_NCS <= '1';		
	when DONE  => state<=IDLE;
		s_reg_busy <= '1';
		s_reg_done <= '1';
		LTC2620_NCS <= '0';		
	when others => state<=IDLE;
		s_reg_busy <= '0';
		s_reg_done <= '0';
		LTC2620_NCS <= '0';		
end case;
end if;
end process;

process(state)
begin
case state is
	when IDLE =>	present_count<= (others => '0');
	when WRITE_WORD => present_count<= conv_std_logic_vector(240,8); -- 240 = 24*10 = 10 clock cycles for each shift in - should be sufficient
	when UPDATE_D_A_REG => present_count<= conv_std_logic_vector(10,8); 
	when DONE  => present_count<=(others => '0'); 
	when others => present_count<=(others => '0'); 
end case;
end process;

process(CLK)
begin
if rising_edge(CLK) then
if counter = present_count then
	counter_period <= (others => '0');
	counter <= (others => '0');
else
	counter <= counter +1;
	if counter_period < 9 then
		counter_period <= counter_period +1;
	else
		counter_period <= (others => '0');
	end if;
end if;
end if;
end process;


process(CLK)
begin
if rising_edge(CLK) then
case state is
	when IDLE =>	
		intSCLK <= '0';
	when WRITE_WORD => 
		if counter_period = 4  or counter_period =9  then intSCLK <= not intSCLK;
		end if;
	when UPDATE_D_A_REG =>  intSCLK <= '0';
	when DONE  => intSCLK <= '0';
	when others => intSCLK <= '0';
end case;
end if;
end process;
LTC2620_SCK <= intSCLK; 


process(CLK)
begin
if rising_edge(CLK) then
	if write_register = '1' and state = IDLE then -- to avoid overwriting if a different write occurs
		intShReg <= command & register_address & register_value & "0000"; -- Check if the registers are in fact "Big endian" with bits
	elsif counter_period =9 then -- at the end of a period shift the internal register by one
		intShReg <= intShReg(22 downto 0) & '0';
	end if;
end if;
LTC2620_SDI <= intShReg(23); 

end process;


end Behavioral;

