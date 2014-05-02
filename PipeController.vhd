library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.types.all;

entity PipeController is
   port(Clk : in std_logic;
		  FrameClk : in std_logic;
		  Reset : in std_logic;
		  RandomIn : in natural;
		  State : in state_t;
        PipeX : out PipeXPosition;
		  PipeY : out PipeYPositions;
		  Score : out natural);
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
	
	signal HasScored : boolean;
	signal Score_i : natural;
begin
	process(FrameClk, Reset, State)
	begin
		if Reset = '1' or State = start_screen then
			PipeX_i <= 825;
			PipeY_i <= (124, 200, 222, 177, 240, 250, 100, 199, 300, 200);
			Score_i <= 8;
			HasScored <= false;
		elsif rising_edge(FrameClk) then
			if State = ok then
				-- Once pipe goes fully outside of bounds
				-- the next pipe becomes left-most
				if PipeX_i - PipeSpeed <= -PipeWidth then
					PipeX_i <= PipeSeparation - PipeWidth;
					PipeY_i <= PipeY_i(1 to (PipeY_i'length - 1)) & PipeY_i(0);
				
					HasScored <= false;
				else
					PipeX_i <= PipeX_i - PipeSpeed;
				end if;
			
				-- or is required to check for passing initial pipe
				if not HasScored and
						((PipeX_i + PipeSeparation - BirdX - PipeWidth / 2) <= PipeSpeed or (PipeX_i - BirdX) <= PipeSpeed) then
					Score_i <= Score_i + 1;
					HasScored <= true;
				end if;		
			elsif State = game_over then
				PipeY_i <= PipeY_i;
				PipeX_i <= PipeX_i;
				Score_i <= Score_i;
			end if;
		end if;
	end process;
	
	PipeX <= PipeX_i;
	PipeY <= PipeY_i;
	Score <= Score_i;
end rtl;