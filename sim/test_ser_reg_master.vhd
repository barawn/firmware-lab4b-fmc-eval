--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   00:47:29 02/09/2013
-- Design Name:   
-- Module Name:   C:/Users/luca/Desktop/LAB4B_Eval/test_ser_reg_master.vhd
-- Project Name:  LAB4B_FMC_Eval
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: serial_register_master
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY test_ser_reg_master IS
END test_ser_reg_master;
 
ARCHITECTURE behavior OF test_ser_reg_master IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT serial_register_master
    PORT(
         CLK : IN  std_logic;
         write_register : IN  std_logic;
         register_address : IN  std_logic_vector(11 downto 0);
         register_value : IN  std_logic_vector(11 downto 0);
         s_reg_busy : OUT  std_logic;
         s_reg_done : OUT  std_logic;
         Sin : OUT  std_logic;
         SCLK : OUT  std_logic;
         Update : OUT  std_logic;
         PCLK : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal CLK : std_logic := '0';
   signal write_register : std_logic := '0';
   signal register_address : std_logic_vector(11 downto 0) := (others => '0');
   signal register_value : std_logic_vector(11 downto 0) := (others => '0');

 	--Outputs
   signal s_reg_busy : std_logic;
   signal s_reg_done : std_logic;
   signal Sin : std_logic;
   signal SCLK : std_logic;
   signal Update : std_logic;
   signal PCLK : std_logic;

   -- Clock period definitions
   constant CLK_period : time := 10 ns;
   constant SCLK_period : time := 10 ns;
   constant PCLK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: serial_register_master PORT MAP (
          CLK => CLK,
          write_register => write_register,
          register_address => register_address,
          register_value => register_value,
          s_reg_busy => s_reg_busy,
          s_reg_done => s_reg_done,
          Sin => Sin,
          SCLK => SCLK,
          Update => Update,
          PCLK => PCLK
        );

   -- Clock process definitions
   CLK_process :process
   begin
		CLK <= '0';
		wait for CLK_period/2;
		CLK <= '1';
		wait for CLK_period/2;
   end process;
 
 
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for CLK_period*10;
			write_register <= '1';
         register_address <= "111100001111";
         register_value <= "101011001110";
      -- insert stimulus here 
		 wait for CLK_period;
			write_register <= '1';
      wait;
   end process;

END;
