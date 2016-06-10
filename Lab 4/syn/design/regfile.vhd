library IEEE; 
use IEEE.std_logic_1164.all;
--use IEEE.numeric_std_unsigned.all;
use IEEE.std_logic_signed.all;
--use IEEE.std_logic_arith.all;
USE work.processor_pack.ALL;

ENTITY regfile IS 
	 port(
		clk 			: IN STD_LOGIC;
		rst_s 		: IN STD_LOGIC; -- synchronous reset
		we 			: IN STD_LOGIC; -- write enable
		raddr_1 	: IN STD_LOGIC_VECTOR(NSEL-1 DOWNTO 0); -- read address 1
		raddr_2 	: IN STD_LOGIC_VECTOR(NSEL-1 DOWNTO 0); -- read address 2
		waddr 		: IN STD_LOGIC_VECTOR(NSEL-1 DOWNTO 0); -- write address
		rdata_1 	: OUT STD_LOGIC_VECTOR(NBIT-1 DOWNTO 0); -- read data 1
		rdata_2 	: OUT STD_LOGIC_VECTOR(NBIT-1 DOWNTO 0); -- read data 2
		wdata 		: IN STD_LOGIC_VECTOR(NBIT-1 DOWNTO 0) -- write data 1
	);
END ENTITY regfile;

architecture logic of regfile is
	type ramtype is array (31 downto 0) of STD_LOGIC_VECTOR(31 downto 0);
	signal mem: ramtype;
begin

	process(clk) begin
		if rising_edge(clk) then
			if we = '1' then 
				mem(conv_integer(waddr)) <= wdata;
			end if;
		end if;
	end process;
	
	process(all) begin
		if (conv_integer(raddr_1) = 0) then 
			rdata_1 <= X"00000000";
		else 
			rdata_1 <= mem(conv_integer(raddr_1));
		end if;
		if (conv_integer(raddr_2) = 0) then 
			rdata_2 <= X"00000000";
		else 
			rdata_2 <= mem(conv_integer(raddr_2));
		end if;
	end process;
END ARCHITECTURE logic;

