package types is
	type state_t is (start_screen, ok, game_over);
	
	constant BirdWidth : integer := 33;
	constant BirdHeight : integer := 23;
	
	constant PipeWidth : integer := 51;
	constant PipeHeight : integer := 26;
		
	-- Distance between pipes
	constant PipeSeparation : integer := 200;
	constant PipeHeightSeparation : integer := 60; -- 2 * BirdHeight is a little bit too small
	
	subtype PipeXPosition is integer range -PipeWidth to 1000;
	subtype PipeYPosition is integer range PipeHeight to (480 - PipeHeight);
	
	type PipeYPositions is array(0 to 3) of PipeYPosition;
	
	constant PipeSpeed : integer := 2;
end package;