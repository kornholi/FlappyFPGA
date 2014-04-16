-- FlappyFPGA - Root entity
--
-- Spring 2014
-- Kornelijus Survila

library ieee;
use ieee.std_logic_1164.all;

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
		 port( Reset : in std_logic;
				 FrameClk : in std_logic;
				 Jump : in std_logic;
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
		 port( FrameClk : in std_logic;
				 BirdY : in unsigned(9 downto 0);
				 DrawX : in std_logic_vector(9 downto 0);
				 DrawY : in std_logic_vector(9 downto 0);
				 Red   : out std_logic_vector(9 downto 0);
				 Green : out std_logic_vector(9 downto 0);
				 Blue  : out std_logic_vector(9 downto 0));
	end component;

	COMPONENT HexDriver
		PORT(In0 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			  Out0 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0));
	END COMPONENT;

	signal Reset_h, Jump_h, vsSig: std_logic;
	signal DrawXsig, DrawYsig, BirdYsig : std_logic_vector(9 downto 0);
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
					FrameClk => vsSig, -- Vertical Sync used as an "ad hoc" 60 Hz clock signal
					Jump => Jump_h,	 -- (This is why we registered it in the vga controller!)
					BirdY => BirdYsig);

	Color_inst : ColorMapper
		Port Map(FrameClk => vsSig,
					BirdY => BirdYsig,
					DrawX => DrawXsig,
					DrawY => DrawYsig,
					Red => Red,
					Green => Green,
					Blue => Blue);
					
	Hex2: HexDriver
	PORT MAP(In0 => x"D", Out0 => AhexU);

	Hex3 : HexDriver
	PORT MAP(In0 => x"D", Out0 => AhexL);
end Behavioral;      
