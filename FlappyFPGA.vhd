-- FlappyFPGA - Root entity
--
-- Spring 2014
-- Kornelijus Survila

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.types.all;

entity FlappyFPGA is
    port(Clk : in std_logic;
			Reset : in std_logic;
			Jump : in std_logic;
			
         Red   : out std_logic_vector(9 downto 0);
         Green : out std_logic_vector(9 downto 0);
         Blue  : out std_logic_vector(9 downto 0);
			
         VGA_Clk : out std_logic; -- Pixel clock
         Sync : out std_logic; -- Composite sync
         VGA_Blank : out std_logic; -- Blanking interval
         VGA_vs : out std_logic; -- vertical sync
         VGA_hs : out std_logic; -- horizontal sync
			
			AhexL : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
			AhexU : OUT STD_LOGIC_VECTOR(6 DOWNTO 0));
end FlappyFPGA;

architecture Behavioral of FlappyFPGA is
	component Bird is
		 port( Clk : in std_logic;
				 FrameClk : in std_logic;
				 Reset : in std_logic;
				 JumpIn : in std_logic;
				 CollisionImpulse : in std_logic;
				 Stateout : out state_t;
				 BirdY : out unsigned(9 downto 0));
	end component;

	component VGAController is
		 port( clk : in std_logic;
				 reset : in std_logic;
				 hs : out std_logic;
				 vs : out std_logic;
				 pixel_clk : out std_logic;
				 blank : out std_logic;
				 sync : out std_logic;
				 DrawX : out std_logic_vector(9 downto 0);
				 DrawY : out std_logic_vector(9 downto 0));
	end component;

	component ColorMapper is
		 port( Clk : in std_logic;
				 FrameClk : in std_logic;
				 BirdY : in unsigned(9 downto 0);
				 PipeX : in PipeXPosition;
				 PipeY : in PipeYPositions;
				 DrawX : in std_logic_vector(9 downto 0);
				 DrawY : in std_logic_vector(9 downto 0);
				 Collision : out std_logic;
				 Red   : out std_logic_vector(9 downto 0);
				 Green : out std_logic_vector(9 downto 0);
				 Blue  : out std_logic_vector(9 downto 0));
	end component;

	COMPONENT HexDriver
		PORT(In0 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			  Out0 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0));
	END COMPONENT;
	
	component LFSR
		port(clk : in std_logic;
			  reset : in std_logic;
			  q : out std_logic_vector(7 downto 0));
	end component;
	
	component PipeController is
		port(Clk : in std_logic;
			  FrameClk : in std_logic;
			  Reset : in std_logic;
			  Collision : in std_logic;
			  PipeX : out PipeXPosition;
			  PipeY : out PipeYPositions);
	end component;

	signal Reset_h, Jump_h, vsSig: std_logic;
	signal DrawXsig, DrawYsig : std_logic_vector(9 downto 0);
	signal BirdYsig : unsigned(9 downto 0);
	
	signal PipeXsig : PipeXPosition;
	signal PipeYsig : PipeYPositions;
	
	signal Statesig : state_t;
	signal statedbg : std_logic_vector(1 downto 0);
	
	signal Collision : std_logic;
begin

	-- The push buttons are active low
	Reset_h <= not Reset; 
	Jump_h <= not Jump;
	
	VGA_vs <= vsSig;

	vgaSync_inst : VGAController
		Port map(clk => clk,
					reset => Reset_h,
					hs => VGA_hs,
					vs => vsSig,
					pixel_clk => VGA_clk,
					blank => VGA_Blank,
					Sync => Sync,
					DrawX => DrawXsig,
					DrawY => DrawYsig);

	Bird_inst : Bird
		Port map(Reset => Reset_h,
					Clk => clk,
					FrameClk => vsSig, -- Vertical Sync used as an "ad hoc" 60 Hz clock signal
					JumpIn => Jump_h,	 -- (This is why we registered it in the vga controller!)
					CollisionImpulse => Collision,
					Stateout => Statesig,
					BirdY => BirdYsig);

	Color_inst : ColorMapper
		Port Map(Clk => clk,
					FrameClk => vsSig,
					BirdY => BirdYsig,
					PipeX => PipeXsig,
					PipeY => PipeYsig,
					DrawX => DrawXsig,
					DrawY => DrawYsig,
					Collision => Collision,
					Red => Red,
					Green => Green,
					Blue => Blue);
			
	Pipe_inst : PipeController
		Port map(Clk => clk,
					FrameClk => vsSig,
					Reset => Reset_h,
					Collision => Collision,
					PipeX => PipeXsig,
					PipeY => PipeYsig);
					
	Hex2: HexDriver
	PORT MAP(In0 => "000" & Collision, Out0 => AhexU);

	statedbg <= "00" when Statesig = start_screen else
					"01" when Statesig = ok else
					"10" when Statesig = game_over else
					"11";
	
	Hex3 : HexDriver
	PORT MAP(In0 => "00" & statedbg, Out0 => AhexL);
end Behavioral;      
