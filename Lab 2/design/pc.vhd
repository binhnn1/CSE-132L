LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE work.processor_pack.ALL;

ENTITY pc IS
    PORT(
		clk 		: IN  STD_LOGIC;
		rst_s		: IN STD_LOGIC;
		addr_out 	: OUT STD_LOGIC_VECTOR(NBIT-1 DOWNTO 0)
    );
END ENTITY pc;

ARCHITECTURE logic OF pc IS
BEGIN
	PROCESS (clk)
	VARIABLE addr_temp : STD_LOGIC_VECTOR(NBIT-1 DOWNTO 0) := (OTHERS=>'0');
	BEGIN
		IF rising_edge(clk) then
			IF (rst_s = '1') THEN
				addr_temp := (others => '0');
			ELSE
				addr_temp := STD_LOGIC_VECTOR(UNSIGNED(addr_temp)+1);
			END IF;
		END IF;
		addr_out <= addr_temp;
	END PROCESS;
END ARCHITECTURE logic;
