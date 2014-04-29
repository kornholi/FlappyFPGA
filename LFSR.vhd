-- LFSR (linear feedback shift register) used to generate pseudo-random numbers

library ieee;
use ieee.std_logic_1164.all;

entity LFSR is
	port(clk : in std_logic;
		  reset : in std_logic;
			
		  q : out std_logic_vector(7 downto 0));
end entity;

architecture Behavioral of LFSR is
	signal q_internal : std_logic_vector(7 downto 0);
	signal feedback : std_logic;
begin
	feedback <= not(q_internal(7) xor q_internal(3));

	process (clk, reset)
	begin
		if (reset = '1') then
			q_internal <= "00000000";
		elsif (rising_edge(clk)) then
			q_internal <= q_internal(6 downto 0) & feedback;
		end if;
	end process;
	
	q <= q_internal;
end architecture;