LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE work.processor_pack.ALL;
-----------------------

ENTITY processor_tb IS 
END ENTITY processor_tb;

-----------------------
ARCHITECTURE logic OF processor_tb IS

SIGNAL clk_tb							: STD_LOGIC := '0';
SIGNAL rst_s_tb						: STD_LOGIC := '0';

COMPONENT processor IS
   	PORT (
		ref_clk		: IN STD_LOGIC;
		reset			: IN STD_LOGIC
	);
END COMPONENT processor;
--------------------------

BEGIN 

	inst: processor PORT MAP (
					ref_clk 		=> clk_tb,
					reset 		=> rst_s_tb
				);
	PROCESS
	variable i									: INTEGER :=0;
	BEGIN

	-- reset
	WAIT FOR 10 ns;
	clk_tb <= '1';
	rst_s_tb <= '1';
	WAIT FOR 10 ns;
	clk_tb <= '0';
	rst_s_tb <= '0';
	
	-- start
	FOR i in 0 to 500 LOOP
		WAIT FOR 10 ns;
		clk_tb <= '1';
		WAIT FOR 10 ns;
		clk_tb <= '0';
	END LOOP;
	WAIT;
	END PROCESS;
END ARCHITECTURE logic;
