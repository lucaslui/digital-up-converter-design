-------------------------------------------------------------------------------------------------------------------------------------------------------
-- Author: Lucas Lui Motta 					@Copyright Unicamp, 2019
-- 													
-- Begin Date: 08/10/2019
--
-- Revision History:  	Date 		  	  Author 			Comments
--  						 	08/10/2019    L. L. Motta 		Created=
-------------------------------------------------------------------------------------------------------------------------------------------------------
-- Purpose:
-- This entity/architecture pair is the top level unit of our Digital Up-Converter.
-------------------------------------------------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.general_setting.all;

entity duc_top_level is
	port( reset           : in  std_logic;
			clk             : in  std_logic;        
			clk_enable      : in  std_logic;
			i_coeff_1 		: in  t_coeff_vect(0 to fir_taps-1);
			i_coeff_2 		: in  t_coeff_vect(0 to fir_taps-1);
			i_data          : in  std_logic_vector(adc_wl-1 DOWNTO 0);
			o_data_branch_1 : out std_logic_vector(data_wl-1 DOWNTO 0);
			o_data_branch_2 : out std_logic_vector(data_wl-1 DOWNTO 0);
			o_data_branch_3 : out std_logic_vector(data_wl-1 DOWNTO 0);
			o_data_branch_4 : out std_logic_vector(data_wl-1 DOWNTO 0));
end duc_top_level;


architecture structure of duc_top_level is

  component timing_controller
	port( reset          : in  std_logic; 
			clk            : in  std_logic;
			clk_enable     : in  std_logic;					  
			enable_div0    : out std_logic;
			enable_div128  : out std_logic;
			enable_div2048 : out std_logic);
  end component;

  component fir_mask_comp
	port( reset          : in  std_logic; 
			clk            : in  std_logic;
			enable_div2048 : in  std_logic;
			i_coeff_1 		: in  t_coeff_vect(0 to fir_taps-1);
			i_coeff_2 		: in  t_coeff_vect(0 to fir_taps-1);
			i_data         : in  std_logic_vector(adc_wl-1 downto 0); 
			o_data         : out std_logic_vector(data_wl-1 downto 0));
	end component;

  component cic_recursive
    port( reset         : in  std_logic;
			 clk           : in  std_logic;
			 enable_div0   : in  std_logic;
          enable_div128 : in  std_logic;
          i_data        : in  std_logic_vector(data_wl-1 downto 0);  
          o_data        : out std_logic_vector(data_wl-1 downto 0));
  end component;

  component cic_polyphase
    port( reset       : in  std_logic;
			 clk         : in  std_logic;
          enable_div0 : in  std_logic;
          i_data      : in  std_logic_vector(data_wl-1 downto 0);  
          o_data_1    : out std_logic_vector(data_wl-1 downto 0);  
          o_data_2    : out std_logic_vector(data_wl-1 downto 0); 
          o_data_3    : out std_logic_vector(data_wl-1 downto 0);
          o_data_4    : out std_logic_vector(data_wl-1 downto 0));
  end component;

  signal enable_div0              : std_logic;
  signal enable_div128            : std_logic;
  signal enable_div2048           : std_logic;
  signal o_data_fir					 : std_logic_vector(data_wl-1 downto 0);
  signal o_data_cic_rec 			 : std_logic_vector(data_wl-1 downto 0);
  signal o_data_cic_poly_branch_1 : std_logic_vector(data_wl-1 downto 0);
  signal o_data_cic_poly_branch_2 : std_logic_vector(data_wl-1 downto 0);
  signal o_data_cic_poly_branch_3 : std_logic_vector(data_wl-1 downto 0);
  signal o_data_cic_poly_branch_4 : std_logic_vector(data_wl-1 downto 0);

begin

  inst_timing_controller : timing_controller
    port map( reset => reset,
				  clk => clk,              
              clk_enable => clk_enable,
              enable_div0 => enable_div0,
              enable_div128 => enable_div128,
              enable_div2048 => enable_div2048);

  inst_fir_mask_comp : fir_mask_comp
    port map( reset => reset,
	           clk => clk,
              enable_div2048 => enable_div2048, 
				  i_coeff_1 => i_coeff_1,
			     i_coeff_2 => i_coeff_2,
              i_data => i_data, 
              o_data => o_data_fir);

  inst_cic_recursive : cic_recursive
    port map( reset => reset,
              clk => clk,
				  enable_div0 => enable_div0,
              enable_div128 => enable_div128,
              i_data => o_data_fir,  
              o_data => o_data_cic_rec);

  inst_cic_polyphase : cic_polyphase
    port map( reset => reset,
              clk => clk,
              enable_div0 => enable_div0,
              i_data => o_data_cic_rec, 
              o_data_1 => o_data_cic_poly_branch_1,
              o_data_2 => o_data_cic_poly_branch_2, 
              o_data_3 => o_data_cic_poly_branch_3,
              o_data_4 => o_data_cic_poly_branch_4);

  o_data_branch_1 <= o_data_cic_poly_branch_1;
  o_data_branch_2 <= o_data_cic_poly_branch_2;
  o_data_branch_3 <= o_data_cic_poly_branch_3;
  o_data_branch_4 <= o_data_cic_poly_branch_4;

end structure;