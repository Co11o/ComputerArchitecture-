-------------------------------------------------------------------------
-- Justin Sebahar and Jackson Collalti
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- MIPS_Processor.vhd
-------------------------------------------------------------------------
-- 10/16/2014
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

  SIGNAL s_X : STD_LOGIC_VECTOR(31 DOWNTO 0) := "--------------------------------"; --Don't care
  SIGNAL s_0 : STD_LOGIC := '0';
  SIGNAL s_one : STD_LOGIC := '1';
  SIGNAL s_31 : STD_LOGIC_VECTOR(4 DOWNTO 0) := "11111";
  SIGNAL s_4 : STD_LOGIC_VECTOR(31 DOWNTO 0) := "00000000000000000000000000000100";

  SIGNAL s_ALUOP : STD_LOGIC_VECTOR(3 DOWNTO 0);
  SIGNAL s_DST_REG : STD_LOGIC;
  SIGNAL s_ALUSrc : STD_LOGIC;
  SIGNAL s_EXTENSION : STD_LOGIC;
  SIGNAL s_MEM_TO_REG : STD_LOGIC;
  SIGNAL s_BRANCH : STD_LOGIC;
  SIGNAL s_BRANCH_TYPE : STD_LOGIC;
  SIGNAL s_JUMP_EN : STD_LOGIC;
  SIGNAL s_JR : STD_LOGIC;
  SIGNAL s_JAL : STD_LOGIC;

  SIGNAL s_rs : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL s_rt : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL s_register_dst_mux_out : STD_LOGIC_VECTOR(4 DOWNTO 0);
  SIGNAL s_immediate_extended : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL s_alu_input : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL s_alu_result : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL s_CarryOut : STD_LOGIC;
  SIGNAL s_Zero : STD_LOGIC;
  SIGNAL s_pc_incremented : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL s_jal_mux2_out : STD_LOGIC_VECTOR(31 DOWNTO 0);

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

BEGIN

  -- TODO: This is required to be your final input to your instruction memory. This provides a feasible method to externally load the memory module which means that the synthesis tool must assume it knows nothing about the values stored in the instruction memory. If this is not included, much, if not all of the design is optimized out because the synthesis tool will believe the memory to be all zeros.
  WITH iInstLd SELECT
    s_IMemAddr <= s_NextInstAddr WHEN '0',
    iInstAddr WHEN OTHERS;

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

  -- TODO: Ensure that s_Halt is connected to an output control signal produced from decoding the Halt instruction (Opcode: 01 0100)
  -- TODO: Ensure that s_Ovfl is connected to the overflow output of your ALU

  -- TODO: Implement the rest of your processor below this comment! 

  fetch : FetchLogic PORT MAP(
    i_CLK => iCLK,
    i_RST => iRST,
    i_Zero => s_Zero,
    i_PC => s_IMemAddr,
    i_JRAddress => s_rs,
    i_JREnable => s_JR,
    i_JumpAddress => s_Inst(25 DOWNTO 0),
    i_JumpEnable => s_JUMP_EN,
    i_BranchAddress => s_immediate_extended,
    i_BranchEnable => s_BRANCH,
    i_BranchType => s_BRANCH_TYPE,
    o_PC => s_NextInstAddr
  );

  -- Get control signals
  control : controller PORT MAP(
    i_OPCODE => s_Inst(31 DOWNTO 26),
    i_FUNCTION => s_Inst(5 DOWNTO 0),
    o_ALUOP => s_ALUOP,
    o_DST_REG => s_DST_REG,
    o_ALUSrc => s_ALUSrc,
    o_EXTENSION => s_EXTENSION,
    o_MEM_TO_REG => s_MEM_TO_REG,
    o_REG_WRITE => s_RegWr,
    o_MEM_WRITE => s_DMemWr,
    o_BRANCH => s_BRANCH,
    o_BRANCH_TYPE => s_BRANCH_TYPE,
    o_JUMP_EN => s_JUMP_EN,
    o_JR => s_JR,
    o_JAL => s_JAL,
    o_HALT => s_Halt
  );
  -- Determine register file write address
  register_dst_mux : mux2t1_N GENERIC MAP(N => 5) PORT MAP(i_S => s_DST_REG, i_D0 => s_Inst(20 DOWNTO 16), i_D1 => s_Inst(15 DOWNTO 11), o_O => s_register_dst_mux_out);
  jal_mux1 : mux2t1_N GENERIC MAP(N => 5) PORT MAP(i_S => s_JAL, i_D0 => s_register_dst_mux_out, i_D1 => s_31, o_O => s_RegWrAddr);

  -- Register file
  reg_file : register_file PORT MAP(
    i_CLOCK => iCLK,
    i_RESET => iRST,
    i_WriteTo => s_RegWrAddr,
    i_WEN => s_RegWr,
    i_INPUT => s_RegWrData,
    i_MUX_SELECT1 => s_Inst(25 DOWNTO 21),
    i_MUX_SELECT2 => s_Inst(20 DOWNTO 16),
    o_OUT1 => s_rs,
    o_OUT2 => s_rt
  );
  s_DMemData <= s_rt;

  extend : bit_extender PORT MAP(i_select => s_EXTENSION, i_immediate => s_Inst(15 DOWNTO 0), o_extended => s_immediate_extended);

  alu_input_mux : mux2t1_N PORT MAP(i_S => s_ALUSrc, i_D0 => s_rt, i_D1 => s_immediate_extended, o_O => s_alu_input);

  alu_block : ALU PORT MAP(
    i_Operand_A => s_rs,
    i_Operand_B => s_alu_input,
    i_ShiftAmount => s_Inst(10 DOWNTO 6),
    i_ALUOP => s_ALUOP,
    o_Result => oALUOut,
    o_CarryOut => s_CarryOut,
    o_Overflow => s_Ovfl,
    o_Zero => s_Zero
  );
  s_alu_result <= oALUOut;
  s_DMemAddr <= oALUOut;

  jal_adder : ripple_carry_adder PORT MAP(i_X => s_IMemAddr, i_Y => s_4, i_RCin => s_0, o_S => s_pc_incremented, o_RCout => OPEN);

  jal_mux2 : mux2t1_N PORT MAP(i_S => s_JAL, i_D0 => s_alu_result, i_D1 => s_pc_incremented, o_O => s_jal_mux2_out);

  write_data : mux2t1_N PORT MAP(i_S => s_MEM_TO_REG, i_D0 => s_jal_mux2_out, i_D1 => s_DMemOut, o_O => s_RegWrData);
END structure;