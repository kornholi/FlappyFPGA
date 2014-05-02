library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

library work;
use work.sprites.all;
use work.types.all;

entity ColorMapper is
   port( Clk : in std_logic;
			FrameClk : in std_logic;
		
			BirdY : in integer range 0 to 1024;
			
			PipeX : in PipeXPosition;
			PipeY : in PipeYPositions;
			
			DrawX : in integer range 0 to 1024;
			DrawY : in integer range 0 to 1024;

			State : in state_t;
			Score : in natural;
			
			Collision : out std_logic;
			
			Red   : out std_logic_vector(9 downto 0);
			Green : out std_logic_vector(9 downto 0);
			Blue  : out std_logic_vector(9 downto 0));
end ColorMapper;

architecture Behavioral of ColorMapper is
	signal BirdOn : boolean;
	
	signal AnimationCounter : unsigned(2 downto 0) := to_unsigned(0, 3);
	signal AnimationFrame : integer range 0 to 2;
	
	signal PipeOn : boolean;
	signal PipeOnTop : boolean;
	signal PipeOnIndex : natural;
	
	signal DigitOn : boolean;
	signal DigitX : natural;
	signal Digit : natural range 0 to 9;
	
	signal GetReadyOn : boolean;
	signal GetReadyX : natural;
	
	signal GameOverOn : boolean;
	signal GameOverX : natural;
begin
	process(FrameClk)
	begin
		if rising_edge(FrameClk) then
			AnimationCounter <= AnimationCounter + 1;
			
			if AnimationCounter = "11" and State /= Game_Over then
				AnimationFrame <= AnimationFrame + 1;
			end if;
		end if;
	end process;

	process (BirdY, DrawX, DrawY, AnimationFrame)
	begin
		BirdOn <= false;
		
		if (DrawX >= BirdX) AND (DrawX < BirdX + BirdWidth) AND
			(DrawY >= BirdY) AND	(DrawY < BirdY + BirdHeight) then
			if (flappy_bird(AnimationFrame, DrawX - BirdX, DrawY - BirdY) /= TransparentColor) then
				BirdOn <= true;
			end if;
		end if;
	end process;		

	process(DrawX, DrawY, PipeX, PipeY, PipeOnIndex)
		variable ClampedY : integer range -1 to 480 := 0;
		variable OffsetX : integer := 0;
	begin
		PipeOn <= false;
		PipeOnTop <= false;
		PipeOnIndex <= 0;
		
		for i in 0 to PipeY'length - 1 loop
			OffsetX := DrawX - i * PipeSeparation - PipeX;
			
			if OffsetX >= 0 AND OffsetX < PipeWidth then
				if DrawY > PipeY(i) + PipeHeightSeparation then
					PipeOnTop <= false;
					ClampedY := DrawY - PipeY(i) - PipeHeightSeparation;
				elsif DrawY < PipeY(i) - PipeHeightSeparation then
					PipeOnTop <= true;
					ClampedY := PipeY(i) - DrawY - PipeHeightSeparation;
				else
					ClampedY := -1;
				end if;

				if ClampedY > PipeHeight then
					ClampedY := PipeHeight;
				end if;
				
				if ClampedY /= -1 and pipespr(OffsetX, ClampedY) /= TransparentColor then
					PipeOn <= true;
					PipeOnIndex <= i;
				end if;
			end if;
		end loop;
	end process;
	
	-- Score
	process(DrawX, DrawY, Score)
		variable HalfWidth : integer := 0;
		variable DistFromCenter : integer := DrawX - DisplayWidth / 2;
	begin
		if Score > 9 then
			HalfWidth := BigDigitWidth + BigDigitSpacing / 2;
		else
			HalfWidth := BigDigitWidth / 2;
		end if;
		
		DigitOn <= false;
		Digit <= 0;
		DigitX <= 0;
		
		-- 2 = transparent color
		if (DistFromCenter >= -HalfWidth and DistFromCenter < HalfWidth) then
			if DrawY >= ScoreTopOffset and DrawY < ScoreTopOffset + BigDigitHeight then
				if Score > 9 then
					if DistFromCenter > BigDigitSpacing / 2 then
						if BigDigits(Score mod 10, DistFromCenter - BigDigitSpacing / 2, DrawY - ScoreTopOffset) /= 2 then
							DigitOn <= true;
							DigitX <= DistFromCenter - BigDigitSpacing / 2;
							Digit <= Score mod 10;
						end if;
					elsif DistFromCenter < -BigDigitSpacing / 2 then
						if BigDigits(Score / 10, DistFromCenter + HalfWidth, DrawY - ScoreTopOffset) /= 2 then
							DigitOn <= true;
							DigitX <= DistFromCenter + HalfWidth;
							Digit <= Score / 10;
						end if;
					end if;
				else
					if BigDigits(Score, DistFromCenter + HalfWidth, DrawY - ScoreTopOffset) /= 2 then
						DigitOn <= true;
						DigitX <= DistFromCenter + HalfWidth;
						Digit <= Score;
					end if;
				end if;
			end if;
		end if;
	end process;
		
	-- Get Ready
	process(DrawX, DrawY, State)
		variable HalfWidth : integer := GetReadyWidth / 2;
		variable DistFromCenter : integer := DrawX - DisplayWidth / 2;
	begin
		GetReadyOn <= false;
		GetReadyX <= 0;
		
		if (State = Start_Screen and DistFromCenter >= -HalfWidth and DistFromCenter < HalfWidth) then
			if DrawY >= MsgTopOffset and DrawY < MsgTopOffset + GetReadyHeight then
				if GetReady(DistFromCenter + HalfWidth, DrawY - MsgTopOffset) /= 4 then
					GetReadyOn <= true;
					GetReadyX <= DistFromCenter + HalfWidth;
				end if;
			end if;
		end if;
	end process;
		
		
	-- Game Over
	process(DrawX, DrawY, State)
		variable HalfWidth : integer := GameOverWidth / 2;
		variable DistFromCenter : integer := DrawX - DisplayWidth / 2;
	begin
		GameOverOn <= false;
		GameOverX <= 0;
		
		if (State = Game_Over and DistFromCenter >= -HalfWidth and DistFromCenter < HalfWidth) then
			if DrawY >= MsgTopOffset and DrawY < MsgTopOffset + GameOverHeight then
				if GameOver(DistFromCenter + HalfWidth, DrawY - MsgTopOffset) /= 4 then
					GameOverOn <= true;
					GameOverX <= DistFromCenter + HalfWidth;
				end if;
			end if;
		end if;
	end process;
	
	Collision <= '1' when (BirdOn = true and PipeOn = true) else '0';
	
	RGB_Display : process (BirdOn, PipeOn, DigitOn, Digit, DigitX, DrawX, DrawY, BirdY, PipeX, PipeY,
									PipeOnIndex, PipeOnTop, AnimationFrame, GetReadyOn, GetReadyX, GameOverX,
									GameOverOn)
		variable ClampedY : integer := 0;
		variable OffsetX : integer := 0;
	begin
		if DigitOn then
			Red   <= BigDigitPalette(BigDigits(Digit, DigitX, DrawY - ScoreTopOffset)) & "00";
			Green <= BigDigitPalette(BigDigits(Digit, DigitX, DrawY - ScoreTopOffset)) & "00";
			Blue  <= BigDigitPalette(BigDigits(Digit, DigitX, DrawY - ScoreTopOffset)) & "00";
		elsif GetReadyOn then
			Red   <= R_GetReady_rom(GetReady(GetReadyX, DrawY - MsgTopOffset)) & "00";
			Green <= G_GetReady_rom(GetReady(GetReadyX, DrawY - MsgTopOffset)) & "00";
			Blue  <= B_GetReady_rom(GetReady(GetReadyX, DrawY - MsgTopOffset)) & "00";
		elsif GameOverOn then
			Red   <= R_GameOver_rom(GameOver(GameOverX, DrawY - MsgTopOffset)) & "00";
			Green <= G_GameOver_rom(GameOver(GameOverX, DrawY - MsgTopOffset)) & "00";
			Blue  <= B_GameOver_rom(GameOver(GameOverX, DrawY - MsgTopOffset)) & "00";
		elsif BirdOn = true then
			Red   <= RED_rom(flappy_bird(AnimationFrame, DrawX - BirdX, DrawY - BirdY)) & "00";
			Green <= GREEN_rom(flappy_bird(AnimationFrame, DrawX - BirdX, DrawY - BirdY)) & "00";
			Blue  <= BLUE_rom(flappy_bird(AnimationFrame, DrawX - BirdX, DrawY - BirdY)) & "00";
			
			--Red <= "0000000000";
			--Green <= "0000000000";
			--Blue <= "1111111111";
		elsif DrawY >= (DisplayHeight - DirtHeight) then
			ClampedY := DrawY - (DisplayHeight - DirtHeight) + 1;
			
			if ClampedY >= DirtSpriteHeight then
				ClampedY := DirtSpriteHeight - 1;
			end if;
			
			Red   <= R_bottom_bg_rom(bottom_bg((DrawX - PipeX) mod (DirtSpriteWidth - 1), ClampedY)) & "00";
			Green <= G_bottom_bg_rom(bottom_bg((DrawX - PipeX) mod (DirtSpriteWidth - 1), ClampedY)) & "00";
			Blue  <= B_bottom_bg_rom(bottom_bg((DrawX - PipeX) mod (DirtSpriteWidth - 1), ClampedY)) & "00";
		elsif PipeOn = true then
			OffsetX := DrawX - PipeOnIndex * PipeSeparation - PipeX;
			
			if not PipeOnTop then
				ClampedY := DrawY - PipeY(PipeOnIndex) - PipeHeightSeparation;
			else
				ClampedY := PipeY(PipeOnIndex) - DrawY - PipeHeightSeparation;
			end if;
			
			if ClampedY > PipeHeight then
				ClampedY := PipeHeight;
			end if;
			
			Red   <= RED_rom(pipespr(OffsetX, ClampedY)) & "00";
			Green <= GREEN_rom(pipespr(OffsetX, ClampedY)) & "00";
			Blue  <= BLUE_rom(pipespr(OffsetX, ClampedY)) & "00";
		else 
			-- Background
			
			if DrawY < (DisplayHeight - DirtHeight - BackgroundHeight) then
				ClampedY := 0;
			else
				ClampedY := DrawY - (DisplayHeight - DirtHeight - BackgroundHeight);
			end if;
			
			Red <= R_bg16col_rom(bg16col(DrawX mod BackgroundWidth, ClampedY)) & "00";
			Green <= G_bg16col_rom(bg16col(DrawX mod BackgroundWidth, ClampedY)) & "00";
			Blue <= B_bg16col_rom(bg16col(DrawX mod BackgroundWidth, ClampedY)) & "00";
			
			--Red <= RED_rom(pipespr(DrawX mod 51, DrawY mod 26)) & "00";
			--Green <= GREEN_rom(pipespr(DrawX mod 51, DrawY mod 26)) & "00";
			--Blue <= BLUE_rom(pipespr(DrawX mod 51, DrawY mod 26)) & "00";
		end if;
	end process RGB_Display;
end Behavioral;
