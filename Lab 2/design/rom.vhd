library IEEE;
use IEEE.STD_LOGIC_1164.all; 
use STD.TEXTIO.all;
use IEEE.NUMERIC_STD_UNSIGNED.all;
USE work.processor_pack.ALL;

ENTITY rom IS
	GENERIC (SIZE : INTEGER := 512);
	PORT (
		addr 		: IN STD_LOGIC_VECTOR(NBIT-1 DOWNTO 0);
		dataIO 		: INOUT STD_LOGIC_VECTOR(NBIT-1 DOWNTO 0)
	);
END ENTITY rom;

ARCHITECTURE logic OF rom IS
BEGIN
PROCESS IS
file mem_file: TEXT;
variable L: line;
VARIABLE ch: character;
variable i, index, result: integer;

TYPE ramtype IS ARRAY (SIZE-1 DOWNTO 0) OF STD_LOGIC_VECTOR(NBIT-1 DOWNTO 0);
variable mem: ramtype;

begin
-- initialize memory from file
for i in 0 to SIZE-1 loop -- set all contents low
mem(i) := (others => '0');
end loop;

index := 0;
--FILE_OPEN (mem_file, "memfile.dat", READ_MODE);
FILE_OPEN (mem_file, "imem.h", READ_MODE);

while not endfile(mem_file) loop
readline(mem_file, L);
result := 0;

for i in 1 to 8 loop
	read (L, ch);
	if '0' <= ch and ch <= '9' then
	result := character'pos(ch) - character'pos('0');
	elsif 'a' <= ch and ch <= 'f' then
	result := character'pos(ch) - character'pos('a')+10;
	else report "Format error on line" & integer'
	image(index) severity error;
	end if;
	mem(index)(35-i*4 downto 32-i*4) := to_std_logic_vector(result,4);
	end loop;
	index := index + 1;
end loop;
-- read memory
loop
dataIO <= mem(to_integer(addr));
wait on addr;
end loop;
end process;
end;
