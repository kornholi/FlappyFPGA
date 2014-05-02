library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.types.all;

entity Bird is
   port(Clk : in std_logic;
		  FrameClk : in std_logic;
		  Reset : in std_logic;
		  JumpIn : in std_logic;
		  CollisionImpulse : in std_logic;
		  Stateout : out state_t;
        BirdY : out unsigned(9 downto 0));
end Bird;

architecture Behavioral of Bird is
	signal Y_pos, Y_vel : integer;
	
	--signal Falling : std_logic;
	signal CanJump : std_logic;
	
	constant Y_Center : integer := 240;

	constant Y_Min    : integer := 0;
	constant Y_Max    : integer := 479 - DirtHeight;
	
	constant JumpVelocity : integer := -13;
	constant FallAcceleration : integer := 1;
	
	signal State : state_t;
	signal Collision : boolean;
	signal CollisionBuffer : std_logic_vector(2 downto 0);
	
	signal Jump, JumpBuffer : std_logic;
begin
	process(Clk, Reset, CollisionImpulse, CollisionBuffer, State)
	begin
		if Reset = '1' then
			Collision <= false;
		elsif rising_edge(Clk) then
			CollisionBuffer <= CollisionBuffer(1 downto 0) & CollisionImpulse;
			
			if State = start_screen then
				Collision <= false;
			elsif CollisionBuffer = "111" then
				Collision <= true;
			else
				Collision <= Collision;
			end if;
		end if;
	end process;
	
	process(FrameClk, JumpIn)
	begin
		if rising_edge(FrameClk) then
			JumpBuffer <= JumpIn;
		end if;
	end process;

	Jump <= JumpIn and (not JumpBuffer);
	
	process(Reset, FrameClk, Jump)
	begin
		if Reset = '1' then
			Y_vel <= 0;
			Y_pos <= Y_Center;
			CanJump <= '1';
			
			state <= start_screen;
		elsif rising_edge(FrameClk) then		
			case state is
				when start_screen =>
					if Jump = '1' then
						state <= ok;
					end if;
					
					if Y_pos > Y_center + 7 then
						Y_vel <= -2;
					elsif Y_pos < Y_center - 7 or Y_vel = 0 then
						Y_vel <= 2;
					end if;
					
				when ok =>
					if Collision = true then
						Y_vel <= JumpVelocity;
						state <= game_over;
					-- Check for falling to the ground (don't jump as in collision)
					elsif Y_pos + 23 + Y_vel > Y_max then
						state <= game_over;
					elsif CanJump = '0' and Jump = '0' then	
						CanJump <= '1';
					elsif CanJump = '1' and Jump = '1' then
						Y_vel <= JumpVelocity;
						CanJump <= '0';
					else
						Y_vel <= Y_vel + FallAcceleration;
					end if;
					
				when game_over =>
					Y_vel <= Y_vel + FallAcceleration;
					
					-- Fall and stay and bottom
					if (Y_pos + 23 + Y_vel > Y_max) then
						Y_pos <= Y_max - 23;
					else
						Y_pos <= Y_pos + Y_vel / 2;
					end if;
					
					if Y_pos + 23 + Y_vel > Y_max and Jump = '1' then
						Y_vel <= 0;
						Y_pos <= Y_Center;
						CanJump <= '1';
			
						state <= start_screen;
					end if;
			end case;
			
			if state = start_screen or state = ok then
				if (Y_pos + Y_vel < Y_min) then
					Y_pos <= Y_min;
				elsif (Y_pos + 23 + Y_vel > Y_max) then
					Y_pos <= Y_max - 23;
				else 
					Y_pos <= Y_pos + Y_vel / 2;
				end if;
			end if;
		end if;
	end process;
	
	Stateout <= State;
	BirdY <= to_unsigned(Y_Pos, BirdY'length);
end Behavioral;      
