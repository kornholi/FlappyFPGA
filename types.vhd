package types is
	type state_t is (start_screen, ok, game_over);
	
	constant DisplayWidth : integer := 640;
	constant DisplayHeight : integer := 480;
	
	constant TransparentColor : integer := 127;
		
	constant BirdX : integer := 230;
	constant BirdSize : integer := 10;
	
	constant BirdWidth : integer := 33;
	constant BirdHeight : integer := 23;
	
	constant PipeWidth : integer := 51;
	constant PipeHeight : integer := 26;
		
	-- Distance between pipes
	constant PipeSeparation : integer := 200;
	constant PipeHeightSeparation : integer := 60; -- 2 * BirdHeight is a little bit too small
	
	subtype PipeXPosition is integer range -PipeWidth to 1000;
	subtype PipeYPosition is integer range PipeHeight to (480 - PipeHeight);
	
	type PipeYPositions is array(0 to 9) of PipeYPosition;
	
	constant PipeSpeed : integer := 2;
	
	--
	constant BigDigitWidth : integer := 24;
	constant BigDigitHeight : integer := 36;
	constant BigDigitSpacing : integer := 2;
	
	constant ScoreTopOffset : integer := 64;
	constant MsgTopOffset : integer := 112;
	
	constant DirtHeight : integer := 75;
	
	constant DirtSpriteWidth : integer := 24;
	constant DirtSpriteHeight : integer := 22;
	
	constant GetReadyWidth : integer := 184;
	constant GetReadyHeight : integer := 50;
	
	constant GameOverWidth : integer := 192;
	constant GameOverHeight : integer := 42;
	
	constant BackgroundWidth : integer := 287;
	constant BackgroundHeight : integer := 83;
end package;