library IEEE;

use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ps2_keyboard is
	port(clk : in std_logic;
			reset : in std_logic;
			ps2_clk : in std_logic;
			ps2_data : in std_logic;
			new_key : out std_logic;
			key_code : out std_logic_vector(7 downto 0));
end ps2_keyboard;

architecture Behavioral of ps2_keyboard is
	signal slow_clk_100khz : std_logic;
	signal slow_clk_counter : std_logic_vector(9 downto 0);

	signal ps2_sync : std_logic_vector(1 downto 0);
	signal ps2_clk_falling : std_logic;
	
	-- ps2 frame = 11 bits
	signal data_buffer : std_logic_vector(10 downto 0);	
	signal bits_shifted : std_logic_vector(3 downto 0);
begin
	-- generate 100khz clock enable signal
	process(clk)
	begin
		if (rising_edge(clk)) then
			slow_clk_counter <= slow_clk_counter + 1;
			if (slow_clk_counter = 0) then
				slow_clk_100khz <= '1';
			else
				slow_clk_100khz <= '0';
			end if;
		end if;
	end process;
	
	-- 2bit DFF as in L07 slide 15
	process(clk)
	begin
		if (rising_edge(clk)) then
			if (reset = '1') then
				ps2_sync <= "00";
			elsif (slow_clk_100khz = '1') then
				ps2_sync(0) <= ps2_clk;
				ps2_sync(1) <= ps2_sync(0);
			end if;
		end if;
	end process;
	
	process(ps2_sync)
	begin
		if (ps2_sync = "10") then
			ps2_clk_falling <= '1';
		else
			ps2_clk_falling <= '0';
		end if;
	end process;
	
	process(reset, ps2_clk_falling)
	begin
		if (reset = '1') then
			bits_shifted <= "0000";
		elsif (rising_edge(ps2_clk_falling)) then
			
			-- 10th bit
			if (bits_shifted = "1010") then
				new_key <= '1';
				key_code <= data_buffer(9 downto 2);
				bits_shifted <= "0000";
			else 
				data_buffer <= ps2_data & data_buffer(10 downto 1);
				bits_shifted <= bits_shifted + 1;
				new_key <= '0';
			end if;
			
			-- todo: error checking (parity)
			-- start bit = 0
			-- odd parity
			-- sotp bit = 1
		end if;
	end process;
end architecture;