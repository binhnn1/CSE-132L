LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE work.processor_pack.ALL;

ENTITY alu IS
	PORT (
		Func_in			: IN STD_LOGIC_VECTOR (5 DOWNTO 0);
		A_in				: IN STD_LOGIC_VECTOR (NBIT-1 DOWNTO 0);
		B_in				: IN STD_LOGIC_VECTOR (NBIT-1 DOWNTO 0);
		O_out			: OUT STD_LOGIC_VECTOR (NBIT-1 DOWNTO 0);
		Branch_out	: OUT STD_LOGIC;
		Jump_out		: OUT STD_LOGIC
	);
END ENTITY alu;

ARCHITECTURE logic OF alu IS

BEGIN
	P: PROCESS(A_in, B_in, Func_in)
	BEGIN
	O_out <= (others=>'0');
	CASE Func_in IS
--- ADD OPERATION
		WHEN "100000" =>
			O_out 			<= STD_LOGIC_VECTOR(to_unsigned(to_integer(unsigned(A_in)) + to_integer(unsigned(B_in)), 32));
			Branch_out 	<= '0';				
			Jump_out 		<= '0';	
		WHEN "100001" =>
			O_out 			<= STD_LOGIC_VECTOR(to_unsigned(to_integer(unsigned(A_in)) + to_integer(unsigned(B_in)), 32));
			Branch_out 	<= '0';				
			Jump_out 		<= '0';	
--- SUB OPERATION
		WHEN "100010" =>
			O_out 			<= STD_LOGIC_VECTOR(to_unsigned(to_integer(unsigned(A_in)) - to_integer(unsigned(B_in)), 32));
			Branch_out 	<= '0';
			Jump_out 		<= '0';
		WHEN "100011" =>
			O_out 			<= STD_LOGIC_VECTOR(to_unsigned(to_integer(unsigned(A_in)) - to_integer(unsigned(B_in)), 32));
			Branch_out 	<= '0';
			Jump_out 		<= '0';
--- AND OPERATION
		WHEN "100100" =>
			O_out 			<= A_in AND B_in;
			Branch_out 	<= '0';
			Jump_out 		<= '0';
--- OR OPERATION
		WHEN "100101" =>
			O_out 			<= A_in OR B_in;
			Branch_out 	<= '0';
			Jump_out 		<= '0';
--- XOR OPERATION
		WHEN "100110" =>
			O_out 			<= A_in XOR B_in;
			Branch_out 	<= '0';
			Jump_out 		<= '0';
--- NOR OPERATION
		WHEN "100111" =>
			O_out 			<= A_in NOR B_in;
			Branch_out 	<= '0';
			Jump_out 		<= '0';
--- Set Less Than Signed
		WHEN "101000" =>
			IF A_in < B_in THEN
				O_out 		<= STD_LOGIC_VECTOR(to_unsigned(1, 32));
			ELSE
				O_out 		<= (others=>'0');
			END IF;
			Branch_out 	<= '0';
			Jump_out 		<= '0';
--- Set Less Than Unsigned
		WHEN "101001" =>
			IF to_integer(unsigned(A_in)) < to_integer(unsigned(B_in)) THEN
				O_out 		<= STD_LOGIC_VECTOR(to_unsigned(1, 32));
			ELSE
				O_out 		<= (others=>'0');
			END IF;
			Branch_out 	<= '0';
			Jump_out 		<= '0';
--- Jump, Branch
		WHEN OTHERS =>
			Branch_out 	<= '0';
			Jump_out 		<= '0';
	END CASE;
	END PROCESS P;

END ARCHITECTURE logic;
