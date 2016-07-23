----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/15/2016 02:24:43 PM
-- Design Name: 
-- Module Name: paddle_c - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity paddle_c is
    Generic (X_POS : natural; SPEED_COUNTER_MAX : natural);
    Port ( clk      : in  STD_LOGIC;
           res_n    : in  STD_LOGIC;
           enb      : in  STD_LOGIC;
           btn_up   : in  STD_LOGIC;
           btn_down : in  STD_LOGIC;
           x_coord  : in  STD_LOGIC_VECTOR (9 downto 0);
           y_coord  : in  STD_LOGIC_VECTOR (8 downto 0);
           y_pos    : out STD_LOGIC_VECTOR (8 downto 0);
           sel      : out STD_LOGIC;
           rgb      : out color_t);
end paddle_c;

architecture Behavioral of paddle_c is
signal paddle_pos_tmp : natural range 0 to WINDOW_HIGHT - PADDLE_HIGHT - 1 := PADDLE_RESET_POS_Y;
signal paddle_speed_counter : natural range 0 to SPEED_COUNTER_MAX - 1 := 0;
begin
  rgb_p : process(clk, res_n)
  begin
    if(res_n = '0') then
      sel <= '0';
    elsif(rising_edge(clk)) then
      if((to_integer(unsigned(x_coord)) > X_POS) and (to_integer(unsigned(x_coord)) < (X_POS + PADDLE_WIDTH))
        and (to_integer(unsigned(y_coord)) > paddle_pos_tmp) and (to_integer(unsigned(y_coord)) < (paddle_pos_tmp + PADDLE_HIGHT))) then
        sel <= '1';
      else
        sel <= '0';
      end if;
    end if;
  end process;

  movement_p : process(clk, res_n)
  begin
    if (res_n = '0') then
      paddle_pos_tmp <= PADDLE_RESET_POS_Y;
      paddle_speed_counter <= 0;
    elsif (rising_edge(clk)) then
      if (enb = '1') then -- paddle movement module is enabled
        if ((btn_up = '1') and (btn_down = '0')) then -- only btn up is pressed
          -- dividing clk so the paddle moves with the right speed
          if (paddle_speed_counter < SPEED_COUNTER_MAX - 1) then
            paddle_speed_counter <= paddle_speed_counter + 1;
          else
            paddle_speed_counter <= 0;
          end if;
          -- move paddle up if it is not at the top edge
          if ((paddle_pos_tmp >= WALL_THICKNESS) and (paddle_speed_counter = 0)) then
            paddle_pos_tmp <= paddle_pos_tmp - 1;
          end if;
        elsif ((btn_down = '1') and (btn_up = '0')) then -- only btn down is pressed
          -- dividing clk so the paddle moves with the right speed
          if (paddle_speed_counter < SPEED_COUNTER_MAX - 1) then
            paddle_speed_counter <= paddle_speed_counter + 1;
          else
            paddle_speed_counter <= 0;
          end if;
          -- move paddle down if it is not at the bottom edge
          if ((paddle_pos_tmp < WINDOW_HIGHT - PADDLE_HIGHT - WALL_THICKNESS) and (paddle_speed_counter = 0)) then
            paddle_pos_tmp <= paddle_pos_tmp + 1;
          end if;
        else -- no btn pressed / both btns pressed
          paddle_speed_counter <= 0;
        end if;
      else -- paddle movement module is disabled
        paddle_pos_tmp <= PADDLE_RESET_POS_Y;
      end if;
    end if;
  end process;
  -- output
  rgb <= WHITE;
  y_pos <= STD_LOGIC_VECTOR(to_unsigned(paddle_pos_tmp, y_pos'length));


end Behavioral;
