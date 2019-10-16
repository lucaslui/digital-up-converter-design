-------------------------------------------------------------------------------------------------------------------------------------------------------
-- Author: Lucas Lui Motta 					@Copyright Unicamp, 2019
-- 													
-- Begin Date: 08/10/2019
--
-- Revision History:  	Date 		  	  Author 			Comments
--  						 	08/10/2019    L. L. Motta 		Created
-------------------------------------------------------------------------------------------------------------------------------------------------------
-- Purpose:
-- This entity/architecture pair is the FIR polyphase filter implementation (of our Digital Up-Converter
-------------------------------------------------------------------------------------------------------------------------------------------------------

library ieee,work;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.general_setting.all;

entity fir_mask_comp is
	port(	reset    		: in  std_logic;
			clk    		   : in  std_logic;
			enable_div2048 : in  std_logic;
			i_coeff_1 		: in  t_coeff_vect(0 to fir_taps-1);
			i_coeff_2 		: in  t_coeff_vect(0 to fir_taps-1);
			i_data   		: in  std_logic_vector(adc_wl-1 downto 0);
			o_data   		: out std_logic_vector(data_wl-1 downto 0));
end fir_mask_comp;

architecture rtl of fir_mask_comp is

	type t_data_delay is array (0 to fir_taps-1) of signed(adc_wl-1 downto 0);
	type t_coeff      is array (0 to fir_taps-1) of signed(coeff_wl-1 downto 0);
	type t_mult       is array (0 to fir_taps-1) of signed((coeff_wl+adc_wl)-1 downto 0);
	type t_add_stg0   is array (0 to 52) of signed((coeff_wl+adc_wl) downto 0);
	type t_add_stg1   is array (0 to 26) of signed((coeff_wl+adc_wl)+1 downto 0);		
	type t_add_stg2   is array (0 to 13) of signed((coeff_wl+adc_wl)+2 downto 0);
	type t_add_stg3   is array (0 to 6)  of signed((coeff_wl+adc_wl)+3 downto 0);
	type t_add_stg4   is array (0 to 3)  of signed((coeff_wl+adc_wl)+4 downto 0);
	type t_add_stg5   is array (0 to 1)  of signed((coeff_wl+adc_wl)+5 downto 0);

	signal sel 			  		  : std_logic := '0';
	signal delay_inc 	  		  : std_logic := '0';
	signal p_data       		  : t_data_delay;
	signal s_coeff      		  : t_coeff;
	signal r_coeff_1    		  : t_coeff;	
   signal r_coeff_2          : t_coeff;
	signal r_mult       		  : t_mult;
	signal r_add_stg0         : t_add_stg0;
	signal r_add_stg1         : t_add_stg1;
	signal r_add_stg2         : t_add_stg2;
	signal r_add_stg3         : t_add_stg3;
	signal r_add_stg4         : t_add_stg4;
	signal r_add_stg5         : t_add_stg5;
	signal r_add_stg6         : signed((coeff_wl+adc_wl)+6 downto 0);
	signal output_typeconvert : std_logic_vector(data_wl-1 downto 0);

begin
	
	---------------------------------------------------------------------------
   -- This process is the multiplex of polyphase implementation
	---------------------------------------------------------------------------
	proc_mux : process(clk, reset)
	begin
	 if reset = '0' then
		sel <= '0';
	 elsif rising_edge(clk) then
		if enable_div2048 = '1' then
		  sel <= not sel;
		end if;
	 end if; 
	end process proc_mux;
	
	delay_inc <= '1' when sel = '0' and enable_div2048 = '1' else '0';

	---------------------------------------------------------------------------
	-- This process pipeline the inputs
	---------------------------------------------------------------------------
	proc_input : process(clk, reset)
	begin
	  if reset = '0' then
		 p_data  <= (others=>(others=>'0'));
		 r_coeff_1 <= (others=>(others=>'0'));
		 r_coeff_2 <= (others=>(others=>'0'));
	  elsif rising_edge(clk) then
		  if delay_inc = '1' then
			 p_data <= signed(i_data) & p_data(0 to p_data'length-2);
			 for k in 0 to (fir_taps-1) loop
				r_coeff_1(k)  <= signed(i_coeff_1(k));
			   r_coeff_2(k)  <= signed(i_coeff_2(k));
			 end loop;
	     end if;
	  end if;
	end process proc_input;
	
	s_coeff <= r_coeff_1 when sel = '0' else r_coeff_2;
								
	---------------------------------------------------------------------------
	-- This process multiply the input and current branch coefficients
	---------------------------------------------------------------------------
	proc_mult : process(clk, reset)
	begin
	  if reset = '0' then
		 r_mult <= (others=>(others=>'0'));
	  elsif rising_edge(clk) then
		 if enable_div2048 = '1' then
			for k in 0 to fir_taps-1 loop
			   r_mult(k) <= p_data(k) * s_coeff(k);
		   end loop;			
		 end if;
	  end if;
	end process proc_mult;
	
	---------------------------------------------------------------------------
   -- These processes sum all multiply results every two terms
	---------------------------------------------------------------------------
	proc_add_stg0 : process(clk, reset)
	begin
	  if reset = '0' then
		 r_add_stg0 <= (others=>(others=>'0'));
	  elsif rising_edge(clk) then
	    if enable_div2048 = '1' then
			for k in 0 to 52 loop	 
				r_add_stg0(k) <= resize(r_mult(2*k),29)  + resize(r_mult(2*k+1),29);
			end loop;	
		 end if;	
	  end if;
	end process proc_add_stg0;
	
	proc_add_stg1 : process(clk, reset)
	begin
	  if reset = '0' then
		 r_add_stg1 <= (others=>(others=>'0'));
	  elsif rising_edge(clk) then
	    if enable_div2048 = '1' then
			for k in 0 to 25 loop	 
				r_add_stg1(k) <= resize(r_add_stg0(2*k),30)  + resize(r_add_stg0(2*k+1),30);
			end loop;	
			r_add_stg1(26) <= resize(r_add_stg0(52),30);
		 end if;	
	  end if;
	end process proc_add_stg1;
	
	proc_add_stg2 : process(clk, reset)
	begin
	  if reset = '0' then
		 r_add_stg2 <= (others=>(others=>'0'));
	  elsif rising_edge(clk) then
	    if enable_div2048 = '1' then
			for k in 0 to 12 loop	 
				r_add_stg2(k) <= resize(r_add_stg1(2*k),31)  + resize(r_add_stg1(2*k+1),31);
			end loop;	
			r_add_stg2(13) <= resize(r_add_stg1(26),31);
		 end if;	
	  end if;
	end process proc_add_stg2;
	
	proc_add_stg3 : process(clk, reset)
	begin
	  if reset = '0' then
		 r_add_stg3 <= (others=>(others=>'0'));
	  elsif rising_edge(clk) then
	    if enable_div2048 = '1' then
			for k in 0 to 6 loop	 
				r_add_stg3(k) <= resize(r_add_stg2(2*k),32)  + resize(r_add_stg2(2*k+1),32);
			end loop;	
		 end if;	
	  end if;
	end process proc_add_stg3;
	
	proc_add_stg4 : process(clk, reset)
	begin
	  if reset = '0' then
		 r_add_stg4 <= (others=>(others=>'0'));
	  elsif rising_edge(clk) then
	    if enable_div2048 = '1' then
			for k in 0 to 2 loop	 
				r_add_stg4(k) <= resize(r_add_stg3(2*k),33)  + resize(r_add_stg3(2*k+1),33);
			end loop;	
			r_add_stg4(3) <= resize(r_add_stg3(6),33);
		 end if;	
	  end if;
	end process proc_add_stg4;
	
	proc_add_stg5 : process(clk, reset)
	begin
	  if reset = '0' then
		 r_add_stg5 <= (others=>(others=>'0'));
	  elsif rising_edge(clk) then
	    if enable_div2048 = '1' then
			for k in 0 to 1 loop	 
				r_add_stg5(k) <= resize(r_add_stg4(2*k),34)  + resize(r_add_stg4(2*k+1),34);
			end loop;	
		 end if;	
	  end if;
	end process proc_add_stg5;	
	

	proc_add_stg6 : process(clk, reset)
	begin
	  if reset = '0' then
		 r_add_stg6 <= (others=>'0');
	  elsif rising_edge(clk) then
	    if enable_div2048 = '1' then
			r_add_stg6 <= resize(r_add_stg5(0),35)  + resize(r_add_stg5(1),35);		
		 end if;		 
	  end if;
	end process proc_add_stg6;
	

	output_typeconvert <= std_logic_vector(r_add_stg6(34 downto 19));
	
	o_data <= output_typeconvert;

end rtl;

