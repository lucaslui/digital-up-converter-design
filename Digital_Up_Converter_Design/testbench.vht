library ieee;
use ieee.std_logic_1164.all;

entity testbench is 
	port( enable_div0      : out   std_logic;
			enable_div128    : out   std_logic;
			enable_div2048   : out   std_logic);
end testbench;

architecture behavior of testbench is

	component timing_controller
		port( reset            : in    std_logic;		
				clk              : in    std_logic;
				clk_enable       : in    std_logic;		
				enable_div0      : out   std_logic;
				enable_div128    : out   std_logic;
				enable_div2048   : out   std_logic);
	end component;
	
	signal reset : std_logic := '0';
	signal clk   : std_logic := '0';
	signal clk_enable : std_logic := '1';
	
	constant half_period : time := 0.5 ns;
	
begin
	
	timing_controller_inst : timing_controller       
   port map(reset => reset,
				clk => clk,
				clk_enable => clk_enable,
				enable_div0 => enable_div0,
				enable_div128 => enable_div128,
				enable_div2048 => enable_div2048);
				
	proc_reset: process
	begin
		reset <= '1';
		WAIT FOR 10 ns;
		reset <= '0'; 
		wait;
	end process proc_reset;
		
	clk <= not clk after half_period;
	
end;