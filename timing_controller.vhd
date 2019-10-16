-------------------------------------------------------------------------------------------------------------------------------------------------------
-- Author: Lucas Lui Motta 					@Copyright Unicamp, 2019
-- 													
-- Begin Date: 08/10/2019
--
-- Revision History:  	Date 		  	  Author 			Comments
--  						 	08/10/2019    L. L. Motta 		Created=
-------------------------------------------------------------------------------------------------------------------------------------------------------
-- Purpose:
-- This entity/architecture pair does the timing controlller over filters with different sampling-rates.
-------------------------------------------------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity timing_controller is
	port( reset            : in    std_logic; 
			clk              : in    std_logic;
			clk_enable       : in    std_logic;					  
			enable_div0      : out   std_logic;
			enable_div128    : out   std_logic;
			enable_div2048   : out   std_logic);
end timing_controller;


architecture rtl of timing_controller is

  signal counter_128  : unsigned(6 downto 0) := to_unsigned(1, 7);
  signal counter_2048 : unsigned(10 downto 0) := to_unsigned(1, 11);  
  signal phase_0      : std_logic;
  signal phase_1      : std_logic;
  signal phase_2      : std_logic;
  signal phase_1_tmp  : std_logic;
  signal phase_2_tmp  : std_logic;

begin
 
	proc_counter_128 : process(clk, reset)
	begin
	 if reset = '1' then
		counter_128 <= to_unsigned(1, 7);
	 elsif clk'event and clk = '1' then
		if clk_enable = '1' then
		  if counter_128 >= to_unsigned(127, 7) then
			 counter_128 <= to_unsigned(0, 7);
		  else
			 counter_128 <= counter_128 + to_unsigned(1, 7);
		  end if;
		end if;
	 end if; 
	end process proc_counter_128;
	
	proc_counter_2048 : process(clk, reset)
	begin
	 if reset = '1' then
		counter_2048 <= to_unsigned(1, 11);
	 elsif clk'event and clk = '1' then
		if clk_enable = '1' then
		  if counter_2048 >= to_unsigned(2047, 11) then
			 counter_2048 <= to_unsigned(0, 11);
		  else
			 counter_2048 <= counter_2048 + to_unsigned(1, 11);
		  end if;
		end if;
	 end if; 
	end process proc_counter_2048;
	
	phase_1_tmp <= '1' when counter_128 = to_unsigned(0, 7) and clk_enable = '1' else '0';
	
	proc_temp_result_1 : process(clk, reset)
	begin
	 if reset = '1' then
		phase_1 <= '1';
	 elsif clk'event and clk = '1' then
		if clk_enable = '1' then
		  phase_1 <= phase_1_tmp;
		end if;
	 end if; 
	end process proc_temp_result_1;
	
	phase_2_tmp <= '1' when counter_2048 = to_unsigned(0, 11) and clk_enable = '1' else '0';
	
	proc_temp_result_2 : process(clk, reset)
	begin
	 if reset = '1' then
		phase_2 <= '1';
	 elsif clk'event and clk = '1' then
		if clk_enable = '1' then
		  phase_2 <= phase_2_tmp;
		end if;
	 end if; 
	end process proc_temp_result_2;
	
	phase_0 <= '1' when clk_enable = '1' else '0';
	
	enable_div0 	<=  phase_0 and clk_enable;
	enable_div128  <=  phase_1 and clk_enable;
	enable_div2048 <=  phase_2 and clk_enable;

end rtl;

