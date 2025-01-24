-------------------------------------------------------------------------
-- Justin Sebahar and Jackson Collalti
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- MIPS_Processor.vhd
-- Our implementation of a software-scheduled pipelined processor.
-------------------------------------------------------------------------
-- 11/7/2014
-------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

LIBRARY work;
USE work.MIPS_types.ALL;

ENTITY MIPS_Processor IS
	GENERIC (N : INTEGER := DATA_WIDTH);
	PORT (
		iCLK : IN STD_LOGIC;
		iRST : IN STD_LOGIC;
		iInstLd : IN STD_LOGIC;
		iInstAddr : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
		iInstExt : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
		oALUOut : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0)); -- TODO: Hook this up to the output of the ALU. It is important for synthesis that you have this output that can effectively be impacted by all other components so they are not optimized away.

END MIPS_Processor;
ARCHITECTURE structure OF MIPS_Processor IS

	COMPONENT mem IS
		GENERIC (
			ADDR_WIDTH : INTEGER;
			DATA_WIDTH : INTEGER);
		PORT (
			clk : IN STD_LOGIC;
			addr : IN STD_LOGIC_VECTOR((ADDR_WIDTH - 1) DOWNTO 0);
			data : IN STD_LOGIC_VECTOR((DATA_WIDTH - 1) DOWNTO 0);
			we : IN STD_LOGIC := '1';
			q : OUT STD_LOGIC_VECTOR((DATA_WIDTH - 1) DOWNTO 0));
	END COMPONENT;

	-- TODO: You may add any additional signals or components your implementation 
	--       requires below this comment
	COMPONENT FetchLogic IS
		GENERIC (
			N : INTEGER := 32;
			M : INTEGER := 26);
		PORT (
			i_CLK : IN STD_LOGIC;
			i_RST : IN STD_LOGIC;
			i_Zero : IN STD_LOGIC; --Zero from ALU component
			i_PC : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0); --Previous PC
			i_JRAddress : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
			i_JREnable : IN STD_LOGIC;
			i_JumpAddress : IN STD_LOGIC_VECTOR(M - 1 DOWNTO 0);
			i_JumpEnable : IN STD_LOGIC;
			i_BranchAddress : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
			i_BranchEnable : IN STD_LOGIC;
			i_BranchType : IN STD_LOGIC; --BNE = 0, BEQ = 1
			o_PC : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0)); --Next PC
	END COMPONENT;

	COMPONENT controller IS
		PORT (
			i_OPCODE : IN STD_LOGIC_VECTOR(5 DOWNTO 0); --bits [31:26] of instruction
			i_FUNCTION : IN STD_LOGIC_VECTOR(5 DOWNTO 0); --bits [5:0] of instruction
			o_ALUOP : OUT STD_LOGIC_VECTOR(3 DOWNTO 0); --4-bit function to be fed into ALU to determine alu function
			o_DST_REG : OUT STD_LOGIC; --0=rt/1=rd
			o_ALUSrc : OUT STD_LOGIC; --0=register/1=immediate
			o_EXTENSION : OUT STD_LOGIC; --0=unsigned/1=signed
			o_MEM_TO_REG : OUT STD_LOGIC; --0=ALU/1=memory
			o_REG_WRITE : OUT STD_LOGIC; --0=disabled/1=enabled
			o_MEM_WRITE : OUT STD_LOGIC; --0=disabled/1=enabled
			o_BRANCH : OUT STD_LOGIC; --0=no/1=yes
			o_BRANCH_TYPE : OUT STD_LOGIC; --BNE = 0, BEQ = 1
			o_JUMP_EN : OUT STD_LOGIC; --0=no/1=yes
			o_JR : OUT STD_LOGIC; --0=no/1=yes
			o_JAL : OUT STD_LOGIC; --0=no/1=yes
			o_HALT : OUT STD_LOGIC
		);
	END COMPONENT;

	COMPONENT register_N IS
		GENERIC (N : INTEGER := 32);
		PORT (
			i_CLK : IN STD_LOGIC;
			i_Reset : IN STD_LOGIC;
			i_W : IN STD_LOGIC;
			i_IN : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
			o_Q : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0));
	END COMPONENT;

	COMPONENT register_file IS
		PORT (
			i_CLOCK : IN STD_LOGIC;
			i_RESET : IN STD_LOGIC;
			i_WriteTo : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
			i_WEN : IN STD_LOGIC;
			i_INPUT : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			i_MUX_SELECT1 : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
			i_MUX_SELECT2 : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
			o_OUT1 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			o_OUT2 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
	END COMPONENT;

	COMPONENT mux2t1_N IS
		GENERIC (N : INTEGER := 32);
		PORT (
			i_S : IN STD_LOGIC;
			i_D0 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
			i_D1 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
			o_O : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0));

	END COMPONENT;

	COMPONENT bit_extender IS
		PORT (
			i_select : IN STD_LOGIC;
			i_immediate : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
			o_extended : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
	END COMPONENT;

	COMPONENT ripple_carry_adder IS
		GENERIC (N : INTEGER := 32);
		PORT (
			i_X : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
			i_Y : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
			i_RCin : IN STD_LOGIC;
			o_S : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
			o_RCout : OUT STD_LOGIC);
	END COMPONENT;

	COMPONENT ALU IS
		PORT (
			i_Operand_A : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			i_Operand_B : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			i_ShiftAmount : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
			i_ALUOP : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			o_Result : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			o_CarryOut : OUT STD_LOGIC;
			o_Overflow : OUT STD_LOGIC;
			o_Zero : OUT STD_LOGIC);
	END COMPONENT;

	-- Required data memory signals
	SIGNAL s_DMemWr : STD_LOGIC; -- TODO: use this signal as the final active high data memory write enable signal
	SIGNAL s_DMemAddr : STD_LOGIC_VECTOR(N - 1 DOWNTO 0); -- TODO: use this signal as the final data memory address input
	SIGNAL s_DMemData : STD_LOGIC_VECTOR(N - 1 DOWNTO 0); -- TODO: use this signal as the final data memory data input
	SIGNAL s_DMemOut : STD_LOGIC_VECTOR(N - 1 DOWNTO 0); -- TODO: use this signal as the data memory output

	-- Required register file signals 
	SIGNAL s_RegWr : STD_LOGIC; -- TODO: use this signal as the final active high write enable input to the register file
	SIGNAL s_RegWrAddr : STD_LOGIC_VECTOR(4 DOWNTO 0); -- TODO: use this signal as the final destination register address input
	SIGNAL s_RegWrData : STD_LOGIC_VECTOR(N - 1 DOWNTO 0); -- TODO: use this signal as the final data memory data input

	-- Required instruction memory signals
	SIGNAL s_IMemAddr : STD_LOGIC_VECTOR(N - 1 DOWNTO 0); -- Do not assign this signal, assign to s_NextInstAddr instead
	SIGNAL s_NextInstAddr : STD_LOGIC_VECTOR(N - 1 DOWNTO 0); -- TODO: use this signal as your intended final instruction memory address input.
	SIGNAL s_Inst : STD_LOGIC_VECTOR(N - 1 DOWNTO 0); -- TODO: use this signal as the instruction signal 

	-- Required halt signal -- for simulation
	SIGNAL s_Halt : STD_LOGIC; -- TODO: this signal indicates to the simulation that intended program execution has completed. (Opcode: 01 0100)

	-- Required overflow signal -- for overflow exception detection
	SIGNAL s_Ovfl : STD_LOGIC; -- TODO: this signal indicates an overflow exception would have been initiated

	--- IF signals
	SIGNAL s_IF_IMemAddr : STD_LOGIC_VECTOR(N - 1 DOWNTO 0);

	--- ID signals
	SIGNAL s_ID_Inst : STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
	SIGNAL s_ID_IMemAddr : STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
	SIGNAL s_ID_ALUOP : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL s_ID_DST_REG : STD_LOGIC_VECTOR(0 DOWNTO 0) := "0";
	SIGNAL s_ID_Reg_WR : STD_LOGIC_VECTOR(0 DOWNTO 0) := "0";
	SIGNAL s_ID_Mem_WR : STD_LOGIC_VECTOR(0 DOWNTO 0) := "0";
	SIGNAL s_ID_ALUSrc : STD_LOGIC_VECTOR(0 DOWNTO 0) := "0";
	SIGNAL s_ID_EXTENSION : STD_LOGIC_VECTOR(0 DOWNTO 0) := "0";
	SIGNAL s_ID_MEM_TO_REG : STD_LOGIC_VECTOR(0 DOWNTO 0) := "0";
	SIGNAL s_ID_BRANCH : STD_LOGIC_VECTOR(0 DOWNTO 0) := "0";
	SIGNAL s_ID_BRANCH_TYPE : STD_LOGIC_VECTOR(0 DOWNTO 0) := "0";
	SIGNAL s_ID_JUMP_EN : STD_LOGIC_VECTOR(0 DOWNTO 0) := "0";
	SIGNAL s_ID_JR : STD_LOGIC_VECTOR(0 DOWNTO 0) := "0";
	SIGNAL s_ID_JAL : STD_LOGIC_VECTOR(0 DOWNTO 0) := "0";
	SIGNAL s_ID_Halt : STD_LOGIC_VECTOR(0 DOWNTO 0) := "0";

	SIGNAL s_ID_regOutRs : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL s_ID_regOutRt : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL s_ID_imm_extended : STD_LOGIC_VECTOR(31 DOWNTO 0);

	--- EX signals
	SIGNAL s_EX_IMemAddr : STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
	SIGNAL s_EX_Inst : STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
	SIGNAL s_EX_ALUOP : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL s_EX_DST_REG : STD_LOGIC_VECTOR(0 DOWNTO 0) := "0";
	SIGNAL s_EX_ALUSrc : STD_LOGIC_VECTOR(0 DOWNTO 0) := "0";
	SIGNAL s_EX_MEM_TO_REG : STD_LOGIC_VECTOR(0 DOWNTO 0) := "0";
	SIGNAL s_EX_Reg_WR : STD_LOGIC_VECTOR(0 DOWNTO 0) := "0";
	SIGNAL s_EX_Mem_WR : STD_LOGIC_VECTOR(0 DOWNTO 0) := "0";
	SIGNAL s_EX_BRANCH : STD_LOGIC_VECTOR(0 DOWNTO 0) := "0";
	SIGNAL s_EX_BRANCH_TYPE : STD_LOGIC_VECTOR(0 DOWNTO 0) := "0";
	SIGNAL s_EX_JUMP_EN : STD_LOGIC_VECTOR(0 DOWNTO 0) := "0";
	SIGNAL s_EX_JR : STD_LOGIC_VECTOR(0 DOWNTO 0) := "0";
	SIGNAL s_EX_JAL : STD_LOGIC_VECTOR(0 DOWNTO 0) := "0";
	SIGNAL s_EX_Halt : STD_LOGIC_VECTOR(0 DOWNTO 0) := "0";

	SIGNAL s_EX_regOutRs : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL s_EX_regOutRt : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL s_EX_imm_extended : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL s_EX_Ovfl : STD_LOGIC_VECTOR(0 DOWNTO 0) := "0";

	--- DM signals
	SIGNAL s_DM_IMemAddr : STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
	SIGNAL s_DM_Reg_WR : STD_LOGIC_VECTOR(0 DOWNTO 0) := "0";
	SIGNAL s_DM_Mem_WR : STD_LOGIC_VECTOR(0 DOWNTO 0) := "0";
	SIGNAL s_DM_MEM_TO_REG : STD_LOGIC_VECTOR(0 DOWNTO 0) := "0";
	SIGNAL s_DM_DST_REG : STD_LOGIC_VECTOR(0 DOWNTO 0) := "0";
	SIGNAL s_DM_JAL : STD_LOGIC_VECTOR(0 DOWNTO 0) := "0";
	SIGNAL s_DM_Halt : STD_LOGIC_VECTOR(0 DOWNTO 0) := "0";
	SIGNAL s_DM_ALURes : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL s_DM_DMemOut : STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
	SIGNAL s_DM_Inst : STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
	SIGNAL s_DM_regOutRs : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL s_DM_regOutRt : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL s_DM_Ovfl : STD_LOGIC_VECTOR(0 DOWNTO 0) := "0";

	--- WB signals
	SIGNAL s_WB_MEM_TO_REG : STD_LOGIC_VECTOR(0 DOWNTO 0) := "0";
	SIGNAL s_WB_Reg_WR : STD_LOGIC_VECTOR(0 DOWNTO 0) := "0";
	SIGNAL s_WB_Halt : STD_LOGIC_VECTOR(0 DOWNTO 0) := "0";
	SIGNAL s_WB_DMemOut : STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
	SIGNAL s_WB_DST_REG : STD_LOGIC_VECTOR(0 DOWNTO 0) := "0";
	SIGNAL s_WB_Inst : STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
	SIGNAL s_WB_jal_mux2_out : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL s_WB_JAL : STD_LOGIC_VECTOR(0 DOWNTO 0) := "0";
	SIGNAL s_WB_Ovfl : STD_LOGIC_VECTOR(0 DOWNTO 0) := "0";

	--- Other signals
	SIGNAL s_register_dst_mux_out : STD_LOGIC_VECTOR(4 DOWNTO 0);
	SIGNAL s_alu_input : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL s_alu_result : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL s_Zero : STD_LOGIC;
	SIGNAL s_pc_incremented : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL s_jal_mux2_out : STD_LOGIC_VECTOR(31 DOWNTO 0);

	-----------------------------------------------------------------------------------------

BEGIN

	WITH iInstLd SELECT
		s_IMemAddr <= s_NextInstAddr WHEN '0',
		iInstAddr WHEN OTHERS;

	---IF

	fetch : FetchLogic PORT MAP(
		i_CLK => iCLK,
		i_RST => iRST,
		i_Zero => s_Zero,
		i_PC => s_IMemAddr,
		i_JRAddress => s_EX_regOutRs,
		i_JREnable => s_EX_JR(0),
		i_JumpAddress => s_EX_Inst(25 DOWNTO 0),
		i_JumpEnable => s_EX_JUMP_EN(0),
		i_BranchAddress => s_EX_imm_extended,
		i_BranchEnable => s_EX_BRANCH(0),
		i_BranchType => s_EX_BRANCH_TYPE(0),
		o_PC => s_NextInstAddr
	);

	IMem : mem
	GENERIC MAP(
		ADDR_WIDTH => ADDR_WIDTH,
		DATA_WIDTH => N)
	PORT MAP(
		clk => iCLK,
		addr => s_IMemAddr(11 DOWNTO 2),
		data => iInstExt,
		we => iInstLd,
		q => s_Inst);

	IF_INST : register_N PORT MAP(i_CLK => iCLK, i_Reset => iRST, i_W => '1', i_IN => s_Inst, o_Q => s_ID_Inst);
	IF_IMemAddr : register_N GENERIC MAP(N => N) PORT MAP(i_CLK => iCLK, i_Reset => iRST, i_W => '1', i_IN => s_IMemAddr, o_Q => s_ID_IMemAddr);

	----------------------------------------------------------------------------------------------------------------------------------
	---ID

	-- Get control signals
	control : controller PORT MAP(
		i_OPCODE => s_ID_Inst(31 DOWNTO 26),
		i_FUNCTION => s_ID_Inst(5 DOWNTO 0),
		o_ALUOP => s_ID_ALUOP,
		o_DST_REG => s_ID_DST_REG(0),
		o_ALUSrc => s_ID_ALUSrc(0),
		o_EXTENSION => s_ID_EXTENSION(0),
		o_MEM_TO_REG => s_ID_MEM_TO_REG(0),
		o_REG_WRITE => s_ID_Reg_WR(0),
		o_MEM_WRITE => s_ID_Mem_WR(0),
		o_BRANCH => s_ID_BRANCH(0),
		o_BRANCH_TYPE => s_ID_BRANCH_TYPE(0),
		o_JUMP_EN => s_ID_JUMP_EN(0),
		o_JR => s_ID_JR(0),
		o_JAL => s_ID_JAL(0),
		o_HALT => s_ID_Halt(0)
	);
	-- Register file
	reg_file : register_file PORT MAP(
		i_CLOCK => NOT iCLK,
		i_RESET => iRST,
		i_WriteTo => s_RegWrAddr,
		i_WEN => s_WB_Reg_WR(0),
		i_INPUT => s_RegWrData,
		i_MUX_SELECT1 => s_ID_Inst(25 DOWNTO 21),
		i_MUX_SELECT2 => s_ID_Inst(20 DOWNTO 16),
		o_OUT1 => s_ID_regOutRs,
		o_OUT2 => s_ID_regOutRt
	);

	extend : bit_extender PORT MAP(i_select => s_ID_EXTENSION(0), i_immediate => s_ID_Inst(15 DOWNTO 0), o_extended => s_ID_imm_extended);

	s_RegWr <= s_WB_Reg_WR(0);

	ID_INST : register_N GENERIC MAP(N => 32) PORT MAP(i_CLK => iCLK, i_Reset => iRST, i_W => '1', i_IN => s_ID_Inst, o_Q => s_EX_Inst);
	ID_IMemAddr : register_N GENERIC MAP(N => N) PORT MAP(i_CLK => iCLK, i_Reset => iRST, i_W => '1', i_IN => s_ID_IMemAddr, o_Q => s_EX_IMemAddr);
	ID_ALUSrc : register_N GENERIC MAP(N => 1) PORT MAP(i_CLK => iCLK, i_Reset => iRST, i_W => '1', i_IN => s_ID_ALUSrc, o_Q => s_EX_ALUSrc);
	ID_ALUOp : register_N GENERIC MAP(N => 4) PORT MAP(i_CLK => iCLK, i_Reset => iRST, i_W => '1', i_IN => s_ID_ALUOp, o_Q => s_EX_ALUOp);
	ID_RegDst : register_N GENERIC MAP(N => 1) PORT MAP(i_CLK => iCLK, i_Reset => iRST, i_W => '1', i_IN => s_ID_DST_REG, o_Q => s_EX_DST_REG);
	ID_MemToReg : register_N GENERIC MAP(N => 1) PORT MAP(i_CLK => iCLK, i_Reset => iRST, i_W => '1', i_IN => s_ID_MEM_TO_REG, o_Q => s_EX_MEM_TO_REG);
	ID_RegWr : register_N GENERIC MAP(N => 1) PORT MAP(i_CLK => iCLK, i_Reset => iRST, i_W => '1', i_IN => s_ID_Reg_WR, o_Q => s_EX_Reg_WR);
	ID_MemWr : register_N GENERIC MAP(N => 1) PORT MAP(i_CLK => iCLK, i_Reset => iRST, i_W => '1', i_IN => s_ID_Mem_WR, o_Q => s_EX_Mem_WR);
	ID_Branch : register_N GENERIC MAP(N => 1) PORT MAP(i_CLK => iCLK, i_Reset => iRST, i_W => '1', i_IN => s_ID_BRANCH, o_Q => s_EX_BRANCH);
	ID_BranchType : register_N GENERIC MAP(N => 1) PORT MAP(i_CLK => iCLK, i_Reset => iRST, i_W => '1', i_IN => s_ID_BRANCH_TYPE, o_Q => s_EX_BRANCH_TYPE);
	ID_JumpEN : register_N GENERIC MAP(N => 1) PORT MAP(i_CLK => iCLK, i_Reset => iRST, i_W => '1', i_IN => s_ID_JUMP_EN, o_Q => s_EX_JUMP_EN);
	ID_JR : register_N GENERIC MAP(N => 1) PORT MAP(i_CLK => iCLK, i_Reset => iRST, i_W => '1', i_IN => s_ID_JR, o_Q => s_EX_JR);
	ID_JAL : register_N GENERIC MAP(N => 1) PORT MAP(i_CLK => iCLK, i_Reset => iRST, i_W => '1', i_IN => s_ID_JAL, o_Q => s_EX_JAL);
	ID_HALT : register_N GENERIC MAP(N => 1) PORT MAP(i_CLK => iCLK, i_Reset => iRST, i_W => '1', i_IN => s_ID_Halt, o_Q => s_EX_Halt);
	ID_RegOut1 : register_N GENERIC MAP(N => 32) PORT MAP(i_CLK => iCLK, i_Reset => iRST, i_W => '1', i_IN => s_ID_regOutRs, o_Q => s_EX_regOutRs);
	ID_RegOut2 : register_N GENERIC MAP(N => 32) PORT MAP(i_CLK => iCLK, i_Reset => iRST, i_W => '1', i_IN => s_ID_regOutRt, o_Q => s_EX_regOutRt);
	ID_ImmEx : register_N GENERIC MAP(N => 32) PORT MAP(i_CLK => iCLK, i_Reset => iRST, i_W => '1', i_IN => s_ID_imm_extended, o_Q => s_EX_imm_extended);

	----------------------------------------------------------------------------------------------------------------------------------
	---EX

	alu_input_mux : mux2t1_N PORT MAP(i_S => s_EX_ALUSrc(0), i_D0 => s_EX_regOutRt, i_D1 => s_EX_imm_extended, o_O => s_alu_input);

	alu_block : ALU PORT MAP(
		i_Operand_A => s_EX_regOutRs,
		i_Operand_B => s_alu_input,
		i_ShiftAmount => s_EX_Inst(10 DOWNTO 6),
		i_ALUOP => s_EX_ALUOp,
		o_Result => s_alu_result,
		o_CarryOut => OPEN,
		o_Overflow => s_EX_Ovfl(0),
		o_Zero => s_Zero
	);
	oALUOut <= s_alu_result;

	EX_INST : register_N GENERIC MAP(N => 32) PORT MAP(i_CLK => iCLK, i_Reset => iRST, i_W => '1', i_IN => s_EX_Inst, o_Q => s_DM_Inst);
	EX_IMemAddr : register_N GENERIC MAP(N => N) PORT MAP(i_CLK => iCLK, i_Reset => iRST, i_W => '1', i_IN => s_EX_IMemAddr, o_Q => s_DM_IMemAddr);
	EX_MemWr : register_N GENERIC MAP(N => 1) PORT MAP(i_CLK => iCLK, i_Reset => iRST, i_W => '1', i_IN => s_EX_Mem_WR, o_Q => s_DM_Mem_WR);
	EX_MemToReg : register_N GENERIC MAP(N => 1) PORT MAP(i_CLK => iCLK, i_Reset => iRST, i_W => '1', i_IN => s_EX_MEM_TO_REG, o_Q => s_DM_MEM_TO_REG);
	EX_RegWr : register_N GENERIC MAP(N => 1) PORT MAP(i_CLK => iCLK, i_Reset => iRST, i_W => '1', i_IN => s_EX_Reg_WR, o_Q => s_DM_Reg_WR);
	EX_JAL : register_N GENERIC MAP(N => 1) PORT MAP(i_CLK => iCLK, i_Reset => iRST, i_W => '1', i_IN => s_EX_JAL, o_Q => s_DM_JAL);
	EX_HALT : register_N GENERIC MAP(N => 1) PORT MAP(i_CLK => iCLK, i_Reset => iRST, i_W => '1', i_IN => s_EX_Halt, o_Q => s_DM_Halt);
	EX_RegOut2 : register_N GENERIC MAP(N => 32) PORT MAP(i_CLK => iCLK, i_Reset => iRST, i_W => '1', i_IN => s_EX_regOutRt, o_Q => s_DM_regOutRt);
	EX_ALURes : register_N GENERIC MAP(N => 32) PORT MAP(i_CLK => iCLK, i_Reset => iRST, i_W => '1', i_IN => s_alu_result, o_Q => s_DM_ALURes);
	EX_RegDst : register_N GENERIC MAP(N => 1) PORT MAP(i_CLK => iCLK, i_Reset => iRST, i_W => '1', i_IN => s_EX_DST_REG, o_Q => s_DM_DST_REG);
	EX_ovfl : register_N GENERIC MAP(N => 1) PORT MAP(i_CLK => iCLK, i_Reset => iRST, i_W => '1', i_IN => s_EX_Ovfl, o_Q => s_DM_Ovfl);

	----------------------------------------------------------------------------------------------------------------------------------
	---DM

	jal_adder : ripple_carry_adder PORT MAP(i_X => s_DM_IMemAddr, i_Y => "00000000000000000000000000000100", i_RCin => '0', o_S => s_pc_incremented, o_RCout => OPEN);

	jal_mux2 : mux2t1_N PORT MAP(i_S => s_DM_JAL(0), i_D0 => s_DM_ALURes, i_D1 => s_pc_incremented, o_O => s_jal_mux2_out);

	s_DMemAddr <= s_DM_ALURes;
	s_DMemData <= s_DM_regOutRt;
	s_DMemWr <= s_DM_Mem_WR(0);

	DMem : mem
	GENERIC MAP(
		ADDR_WIDTH => ADDR_WIDTH,
		DATA_WIDTH => N)
	PORT MAP(
		clk => iCLK,
		addr => s_DMemAddr(11 DOWNTO 2),
		data => s_DMemData,
		we => s_DMemWr,
		q => s_DMemOut);

	DM_INST : register_N GENERIC MAP(N => 32) PORT MAP(i_CLK => iCLK, i_Reset => iRST, i_W => '1', i_IN => s_DM_Inst, o_Q => s_WB_Inst);
	DM_MemToReg : register_N GENERIC MAP(N => 1) PORT MAP(i_CLK => iCLK, i_Reset => iRST, i_W => '1', i_IN => s_DM_MEM_TO_REG, o_Q => s_WB_MEM_TO_REG);
	DM_RegWr : register_N GENERIC MAP(N => 1) PORT MAP(i_CLK => iCLK, i_Reset => iRST, i_W => '1', i_IN => s_DM_Reg_WR, o_Q => s_WB_Reg_WR);
	DM_HALT : register_N GENERIC MAP(N => 1) PORT MAP(i_CLK => iCLK, i_Reset => iRST, i_W => '1', i_IN => s_DM_Halt, o_Q => s_WB_Halt);
	DM_DMEM_OUT : register_N GENERIC MAP(N => 32) PORT MAP(i_CLK => iCLK, i_Reset => iRST, i_W => '1', i_IN => s_DMemOut, o_Q => s_WB_DMemOut);
	DM_RegDst : register_N GENERIC MAP(N => 1) PORT MAP(i_CLK => iCLK, i_Reset => iRST, i_W => '1', i_IN => s_DM_DST_REG, o_Q => s_WB_DST_REG);
	DM_JAL_ADDR : register_N GENERIC MAP(N => 32) PORT MAP(i_CLK => iCLK, i_Reset => iRST, i_W => '1', i_IN => s_jal_mux2_out, o_Q => s_WB_jal_mux2_out);
	DM_JAL : register_N GENERIC MAP(N => 1) PORT MAP(i_CLK => iCLK, i_Reset => iRST, i_W => '1', i_IN => s_DM_JAL, o_Q => s_WB_JAL);
	DM_ovfl : register_N GENERIC MAP(N => 1) PORT MAP(i_CLK => iCLK, i_Reset => iRST, i_W => '1', i_IN => s_DM_Ovfl, o_Q => s_WB_Ovfl);

	----------------------------------------------------------------------------------------------------------------------------------
	---WB

	write_data : mux2t1_N PORT MAP(i_S => s_WB_MEM_TO_REG(0), i_D0 => s_WB_jal_mux2_out, i_D1 => s_WB_DMemOut, o_O => s_RegWrData);

	-- Determine register file write address
	register_dst_mux : mux2t1_N GENERIC MAP(N => 5) PORT MAP(i_S => s_WB_DST_REG(0), i_D0 => s_WB_Inst(20 DOWNTO 16), i_D1 => s_WB_Inst(15 DOWNTO 11), o_O => s_register_dst_mux_out);
	jal_mux1 : mux2t1_N GENERIC MAP(N => 5) PORT MAP(i_S => s_WB_JAL(0), i_D0 => s_register_dst_mux_out, i_D1 => "11111", o_O => s_RegWrAddr);

	s_Ovfl <= s_WB_Ovfl(0);
	s_Halt <= s_WB_Halt(0);

END structure;