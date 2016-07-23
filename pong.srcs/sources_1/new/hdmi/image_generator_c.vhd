----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/08/2016 09:03:25 AM
-- Design Name: 
-- Module Name: image_generator_c - Behavioral
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
use work.defines.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity image_generator_c is
    Port ( clk           : in  STD_LOGIC;
           res_n         : in  STD_LOGIC;
           btn_up        : in  STD_LOGIC;
           btn_down      : in  STD_LOGIC;
           x_coord       : in  STD_LOGIC_VECTOR (9 downto 0);
           y_coord       : in  STD_LOGIC_VECTOR (8 downto 0);
           enb           : in  STD_LOGIC;
           l_scored      : in  STD_LOGIC;
           r_scored      : in  STD_LOGIC;
           l_paddle_hit  : in  STD_LOGIC;
           r_paddle_hit  : in  STD_LOGIC;
           rgb           : out color_t;
           y_paddle_left : out STD_LOGIC_VECTOR (8 downto 0);
           y_paddle_right: out STD_LOGIC_VECTOR (8 downto 0);
           x_ball        : out STD_LOGIC_VECTOR (9 downto 0);
           y_ball        : out STD_LOGIC_VECTOR (8 downto 0));
end image_generator_c;

architecture Behavioral of image_generator_c is
component ball_c
  Port ( clk     : in  STD_LOGIC;
         res_n   : in  STD_LOGIC;
         enb     : in  STD_LOGIC;
         x_coord : in  STD_LOGIC_VECTOR (9 downto 0);
         y_coord : in  STD_LOGIC_VECTOR (8 downto 0);
         x_pos   : out STD_LOGIC_VECTOR (9 downto 0);
         y_pos   : out STD_LOGIC_VECTOR (8 downto 0);
         sel     : out STD_LOGIC;
         rgb     : out color_t);
end component;

component paddle_c
  generic (X_POS : natural; SPEED_COUNTER_MAX : natural);
  Port ( clk      : in  STD_LOGIC;
         res_n    : in  STD_LOGIC;
         enb      : in  STD_LOGIC;
         btn_up   : in  STD_LOGIC;
         btn_down : in  STD_LOGIC;
         x_coord  : in  STD_LOGIC_VECTOR;
         y_coord  : in  STD_LOGIC_VECTOR;
         y_pos    : out STD_LOGIC_VECTOR(8 downto 0);
         sel      : out STD_LOGIC;
         rgb      : out color_t);
end component;

component wall_c
  Port ( clk     : in  STD_LOGIC;
         res_n   : in  STD_LOGIC;
         x_coord : in  STD_LOGIC_VECTOR(9 downto 0);
         y_coord : in  STD_LOGIC_VECTOR(8 downto 0);
         sel     : out STD_LOGIC;
         rgb     : out color_t);
end component;

signal ball_sel_wire     : STD_LOGIC;
signal ball_rgb_wire     : color_t;
signal wall_sel_wire     : STD_LOGIC;
signal wall_rgb_wire     : color_t;
signal l_paddle_sel_wire : STD_LOGIC;
signal l_paddle_rgb_wire : color_t;
signal r_paddle_sel_wire : STD_LOGIC;
signal r_paddle_rgb_wire : color_t;
signal mux_sel_wire      : STD_LOGIC_VECTOR (3 downto 0);
begin

  ball_I: ball_c
  port map (
    clk     => clk,
    res_n   => res_n,
    enb     => enb,
    x_coord => x_coord,
    y_coord => y_coord,
    x_pos   => x_ball,
    y_pos   => y_ball,
    sel     => ball_sel_wire,
    rgb     => ball_rgb_wire
  );
  
  l_paddle_I: paddle_c
  generic map (L_PADDLE_POS_X, L_PADDLE_SPEED_COUNTER_MAX)
  port map (
    clk      => clk,
    res_n    => res_n,
    enb      => enb,
    btn_up   => btn_up,
    btn_down => btn_down,
    x_coord  => x_coord,
    y_coord  => y_coord,
    y_pos    => y_paddle_left,
    sel      => l_paddle_sel_wire,
    rgb      => l_paddle_rgb_wire
  );
  
  r_paddle_I: paddle_c
  generic map (R_PADDLE_POS_X, R_PADDLE_SPEED_COUNTER_MAX)
  port map (
    clk      => clk,
    res_n    => res_n,
    enb      => enb,
    btn_up   => btn_up,
    btn_down => btn_down,
    x_coord  => x_coord,
    y_coord  => y_coord,
    y_pos    => y_paddle_right,
    sel      => r_paddle_sel_wire,
    rgb      => r_paddle_rgb_wire
  );

  wall_I: wall_c
  port map (
    clk     => clk,
    res_n   => res_n,
    x_coord => x_coord,
    y_coord => y_coord,
    sel     => wall_sel_wire,
    rgb     => wall_rgb_wire
  );

  mux_sel_wire <= wall_sel_wire & ball_sel_wire & l_paddle_sel_wire & r_paddle_sel_wire;

  mux : process(mux_sel_wire, wall_rgb_wire, ball_rgb_wire, l_paddle_rgb_wire, r_paddle_rgb_wire)
  begin
    case mux_sel_wire is
      when "1000" => rgb <= wall_rgb_wire;
      when "1001" => rgb <= wall_rgb_wire;
      when "1010" => rgb <= wall_rgb_wire;
      when "1011" => rgb <= wall_rgb_wire;
      when "1100" => rgb <= wall_rgb_wire;
      when "1101" => rgb <= wall_rgb_wire;
      when "1110" => rgb <= wall_rgb_wire;
      when "1111" => rgb <= wall_rgb_wire;
      when "0100" => rgb <= ball_rgb_wire;
      when "0101" => rgb <= ball_rgb_wire;
      when "0110" => rgb <= ball_rgb_wire;
      when "0111" => rgb <= ball_rgb_wire;
      when "0010" => rgb <= l_paddle_rgb_wire;
      when "0011" => rgb <= l_paddle_rgb_wire;
      when "0001" => rgb <= r_paddle_rgb_wire;
      when others => rgb <= BLACK;
    end case;
  end process;
end Behavioral;
