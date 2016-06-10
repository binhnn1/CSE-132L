LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE work.processor_pack.ALL;

ENTITY processor IS
	PORT (
		clk			: IN STD_LOGIC;
		reset			: IN STD_LOGIC;
    out1   : OUT std_logic_vector(31 downto 0);
	);
END ENTITY processor;

ARCHITECTURE logic OF processor IS

COMPONENT pc_clock IS
    PORT(
		addr_in		: IN STD_LOGIC_VECTOR(NBIT-1 DOWNTO 0);
		clk 			: IN  STD_LOGIC;
		rst_s		: IN STD_LOGIC;
		set			: IN STD_LOGIC;
		addr_out 	: OUT STD_LOGIC_VECTOR(NBIT-1 DOWNTO 0)
    );
END COMPONENT pc_clock;

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

COMPONENT mux4to1 IS
	GENERIC (S : INTEGER := 32);
	PORT (
		input_1 	: IN STD_LOGIC_VECTOR(S-1 DOWNTO 0);
		input_2 	: IN STD_LOGIC_VECTOR(S-1 DOWNTO 0);
		input_3 	: IN STD_LOGIC_VECTOR(S-1 DOWNTO 0);
		input_4 	: IN STD_LOGIC_VECTOR(S-1 DOWNTO 0);
		sel 			: IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		output 		: OUT STD_LOGIC_VECTOR(S-1 DOWNTO 0)
	);
END COMPONENT mux4to1;

COMPONENT flipflop IS
	GENERIC (S : INTEGER := 32);
	PORT (
		Set				: IN STD_LOGIC;
		Reset			: IN STD_LOGIC;
		Data				: IN STD_LOGIC_VECTOR(S-1 DOWNTO 0);
		clk				: IN STD_LOGIC;
		Q 					: OUT STD_LOGIC_VECTOR(S-1 DOWNTO 0)
   );
END COMPONENT flipflop;

COMPONENT regfile IS
--	GENERIC (SIZE: INTEGER := 32);
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

COMPONENT hazard_control IS 
	PORT (
		rsE				: IN STD_LOGIC_VECTOR(NSEL-1 DOWNTO 0);
		rtE				: IN STD_LOGIC_VECTOR(NSEL-1 DOWNTO 0);
		wrE				: IN STD_LOGIC_VECTOR(NSEL-1 DOWNTO 0);
		wrM				: IN STD_LOGIC_VECTOR(NSEL-1 DOWNTO 0);
		wrW				: IN STD_LOGIC_VECTOR(NSEL-1 DOWNTO 0);
		rsD				: IN STD_LOGIC_VECTOR(NSEL-1 DOWNTO 0);
		rtD				: IN STD_LOGIC_VECTOR(NSEL-1 DOWNTO 0);
		rwE				: IN STD_LOGIC;
		rwM				: IN STD_LOGIC;
		rwW				: IN STD_LOGIC;
		brD				: IN STD_LOGIC;
		mtrE				: IN STD_LOGIC;
		mtrM			: IN STD_LOGIC;
		fwdAD			: OUT STD_LOGIC;
		fwdBD			: OUT STD_LOGIC;
		fwdAE			: OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		fwdBE			: OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		StallF			: OUT STD_LOGIC;
		StallD			: OUT STD_LOGIC;
		FlushE			: OUT STD_LOGIC
	);
END COMPONENT hazard_control;

COMPONENT flipflop1bit IS
	PORT (
		Set				: IN STD_LOGIC;
		Reset			: IN STD_LOGIC;
		Data				: IN STD_LOGIC;
		clk				: IN STD_LOGIC;
		Q 					: OUT STD_LOGIC
   );
END COMPONENT flipflop1bit;

SIGNAL PC, PCF, PCPlus4F, PCPlus4D, PCPlus4E : STD_LOGIC_VECTOR(NBIT-1 DOWNTO 0) := (OTHERS=>'X');
SIGNAL InstrF, InstrD, InstrE, InstrM, InstrW : STD_LOGIC_VECTOR(NBIT-1 DOWNTO 0) := (OTHERS=>'X');

SIGNAL ReadData1D, ReadData1E : STD_LOGIC_VECTOR(NBIT-1 DOWNTO 0);
SIGNAL ReadData2D, ReadData2E : STD_LOGIC_VECTOR(NBIT-1 DOWNTO 0);

SIGNAL MemToRegD, MemToRegE, MemToRegM, MemToRegW: STD_LOGIC;
SIGNAL MemWriteD, MemWriteE, MemWriteM: STD_LOGIC;
SIGNAL BranchD, BranchE, BranchM: STD_LOGIC;
SIGNAL ALUControlD, ALUControlE : STD_LOGIC_VECTOR(5 DOWNTO 0);
SIGNAL ALUSrcD, ALUSrcE: STD_LOGIC;
SIGNAL RegDstD, RegDstE: STD_LOGIC;
SIGNAL RegWriteD, RegWriteE, RegWriteM, RegWriteW: STD_LOGIC;
SIGNAL JALRControlD, JALRControlE, JALRControlM, JALRControlW: STD_LOGIC;
SIGNAL JALDataControlD, JALDataControlE, JALDataControlM, JALDataControlW: STD_LOGIC;
SIGNAL ShiftValueControlD, ShiftValueControlE, ShiftValueControlM, ShiftValueControlW: STD_LOGIC;
SIGNAL LUIControlD, LUIControlE, LUIControlM, LUIControlW: STD_LOGIC;
SIGNAL JRControlD, JRControlE, JRControlM, JRControlW: STD_LOGIC;
SIGNAL JALAddrControlD, JALAddrControlE, JALAddrControlM, JALAddrControlW: STD_LOGIC;
SIGNAL dsizeD, dsizeE, dsizeM, dsizeW: STD_LOGIC_VECTOR(2 DOWNTO 0);
SIGNAL JControlD,JControlE, JControlM, JControlW : STD_LOGIC;

SIGNAL WriteRegE, WriteRegM, WriteRegW : STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL SignImmD, SignImmE : STD_LOGIC_VECTOR(NBIT-1 DOWNTO 0);
SIGNAL SrcAD, SrcBD, SrcAE, SrcBE : STD_LOGIC_VECTOR(NBIT-1 DOWNTO 0);
SIGNAL WriteDataE, WriteDataM : STD_LOGIC_VECTOR(NBIT-1 DOWNTO 0);
SIGNAL ForwardAE, ForwardBE : STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL ForwardAD, ForwardBD : STD_LOGIC;

SIGNAL ALUOutE, ALUOutM, ALUOutW : STD_LOGIC_VECTOR(NBIT-1 DOWNTO 0);
SIGNAL BranchOutE, BranchOutM : STD_LOGIC;
SIGNAL PCBranchD: STD_LOGIC_VECTOR(NBIT-1 DOWNTO 0);

SIGNAL EqualD, PCSrcD : STD_LOGIC;
SIGNAL ReadDataM, ReadDataW : STD_LOGIC_VECTOR(NBIT-1 DOWNTO 0);

SIGNAL StallF, StallD, FlushE : STD_LOGIC;
SIGNAL ResultW : STD_LOGIC_VECTOR(NBIT-1 DOWNTO 0);
BEGIN
	-- Pre Fetch
	
	inst_mux_pc : mux2to1 
					GENERIC MAP (S => 32)
					PORT MAP (
						input_1			=> PCPlus4F,
						input_2			=> PCBranchD,
						sel				=> PCSrcD,
						output			=> PC
					);
	
	inst_pc_clock : pc_clock PORT MAP (
						addr_in			=> PC,
						clk 				=> clk,
						rst_s 			=> reset,
						set				=> StallF,
						addr_out		=> PCF
					);
	-- Fetch
	inst_rom : rom PORT MAP (
						addr				=> PCF,
						dataIO			=> InstrF
					);
					
	
	-- inst_pc_adder : adder PORT MAP (
						-- addr_in			=> PCF,
						-- addr_out		=> PCPlus4F
					-- );
	PCPlus4F <= STD_LOGIC_VECTOR(to_unsigned(to_integer(unsigned(PCF)) + 1, 32));
	
	inst_inst_ff_FD: flipflop
					GENERIC MAP (S=>32)
					PORT MAP (
						Set				=> StallD,
						Reset			=> PCSrcD,
						Data				=> InstrF,
						clk				=> clk,
						Q					=> InstrD
					);
	
	inst_pcplus4_ff_FD: flipflop
					GENERIC MAP (S=>32)
					PORT MAP (
						Set				=> StallD,
						Reset			=> PCSrcD,
						Data				=> PCPlus4F,
						clk				=> clk,
						Q					=> PCPlus4D
					);
	
	-- -- babo <= br AND bro;
	-- -- t1 <= STD_LOGIC_VECTOR(to_unsigned(to_integer(unsigned(PCPlus4F)) + to_integer(unsigned(ext_imm)), 32));
	

	
	-- -- t2 <=  addr_instruction(NBIT-1 DOWNTO NBIT-6)& instruction(NBIT-7 DOWNTO 0);
	
	-- -- inst_br_jump : mux2to1 
					-- -- GENERIC MAP (S => 32)
					-- -- PORT MAP (
						-- -- input_1			=> t2,
						-- -- input_2			=> alu_result,
						-- -- sel				=> jrc,
						-- -- output			=> muxj_result
					-- -- );
	
	
	-- -- inst1m2 : mux2to1 
					-- -- GENERIC MAP (S => 32)
					-- -- PORT MAP (
						-- -- input_1			=> mux1_result,
						-- -- input_2			=> muxj_result,
						-- -- sel				=> jc,
						-- -- output			=> addr_pc
					-- -- );
	
	
	-- -- inst_sign_extender : sign_extender 
					-- -- GENERIC MAP (SIZE => 5)
					-- -- PORT MAP (
						-- -- input				=> instruction(NBIT-22 DOWNTO NBIT-26),
						-- -- output			=> shift_value
					-- -- );
	
	-- Decode
	inst_controller : controller PORT MAP (
						opcode			=> InstrD(NBIT-1 DOWNTO NBIT-6),
						func_in			=> InstrD(NBIT-27 DOWNTO 0),
						rt_in				=> InstrD(NBIT-16),
						MemToReg	=> MemToRegD,
						MemWrite		=> MemWriteD,
						Branch			=> BranchD,
						ALUControl	=> ALUControlD,
						ALUSrc			=> ALUSrcD,
						RegDst			=> RegDstD,
						RegWrite		=> RegWriteD,
						JALRControl	=> JALRControlD,
						JALDataControl	=> JALDataControlD,
						ShiftValueControl	=> ShiftValueControlD,
						LUIControl	=> LUIControlD,
						JRControl		=> JRControlD,
						JALAddrControl	=> JALAddrControlD,
						dsize			=> dsizeD,
						JControl		=> JControlD
					);
					
	inst_regfile : regfile PORT MAP (
						clk				=> clk,
						rst_s			=> reset,
						we				=> RegWriteW,
						raddr_1		=> InstrD(NBIT-7 DOWNTO NBIT-11),
						raddr_2		=> InstrD(NBIT-12 DOWNTO NBIT-16),
						waddr			=> WriteRegW,
						rdata_1		=> ReadData1D,
						rdata_2		=> ReadData2D,
						wdata			=> ResultW
					);
					
	inst_mux_SrcAD : mux2to1 
					GENERIC MAP (S =>32)
					PORT MAP (
						input_1			=> ReadData1D,
						input_2			=> ALUOutM,
						sel				=> ForwardAD,
						output			=> SrcAD
					);
					
	inst_mux_SrcBD : mux2to1 
					GENERIC MAP (S =>32)
					PORT MAP (
						input_1			=> ReadData2D,
						input_2			=> ALUOutM,
						sel				=> ForwardBD,
						output			=> SrcBD
					);
	
	EqualD <= '1' WHEN SrcAD = SrcBD ELSE '0';
	PCSrcD <= EqualD AND BranchD;
	
	inst_sign_extender : sign_extender PORT MAP (
						input				=> InstrD(NBIT-17 DOWNTO 0),
						output			=> SignImmD
					);
	
	PCBranchD <= STD_LOGIC_VECTOR(to_unsigned(to_integer(unsigned(PCPlus4D)) + to_integer(unsigned(SignImmD)), 32));
	
	inst_RegWrite_ff_DE: flipflop1bit
					PORT MAP (
						Set				=> '0',
						Reset			=> FlushE,
						Data				=> RegWriteD,
						clk				=> clk,
						Q					=> RegWriteE
					);
	
	inst_MemToReg_ff_DE: flipflop1bit
					PORT MAP (
						Set				=> '0',
						Reset			=> FlushE,
						Data				=> MemToRegD,
						clk				=> clk,
						Q					=> MemToRegE
					);
					
	inst_MemWrite_ff_DE: flipflop1bit
					PORT MAP (
						Set				=> '0',
						Reset			=> FlushE,
						Data				=> MemWriteD,
						clk				=> clk,
						Q					=> MemWriteE
					);
					
	inst_Branch_ff_DE: flipflop1bit
					PORT MAP (
						Set				=> '0',
						Reset			=> FlushE,
						Data				=> BranchD,
						clk				=> clk,
						Q					=> BranchE
					);
					
	inst_ALUControl_ff_DE: flipflop
					GENERIC MAP (S=>6)
					PORT MAP (
						Set				=> '0',
						Reset			=> FlushE,
						Data				=> ALUControlD,
						clk				=> clk,
						Q					=> ALUControlE
					);
					
	inst_ALUSrc_ff_DE: flipflop1bit
					PORT MAP (
						Set				=> '0',
						Reset			=> FlushE,
						Data				=> ALUSrcD,
						clk				=> clk,
						Q					=> ALUSrcE
					);	
					
	inst_RegDst_ff_DE: flipflop1bit
					PORT MAP (
						Set				=> '0',
						Reset			=> FlushE,
						Data				=> RegDstD,
						clk				=> clk,
						Q					=> RegDstE
					);
					
	inst_dsize_ff_DE: flipflop
					GENERIC MAP (S=>3)
					PORT MAP (
						Set				=> '0',
						Reset			=> FlushE,
						Data				=> dsizeD,
						clk				=> clk,
						Q					=> dsizeE
					);
					
	-- inst_mux_jalrc : mux2to1 
					-- GENERIC MAP (S => 5)
					-- PORT MAP (
						-- input_1			=> instruction(NBIT-17 DOWNTO NBIT-21),
						-- input_2			=> "11111",
						-- sel				=> jalrc,
						-- output			=> out2
					-- );
					
	inst_ReadData1_ff_DE: flipflop
					GENERIC MAP (S=>32)
					PORT MAP (
						Set				=> '0',
						Reset			=> FlushE,
						Data				=> ReadData1D,
						clk				=> clk,
						Q					=> ReadData1E
					);

	inst_ReadData2_ff_DE: flipflop
					GENERIC MAP (S=>32)
					PORT MAP (
						Set				=> '0',
						Reset			=> FlushE,
						Data				=> ReadData2D,
						clk				=> clk,
						Q					=> ReadData2E
					);
	
	inst_inst_ff_DE: flipflop
					GENERIC MAP (S=>32)
					PORT MAP (
						Set				=> '0',
						Reset			=> FlushE,
						Data				=> InstrD,
						clk				=> clk,
						Q					=> InstrE
					);
	

					
	-- inst_mux_jalac : mux2to1 
					-- GENERIC MAP (S => 5)
					-- PORT MAP (
						-- input_1			=> out1,
						-- input_2			=> out2,
						-- sel				=> jalac,
						-- output			=> write_address
					-- );
					
	-- inst_mux_jaldc : mux2to1 
					-- GENERIC MAP (S => 32)
					-- PORT MAP (
						-- input_1			=> write_data_temp,
						-- input_2			=> incr_addr_inst,
						-- sel				=> jaldc,
						-- output			=> write_data
					-- );
					

	

					
	-- inst_mux_shift : mux2to1 
					-- GENERIC MAP (S => 32)
					-- PORT MAP (
						-- input_1			=> read_data_1,
						-- input_2			=> shift_value,
						-- sel				=> shiftc,
						-- output			=> alu_input_1
					-- );
					

					
	inst_SignImm_ff_DE: flipflop
					GENERIC MAP (S=>32)
					PORT MAP (
						Set				=> '0',
						Reset			=> FlushE,
						Data				=> SignImmD,
						clk				=> clk,
						Q					=> SignImmE
					);
					
	inst_pcplus4_ff_DE: flipflop
					GENERIC MAP (S=>32)
					PORT MAP (
						Set				=> '0',
						Reset			=> FlushE,
						Data				=> PCPlus4D,
						clk				=> clk,
						Q					=> PCPlus4E
					);
	-- Execution
	inst_mux_SrcAE : mux4to1
					GENERIC MAP (S => 32)
					PORT MAP (
						input_1			=> ReadData1E,
						input_2			=> ResultW,
						input_3			=> ALUOutM,
						input_4			=> (OTHERS=>'0'),
						sel 				=> ForwardAE,
						output			=> SrcAE
					);
	
	inst_mux_WriteDataE : mux4to1
					GENERIC MAP (S => 32)
					PORT MAP (
						input_1			=> ReadData2E,
						input_2			=> ResultW,
						input_3			=> ALUOutM,
						input_4			=> (OTHERS=>'0'),
						sel				=> ForwardBE,
						output			=> WriteDataE
					);
					
	inst_mux_SrcBE : mux2to1 
					GENERIC MAP (S =>32)
					PORT MAP (
						input_1			=> WriteDataE,
						input_2			=> SignImmE,
						sel				=> ALUSrcE,
						output			=> SrcBE
					);
					
	inst_mux_WriteRegE : mux2to1 
					GENERIC MAP (S => 5)
					PORT MAP (
						input_1			=> InstrE(NBIT-12 DOWNTO NBIT-16),
						input_2			=> InstrE(NBIT-17 DOWNTO NBIT-21),
						sel				=> RegDstE,
						output			=> WriteRegE
					);
					
	inst_alu : alu PORT MAP (
						Func_in			=> ALUControlE,
						A_in				=> SrcAE,
						B_in				=> SrcBE,
						O_out			=> ALUOutE,
						Branch_out	=> BranchOutE
					);

	-- PCBranchE <= STD_LOGIC_VECTOR(to_unsigned(to_integer(unsigned(PCPlus4E)) + to_integer(unsigned(SignImmE)), 32));
	
	inst_RegWrite_ff_EM: flipflop1bit
					PORT MAP (
						Set				=> '0',
						Reset			=> '0',
						Data				=> RegWriteE,
						clk				=> clk,
						Q					=> RegWriteM
					);
	
	inst_MemToReg_ff_EM: flipflop1bit
					PORT MAP (
						Set				=> '0',
						Reset			=> '0',
						Data				=> MemToRegE,
						clk				=> clk,
						Q					=> MemToRegM
					);
					
	inst_MemWrite_ff_EM: flipflop1bit
					PORT MAP (
						Set				=> '0',
						Reset			=> '0',
						Data				=> MemWriteE,
						clk				=> clk,
						Q					=> MemWriteM
					);
					
	inst_dsize_ff_EM: flipflop
					GENERIC MAP (S=>3)
					PORT MAP (
						Set				=> '0',
						Reset			=> '0',
						Data				=> dsizeE,
						clk				=> clk,
						Q					=> dsizeM
					);
					
	inst_Branch_ff_EM: flipflop1bit
					PORT MAP (
						Set				=> '0',
						Reset			=> '0',
						Data				=> BranchE,
						clk				=> clk,
						Q					=> BranchM
					);
					
	inst_BranchOut_ff_EM: flipflop1bit
					PORT MAP (
						Set				=> '0',
						Reset			=> '0',
						Data				=> BranchOutE,
						clk				=> clk,
						Q					=> BranchOutM
					);
					
	inst_ALUOut_ff_EM: flipflop
					GENERIC MAP (S=>32)
					PORT MAP (
						Set				=> '0',
						Reset			=> '0',
						Data				=> ALUOutE,
						clk				=> clk,
						Q					=> ALUOutM
					);	
					
	inst_WriteData_ff_EM: flipflop
					GENERIC MAP (S=>32)
					PORT MAP (
						Set				=> '0',
						Reset			=> '0',
						Data				=> WriteDataE,
						clk				=> clk,
						Q					=> WriteDataM
					);

	inst_WriteReg_ff_EM: flipflop
					GENERIC MAP (S=>5)
					PORT MAP (
						Set				=> '0',
						Reset			=> '0',
						Data				=> WriteRegE,
						clk				=> clk,
						Q					=> WriteRegM
					);	
	
	-- inst_PCBranch_ff_EM: flipflop
					-- GENERIC MAP (S=>32)
					-- PORT MAP (
						-- Set				=> '0',
						-- Reset			=> '0',
						-- Data				=> PCBranchE,
						-- clk				=> clk,
						-- Q					=> PCBranchM
					-- );
					
	inst_inst_ff_EM: flipflop
					GENERIC MAP (S=>32)
					PORT MAP (
						Set				=> '0',
						Reset			=> '0',
						Data				=> InstrE,
						clk				=> clk,
						Q					=> InstrM
					);
					
	-- Memory
	-- PCSrcM <= BranchM AND BranchOutM;
	
	inst_ram : ram PORT MAP (
						clk				=> clk,
						we				=> MemWriteM,
						dsize			=> dsizeM,
						addr				=> ALUOutM,
						dataI			=> WriteDataM,
						dataO			=> ReadDataM
					);

	inst_RegWrite_ff_MW: flipflop1bit
					PORT MAP (
						Set				=> '0',
						Reset			=> '0',
						Data				=> RegWriteM,
						clk				=> clk,
						Q					=> RegWriteW
					);
					
	inst_MemToReg_ff_MW: flipflop1bit
					PORT MAP (
						Set				=> '0',
						Reset			=> '0',
						Data				=> MemToRegM,
						clk				=> clk,
						Q					=> MemToRegW
					);
	
	inst_ReadData_ff_MW: flipflop
					GENERIC MAP (S=>32)
					PORT MAP (
						Set				=> '0',
						Reset			=> '0',
						Data				=> ReadDataM,
						clk				=> clk,
						Q					=> ReadDataW
					);	
	
	inst_ALUOut_ff_MW: flipflop
					GENERIC MAP (S=>32)
					PORT MAP (
						Set				=> '0',
						Reset			=> '0',
						Data				=> ALUOutM,
						clk				=> clk,
						Q					=> ALUOutW
					);	
					
	inst_WriteReg_ff_MW: flipflop
					GENERIC MAP (S=>5)
					PORT MAP (
						Set				=> '0',
						Reset			=> '0',
						Data				=> WriteRegM,
						clk				=> clk,
						Q					=> WriteRegW
					);
					
	-- inst_inst_ff_MW: flipflop
					-- GENERIC MAP (S=>32)
					-- PORT MAP (
						-- Set				=> '0',
						-- Reset			=> '0',
						-- Data				=> InstrM,
						-- clk				=> clk,
						-- Q					=> InstrW
					-- );
	
	-- Write Back
	-- -- t3 <= alu_result(NBIT-17 DOWNTO 0) & "0000000000000000";
	
	-- -- inst_mux_ResultW : mux2to1 
					-- -- GENERIC MAP (S =>32)
					-- -- PORT MAP (
						-- -- input_1			=> alu_result,
						-- -- input_2			=> t3,
						-- -- sel				=> luic,
						-- -- output			=> out3
					-- -- );
	
	inst_mux_ResultW : mux2to1 PORT MAP (
						input_1			=> ALUOutW,
						input_2			=> ReadDataW,
						sel				=> MemToRegW,
						output			=> ResultW
					);	
					
	-- Data Hazard Control
	inst_hazard_control: hazard_control PORT MAP (
		rsE				=> InstrE(NBIT-7 DOWNTO NBIT-11),
		rtE				=> InstrE(NBIT-12 DOWNTO NBIT-16),
		wrE				=> WriteRegE,
		wrM				=> WriteRegM,
		wrW				=> WriteRegW,
		rsD				=> InstrD(NBIT-7 DOWNTO NBIT-11),
		rtD				=> InstrD(NBIT-12 DOWNTO NBIT-16),
		rwE				=> RegWriteE,
		rwM				=> RegWriteM,
		rwW				=> RegWriteW,
		brD				=> BranchD,
		mtrE				=> MemToRegE,
		mtrM			=> MemToRegM,
		fwdAD			=> ForwardAD,
		fwdBD			=> ForwardBD,
		fwdAE			=> ForwardAE,
		fwdBE			=> ForwardBE,
		StallF			=> StallF,
		StallD			=> StallD,
		FlushE			=> FlushE
	);
 
 out1 <= ResultW;
END ARCHITECTURE logic;

