-------------------------------------------------------------------------------------------------------------------------------------------------------
-- Author: Lucas Lui Motta 					@Copyright Unicamp, 2019
-- 													
-- Begin Date: 08/10/2019
--
-- Revision History:  	Date 		  	  Author 			Comments
--  						 	08/10/2019    L. L. Motta 		Created
-------------------------------------------------------------------------------------------------------------------------------------------------------
-- Purpose:
-- This entity/architecture pair is the CIC filter implementation (Recursive Form) of our Digital Up-Converter
-------------------------------------------------------------------------------------------------------------------------------------------------------

library ieee,work;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.general_setting.all;

entity cic_recursive is
   port(	reset    		: in  std_logic;
			clk    		   : in  std_logic;
			enable_div0    : in  std_logic;
			enable_div128  : in  std_logic;
			i_data   		: in  std_logic_vector(data_wl-1 downto 0);
			o_data   		: out std_logic_vector(data_wl-1 downto 0));
end cic_recursive;


architecture rtl of cic_recursive is

  constant zeroconst : signed(17 downto 0) := to_signed(0, 18); 
  
  signal data_in     : signed(data_wl-1 downto 0);
  
  signal r_add_1     : signed(16 downto 0); -- section 1 signals
  signal r_delay_1   : signed(15 downto 0);  
  signal r_add_2     : signed(17 downto 0); -- section 2 signals
  signal r_delay_2   : signed(16 downto 0);   
  signal r_add_3     : signed(18 downto 0); -- section 3 signals
  signal r_delay_3   : signed(17 downto 0);
  
  signal upsampling  : signed(17 downto 0);  
      
  signal r_int_1     : signed(17 downto 0); -- section 4 signals
  signal sum_1       : signed(17 downto 0);   
  signal r_int_2     : signed(23 downto 0); -- section 5 signals
  signal sum_2       : signed(23 downto 0);
  signal r_int_3     : signed(29 downto 0); -- section 6 signals 
  signal sum_3       : signed(29 downto 0);
	
 signal output_typeconvert : signed(data_wl-1 downto 0);
  
begin
  
  ---------------------- section # 1 : comb ------------------

  data_in <= signed(i_data);
	
  r_add_1 <= resize(data_in, 17) - resize(r_delay_1, 17);
  
  comb_section_1 : process(clk, reset)
  begin
    if reset = '0' then
      r_delay_1 <= (others => '0');		
    elsif rising_edge(clk) then
      if enable_div128 = '1' then		  
        r_delay_1 <= data_in;		  
      end if;
    end if; 
  end process comb_section_1;

  ---------------------- section # 2 : comb ------------------
	
  r_add_2 <= resize(r_add_1, 18) - resize(r_delay_2, 18);
  
  comb_section_2 : process(clk, reset)
  begin
    if reset = '0' then
      r_delay_2 <= (others => '0');
    elsif rising_edge(clk) then
      if enable_div128 = '1' then		  
        r_delay_2 <= r_add_1;
      end if;
    end if; 
  end process comb_section_2;

  ---------------------- section # 3 : comb ------------------

  r_add_3 <= resize(r_add_2, 19) - resize(r_delay_3, 19);

  comb_section_3 : process(clk, reset)
  begin
    if reset = '0' then
      r_delay_3 <= (others => '0');
    elsif rising_edge(clk) then
      if enable_div128 = '1' then		  
        r_delay_3 <= r_add_2;
      end if;
    end if; 
  end process comb_section_3;

  upsampling <= r_add_3(18 downto 1) when enable_div128 = '1' else zeroconst;
  
  ---------------------- section # 4 : integrator ------------------

  sum_1 <= resize(upsampling, 18) + resize(r_int_1, 18);

  int_section_1 : process(clk, reset)
  begin
    if reset = '0' then
      r_int_1 <= (others => '0');
    elsif rising_edge(clk) then
      if enable_div0 = '1' then
        r_int_1 <= sum_1;
      end if;
    end if; 
  end process int_section_1;

  ---------------------- section # 5 : integrator ------------------

  sum_2 <= resize(r_int_1, 24) + resize(r_int_2, 24);

  int_section_2 : process(clk, reset)
  begin
    if reset = '0' then
      r_int_2 <= (others => '0');
    elsif rising_edge(clk) then
      if enable_div0 = '1' then
        r_int_2 <= sum_2;
      end if;
    end if; 
  end process int_section_2;


  ---------------------- section # 6 : integrator ------------------

  sum_3 <= resize(r_int_2, 30) + resize(r_int_3, 30);

  int_section_3 : process(clk, reset)
  begin
    if reset = '0' then
      r_int_3 <= (others => '0');
    elsif rising_edge(clk) then
      if enable_div0 = '1' then
        r_int_3 <= sum_3;
      end if;
    end if; 
  end process int_section_3;
	
  output_typeconvert <= r_int_3(29 downto 14);
  
  o_data <= std_logic_vector(output_typeconvert);
  
end rtl;
