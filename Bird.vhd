library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Bird is
   port(Reset : in std_logic;
        FrameClk : in std_logic;
		  Jump : in std_logic;
        BirdY : out unsigned(9 downto 0));
end Bird;

architecture Behavioral of Bird is
	signal Y_pos, Y_vel : integer;
	
	signal Falling : std_logic;
	signal CanJump : std_logic;
	
	constant Y_Center : integer := 240;

	constant Y_Min    : integer := 0;
	constant Y_Max    : integer := 479;
	
	constant JumpVelocity : integer := -13;
	constant FallAcceleration : integer := 1;
begin
	process(Reset, FrameClk, Jump)
	begin
		if(Reset = '1') then
			Y_vel <= 0;
			Y_pos <= Y_Center;
			Falling <= '0';
			CanJump <= '1';
		elsif(rising_edge(FrameClk)) then
			if (CanJump = '0' and Jump = '0') then	
				CanJump <= '1';
			end if;
		
			if (CanJump = '1' and Jump = '1') then
				Y_vel <= JumpVelocity;
				Falling <= '1';
				CanJump <= '0';
			elsif (Falling = '1') then
				Y_vel <= Y_vel + FallAcceleration;
			end if;
			
			if (Y_pos + Y_vel < Y_min) then
				Y_pos <= Y_min;
			elsif (Y_pos + 23 + Y_vel > Y_max) then
				Y_pos <= Y_max - 23;
			else 
				Y_pos <= Y_pos + Y_vel;
			end if;
		end if;
	end process;

	BirdY <= unsigned(Y_Pos, BirdY'length));
end Behavioral;      
