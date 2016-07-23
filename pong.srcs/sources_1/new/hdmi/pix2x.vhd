----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:08:25 01/17/2014 
-- Design Name: 
-- Module Name:    pix2x - Behavioral 
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity pix2x is
    PORT(
         datain : IN  std_logic_vector(29 downto 0);
         dataout : OUT  std_logic_vector(14 downto 0);
         CLK : IN  std_logic;
         CLKx2 : IN  std_logic;
			rst : in std_logic
		);
end pix2x;

architecture Behavioral of pix2x is

	signal toggle: std_logic;
	signal DATA_in_r : std_logic_vector(29 downto 0);
	signal DATA_in_r0 : std_logic_vector(29 downto 0);
	signal DATA_OUT_r0 : std_logic_vector(14 downto 0);
	signal DATA_OUT_r1 : std_logic_vector(14 downto 0);
	signal DATA_OUT_r2 : std_logic_vector(14 downto 0);

begin

	-- input register, slow clock
	process
	begin
		wait until rising_edge(clk);
		DATA_in_r0 <= datain;
		DATA_in_r <= DATA_in_r0;
	end process;

	-- phase toggle, fast clock
	process
	begin
		wait until rising_edge(clkx2);
		if rst = '1' then
			toggle <= '0';
		else
			toggle <= not toggle;
		end if;
	end process;

	-- output register, fast clock
	process
	begin
		wait until rising_edge(clkx2);
		if toggle = '0' then 
			data_out_r0 <= data_in_r(14 downto 0);
		else
			data_out_r0 <= data_in_r(29 downto 15);
		end if;
		-- pipeline
		data_out_r1 <= data_out_r0;
		data_out_r2 <= data_out_r1;
		dataout <= data_out_r2;
	end process;

end Behavioral;

