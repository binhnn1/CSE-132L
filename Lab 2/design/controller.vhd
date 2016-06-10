LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE work.processor_pack.ALL;

ENTITY controller IS
	PORT (
		opcode 			: IN STD_LOGIC_VECTOR(5 DOWNTO 0);
		MemToReg		: OUT STD_LOGIC;
		MemWrite		: OUT STD_LOGIC;
		Branch			: OUT STD_LOGIC;
		ALUControl		: OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		ALUSrc			: OUT STD_LOGIC;
		RegDst			: OUT STD_LOGIC;
		RegWrite		: OUT STD_LOGIC
	);
END ENTITY controller;

ARCHITECTURE logic OF controller IS
BEGIN
	PROCESS(opcode)
	BEGIN
		CASE opcode IS
			-- R-Type
			WHEN R_opcode =>
				MemToReg 		<= '0';
				MemWrite 		<= '0';
				Branch 			<= '0';
				ALUControl 		<= "10";
				ALUSrc 			<= '0';
				RegDst 			<= '1';
				RegWrite 		<= '1';
			-- Load Type
			WHEN L_opcode =>
				MemToReg 		<= '1';
				MemWrite 		<= '0';
				Branch 			<= '0';
				ALUControl 		<= "00";
				ALUSrc 			<= '1';
				RegDst 			<= '0';
				RegWrite 		<= '1';
			-- Save Type
			WHEN S_opcode =>
				MemToReg 		<= 'X';
				MemWrite 		<= '1';
				Branch 			<= '0';
				ALUControl 		<= "00";
				ALUSrc 			<= '1';
				RegDst 			<= 'X';
				RegWrite 		<= '0';
			-- Branch
			WHEN J_opcode =>
				MemToReg 		<= 'X';
				MemWrite 		<= '0';
				Branch 			<= '1';
				ALUControl 		<= "01";
				ALUSrc 			<= '0';
				RegDst 			<= 'X';
				RegWrite 		<= '0';
			WHEN OTHERS =>
				MemToReg 		<= 'X';
				MemWrite 		<= 'X';
				Branch 			<= 'X';
				ALUControl 		<= "XX";
				ALUSrc 			<= 'X';
				RegDst 			<= 'X';
				RegWrite 		<= 'X';
		END CASE;
	END PROCESS;
END ARCHITECTURE logic;

