LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE work.processor_pack.ALL;

ENTITY flipflop1bit IS
	PORT (
		Set				: IN STD_LOGIC;
		Reset			: IN STD_LOGIC;
		Data				: IN STD_LOGIC;
		clk				: IN STD_LOGIC;
		Q 					: OUT STD_LOGIC
   );
END ENTITY flipflop1bit;

ARCHITECTURE logic OF flipflop1bit IS
SIGNAL temp : STD_LOGIC := '0';
BEGIN
	PROCESS(clk)
	BEGIN
		IF (rising_edge(clk)) THEN
			IF (Set = '0') THEN
				IF (Reset = '1') THEN
					temp <= '0';
				ELSE
					temp <= Data;
				END IF;
			END IF;
		END IF;
		Q <= temp;
	END PROCESS;
	
	
	
		-- PROCESS(clk, Reset)
	-- BEGIN
		-- IF rising_edge(clk) THEN
			-- IF Reset = '1' THEN
				-- Q <= '0';
			-- ELSIF Set = '1' THEN
				-- Q <= '1';
			-- ELSE
				-- Q <= Data;       
			-- END IF;
		-- END IF;       
	-- END PROCESS;
END ARCHITECTURE logic;
