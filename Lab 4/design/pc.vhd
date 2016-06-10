
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE work.processor_pack.ALL;

ENTITY pc_clock IS
    PORT(
		addr_in		: IN STD_LOGIC_VECTOR(NBIT-1 DOWNTO 0);
		clk 			: IN STD_LOGIC;
		set			: IN STD_LOGIC;
		rst_s		: IN STD_LOGIC;
		addr_out 	: OUT STD_LOGIC_VECTOR(NBIT-1 DOWNTO 0)
    );
END ENTITY pc_clock;

ARCHITECTURE logic OF pc_clock IS
SIGNAL temp : STD_LOGIC_VECTOR(NBIT-1 DOWNTO 0) := (OTHERS=>'0');
BEGIN
	PROCESS (clk)
	BEGIN
		IF (rising_edge(clk)) THEN
			IF (set = '0') THEN
				IF (rst_s = '1') THEN
					temp <= (OTHERS => '0');
				ELSE
				temp <= addr_in;
				END IF;
			END IF;
		END IF;
		addr_out <= temp;
	END PROCESS;
END ARCHITECTURE logic;
