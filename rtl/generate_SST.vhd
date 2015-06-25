----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:43:14 02/08/2013 
-- Design Name: 
-- Module Name:    generate_SST - Behavioral 
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
library UNISIM;
use UNISIM.VComponents.all;

entity generate_SST is
 port(
CLK : in std_logic;
SSTdbg : out std_logic;
SSTinP : out std_logic;
SSTinN : out std_logic
);
end generate_SST;

architecture Behavioral of generate_SST is

signal SST : std_logic := '0';
signal count : std_logic_vector(6 downto 0) := (others =>'0');
begin

SSTdbg <= SST;

process(CLK)
begin
if rising_edge(CLK) then
--Generate pulse for delay line testing:
--if count < 63 then -- a duty cycle of 1/16
--		count <= count +1;
--	else
--		count <= (others => '0');
--	end if;
--if count < 4 then
--SST<='1';
--else
--SST<='0';
--end if;

--	if count < 4 then -- this for 2.56Gsa/s
--	if count < 2 then -- this for 4.266Gsa/s
	if count < 3 then -- this for 3.2Gsa/s
		count <= count +1;
	else
		count <= (others => '0');
		SST <= not SST;
	end if;
end if;
end process;

inst_diff_buffer: OBUFDS 
  port map(
    I => SST, 
	 O  => SSTinP,
    OB => SSTinN
  );

end Behavioral;

