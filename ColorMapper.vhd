library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

library work;
use work.sprites.all;
use work.types.all;

entity ColorMapper is
   port( Clk : in std_logic;
			FrameClk : in std_logic;
		
			BirdY : in unsigned(9 downto 0);
			
			PipeX : in PipeXPosition;
			PipeY : in PipeYPositions;
			
			DrawX : in unsigned(9 downto 0);
			DrawY : in unsigned(9 downto 0);

			Collision : out std_logic;
			
			Red   : out std_logic_vector(9 downto 0);
			Green : out std_logic_vector(9 downto 0);
			Blue  : out std_logic_vector(9 downto 0));
end ColorMapper;

architecture Behavioral of ColorMapper is
	signal BirdOn : boolean;
	
	signal AnimationCounter : unsigned(2 downto 0) := to_unsigned(0, 3);
	signal AnimationFrame : integer range 0 to 2;
	
	constant BirdX : unsigned(9 downto 0) := to_unsigned(230, 10);
	constant BirdSize : integer := 10;
	
	constant TransparentColor : integer := 127;
	
	--component single_port_rom is
	--port 
	--(
	--	clk	: in std_logic;
	--	x 		: in natural range 0 to 287;
	--	y 		: in natural range 0 to 83;
	--	q		: out integer range 0 to 127 -- unsigned(6 downto 0)
	--);
	--end component;
	
	signal PipeOn : boolean;
	signal PipeOnTop : boolean;
	signal PipeOnIndex : natural;
	
	--signal palette_idx : integer range 0 to 127; --unsigned(7 downto 0);
begin
	process(FrameClk)
	begin
		if rising_edge(FrameClk) then
			AnimationCounter <= AnimationCounter + 1;
			
			if AnimationCounter = "11" then
				AnimationFrame <= AnimationFrame + 1;
			end if;
		end if;
	end process;

	Drawing_Bird_proc : process (BirdY, DrawX, DrawY, AnimationFrame)
	begin
		BirdOn <= false;
		
		if (DrawX >= BirdX) AND (DrawX < BirdX + BirdWidth) AND
			(DrawY >= BirdY) AND	(DrawY < BirdY + BirdHeight) then
			if (flappy_bird(AnimationFrame, to_integer(DrawX - BirdX), to_integer(DrawY - BirdY)) /= TransparentColor) then
				BirdOn <= true;
			end if;
		end if;
	end process Drawing_Bird_proc;		

	process(DrawX, DrawY)
		variable ClampedY : natural := 0;
		variable OffsetX : integer := 0;
	begin
		PipeOn <= false;
		PipeOnTop <= false;
		PipeOnIndex <= 0;
	
		for i in 0 to PipeY'length - 1 loop
			OffsetX := to_integer(DrawX) - i * PipeSeparation - PipeX;
			
			if OffsetX >= 0 AND OffsetX < PipeWidth then
				if (to_integer(DrawY) > PipeY(i) + PipeHeightSeparation) then
					ClampedY := to_integer(DrawY) - PipeY(i) - PipeHeightSeparation;
				elsif (to_integer(DrawY) < PipeY(i) - PipeHeightSeparation) then
					ClampedY := PipeY(i) - to_integer(DrawY) - PipeHeightSeparation;
				end if;

				if ClampedY > PipeHeight then
					ClampedY := PipeHeight;
				end if;
				
				if pipespr(OffsetX, ClampedY) /= TransparentColor then
					PipeOn <= true;
					PipeOnTop <= true;
					PipeOnIndex <= i;
				end if;
			end if;
		end loop;
	end process;
		
	--end process;
	
	--Bg_inst : single_port_rom
	--port map(clk => clk,
	--		X => to_integer(DrawX) mod 288,	
	--		Y => to_integer(DrawY) mod 84,
	--		Q => palette_idx);
	
	RGB_Display : process (BirdOn, PipeOn, DrawX, DrawY, BirdY, AnimationFrame)
		variable ClampedY : integer := 0;
		variable OffsetX : integer := 0;
	begin
		Collision <= '0';
	
		if BirdOn = true and PipeOn = true then
			Red <= "1111111111";
			Green <= "0000000000";
			Blue <= "0000000000";
			Collision <= '1';
		elsif BirdOn = true then
			Red   <= RED_rom(flappy_bird(AnimationFrame, to_integer(DrawX - BirdX), to_integer(DrawY - BirdY))) & "00";
			Green <= GREEN_rom(flappy_bird(AnimationFrame, to_integer(DrawX - BirdX), to_integer(DrawY - BirdY))) & "00";
			Blue  <= BLUE_rom(flappy_bird(AnimationFrame, to_integer(DrawX - BirdX), to_integer(DrawY - BirdY))) & "00";
			
			--Red <= "0000000000";
			--Green <= "0000000000";
			--Blue <= "1111111111";
		elsif PipeOn = true then
			OffsetX := to_integer(DrawX) - PipeOnIndex * PipeSeparation - PipeX;
			
			if not PipeOnTop then
				ClampedY := to_integer(DrawY) - PipeY(PipeOnIndex) - PipeHeightSeparation;
			else
				ClampedY := PipeY(PipeOnIndex) - to_integer(DrawY) - PipeHeightSeparation;
			end if;
			
			if ClampedY > PipeHeight then
				ClampedY := PipeHeight;
			end if;
			
			Red   <= RED_rom(pipespr(OffsetX, ClampedY)) & "00";
			Green <= GREEN_rom(pipespr(OffsetX, ClampedY)) & "00";
			Blue  <= BLUE_rom(pipespr(OffsetX, ClampedY)) & "00";
		else 
			-- Background
			Red <= RED_rom(pipespr(to_integer(DrawX) mod 51, to_integer(DrawY) mod 26)) & "00";
			Green <= GREEN_rom(pipespr(to_integer(DrawX) mod 51, to_integer(DrawY) mod 26)) & "00";
			Blue <= BLUE_rom(pipespr(to_integer(DrawX) mod 51, to_integer(DrawY) mod 26)) & "00";
		end if;
	end process RGB_Display;
end Behavioral;
