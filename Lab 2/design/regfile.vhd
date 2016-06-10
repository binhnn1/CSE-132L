LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE work.processor_pack.ALL;

ENTITY regfile IS
	GENERIC (SIZE: INTEGER := 32);
	PORT (
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

ARCHITECTURE logic OF regfile IS
TYPE RF IS ARRAY (SIZE-1 DOWNTO 0) OF STD_LOGIC_VECTOR(NBIT-1 DOWNTO 0);
SIGNAL Storage : RF := (
					-- initial values for testing
					0 => (OTHERS=>'0'),
					1 => "00000000000000000000000000000001",
					31 => (OTHERS=>'1'),
					OTHERS=>(OTHERS=>'0')
			);

BEGIN
	PROCESS(clk, raddr_1, raddr_2, wdata)
	BEGIN
		
		IF (rising_edge(clk) AND rst_s='1') THEN
			allzero: FOR i IN 0 TO SIZE-1 LOOP
				Storage(i) <= (OTHERS => '0');
			END LOOP;
			-- initial values for testing
			Storage(1) <= "00000000000000000000000000000001";
			Storage(31) <= (OTHERS=>'1');
				
			rdata_1 <= (OTHERS => '0');
			rdata_2 <= (OTHERS => '0');
		ELSIF (we='1') THEN
			Storage(to_integer(unsigned(waddr)))<=wdata;
		END IF;
		rdata_1 <= Storage(to_integer(unsigned(raddr_1)));
		rdata_2 <= Storage(to_integer(unsigned(raddr_2)));
	END PROCESS;

END ARCHITECTURE logic;

