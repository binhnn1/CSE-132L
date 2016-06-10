LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE work.processor_pack.ALL;

ENTITY flipflop IS
	GENERIC (S : INTEGER := 32);
	PORT (
		Set				: IN STD_LOGIC;
		Reset			: IN STD_LOGIC;
		Data				: IN STD_LOGIC_VECTOR(S-1 DOWNTO 0);
		clk				: IN STD_LOGIC;
		Q 					: OUT STD_LOGIC_VECTOR(S-1 DOWNTO 0)
   );
END ENTITY flipflop;

ARCHITECTURE logic OF flipflop IS
SIGNAL temp : STD_LOGIC_VECTOR(S-1 DOWNTO 0) := (OTHERS=>'0');
BEGIN
	PROCESS(clk) BEGIN
		IF (rising_edge(clk)) THEN
			IF (Set = '0') THEN
				IF (Reset = '1') THEN
					temp <= (OTHERS=>'0');
				ELSE
					temp <= Data;
				END IF;
			END IF;
		END IF;
		Q <= temp;
			-- IF Reset = '1' THEN
				-- Q <= (OTHERS=>'0');
			-- ELSIF Set = '1' THEN
				-- Q <= (OTHERS=>'1');
			-- ELSE
				-- Q <= Data;       
			-- END IF;
		-- END IF;       
	END PROCESS;

	-- PROCESS(clk)
	-- BEGIN
		-- IF rising_edge(clk) THEN
			-- IF Reset = '1' THEN
				-- Q <= (OTHERS=>'0');
			-- ELSIF Set = '1' THEN
				-- Q <= (OTHERS=>'1');
			-- ELSE
				-- Q <= Data;       
			-- END IF;
		-- END IF;       
	-- END PROCESS;
END ARCHITECTURE logic;