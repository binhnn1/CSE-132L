LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE work.processor_pack.ALL;

ENTITY mux4to1 IS
	GENERIC (S : INTEGER := 32);
	PORT (
		input_1 	: IN STD_LOGIC_VECTOR(S-1 DOWNTO 0);
		input_2 	: IN STD_LOGIC_VECTOR(S-1 DOWNTO 0);
		input_3 	: IN STD_LOGIC_VECTOR(S-1 DOWNTO 0);
		input_4 	: IN STD_LOGIC_VECTOR(S-1 DOWNTO 0);
		sel 			: IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		output 		: OUT STD_LOGIC_VECTOR(S-1 DOWNTO 0)
	);
END ENTITY mux4to1;

ARCHITECTURE logic OF mux4to1 IS
BEGIN
	output <= input_1 WHEN (sel = "00") ELSE
				input_2 WHEN (sel = "01") ELSE
				input_3 WHEN (sel = "10") ELSE
				input_4;
END ARCHITECTURE logic;
