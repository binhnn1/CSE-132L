LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE work.processor_pack.ALL;

ENTITY alu_controller IS
	PORT (
		ALUControl		: IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		FuncCode			: IN STD_LOGIC_VECTOR(5 DOWNTO 0);
		FuncOut			: OUT STD_LOGIC_VECTOR(5 DOWNTO 0)
	);
END ENTITY alu_controller;

ARCHITECTURE logic OF alu_controller IS

BEGIN
	PROCESS(ALUControl, FuncCode)
	BEGIN
	CASE ALUControl IS
		WHEN "00" => FuncOut <= "100000";
		WHEN "01" => FuncOut <= "XXXXXX";
		WHEN "10" => FuncOut <= FuncCode;
		WHEN OTHERS => FuncOut <= "XXXXXX";
	END CASE;
	END PROCESS;
END ARCHITECTURE logic;
