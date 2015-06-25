--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   14:51:30 02/11/2013
-- Design Name:   
-- Module Name:   C:/Users/Luca/Desktop/ANITA/LAB4B_FMC_ML605_firmware/LAB4B_FMC_Eval/test_ext_DAC_program.vhd
-- Project Name:  LAB4B_FMC_Eval
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: external_DAC_program
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
 
ENTITY test_ext_DAC_program IS
END test_ext_DAC_program;
 
ARCHITECTURE behavior OF test_ext_DAC_program IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT external_DAC_program
    PORT(
         CLK : IN  std_logic;
         update_all_DACs : IN  std_logic;
         LTC2620_SCK : OUT  std_logic_vector(1 downto 0);
         LTC2620_SDI : OUT  std_logic_vector(1 downto 0);
         LTC2620_NCS : OUT  std_logic_vector(1 downto 0);
         LTC2620_SDO : IN  std_logic_vector(1 downto 0);
         CONTROL : INOUT  std_logic_vector(35 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal CLK : std_logic := '0';
   signal update_all_DACs : std_logic := '0';
   signal LTC2620_SDO : std_logic_vector(1 downto 0) := (others => '0');

	--BiDirs
   signal CONTROL : std_logic_vector(35 downto 0);

 	--Outputs
   signal LTC2620_SCK : std_logic_vector(1 downto 0);
   signal LTC2620_SDI : std_logic_vector(1 downto 0);
   signal LTC2620_NCS : std_logic_vector(1 downto 0);

   -- Clock period definitions
   constant CLK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: external_DAC_program PORT MAP (
          CLK => CLK,
          update_all_DACs => update_all_DACs,
          LTC2620_SCK => LTC2620_SCK,
          LTC2620_SDI => LTC2620_SDI,
          LTC2620_NCS => LTC2620_NCS,
          LTC2620_SDO => LTC2620_SDO,
          CONTROL => CONTROL
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
      -- insert stimulus here 
		update_all_DACs <='1';
      wait for CLK_period*10;
		update_all_DACs <='0';
      wait;
   end process;

END;
