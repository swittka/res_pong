----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/03/2016 01:35:47 PM
-- Design Name: 
-- Module Name: top_c - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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
use IEEE.NUMERIC_STD.ALL;
use work.defines.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top_hdmi is
  Port (
		  --SYS_CLK : in  STD_LOGIC;
		  --RSTBTN  : in  std_logic;
        SYS_CLK         : in  STD_LOGIC;
        --RSTBTN : in  STD_LOGIC;			RSTBTN disabled
        btnU        : in  STD_LOGIC;
        btnD        : in  STD_LOGIC;
		  
		  TMDS : out	std_logic_vector(3 downto 0);
        TMDSB : out	std_logic_vector(3 downto 0));
        --Hsync       : out STD_LOGIC;
        --Vsync       : out STD_LOGIC;
        --vgaRed      : out STD_LOGIC_VECTOR(3 downto 0);
        --vgaBlue     : out STD_LOGIC_VECTOR(3 downto 0);
        --vgaGreen    : out STD_LOGIC_VECTOR(3 downto 0));
end top_hdmi;

architecture Behavioral of top_hdmi is

  component debouncer_c
    Port (clk     : in  STD_LOGIC;
          res_n   : in  STD_LOGIC;
          btn     : in  STD_LOGIC;
          deb_btn : out STD_LOGIC);
  end component;

  component image_generator_c
    Port ( clk            : in  STD_LOGIC;
           res_n          : in  STD_LOGIC;
           btn_up         : in  STD_LOGIC;
           btn_down       : in  STD_LOGIC;
           x_coord        : in  STD_LOGIC_VECTOR (9 downto 0);
           y_coord        : in  STD_LOGIC_VECTOR (8 downto 0);
           enb            : in  STD_LOGIC;
           l_scored       : in  STD_LOGIC;
           r_scored       : in  STD_LOGIC;
           l_paddle_hit   : in  STD_LOGIC;
           r_paddle_hit   : in  STD_LOGIC;
           rgb            : out color_t;
           y_paddle_left  : out STD_LOGIC_VECTOR (8 downto 0);
           y_paddle_right : out STD_LOGIC_VECTOR (8 downto 0);
           x_ball         : out STD_LOGIC_VECTOR (9 downto 0);
           y_ball         : out STD_LOGIC_VECTOR (8 downto 0));
  end component;

--  component vga_controller_c
--  port (clk     : in  STD_LOGIC;
--        res_n   : in  STD_LOGIC;
--        h_sync  : out STD_LOGIC;
--        v_sync  : out STD_LOGIC;
--        x_coord : out STD_LOGIC_VECTOR(9 downto 0);
--        y_coord : out STD_LOGIC_VECTOR(8 downto 0));
--  end component;
  
	component clk_wiz_v3_6
	port
	(-- Clock in ports
		CLK_IN1           : in     std_logic;
		-- Clock out ports
		CLK_OUT1          : out    std_logic;
		CLK_OUT2          : out    std_logic;
		-- Status and control signals
		RESET             : in     std_logic;
		LOCKED            : out    std_logic
		);
	end component;


  
  component hdmi_red
  port (
			--clk 		: in  STD_LOGIC;
			clkfx		: in 	std_logic;
			RSTBTN  	: in  std_logic;
			rgb_wire : in color_t;
			pclk		: out	std_logic;
			pclk_lckd: in 	std_logic;
         TMDS 		: out	std_logic_vector(3 downto 0);
         TMDSB 	: out	std_logic_vector(3 downto 0);
			x_coord 	: out STD_LOGIC_VECTOR(9 downto 0);
			y_coord 	: out STD_LOGIC_VECTOR(8 downto 0));
  end component;
  
  
  
  
  signal x_coord_wire      : STD_LOGIC_VECTOR (9 downto 0);
  signal y_coord_wire      : STD_LOGIC_VECTOR (8 downto 0);
  signal rgb_wire          : color_t;
  signal btn_up_deb_wire   : STD_LOGIC;
  signal btn_down_deb_wire : STD_LOGIC;
  signal enb_wire          : STD_LOGIC;
  signal pclk					: STD_LOGIC;
  signal clkfx					: STD_LOGIC;
  signal clk					: STD_LOGIC;
  signal pclk_lckd			: STD_LOGIC;
begin

  btn_up_debouncer_I : debouncer_c
  port map (
    clk     => clkfx,
    res_n   => '1',		-- RSTBTN/reset disabled
    btn     => btnU,
    deb_btn => btn_up_deb_wire
  );
  
  btn_down_debouncer_I : debouncer_c
  port map (
    clk     => clkfx,
    res_n   => '1',		-- RSTBTN/reset disabled
    btn     => btnD,
    deb_btn => btn_down_deb_wire
  );
  
   clk_wiz_i : clk_wiz_v3_6
	port map
	(-- Clock in ports
		CLK_IN1 	=> SYS_CLK,
		-- Clock out ports
		CLK_OUT1 => clk,
		CLK_OUT2	=> clkfx,
		-- Status and control signals
		RESET		=> '0',		-- RSTBTN/reset disabled
		LOCKED	=> pclk_lckd
		);
	

  
--  GEN_HDMI: if HDMI = true generate
	 hdmi_red_I: hdmi_red
    port map (
      clkfx		=> clkfx,
      RSTBTN  	=> '0',		-- RSTBTN/reset disabled
      rgb_wire	=> rgb_wire,
		pclk 		=> pclk,
		pclk_lckd=> pclk_lckd,
      TMDS  	=> TMDS,
      TMDSB 	=> TMDSB,
		x_coord 	=> x_coord_wire,
		y_coord 	=> y_coord_wire
    );
--  end generate GEN_HDMI;

--  GEN_VGA: if HDMI = false generate
--    vga_controller_I: vga_controller_c
--    port map (
--      clk     => clk,
--      res_n   => btnCpuReset,
--      h_sync  => Hsync,
--      v_sync  => Vsync,
--      x_coord => x_coord_wire,
--      y_coord => y_coord_wire
--    );
--  end generate GEN_VGA;
  
  image_generator_I: image_generator_c
  port map (
    clk            => clkfx,
    res_n          => '1',		-- RSTBTN/reset disabled
    btn_up         => btn_up_deb_wire,
    btn_down       => btn_down_deb_wire,
    x_coord        => x_coord_wire,
    y_coord        => y_coord_wire,
    enb            => enb_wire,
    l_scored       => '0',
    r_scored       => '0',
    l_paddle_hit   => '0',
    r_paddle_hit   => '0',
    rgb            => rgb_wire,
    y_paddle_left  => open,
    y_paddle_right => open,
    x_ball         => open,
    y_ball         => open
  );
  
  color_test : process (clkfx) -- , RSTBTN
  begin
  --if (not RSTBTN = '0') then
  --  enb_wire <= '0';
  --els
  if rising_edge(clkfx) then
        enb_wire <= '1';
  end if;
  end process;
--  vgaRed   <= rgb_wire(RED);
--  vgaBlue  <= rgb_wire(BLUE);
--  vgaGreen <= rgb_wire(GREEN);
end Behavioral;
