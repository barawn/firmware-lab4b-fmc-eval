--
--	Package File Template
--
--	Purpose: This package defines supplemental types, subtypes, 
--		 constants, and functions 
--
--   To use any of the example code shown below, uncomment the lines and modify as necessary
--

library IEEE;
use IEEE.STD_LOGIC_1164.all;

package package_types is
type ext_DACs_from_UART_type is array (0 to 15) of std_logic_vector(11 downto 0);
type DACs_from_UART_type is array (0 to 12) of std_logic_vector(11 downto 0);
type DT_type is array (0 to 127) of std_logic_vector(11 downto 0);
end package_types;
