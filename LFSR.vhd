-- LFSR (linear feedback shift register) used to generate pseudo-random numbers

library ieee;
use ieee.std_logic_1164.all;

entity LFSR is
	port(clk : in std_logic;
		  reset : in std_logic;
			
		  q : out std_logic_vector(7 downto 0));
end entity;

architecture Behavioral of LFSR is
	
	signal feedback : std_logic;
begin
	process (clk, reset)
		variable q_internal : std_logic_vector(7 downto 0) := "10101101";
		variable feedback : std_logic;
	begin
		if (rising_edge(clk)) then
			feedback := not(q_internal(7) xor q_internal(3));
			q_internal := q_internal(6 downto 0) & feedback;
		end if;
		
		q <= q_internal;
	end process;
end architecture;