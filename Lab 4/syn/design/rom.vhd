library IEEE;
use IEEE.STD_LOGIC_1164.all; 
--use STD.TEXTIO.all;
--use IEEE.NUMERIC_STD_UNSIGNED.all;
use IEEE.std_logic_signed.all;
USE work.processor_pack.ALL;

ENTITY rom IS
	GENERIC (SIZE : INTEGER := 512);
	PORT (
		addr 		: IN STD_LOGIC_VECTOR(NBIT-1 DOWNTO 0);
		dataIO 		: INOUT STD_LOGIC_VECTOR(NBIT-1 DOWNTO 0)
	);
END ENTITY rom;

ARCHITECTURE logic OF rom IS
	TYPE ramtype IS ARRAY (SIZE-1 DOWNTO 0) OF STD_LOGIC_VECTOR(NBIT-1 DOWNTO 0);
	signal mem: ramtype;
BEGIN
	PROCESS IS
--	FILE mem_file: TEXT;
--	VARIABLE L: line;
--	VARIABLE ch: character;
--	VARIABLE i, index, result: integer;



	BEGIN
		-- initialize memory from file
	--	FOR i IN 0 TO SIZE-1 LOOP -- set all contents low
	--		mem(i) := (OTHERS => '0');
	--	END LOOP;

	--	index := 0;
		--FILE_OPEN (mem_file, "memfile.dat", READ_MODE);
	--	FILE_OPEN (mem_file, "imem.h", READ_MODE);

	--	WHILE not endfile(mem_file) LOOP
	--		readline(mem_file, L);
	--		result := 0;

	--		FOR i IN 1 TO 8 LOOP
	--			read (L, ch);
	--			IF '0' <= ch and ch <= '9' THEN
	--				result := character'pos(ch) - character'pos('0');
	--			ELSIF 'a' <= ch and ch <= 'f' THEN
	--				result := character'pos(ch) - character'pos('a')+10;
	--			ELSE REPORT "FORmat error on line" & integer'
	--				image(index) SEVERITY error;
	--			END IF;
	--				mem(index)(35-i*4 DOWNTO 32-i*4) := conv_std_logic_vector(result,4);
	--		END LOOP;
	--		index := index + 1;
	--	END LOOP;
		
	-- read memory
--		LOOP
			dataIO <= mem(conv_integer(addr));
--			WAIT ON addr;
--		END LOOP;
		
	END PROCESS;
END;
