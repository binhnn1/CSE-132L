LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE work.processor_pack.ALL;
-----------------------

ENTITY sign_extender IS
	GENERIC (SIZE : INTEGER := 16);
	PORT (
		input		: IN STD_LOGIC_VECTOR(SIZE-1 DOWNTO 0);
		output	: OUT STD_LOGIC_VECTOR(NBIT-1 DOWNTO 0)
	);
END ENTITY sign_extender;

-----------------------
ARCHITECTURE logic OF sign_extender IS

SIGNAL ex_0 : STD_LOGIC_VECTOR(NBIT-1-SIZE DOWNTO 0) := (others=>'0');
SIGNAL ex_1 : STD_LOGIC_VECTOR(NBIT-1-SIZE DOWNTO 0) := (others=>'1');

BEGIN
	WITH input(SIZE-1) SELECT output <=
									ex_0 & input WHEN '0',
									ex_1 & input WHEN '1',
									(others => 'Z') WHEN OTHERS;
END ARCHITECTURE logic;
