library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

library work;
use work.sprites.all;

entity ColorMapper is
   port(	FrameClk : in std_logic;
			BirdY : in unsigned(9 downto 0);
			DrawX : in unsigned(9 downto 0);
			DrawY : in unsigned(9 downto 0);

			Red   : out std_logic_vector(9 downto 0);
			Green : out std_logic_vector(9 downto 0);
			Blue  : out std_logic_vector(9 downto 0));
end ColorMapper;

architecture Behavioral of ColorMapper is
	signal Bird_on : std_logic;
	signal Pipe_on : std_logic;
	
	signal AnimationCounter : unsigned(3 downto 0) := to_unsigned(0, 4);
	signal AnimationFrame : integer range 0 to 2;
	signal PipeFrame : integer range 0 to 750;
	
	constant BirdX : unsigned(9 downto 0) := to_unsigned(230, 10);
	constant BirdSize : integer := 10;
	
	constant TransparentColor : integer := 127;
begin

	process(FrameClk)
	begin
		if (rising_edge(FrameClk)) then
			AnimationCounter <= AnimationCounter + 1;
			
			if (AnimationCounter = "111") then
				AnimationFrame <= AnimationFrame + 1;
			end if;
			
			PipeFrame <= PipeFrame + 1;
		end if;
	end process;

	Drawing_Bird_proc : process (BirdY, DrawX, DrawY, AnimationFrame)
	begin
	if ((DrawX >= BirdX) AND
      (DrawX < BirdX + 34) AND
      (DrawY >= BirdY) AND
      (DrawY < BirdY + 24)) then
			if (flappy_bird(AnimationFrame, to_integer(DrawX) - 230, to_integer(DrawY - BirdY)) /= TransparentColor) then
				Bird_on <= '1';
			else
				Bird_on <= '0';
			end if;
		else
			Bird_on <= '0';
		end if;
	end process Drawing_Bird_proc;
	
	process(DrawX, DrawY)
		variable lel : integer := 0;
		variable RealX : integer := to_integer(DrawX) + PipeFrame;
	begin
		-- (0 to 51, 0 to 26)
		if ((RealX >= 340) AND
      (RealX < 340 + 52) AND
      (DrawY >= 300)) then
			lel := to_integer(DrawY - 300);
			
			if (lel > 26) then
				lel := 26;
			end if;
			
			if (pipespr(RealX - 340, lel) /= TransparentColor) then
				Pipe_on <= '1';
			else
				Pipe_on <= '0';
			end if;
		else
			Pipe_on <= '0';
		end if;
	end process;
	
	RGB_Display : process (Bird_on, DrawX, DrawY, BirdY, AnimationFrame)
		variable lel : integer := 0;
		variable RealX : integer := to_integer(DrawX) + PipeFrame;
	begin
		if (Bird_on = '1') then -- blue Bird

			Red   <= "00" & RED_rom(flappy_bird(AnimationFrame, to_integer(DrawX) - 230, to_integer(DrawY - BirdY)));
			Green <= "00" & GREEN_rom(flappy_bird(AnimationFrame, to_integer(DrawX) - 230, to_integer(DrawY - BirdY)));
			Blue  <= "00" & BLUE_rom(flappy_bird(AnimationFrame, to_integer(DrawX) - 230, to_integer(DrawY - BirdY)));
			
			--Red <= "0000000000";
			--Green <= "0000000000";
			--Blue <= "1111111111";
		elsif (Pipe_on = '1') then
			lel := to_integer(DrawY - 300);
			
			if (lel > 26) then
				lel := 26;
			end if;
		
			Red   <= "00" & RED_rom(pipespr(RealX - 340, lel));
			Green <= "00" & GREEN_rom(pipespr(RealX - 340, lel));
			Blue  <= "00" & BLUE_rom(pipespr(RealX - 340, lel));
			
		else -- gradient background
			Red <= "00" & RED_rom(pipespr(to_integer(DrawX) mod 51, to_integer(DrawY) mod 26));
			Green <= "00" & GREEN_rom(pipespr(to_integer(DrawX) mod 51, to_integer(DrawY) mod 26));
			Blue <= "00" & BLUE_rom(pipespr(to_integer(DrawX) mod 51, to_integer(DrawY) mod 26));
		end if;
	end process RGB_Display;
end Behavioral;
