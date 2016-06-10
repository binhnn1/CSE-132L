LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE work.processor_pack.ALL;

ENTITY mux2to1 IS
	GENERIC (S : INTEGER := 32);
	PORT (
		input_1 	: IN STD_LOGIC_VECTOR(S-1 DOWNTO 0);
		input_2 	: IN STD_LOGIC_VECTOR(S-1 DOWNTO 0);
		sel 		: IN STD_LOGIC;
		output 	: OUT STD_LOGIC_VECTOR(S-1 DOWNTO 0)
	);
END ENTITY mux2to1;

ARCHITECTURE logic OF mux2to1 IS
BEGIN
	output <= input_1 WHEN (sel = '0') ELSE
				input_2 WHEN (sel = '1');
END ARCHITECTURE logic;
