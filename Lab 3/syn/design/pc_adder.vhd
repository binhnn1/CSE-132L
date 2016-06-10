LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE work.processor_pack.ALL;


entity adder is
port(
	addr_in 	: in std_logic_vector(nbit-1 downto 0);
	addr_out 	: out std_logic_vector(nbit-1 downto 0)
);
end adder;


architecture behav of adder is
signal temp_addr : std_logic_vector(nbit-1 downto 0);
begin


process (addr_in)
begin

temp_addr <= STD_LOGIC_VECTOR(to_unsigned(to_integer(unsigned(addr_in)) + 1, 32));


end process;
addr_out <= temp_addr;
end architecture;
