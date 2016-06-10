LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE work.processor_pack.ALL;

ENTITY ram IS
	GENERIC (SIZE : INTEGER := 512);
	PORT (
		clk		: IN STD_LOGIC;
		we		: IN STD_LOGIC;
		dsize	: IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		addr		: IN STD_LOGIC_VECTOR(NBIT-1 DOWNTO 0);
		dataI	: IN STD_LOGIC_VECTOR(NBIT-1 DOWNTO 0);
		dataO	: OUT STD_LOGIC_VECTOR(NBIT-1 DOWNTO 0)
	);
END ENTITY ram;

ARCHITECTURE logic OF ram IS

TYPE ram_type IS ARRAY (0  TO 4*SIZE-1) OF STD_LOGIC_VECTOR(NBYTE-1 DOWNTO 0);
SIGNAL ram_block : ram_type;
SIGNAL t : STD_LOGIC_VECTOR(NBIT-1 DOWNTO 0);
SIGNAL read_address : STD_LOGIC_VECTOR(NBIT-1 DOWNTO 0);

BEGIN
	PROCESS(clk, addr)
	VARIABLE s, i: INTEGER;
	VARIABLE temp_result : STD_LOGIC_VECTOR(NBIT-1 DOWNTO 0);
	BEGIN
		s := to_integer(unsigned(dsize(1 DOWNTO 0)));
		IF clk='1' AND we = '1' THEN
				FOR i IN  0 TO s LOOP
					ram_block(4*to_integer(unsigned(addr))+i)  			<= dataI(8*i+7 DOWNTO 8*i);
				END LOOP;
		END IF;
		read_address <= addr;
		
		IF to_integer(unsigned(addr)) >= 0 AND to_integer(unsigned(addr)) < SIZE THEN
			FOR i IN 0 TO s LOOP
				temp_result(8*i+7 DOWNTO 8*i)		:= ram_block(4*to_integer(unsigned(addr))+i) ;
			END LOOP;
			
			IF s < 2 THEN
				IF dsize(2) = '1' THEN
					temp_result(NBIT-1 DOWNTO 8*s+8) := (OTHERS=>'0');
				ELSE
					temp_result(NBIT-1 DOWNTO 8*s+8) := (OTHERS=>temp_result(8*s+7));
				END IF;
			END IF;
			t <= temp_result;
		ELSE
			t <= (OTHERS=>'X');
		END IF;
	END PROCESS;
	dataO <= t;
END ARCHITECTURE logic;