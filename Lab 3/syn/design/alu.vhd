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
		Branch_out	: OUT STD_LOGIC
	);
END ENTITY alu;

ARCHITECTURE logic OF alu IS

BEGIN
	P: PROCESS(A_in, B_in, Func_in)
	VARIABLE t: INTEGER;
	BEGIN
	Branch_out 	<= '0';
	O_out <= (others=>'0');
	CASE Func_in IS
-- Shift Left Logical
		WHEN "000000" =>
			t := to_integer(unsigned(A_in));
			O_out(NBIT-1 DOWNTO t)	 		<= B_in(NBIT-1-t DOWNTO 0);
			O_out(t-1 DOWNTO 0)				<= (OTHERS=>'0');
-- Shift Right Logical
		WHEN "000010" =>
			t := to_integer(unsigned(A_in));
			O_out(NBIT-1 DOWNTO NBIT-t)	<= (OTHERS=>'0');
			O_out(NBIT-1-t DOWNTO 0)		<= B_in(NBIT-1 DOWNTO t);
-- Shift Right Arithmetic
		WHEN "000011" =>
			t := to_integer(unsigned(A_in));
			O_out(NBIT-1 DOWNTO NBIT-t)	<= (OTHERS=>B_in(31));
			O_out(NBIT-1-t DOWNTO 0)		<= B_in(NBIT-1 DOWNTO t);
--- ADD OPERATION
		WHEN "100000" =>
			O_out 			<= STD_LOGIC_VECTOR(to_unsigned(to_integer(unsigned(A_in)) + to_integer(unsigned(B_in)), 32));
		WHEN "100001" =>
			O_out 			<= STD_LOGIC_VECTOR(to_unsigned(to_integer(unsigned(A_in)) + to_integer(unsigned(B_in)), 32));
--- SUB OPERATION
		WHEN "100010" =>
			O_out 			<= STD_LOGIC_VECTOR(to_unsigned(to_integer(unsigned(A_in)) - to_integer(unsigned(B_in)), 32));
		WHEN "100011" =>
			O_out 			<= STD_LOGIC_VECTOR(to_unsigned(to_integer(unsigned(A_in)) - to_integer(unsigned(B_in)), 32));
--- AND OPERATION
		WHEN "100100" =>
			O_out 			<= A_in AND B_in;
--- OR OPERATION
		WHEN "100101" =>
			O_out 			<= A_in OR B_in;
--- XOR OPERATION
		WHEN "100110" =>
			O_out 			<= A_in XOR B_in;
--- NOR OPERATION
		WHEN "100111" =>
			O_out 			<= A_in NOR B_in;
--- Set Less Than Signed
		WHEN "101010" =>
			IF A_in < B_in THEN
				O_out 		<= STD_LOGIC_VECTOR(to_unsigned(1, 32));
			ELSE
				O_out 		<= (others=>'0');
			END IF;
--- Set Less Than Unsigned
		WHEN "101011" =>
			IF to_integer(unsigned(A_in)) < to_integer(unsigned(B_in)) THEN
				O_out 		<= STD_LOGIC_VECTOR(to_unsigned(1, 32));
			ELSE
				O_out 		<= (others=>'0');
			END IF;
-- Branch Less Than Zero		
		WHEN "111000" =>
			O_out 			<= A_in;
			IF to_integer(unsigned(A_in)) < 0 THEN
				Branch_out <= '1';
			END IF;
-- Branch Greater Than or Equal To Zero
		WHEN "111001" =>
			O_out 			<= A_in;
			IF to_integer(unsigned(A_in)) >= 0 THEN
				Branch_out <= '1';
			END IF;
-- Branch Equal
		WHEN "111100" =>
			O_out 			<= A_in;
			IF to_integer(unsigned(A_in)) = to_integer(unsigned(B_in)) THEN
				Branch_out <= '1';
			END IF;
-- Branch Not Equal		
		WHEN "111101" =>
			O_out 			<= A_in;
			IF to_integer(unsigned(A_in)) /= to_integer(unsigned(B_in)) THEN
				Branch_out <= '1';
			END IF;
-- Branch Less Than or Equal to Zero
		WHEN "111110" =>
			O_out 			<= A_in;
			IF to_integer(unsigned(A_in)) <= 0 THEN
				Branch_out <= '1';
			END IF;
-- Branch Greater Than Zero
		WHEN "111111" =>
			O_out 			<= A_in;
			IF to_integer(unsigned(A_in)) > 0 THEN
				Branch_out <= '1';
			END IF;
-- OTHER
		WHEN OTHERS =>
			Branch_out 	<= 'X';
			O_out <= (OTHERS=>'X');
	END CASE;
	END PROCESS P;

END ARCHITECTURE logic;
