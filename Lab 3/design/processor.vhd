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
		addr_in		: IN STD_LOGIC_VECTOR(NBIT-1 DOWNTO 0);
		clk 			: IN  STD_LOGIC;
		rst_s		: IN STD_LOGIC;
		addr_out 	: OUT STD_LOGIC_VECTOR(NBIT-1 DOWNTO 0)
    );
END COMPONENT pc;

COMPONENT adder IS
	port(
		addr_in 	: in std_logic_vector(nbit-1 downto 0);
		addr_out 	: out std_logic_vector(nbit-1 downto 0)
	);
END COMPONENT adder;

COMPONENT rom IS
	GENERIC (SIZE : INTEGER := 512);
	PORT (
		addr 			: IN STD_LOGIC_VECTOR(NBIT-1 DOWNTO 0);
		dataIO 			: INOUT STD_LOGIC_VECTOR(NBIT-1 DOWNTO 0)
	);
END COMPONENT rom;

COMPONENT controller IS 
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
		rst_s 			: IN STD_LOGIC;
		we 				: IN STD_LOGIC;
		raddr_1 		: IN STD_LOGIC_VECTOR(NSEL-1 DOWNTO 0);
		raddr_2 		: IN STD_LOGIC_VECTOR(NSEL-1 DOWNTO 0);
		waddr 			: IN STD_LOGIC_VECTOR(NSEL-1 DOWNTO 0);
		rdata_1 		: OUT STD_LOGIC_VECTOR(NBIT-1 DOWNTO 0);
		rdata_2 		: OUT STD_LOGIC_VECTOR(NBIT-1 DOWNTO 0);
		wdata 			: IN STD_LOGIC_VECTOR(NBIT-1 DOWNTO 0)
	);
END COMPONENT regfile;

COMPONENT sign_extender IS 
	GENERIC (SIZE : INTEGER := 16);
	PORT (
		input		: IN STD_LOGIC_VECTOR(SIZE-1 DOWNTO 0);
		output	: OUT STD_LOGIC_VECTOR(NBIT-1 DOWNTO 0)
	);
END COMPONENT sign_extender;

COMPONENT alu IS
	PORT (
		Func_in			: IN STD_LOGIC_VECTOR (5 DOWNTO 0);
		A_in				: IN STD_LOGIC_VECTOR (NBIT-1 DOWNTO 0);
		B_in				: IN STD_LOGIC_VECTOR (NBIT-1 DOWNTO 0);
		O_out			: OUT STD_LOGIC_VECTOR (NBIT-1 DOWNTO 0);
		Branch_out	: OUT STD_LOGIC
	);
END COMPONENT alu;

COMPONENT ram IS
	GENERIC (SIZE : INTEGER := 512);
	PORT (
		clk		: IN STD_LOGIC;
		we		: IN STD_LOGIC;
		dsize	: IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		addr		: IN STD_LOGIC_VECTOR(NBIT-1 DOWNTO 0);
		dataI	: IN STD_LOGIC_VECTOR(NBIT-1 DOWNTO 0);
		dataO	: OUT STD_LOGIC_VECTOR(NBIT-1 DOWNTO 0)
	);
END COMPONENT ram;

SIGNAL addr_pc : STD_LOGIC_VECTOR(NBIT-1 DOWNTO 0) := (OTHERS=>'0');
SIGNAL addr_instruction : STD_LOGIC_VECTOR(NBIT-1 DOWNTO 0) := (OTHERS=>'0');
SIGNAL instruction, read_data_1, read_data_2, write_data, write_data_temp, ext_imm, alu_input_2 : STD_LOGIC_VECTOR(NBIT-1 DOWNTO 0);
SIGNAL alu_result, ram_output : STD_LOGIC_VECTOR(NBIT-1 DOWNTO 0);
SIGNAL write_address : STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL mtr, mw, br, asrc, regdst, regwrite, bro, jmp: STD_LOGIC;
SIGNAL alu_func : STD_LOGIC_VECTOR(5 DOWNTO 0);
SIGNAL mux1_result, mux2_result, muxj_result, shift_value, alu_input_1 : STD_LOGIC_VECTOR(NBIT-1 DOWNTO 0);
SIGNAL out3 : STD_LOGIC_VECTOR(NBIT-1 DOWNTO 0);
SIGNAL out1, out2 : STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL jalrc, jaldc, luic, jrc, shiftc, jalac : STD_LOGIC;
SIGNAL t1, t2, t3, incr_addr_inst : STD_LOGIC_VECTOR(NBIT-1 DOWNTO 0);
SIGNAL babo, jc: STD_LOGIC;
SIGNAL ds: STD_LOGIC_VECTOR(2 DOWNTO 0);

BEGIN			

					
	inst0 : pc PORT MAP (
						addr_in			=> addr_pc,
						clk 				=> ref_clk,
						rst_s 			=> reset,
						addr_out		=> addr_instruction
					);
	
	inst1 : rom PORT MAP (
						addr				=> addr_instruction,
						dataIO			=> instruction
					);
					
	-- addr_pc <= STD_LOGIC_VECTOR(UNSIGNED(addr_pc)+1);
	
	instpcadd : adder PORT MAP (
						addr_in			=> addr_instruction,
						addr_out		=> incr_addr_inst
					);
	
	babo <= br AND bro;
	t1 <= STD_LOGIC_VECTOR(to_unsigned(to_integer(unsigned(incr_addr_inst)) + to_integer(signed(ext_imm)), 32));
	
	instpca : mux2to1 
					GENERIC MAP (S => 32)
					PORT MAP (
						input_1			=> incr_addr_inst,
						input_2			=> t1,
						sel				=> babo,
						-- sel				=> '0',
						output			=> mux1_result
					);
	
	t2 <=  addr_instruction(NBIT-1 DOWNTO NBIT-6)& instruction(NBIT-7 DOWNTO 0);
	
	inst1mj : mux2to1 
					GENERIC MAP (S => 32)
					PORT MAP (
						input_1			=> t2,
						input_2			=> alu_result,
						sel				=> jrc,
						output			=> muxj_result
					);
	
	
	inst1m2 : mux2to1 
					GENERIC MAP (S => 32)
					PORT MAP (
						input_1			=> mux1_result,
						input_2			=> muxj_result,
						sel				=> jc,
						-- sel				=> '0',
						output			=> addr_pc
					);
	
	inst1s : sign_extender 
					GENERIC MAP (SIZE => 5)
					PORT MAP (
						input				=> instruction(NBIT-22 DOWNTO NBIT-26),
						output			=> shift_value
					);
	
	inst2 : controller PORT MAP (
						opcode			=> instruction(NBIT-1 DOWNTO NBIT-6),
						func_in			=> instruction(NBIT-27 DOWNTO 0),
						rt_in				=> instruction(NBIT-16),
						MemToReg	=> mtr,
						MemWrite		=> mw,
						Branch			=> br,
						ALUControl	=> alu_func,
						ALUSrc			=> asrc,
						RegDst			=> regdst,
						RegWrite		=> regwrite,
						JALRControl	=> jalrc,
						JALDataControl	=> jaldc,
						ShiftValueControl	=> shiftc,
						LUIControl	=> luic,
						JRControl		=> jrc,
						JALAddrControl	=> jalac,
						dsize			=> ds,
						JControl		=> jc
					);
					
					
	insta : mux2to1 
					GENERIC MAP (S => 5)
					PORT MAP (
						input_1			=> instruction(NBIT-17 DOWNTO NBIT-21),
						input_2			=> "11111",
						sel				=> jalrc,
						output			=> out2
					);
	
	
	instb : mux2to1 
					GENERIC MAP (S => 5)
					PORT MAP (
						input_1			=> instruction(NBIT-12 DOWNTO NBIT-16),
						input_2			=> instruction(NBIT-17 DOWNTO NBIT-21),
						sel				=> regdst,
						output			=> out1
					);
	
	instc : mux2to1 
					GENERIC MAP (S => 5)
					PORT MAP (
						input_1			=> out1,
						input_2			=> out2,
						sel				=> jalac,
						output			=> write_address
					);
					
	instd : mux2to1 
					GENERIC MAP (S => 32)
					PORT MAP (
						input_1			=> write_data_temp,
						input_2			=> incr_addr_inst,
						sel				=> jaldc,
						output			=> write_data
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
					
	instshift : mux2to1 
					GENERIC MAP (S => 32)
					PORT MAP (
						input_1			=> read_data_1,
						input_2			=> shift_value,
						sel				=> shiftc,
						output			=> alu_input_1
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
					
	inst8 : alu PORT MAP (
						Func_in			=> alu_func,
						A_in				=> alu_input_1,
						B_in				=> alu_input_2,
						O_out			=> alu_result,
						Branch_out	=> bro
					);

	inst9 : ram PORT MAP (
						clk				=> ref_clk,
						we				=> mw,
						dsize			=> ds,
						addr				=> alu_result,
						dataI			=> read_data_2,
						dataO			=> ram_output
					);
	
	t3 <= alu_result(NBIT-17 DOWNTO 0) & "0000000000000000";
	
	inste : mux2to1 
					GENERIC MAP (S =>32)
					PORT MAP (
						input_1			=> alu_result,
						input_2			=> t3,
						sel				=> luic,
						output			=> out3
					);
	
	inst10 : mux2to1 PORT MAP (
						input_1			=> out3,
						input_2			=> ram_output,
						sel				=> mtr,
						output			=> write_data_temp
					);		
END ARCHITECTURE logic;

