----------------------------------------------------------------------------------
-- Company: IDLAB - Dept. of Physics - University of Hawaii at Manoa
-- Engineer: Luca MACCHIARULO
-- 
-- Create Date:    23:47:41 02/08/2013 
-- Design Name: 
-- Module Name:    serial_register_master - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: Module that forces a write in an internal register
--						thrugh its address and value - caller must
--						wait for an acknowledge - easy modification
--						for multiple callers possible - as long as each
--						uses the "busy signal" to understand when another
--						module has been granted access. TBI.
--						Also, values of delays are now magic numbers (10 cycles
--						per shift in).
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

entity serial_register_master is
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
end serial_register_master;

architecture Behavioral of serial_register_master is
type state_t is (IDLE,  WRITE_VALUE, WRITE_ADDRESS, UPDATE_D_A_REG, DO_PCLK, DONE);
signal state : state_t := IDLE; 


signal intShReg : std_logic_vector(23 downto 0);
signal counter : std_logic_vector(7 downto 0) := (others => '0');
signal present_count : std_logic_vector(7 downto 0);
signal counter_period : std_logic_vector(3 downto 0);

signal intSCLK : std_logic;
signal toggleSCLK : std_logic := '0';
begin


process(CLK)
begin
if rising_edge(CLK) then
case state is 
	when IDLE =>if write_register = '1' then state<=WRITE_VALUE; end if;
		s_reg_busy <= '0';
		s_reg_done <= '0';
		Update <= '0';		
		PCLK <= '0';		
	when WRITE_VALUE => if counter = present_count then state<=WRITE_ADDRESS; end if;
		s_reg_busy <= '1';
		s_reg_done <= '0';
		Update <= '0';		
		PCLK <= '0';
	when WRITE_ADDRESS =>if counter = present_count then state<=UPDATE_D_A_REG; end if;
		s_reg_busy <= '1';
		s_reg_done <= '0';
		Update <= '0';		
		PCLK <= '0';
	when UPDATE_D_A_REG => if counter = present_count then state<=DO_PCLK; end if;
		s_reg_busy <= '1';
		s_reg_done <= '0';
		Update <= '1';		
		PCLK <= '0';
	when DO_PCLK =>if counter = present_count then state<=DONE; end if;
		s_reg_busy <= '1';
		s_reg_done <= '0';
		Update <= '0';		
		PCLK <= '1';
	when DONE  => state<=IDLE;
		s_reg_busy <= '1';
		s_reg_done <= '1';
		Update <= '0';		
		PCLK <= '0';
	when others => state<=IDLE;
		s_reg_busy <= '0';
		s_reg_done <= '0';
		Update <= '0';		
		PCLK <= '0';
end case;
end if;
end process;

process(state)
begin
case state is
	when IDLE =>	present_count<= (others => '0');
	when WRITE_VALUE => present_count<= conv_std_logic_vector(120,8); -- 120 = 12*10 = 10 clock cycles for each shift in - should be sufficient
	when WRITE_ADDRESS => present_count<= conv_std_logic_vector(120,8); 
	when UPDATE_D_A_REG => present_count<= conv_std_logic_vector(10,8); 
	when DO_PCLK => present_count<= conv_std_logic_vector(10,8); 
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
	if counter_period = 3 or counter_period = 8 then
		toggleSCLK <= '1';
	else
		toggleSCLK <= '0';
	end if;
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
	when WRITE_VALUE => 
--		if counter_period = 4  or counter_period =9  then intSCLK <= not intSCLK;
		if toggleSCLK = '1' then intSCLK <= not intSCLK;
		end if;
	when WRITE_ADDRESS => 
--		if counter_period = 4  or counter_period =9  then intSCLK <= not intSCLK;
		if toggleSCLK = '1' then intSCLK <= not intSCLK;
		end if;
	when UPDATE_D_A_REG =>  intSCLK <= '0';
	when DO_PCLK => intSCLK <= '0';
	when DONE  => intSCLK <= '0';
	when others => intSCLK <= '0';
end case;
end if;
end process;
SCLK <= intSCLK; 


process(CLK)
begin
if rising_edge(CLK) then
	if write_register = '1' and state = IDLE then -- to avoid overwriting if a different write occurs
		intShReg <= register_address & register_value; -- Check if the registers are in fact "Big endian" with bits
	elsif counter_period =9 then -- at the end of a period shift the internal register by one
		intShReg <= intShReg(22 downto 0) & '0';
	end if;
end if;
Sin <= intShReg(23); 

end process;

end Behavioral;

