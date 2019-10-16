-------------------------------------------------------------------------------------------------------------------------------------------------------
-- Author: Lucas Lui Motta 					@Copyright Unicamp, 2019
-- 													
-- Begin Date: 08/10/2019
--
-- Revision History:  	Date 		  	  Author 			Comments
--  						 	08/10/2019    L. L. Motta 		Created
-------------------------------------------------------------------------------------------------------------------------------------------------------
-- Purpose:
-- This entity/architecture pair is the CIC filter implementation (Polyphase Form) of our Digital Up-Converter
-------------------------------------------------------------------------------------------------------------------------------------------------------

library ieee,work;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.general_setting.all;

entity cic_polyphase is
	port(	reset    		: in  std_logic;
			clk    		   : in  std_logic;
			enable_div0    : in  std_logic;
			i_data   		: in  std_logic_vector(data_wl-1 downto 0);
			o_data_1   		: out std_logic_vector(data_wl-1 downto 0);
			o_data_2   		: out std_logic_vector(data_wl-1 downto 0);
			o_data_3   		: out std_logic_vector(data_wl-1 downto 0);
			o_data_4   		: out std_logic_vector(data_wl-1 downto 0));
end cic_polyphase;

architecture rtl of cic_polyphase is

	type t_data_delay is array (0 to cic_taps-1) of signed(data_wl-1 downto 0);
	type t_coeff      is array (0 to cic_taps-1) of signed(coeff_wl-1 downto 0);
	type t_mult       is array (0 to cic_taps-1) of signed((coeff_wl+data_wl)-1 downto 0);
	type t_add_stg0   is array (0 to 1)  of signed((coeff_wl+data_wl) downto 0);
	
	constant coeffphase1 : t_coeff := (to_signed(2545, coeff_wl),to_signed(7452, coeff_wl),to_signed(5213, coeff_wl));
	constant coeffphase2 : t_coeff := (to_signed(3232, coeff_wl),to_signed(3521, coeff_wl),to_signed(1678, coeff_wl));
	constant coeffphase3 : t_coeff := (to_signed(2231, coeff_wl),to_signed(2235, coeff_wl),to_signed(3686, coeff_wl));
	constant coeffphase4 : t_coeff := (to_signed(4313, coeff_wl),to_signed(1231, coeff_wl),to_signed(2788, coeff_wl));
	
	signal p_data       		    : t_data_delay;
	signal r_mult_1       	    : t_mult;
	signal r_mult_2       	    : t_mult;
	signal r_mult_3       	    : t_mult;
	signal r_mult_4       	    : t_mult;
	signal r_add_stg0_1         : t_add_stg0;
	signal r_add_stg0_2         : t_add_stg0;
	signal r_add_stg0_3         : t_add_stg0;
	signal r_add_stg0_4         : t_add_stg0;
	signal r_add_stg1_1         : signed((coeff_wl+data_wl)+1 downto 0);
	signal r_add_stg1_2         : signed((coeff_wl+data_wl)+1 downto 0);
	signal r_add_stg1_3         : signed((coeff_wl+data_wl)+1 downto 0);
	signal r_add_stg1_4         : signed((coeff_wl+data_wl)+1 downto 0);
	signal output_typeconvert_1 : std_logic_vector(data_wl-1 downto 0);
	signal output_typeconvert_2 : std_logic_vector(data_wl-1 downto 0);
	signal output_typeconvert_3 : std_logic_vector(data_wl-1 downto 0);
	signal output_typeconvert_4 : std_logic_vector(data_wl-1 downto 0);

begin
	
	---------------------------------------------------------------------------
	-- This process pipeline the inputs
	---------------------------------------------------------------------------
	proc_input : process(clk, reset)
	begin
	  if reset = '0' then
		 p_data  <= (others=>(others=>'0'));
	  elsif rising_edge(clk) then
		  if enable_div0 = '1' then
			 p_data <= signed(i_data) & p_data(0 to p_data'length-2);
	     end if;
	  end if;
	end process proc_input;
	
	---------------------------------------------------------------------------
	-- This process multiply the input and current branch coefficients
	---------------------------------------------------------------------------
	
	proc_mult : process(clk, reset)
	begin
	  if reset = '0' then
		 r_mult_1 <= (others=>(others=>'0'));
		 r_mult_2 <= (others=>(others=>'0'));
		 r_mult_3 <= (others=>(others=>'0'));
		 r_mult_4 <= (others=>(others=>'0'));
	  elsif rising_edge(clk) then
		 if enable_div0 = '1' then
			for k in 0 to cic_taps-1 loop
			   r_mult_1(k) <= p_data(k) * coeffphase1(k);
				r_mult_2(k) <= p_data(k) * coeffphase2(k);
				r_mult_3(k) <= p_data(k) * coeffphase3(k);
				r_mult_4(k) <= p_data(k) * coeffphase4(k);
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
		 r_add_stg0_1 <= (others=>(others=>'0'));
		 r_add_stg0_2 <= (others=>(others=>'0'));
		 r_add_stg0_3 <= (others=>(others=>'0'));
		 r_add_stg0_4 <= (others=>(others=>'0'));
	  elsif rising_edge(clk) then
	    if enable_div0 = '1' then
			r_add_stg0_1(0) <= resize(r_mult_1(0),33)  + resize(r_mult_1(1),33);
			r_add_stg0_2(0) <= resize(r_mult_2(0),33)  + resize(r_mult_2(1),33);
			r_add_stg0_3(0) <= resize(r_mult_3(0),33)  + resize(r_mult_3(1),33);
			r_add_stg0_4(0) <= resize(r_mult_4(0),33)  + resize(r_mult_4(1),33);
			r_add_stg0_1(1) <= resize(r_mult_1(2),33);
			r_add_stg0_2(1) <= resize(r_mult_2(2),33);
			r_add_stg0_3(1) <= resize(r_mult_3(2),33);
			r_add_stg0_4(1) <= resize(r_mult_4(2),33);
		 end if;	
	  end if;
	end process proc_add_stg0;
	
	proc_add_stg1 : process(clk, reset)
	begin
	  if reset = '0' then
		 r_add_stg1_1 <= (others=>'0');
		 r_add_stg1_2 <= (others=>'0');
		 r_add_stg1_3 <= (others=>'0');
		 r_add_stg1_4 <= (others=>'0');
	  elsif rising_edge(clk) then
	    if enable_div0 = '1' then
			r_add_stg1_1 <= resize(r_add_stg0_1(0),34)  + resize(r_add_stg0_1(1),34);
			r_add_stg1_2 <= resize(r_add_stg0_2(0),34)  + resize(r_add_stg0_2(1),34);
			r_add_stg1_3 <= resize(r_add_stg0_3(0),34)  + resize(r_add_stg0_3(1),34);
			r_add_stg1_4 <= resize(r_add_stg0_4(0),34)  + resize(r_add_stg0_4(1),34);
		 end if;	
	  end if;
	end process proc_add_stg1;
	
	output_typeconvert_1 <= std_logic_vector(r_add_stg1_1(33 downto 18));
	output_typeconvert_2 <= std_logic_vector(r_add_stg1_2(33 downto 18));
	output_typeconvert_3 <= std_logic_vector(r_add_stg1_3(33 downto 18));
	output_typeconvert_4 <= std_logic_vector(r_add_stg1_4(33 downto 18));
	
	o_data_1 <= output_typeconvert_1;
	o_data_2 <= output_typeconvert_2;
	o_data_3 <= output_typeconvert_3;
	o_data_4 <= output_typeconvert_4;

end rtl;

