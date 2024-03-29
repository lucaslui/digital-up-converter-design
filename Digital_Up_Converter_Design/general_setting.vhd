-------------------------------------------------------------------------------------------------------------------------------------------------------
-- Author: Lucas Lui Motta 					@Copyright Unicamp, 2019
-- 													
-- Begin Date: 08/10/2019
--
-- Revision History:  	Date 		  	  Author 			Comments
--  						 	08/10/2019    L. L. Motta 		Created=
-------------------------------------------------------------------------------------------------------------------------------------------------------
-- Purpose:
-- This package define some general settings of our Digital Up-Converter.
-------------------------------------------------------------------------------------------------------------------------------------------------------

library ieee,work;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package general_setting is
		
	-- Constant Declaration
	constant adc_wl   : integer := 12;
	constant data_wl  : integer := 16;
	constant coeff_wl : integer := 16;
	constant cic_taps : integer := 3;
	constant fir_taps : integer := 106;
	
	-- Type Declaration
	type t_coeff_vect is array (integer range <>) of std_logic_vector (coeff_wl-1 downto 0);

end general_setting;
