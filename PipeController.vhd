library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.types.all;

entity PipeController is
   port(Clk : in std_logic;
		  FrameClk : in std_logic;
		  Reset : in std_logic;
		  Collision : in std_logic;
        PipeX : out PipeXPosition;
		  PipeY : out PipeYPositions);
end PipeController;

-- Pipe Controller maintains 6 columns of pipes

-- A pipe is described by a single y coordinate which is the center
-- between top and bottom pipes on the left side. Two bird heights
-- are used above/below that point as free space.

-- Once a pipe goes offscreen, its y position is randomized and it
-- is placed at the end

architecture rtl of PipeController is
	-- PipeX is the X position of left-most. At the start of the game
	-- it is a large number which "brings" pipes in from the right 
	-- side.
	signal PipeX_i : PipeXPosition;
	signal PipeY_i : PipeYPositions;
begin
	process(Clk, Reset)
	begin
		if Reset = '1' then
			PipeX_i <= 600;
			PipeY_i <= (100, 400, 250, 333);
		elsif rising_edge(FrameClk) then
			-- Once pipe goes fully outside of bounds
			-- the next pipe becomes left-most
			if PipeX_i - PipeSpeed <= -PipeWidth then
				PipeX_i <= PipeSeparation - PipeWidth;
				PipeY_i <= PipeY_i(1 to (PipeY_i'length - 1)) & PipeY_i(0);
			else
				PipeX_i <= PipeX_i - PipeSpeed;
			end if;	
		end if;
	end process;
	
	PipeX <= PipeX_i;
	PipeY <= PipeY_i;
end rtl;