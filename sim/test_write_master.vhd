--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   22:20:23 02/12/2013
-- Design Name:   
-- Module Name:   C:/Users/luca/Desktop/LAB4B_Eval/test_write_master.vhd
-- Project Name:  LAB4B_FMC_Eval
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: write_master
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY test_write_master IS
END test_write_master;
 
ARCHITECTURE behavior OF test_write_master IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT write_master
    PORT(
         CLK : IN  std_logic;
         load_internal_done : IN  std_logic;
         PHAB : IN  std_logic;
         read_start : IN  std_logic;
         read_done : IN  std_logic;
         WR_Ena : OUT  std_logic;
         WR_S : OUT  std_logic_vector(4 downto 0);
         start_read_0 : OUT  std_logic_vector(2 downto 0);
         start_read_1 : OUT  std_logic_vector(2 downto 0);
         start_read_2 : OUT  std_logic_vector(2 downto 0);
         start_read_3 : OUT  std_logic_vector(2 downto 0);
			curr_bank : out std_logic_vector(1 downto 0);
			curr_low : out std_logic_vector(2 downto 0);
			choice_phase_debug : in std_logic_vector(4 downto 0)
        );
    END COMPONENT;
   
	signal initialize_done : std_logic := '0';
	signal counter : std_logic_vector(3 downto 0) := "0000";
	
   --Inputs
   signal CLK : std_logic := '0';
   signal load_internal_done : std_logic := '0';
   signal PHAB : std_logic := '0';
   signal read_start : std_logic := '0';
   signal read_done : std_logic := '0';

 	--Outputs
   signal WR_Ena : std_logic;
   signal WR_S : std_logic_vector(4 downto 0);
   signal start_read_0 : std_logic_vector(2 downto 0);
   signal start_read_1 : std_logic_vector(2 downto 0);
   signal start_read_2 : std_logic_vector(2 downto 0);
   signal start_read_3 : std_logic_vector(2 downto 0);

   -- Clock period definitions
   constant CLK_period_H : time := 3 ns; -- this allows "real" timing  (200MHz)
   constant CLK_period_L : time := 2 ns;
	
	signal	curr_bank :  std_logic_vector(1 downto 0);
	signal	curr_low :  std_logic_vector(2 downto 0);
 
BEGIN

	-- Instantiate the Unit Under Test (UUT)
   uut: write_master PORT MAP (
          CLK => CLK,
          load_internal_done => load_internal_done,
          PHAB => PHAB,
          read_start => read_start,
          read_done => read_done,
          WR_Ena => WR_Ena,
          WR_S => WR_S,
          start_read_0 => start_read_0,
          start_read_1 => start_read_1,
          start_read_2 => start_read_2,
          start_read_3 => start_read_3, 
			curr_bank => curr_bank,
			curr_low => curr_low,
			 choice_phase_debug => (others => '0')
        );
   -- Clock process definitions
   CLK_process :process
   begin
		CLK <= '0';
		wait for CLK_period_L;
		CLK <= '1';
		wait for CLK_period_H;
   end process;
 
	process(CLK)
	begin
		if rising_edge(CLK) then
			if counter = 9 then
				counter  <= (others =>'0');
				PHAB <= not PHAB;
			else
				counter <= counter +1;
			end if;
		end if;
	end process;

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
		load_internal_done <= '0';
		initialize_done <='0';
      wait for 100 ns;	
		initialize_done <='1';
	   wait until CLK = '0';
		load_internal_done <= '1';
	   wait until CLK = '0';
		load_internal_done <= '0';
	   wait until CLK = '0';
      wait for 1000 ns;	
	   wait until CLK = '0';
		read_start <= '1';
	   wait until CLK = '0';
		read_start <= '0';
		wait for 1000 ns;	
	   wait until CLK = '0';
		read_done <='1';
		wait until CLK = '0';
		read_done <='0';
     wait for 100 ns;	
	   wait until CLK = '0';
		read_start <= '1';
	   wait until CLK = '0';
		read_start <= '0';
     wait for 100 ns;	
	   wait until CLK = '0';
		read_start <= '1';
	   wait until CLK = '0';
		read_start <= '0';
     wait for 100 ns;	
	   wait until CLK = '0';
		read_start <= '1';
	   wait until CLK = '0';
		read_start <= '0';
     wait for 100 ns;	
	   wait until CLK = '0';
		read_start <= '1';
	   wait until CLK = '0';
		read_start <= '0';	
		wait for 1000 ns;	
	   wait until CLK = '0';
		read_done <='1';
		wait for 1000 ns;	
	   wait until CLK = '0';
		read_done <='1';
		wait for 1000 ns;	
	   wait until CLK = '0';
		read_done <='1';
		wait for 1000 ns;	
	   wait until CLK = '0';
		read_done <='1';
		wait;

		
      -- insert stimulus here 

      wait;
   end process;

END;
