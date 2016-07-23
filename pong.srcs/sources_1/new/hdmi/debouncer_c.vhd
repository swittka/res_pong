----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/09/2016 10:09:57 AM
-- Design Name: 
-- Module Name: debouncer_c - Behavioral
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

entity debouncer_c is
  Port (clk     : in  STD_LOGIC;
        res_n   : in  STD_LOGIC;
        btn     : in  STD_LOGIC;
        deb_btn : out STD_LOGIC);
end debouncer_c;

architecture Behavioral of debouncer_c is
signal prev_btn : STD_LOGIC := '0';
signal deb_counter : natural range 0 to DEBOUNCER_COUNTER_MAX := 0;
begin
  seq : process(res_n, clk)
  begin
    if(res_n = '0') then
      deb_btn <= '0';
      prev_btn <= '0';
      deb_counter <= 0;
    elsif(rising_edge(clk)) then
      prev_btn <= btn;
      if(prev_btn = btn) then
        if(deb_counter < DEBOUNCER_COUNTER_MAX - 1) then
          deb_counter <= deb_counter + 1;
        else
          deb_btn <= btn;
        end if;
      else
        deb_counter <= 0;
      end if;
    end if;
  end process;
end Behavioral;
