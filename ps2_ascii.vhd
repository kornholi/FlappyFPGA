library IEEE;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ps2_ascii is
	port(clk : in std_logic;
			key_ready : in std_logic;    
			key_code : in std_logic_vector(7 downto 0);
			ascii_ready : out std_logic;
			ascii_code : out std_logic_vector(7 downto 0));
end ps2_ascii;

architecture Behavioral of ps2_ascii is
	type state_t is (idle, new_code, output);
	signal state : state_t;
	
	signal last_ready : std_logic;
	
	signal break_code : std_logic;
begin
	process(clk)
	begin
		if (rising_edge(clk)) then
			ascii_code <= x"FF";
			case state is
				when idle =>
					if (last_ready = '0' and key_ready = '1') then
						-- new code
						state <= new_code;
					else
						state <= idle;
					end if;
					
				when new_code =>
					ascii_ready <= '0';
					if (key_code = x"F0") then
						break_code <= '1';
						state <= idle;
					else
						state <= output;
					end if;
					
				when output =>
					break_code <= '0';
					if (break_code = '1') then
						ascii_code <= x"FF";
						ascii_ready <= '1';
						state <= idle;
					else
						case key_code is
							when x"29" => ascii_code <= x"20"; -- Space
							when others => ascii_code <= x"FF";
						end case;
						
						ascii_ready <= '1';
						state <= idle;
					end if;
			end case;
			last_ready <= key_ready;
		end if;
	end process;
end architecture;