LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE work.processor_pack.ALL;

ENTITY ram IS
	GENERIC (SIZE : INTEGER := 512);
	PORT (
		clk		: IN STD_LOGIC;
		we		: IN STD_LOGIC;
		addr		: IN STD_LOGIC_VECTOR(NBIT-1 DOWNTO 0);
		dataI		: IN STD_LOGIC_VECTOR(NBIT-1 DOWNTO 0);
		dataO	: OUT STD_LOGIC_VECTOR(NBIT-1 DOWNTO 0)
	);
END ENTITY ram;

ARCHITECTURE logic OF ram IS

TYPE ram_type IS ARRAY (0  TO SIZE-1) OF STD_LOGIC_VECTOR(NBIT-1 DOWNTO 0);
SIGNAL ram_block : ram_type;
SIGNAL read_address : STD_LOGIC_VECTOR(NBIT-1 DOWNTO 0);

BEGIN
	P: PROCESS(addr)
	BEGIN
		IF clk='1' THEN
			IF we = '1' THEN
				ram_block(to_integer(unsigned(addr)))  <= dataI;
			END IF;
		END IF;
		read_address <= addr;
	END PROCESS;
	dataO <= ram_block(to_integer(unsigned(read_address)));
END ARCHITECTURE logic;