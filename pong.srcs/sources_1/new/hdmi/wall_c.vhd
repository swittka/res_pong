----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/15/2016 01:09:03 PM
-- Design Name: 
-- Module Name: wall_c - Behavioral
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

entity wall_c is
    Port ( clk     : in  STD_LOGIC;
           res_n   : in  STD_LOGIC;
           x_coord : in  STD_LOGIC_VECTOR (9 downto 0);
           y_coord : in  STD_LOGIC_VECTOR (8 downto 0);
           sel     : out STD_LOGIC;
           rgb     : out color_t);
end wall_c;

architecture Behavioral of wall_c is

begin
  rgb_p : process(clk, res_n)
  begin
  if(res_n = '0') then
    sel <= '0';
  elsif(rising_edge(clk)) then
    if(((to_integer(unsigned(x_coord)) >= 0) and (to_integer(unsigned(x_coord)) < WINDOW_WIDTH)
        and (to_integer(unsigned(y_coord)) >= 0) and (to_integer(unsigned(y_coord)) < WALL_THICKNESS))
        or ((to_integer(unsigned(x_coord)) >= 0) and (to_integer(unsigned(x_coord)) < WINDOW_WIDTH)
        and (to_integer(unsigned(y_coord)) >= (WINDOW_HIGHT - WALL_THICKNESS)) and (to_integer(unsigned(y_coord)) < WINDOW_HIGHT))) then
      sel <= '1';
    else
      sel <= '0';
    end if;
  
  
--    if((to_integer(unsigned(x_coord)) > WALL_THICKNESS) and (to_integer(unsigned(x_coord)) < WINDOW_WIDTH - WALL_THICKNESS)
--        and (to_integer(unsigned(y_coord)) > WALL_THICKNESS) and (to_integer(unsigned(y_coord)) < WINDOW_HIGHT - WALL_THICKNESS)) then
--      sel <= '0';
--    else
--      sel <= '1';
--    end if;
  end if;
  end process;
  rgb <= WHITE;

end Behavioral;
