--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   11:14:26 02/25/2013
-- Design Name:   
-- Module Name:   C:/Users/Luca/Desktop/ANITA/LAB4B_FMC_ML605_firmware/LAB4B_FMC_Eval/test_write_readout.vhd
-- Project Name:  LAB4B_FMC_Eval
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: LAB4B_FMC_top
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
 
ENTITY test_write_readout IS
END test_write_readout;
 
ARCHITECTURE behavior OF test_write_readout IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT LAB4B_FMC_top
    PORT(
         CLOCK_200MHz_N : IN  std_logic;
         CLOCK_200MHz_P : IN  std_logic;
         WR_Ena : OUT  std_logic;
         WR_S : OUT  std_logic_vector(4 downto 0);
         SEL_Any : OUT  std_logic;
         CLR : OUT  std_logic;
         SSTinP : OUT  std_logic;
         SSTinN : OUT  std_logic;
         PT : OUT  std_logic;
         SSTdly : IN  std_logic;
         MonTiming : IN  std_logic;
         RD_Ena : OUT  std_logic;
         RD_S : OUT  std_logic_vector(4 downto 0);
         WCLKp : OUT  std_logic;
         WCLKn : OUT  std_logic;
         Ramp : OUT  std_logic;
         Sin : OUT  std_logic;
         SCLK : OUT  std_logic;
         Update : OUT  std_logic;
         PCLK : OUT  std_logic;
         SHout : IN  std_logic;
         RegCLR : OUT  std_logic;
         SS_Incr : OUT  std_logic;
         SR_Sel : OUT  std_logic;
         SRCLKp : OUT  std_logic;
         SRCLKn : OUT  std_logic;
         DOE : IN  std_logic;
         DOE_LVDSp : IN  std_logic;
         DOE_LVDSn : IN  std_logic;
         LTC2620_SCK : OUT  std_logic_vector(1 downto 0);
         LTC2620_SDI : OUT  std_logic_vector(1 downto 0);
         LTC2620_NCS : OUT  std_logic_vector(1 downto 0);
         LTC2620_SDO : IN  std_logic_vector(1 downto 0);
         MONITOR : OUT  std_logic_vector(6 downto 4)
        );
    END COMPONENT;
    

   --Inputs
   signal CLOCK_200MHz_N : std_logic := '0';
   signal CLOCK_200MHz_P : std_logic := '0';
   signal SSTdly : std_logic := '0';
   signal MonTiming : std_logic := '0';
   signal SHout : std_logic := '0';
   signal DOE : std_logic := '0';
   signal DOE_LVDSp : std_logic := '0';
   signal DOE_LVDSn : std_logic := '0';
   signal LTC2620_SDO : std_logic_vector(1 downto 0) := (others => '0');

 	--Outputs
   signal WR_Ena : std_logic;
   signal WR_S : std_logic_vector(4 downto 0);
   signal SEL_Any : std_logic;
   signal CLR : std_logic;
   signal SSTinP : std_logic;
   signal SSTinN : std_logic;
   signal PT : std_logic;
   signal RD_Ena : std_logic;
   signal RD_S : std_logic_vector(4 downto 0);
   signal WCLKp : std_logic;
   signal WCLKn : std_logic;
   signal Ramp : std_logic;
   signal Sin : std_logic;
   signal SCLK : std_logic;
   signal Update : std_logic;
   signal PCLK : std_logic;
   signal RegCLR : std_logic;
   signal SS_Incr : std_logic;
   signal SR_Sel : std_logic;
   signal SRCLKp : std_logic;
   signal SRCLKn : std_logic;
   signal LTC2620_SCK : std_logic_vector(1 downto 0);
   signal LTC2620_SDI : std_logic_vector(1 downto 0);
   signal LTC2620_NCS : std_logic_vector(1 downto 0);
   signal MONITOR : std_logic_vector(6 downto 4);

   -- Clock period definitions
   constant CLOCK_200MHz_N_period : time := 5 ns;
   constant CLOCK_200MHz_P_period : time := 5 ns;

	signal data : std_logic_vector(11 downto 0) := (others => '0');

 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: LAB4B_FMC_top PORT MAP (
          CLOCK_200MHz_N => CLOCK_200MHz_N,
          CLOCK_200MHz_P => CLOCK_200MHz_P,
          WR_Ena => WR_Ena,
          WR_S => WR_S,
          SEL_Any => SEL_Any,
          CLR => CLR,
          SSTinP => SSTinP,
          SSTinN => SSTinN,
          PT => PT,
          SSTdly => SSTdly,
          MonTiming => MonTiming,
          RD_Ena => RD_Ena,
          RD_S => RD_S,
          WCLKp => WCLKp,
          WCLKn => WCLKn,
          Ramp => Ramp,
          Sin => Sin,
          SCLK => SCLK,
          Update => Update,
          PCLK => PCLK,
          SHout => SHout,
          RegCLR => RegCLR,
          SS_Incr => SS_Incr,
          SR_Sel => SR_Sel,
          SRCLKp => SRCLKp,
          SRCLKn => SRCLKn,
          DOE => DOE,
          DOE_LVDSp => DOE_LVDSp,
          DOE_LVDSn => DOE_LVDSn,
          LTC2620_SCK => LTC2620_SCK,
          LTC2620_SDI => LTC2620_SDI,
          LTC2620_NCS => LTC2620_NCS,
          LTC2620_SDO => LTC2620_SDO,
          MONITOR => MONITOR
        );

   -- Clock process definitions
   CLOCK_200MHz_N_process :process
   begin
		CLOCK_200MHz_N <= '1';
		wait for CLOCK_200MHz_N_period/2;
		CLOCK_200MHz_N <= '0';
		wait for CLOCK_200MHz_N_period/2;
   end process;
 
   CLOCK_200MHz_P_process :process
   begin
		CLOCK_200MHz_P <= '0';
		wait for CLOCK_200MHz_P_period/2;
		CLOCK_200MHz_P <= '1';
		wait for CLOCK_200MHz_P_period/2;
   end process;
 
 
   -- Stimulus process
   stim_proc: process -- mostly  to set unused inputs to 0.
   begin		
      -- hold reset state for 100 ns.
			SSTdly   <= '0';  -- no used for now
         SHout <= '0'; -- no used for now
         LTC2620_SDO <= (others => '0'); -- don't care about the programming of ext. DACs
      wait for 100 ns;	
		
      wait for CLOCK_200MHz_N_period*10;

      -- insert stimulus here 

      wait;
   end process;
	PHAB_process: process(SSTinP)
	begin
		MonTiming <= '0'; 
		if rising_edge(SSTinP) then
			MonTiming<= not MonTiming after 3 ns;
		end if;
	end process;
	
	DOE_process: process(SRCLKp) -- on sr_clock - to generate serial in data
	variable shreg_data : std_logic_vector(11 downto 0) := (others => '0');
	begin
		   DOE <= '0'; --follow DOE_LVDSp
         DOE_LVDSp <= '0';
         DOE_LVDSn <= '1';
		if falling_edge(SRCLKp) then 
			if (SR_Sel = '1') then
				shreg_data:= data;
			else
				shreg_data:= shreg_data(10 downto 0) & '0';
			end if;
			DOE<=shreg_data(11);
			DOE_LVDSp<=shreg_data(11);
			DOE_LVDSn<= not shreg_data(11);
		end if;
	end process;
	
		data_process: process(SS_Incr) -- on sr_clock - to generate serial in data
	begin
		if rising_edge(SS_Incr) then 
				data <= data +1;
		end if;
	end process;
	
	
END;
