----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Felix Kaiser
-- 
-- Create Date:    16:10:09 07/19/2016 
-- Design Name: 
-- Module Name:    hdmi_red - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.defines.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity hdmi_red is
    Port ( clkfx		 	: in  std_logic;
			  RSTBTN  	: in  std_logic;
			  rgb_wire 	: in color_t;
			  pclk		: out std_logic;
			  pclk_lckd	: in std_logic;
           TMDS 		: out	std_logic_vector(3 downto 0);
           TMDSB 		: out	std_logic_vector(3 downto 0);
			  x_coord 	: out	std_logic_vector(9 downto 0);
			  y_coord 	: out	std_logic_vector(8 downto 0));
end hdmi_red;

architecture Behavioral of hdmi_red is

	component hdmiTx720p
	port(
		RSTBTN 	: in std_logic; -- high active !

		-- clk 	: in std_logic;

		-- timing + data
		clkfx		: in 	std_logic;
		pclk 		: out std_logic;
		pclk_lckd	: in std_logic;

		reset		: out std_logic;	
		bgnd_hcount : out	std_logic_vector(10 downto 0); 
		bgnd_vcount : out	std_logic_vector(10 downto 0); 
		red_data : in	std_logic_vector(7 downto 0); 
		blue_data : in	std_logic_vector(7 downto 0); 
		green_data : in	std_logic_vector(7 downto 0); 
		
		TMDS : out	std_logic_vector(3 downto 0); 
		TMDSB : out	std_logic_vector(3 downto 0)
	);
	end component;

	
	signal reset			: std_logic; --out
	signal bgnd_hcount 	: std_logic_vector(10 downto 0); --out
	signal bgnd_vcount 	: std_logic_vector(10 downto 0); --out
	signal red_data		: std_logic_vector(7 downto 0) := "00000000"; --in
	signal blue_data		: std_logic_vector(7 downto 0) := "00000000"; --in
	signal green_data		: std_logic_vector(7 downto 0) := "00000000"; --in
	--signal clkfx			: std_logic := '0';
	--signal pclk_lckd		: std_logic := '0'; 
	--signal p_count	 	: std_logic_vector(17 downto 0):= "000000000000000000";
	
begin

	red_data <= rgb_wire(RED);
	green_data <= rgb_wire(GREEN);
	blue_data<= rgb_wire(BLUE);
	x_coord	<= bgnd_hcount(9 downto 0);
	y_coord	<= bgnd_vcount(8 downto 0);

	hdmiTxInterface : hdmiTx720p
	port map (
		RSTBTN 	=> RSTBTN, -- high active !

		--clk 	=> clk,

		-- timing + data
		clkfx			=> clkfx,
		pclk 			=> pclk,
		pclk_lckd	=> pclk_lckd,
		reset			=> reset,
		bgnd_hcount => bgnd_hcount,
		bgnd_vcount => bgnd_vcount,
		red_data 	=> red_data,
		blue_data 	=> blue_data,
		green_data 	=> green_data,
		
		TMDS 			=> TMDS,
		TMDSB 		=> TMDSB
	);


end Behavioral;

