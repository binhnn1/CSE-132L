LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE work.processor_pack.ALL;

ENTITY processor IS
	PORT (
		ref_clk			: IN STD_LOGIC;
		reset			: IN STD_LOGIC
	);
END ENTITY processor;

ARCHITECTURE logic OF processor IS

COMPONENT pc IS
    PORT(
		clk 		: IN  STD_LOGIC;
		rst_s		: IN STD_LOGIC;
		addr_out 	: OUT STD_LOGIC_VECTOR(NBIT-1 DOWNTO 0)
    );
END COMPONENT pc;

COMPONENT rom IS
	GENERIC (SIZE : INTEGER := 512);
	PORT (
		addr 			: IN STD_LOGIC_VECTOR(NBIT-1 DOWNTO 0);
		dataIO 			: INOUT STD_LOGIC_VECTOR(NBIT-1 DOWNTO 0)
	);
END COMPONENT rom;

COMPONENT controller IS 
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
END COMPONENT controller;

COMPONENT mux2to1 IS 
	GENERIC (S : INTEGER := 32);
	PORT (
		input_1 			: IN STD_LOGIC_VECTOR(S-1 DOWNTO 0);
		input_2 			: IN STD_LOGIC_VECTOR(S-1 DOWNTO 0);
		sel 				: IN STD_LOGIC;
		output 			: OUT STD_LOGIC_VECTOR(S-1 DOWNTO 0)
	);
END COMPONENT mux2to1;

COMPONENT regfile IS
	GENERIC (SIZE: INTEGER := 32);
	PORT (
		clk 				: IN STD_LOGIC;
		rst_s 			: IN STD_LOGIC; -- synchronous reset
		we 				: IN STD_LOGIC; -- write enable
		raddr_1 		: IN STD_LOGIC_VECTOR(NSEL-1 DOWNTO 0); -- read address 1
		raddr_2 		: IN STD_LOGIC_VECTOR(NSEL-1 DOWNTO 0); -- read address 2
		waddr 			: IN STD_LOGIC_VECTOR(NSEL-1 DOWNTO 0); -- write address
		rdata_1 		: OUT STD_LOGIC_VECTOR(NBIT-1 DOWNTO 0); -- read data 1
		rdata_2 		: OUT STD_LOGIC_VECTOR(NBIT-1 DOWNTO 0); -- read data 2
		wdata 			: IN STD_LOGIC_VECTOR(NBIT-1 DOWNTO 0) -- write data 1
	);
END COMPONENT regfile;

COMPONENT sign_extender IS 
	PORT (
		input				: IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		output			: OUT STD_LOGIC_VECTOR(NBIT-1 DOWNTO 0)
	);
END COMPONENT sign_extender;

COMPONENT alu_controller IS
	PORT (
		ALUControl		: IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		FuncCode			: IN STD_LOGIC_VECTOR(5 DOWNTO 0);
		FuncOut			: OUT STD_LOGIC_VECTOR(5 DOWNTO 0)
	);
END COMPONENT alu_controller;

COMPONENT alu IS 
	PORT (
		Func_in			: IN STD_LOGIC_VECTOR (5 DOWNTO 0);
		A_in				: IN STD_LOGIC_VECTOR (NBIT-1 DOWNTO 0);
		B_in				: IN STD_LOGIC_VECTOR (NBIT-1 DOWNTO 0);
		O_out			: OUT STD_LOGIC_VECTOR (NBIT-1 DOWNTO 0);
		Branch_out	: OUT STD_LOGIC;
		Jump_out		: OUT STD_LOGIC
	);
END COMPONENT alu;

COMPONENT ram IS
	GENERIC (SIZE : INTEGER := 512);
	PORT (
		clk				: IN STD_LOGIC;
		we				: IN STD_LOGIC;
		addr				: IN STD_LOGIC_VECTOR(SIZE-1 DOWNTO 0);
		dataI			: IN STD_LOGIC_VECTOR(SIZE-1 DOWNTO 0);
		dataO			: OUT STD_LOGIC_VECTOR(SIZE-1 DOWNTO 0)
	);
END COMPONENT ram;

SIGNAL addr_pc : STD_LOGIC_VECTOR(NBIT-1 DOWNTO 0) := (OTHERS=>'0');
SIGNAL addr_instruction : STD_LOGIC_VECTOR(NBIT-1 DOWNTO 0) := (OTHERS=>'0');
SIGNAL instruction, read_data_1, read_data_2, write_data, ext_imm, alu_input_2 : STD_LOGIC_VECTOR(NBIT-1 DOWNTO 0);
SIGNAL alu_result, ram_output : STD_LOGIC_VECTOR(NBIT-1 DOWNTO 0);
SIGNAL write_address : STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL mtr, mw, br, asrc, regdst, regwrite, bro, jmp : STD_LOGIC;
SIGNAL alu_func : STD_LOGIC_VECTOR(5 DOWNTO 0);
SIGNAL alu_con : STD_LOGIC_VECTOR(1 DOWNTO 0);

BEGIN			
	inst0 : rom PORT MAP (
						addr				=> addr_instruction,
						dataIO			=> instruction
					);
					
	inst1 : pc PORT MAP (
						clk 				=> ref_clk,
						rst_s 			=> reset,
						addr_out		=> addr_instruction
					);
					
	inst2 : controller PORT MAP (
						opcode			=> instruction(NBIT-1 DOWNTO NBIT-6),
						MemToReg		=> mtr,
						MemWrite		=> mw,
						Branch			=> br,
						ALUControl		=> alu_con,
						ALUSrc			=> asrc,
						RegDst			=> regdst,
						RegWrite		=> regwrite
					);
					
	inst3 : mux2to1 
					GENERIC MAP (S => 5)
					PORT MAP (
						input_1			=> instruction(NBIT-12 DOWNTO NBIT-16),
						input_2			=> instruction(NBIT-17 DOWNTO NBIT-21),
						sel				=> regdst,
						output			=> write_address
					);
					
	inst4 : regfile PORT MAP (
						clk				=> ref_clk,
						rst_s			=> reset,
						we				=> regwrite,
						raddr_1		=> instruction(NBIT-7 DOWNTO NBIT-11),
						raddr_2		=> instruction(NBIT-12 DOWNTO NBIT-16),
						waddr			=> write_address,
						rdata_1		=> read_data_1,
						rdata_2		=> read_data_2,
						wdata			=> write_data
					);
					
	inst5 : sign_extender PORT MAP (
						input				=> instruction(NBIT-17 DOWNTO 0),
						output			=> ext_imm
					);
					
	inst6 : mux2to1 
					GENERIC MAP (S =>32)
					PORT MAP (
						input_1			=> read_data_2,
						input_2			=> ext_imm,
						sel				=> asrc,
						output			=> alu_input_2
					);
					
	inst7 : alu_controller PORT MAP (
						ALUControl	=> alu_con,
						FuncCode		=> instruction(5 DOWNTO 0),
						FuncOut		=>  alu_func
					);
					
	inst8 : alu PORT MAP (
						Func_in			=> alu_func,
						A_in				=> read_data_1,
						B_in				=> alu_input_2,
						O_out			=> alu_result,
						Branch_out		=> bro,
						Jump_out		=> jmp
					);

	inst9 : ram PORT MAP (
						clk				=> ref_clk,
						we				=> mw,
						addr				=> alu_result,
						dataI				=> read_data_2,
						dataO			=> ram_output
					);
					
	inst10 : mux2to1 PORT MAP (
						input_1			=> alu_result,
						input_2			=> ram_output,
						sel				=> mtr,
						output			=> write_data
					);		
END ARCHITECTURE logic;

