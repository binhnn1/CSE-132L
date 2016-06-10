LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE work.processor_pack.ALL;

ENTITY controller IS
	PORT (
		opcode 				: IN STD_LOGIC_VECTOR(5 DOWNTO 0);
		func_in					: IN STD_LOGIC_VECTOR(5 DOWNTO 0);
		rt_in						: IN STD_LOGIC;
		MemToReg			: OUT STD_LOGIC;
		MemWrite				: OUT STD_LOGIC;
		Branch					: OUT STD_LOGIC;
		ALUControl			: OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
		ALUSrc					: OUT STD_LOGIC;
		RegDst					: OUT STD_LOGIC;
		RegWrite				: OUT STD_LOGIC;
		JALRControl			: OUT STD_LOGIC;
		JALDataControl		: OUT STD_LOGIC;
		ShiftValueControl	: OUT STD_LOGIC;
		LUIControl			: OUT STD_LOGIC;
		JRControl				: OUT STD_LOGIC;
		JALAddrControl		: OUT STD_LOGIC;
		dsize					: OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		JControl				: OUT STD_LOGIC
	);
END ENTITY controller;

ARCHITECTURE logic OF controller IS
BEGIN
	PROCESS(opcode, func_in)
	BEGIN
		MemToReg 		<= '0';
		MemWrite 		<= '0';
		Branch				<= '0';
		ALUControl		<= func_in;
		ALUSrc				<= '1';
		RegDst				<= '1';
		RegWrite			<= '0';
		JALRControl		<= '0';
		JALDataControl	<= '0';
		ShiftValueControl	<= '0';
		LUIControl		<= '0';
		JRControl			<= '0';
		JALAddrControl	<= '0';
		dsize				<= "0XX";
		JControl			<= '0';
		CASE opcode IS
			-- R-Type
			WHEN "000000" =>
				ALUSrc		<= '0';
				RegWrite	<= '1';
				IF func_in(5 DOWNTO 4) = "00" THEN
					-- ADD, ADDU, SUB, SUBU, AND, OR, XOR, NOR, SLT, SLTU
					ALUControl			<= "100000";
					CASE func_in(3 DOWNTO 0) IS
						-- JR
						WHEN "1000" =>
							JRControl		<= '1';
							RegWrite		<= '0';
							ALUControl	<= "100000";
							JControl			<= '1';
						-- JALR
						WHEN "1001" =>
							JRControl		<= '1';
							JALRControl	<= '1';
							JALAddrControl		<= '1';
							JALDataControl		<= '1';
							ALUControl	<= "100000";
							JControl			<= '1';
							RegWrite			<= '1';
						WHEN OTHERS =>
							IF func_in(2) = '0' THEN
							-- SLL, SRL, SRA
								ShiftValueControl 	<= '1';
								ALUControl			<= func_in;
							-- SLLV, SRLV, SRAV
							ELSE
								ShiftValueControl <= '0';
								ALUControl			<= func_in(5 DOWNTO 3) & '0' & func_in(1 DOWNTO 0);
							END IF;
					END CASE;
				END IF;
			-- J Type
			-- J
			WHEN "000010" => 
				JControl			<= '1';
			-- JAL
			WHEN "000011" =>
				JALAddrControl		<= '1';
				JALDataControl		<= '1';
				JControl				<= '1';
				JALRControl			<= '1';
				RegWrite				<= '1';
			-- I-Type
			WHEN OTHERS =>
				-- Branch, Imm Arithmetic
				IF opcode(5) = '0' THEN
					-- Branch
					IF opcode(3) = '0' THEN
						ALUSrc			<= '0';
						Branch			<= '1';
						CASE opcode(2 DOWNTO 0) IS
							-- BLTZ, BGEZ
							WHEN "000" =>
								ALUControl		<= "11100" & rt_in;
							WHEN OTHERS =>
								ALUControl		<= "111" & opcode(2 DOWNTO 0);
						END CASE;
					-- Imm Arithmetic
					ELSE
						RegWrite					<= '1';
						RegDst						<= '0';
						CASE opcode(2 DOWNTO 0) IS
							-- SLTI
							WHEN "010" =>
								ALUControl		<= "101000";
							-- SLTIU
							WHEN "011" =>
								ALUControl		<= "101001";
							-- LUI
							WHEN "111" =>
								ALUControl		<= "100000";
								LUIControl		<= '1';
							-- ADDI, ORI, XORI
							WHEN OTHERS =>
								ALUControl		<= "100" & opcode(2 DOWNTO 0);
						END CASE;
					END IF;
				
				-- Load and Store
				ELSE
					ALUControl				<= "100000";
					dsize						<= opcode(2 DOWNTO 0);
					-- Load
					IF opcode(3) = '0' THEN
						MemToReg			<= '1';
						RegDst					<= '0';
						RegWrite				<= '1';
					-- Store
					ELSE
						MemWrite				<= '1';
						RegWrite				<= '0';
					END IF;
				END IF;			
		END CASE;
	END PROCESS;
END ARCHITECTURE logic;
