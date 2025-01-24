--Jackson Collalti
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_textio.ALL; -- For logic types I/O
LIBRARY std;
USE std.textio.ALL; -- For basic I/O

-- Usually name your testbench similar to below for clarity tb_<name>
-- TODO: change all instances of tb_TPU_MV_Element to reflect the new testbench.
ENTITY tb_Full_And_Stall IS
  GENERIC (gCLK_HPER : TIME := 10 ns); -- Generic for half of the clock cycle period
END tb_Full_And_Stall;

ARCHITECTURE behavior OF tb_Full_And_Stall IS

  -- Define the total clock period time
  CONSTANT cCLK_PER : TIME := gCLK_HPER * 2;

  COMPONENT Flush_And_Stall IS
	  GENERIC (N : INTEGER := 32);
	  PORT (
      iCLK : IN STD_LOGIC;
      --Instruction In
      iInst : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
      --Flush = 1 means flush is needed
      iFlush_ID : IN STD_LOGIC;
      iFlush_EX : IN STD_LOGIC;
      iFlush_MEM : IN STD_LOGIC;
      iFlush_WB : IN STD_LOGIC;
      --Stall = 1 means stall is needed
      iStall_ID : IN STD_LOGIC;
      iStall_EX : IN STD_LOGIC;
      iStall_MEM : IN STD_LOGIC;
      iStall_WB : IN STD_LOGIC;
      --Pipe instructions
      oInst_ID : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
      oInst_EX : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
      oInst_MEM : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
      oInst_WB : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0)
    );
  END COMPONENT;

  SIGNAL s_CLK : STD_LOGIC := '0';
  SIGNAL s_Inst_In : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL s_Flush_ID : STD_LOGIC := '0';
	SIGNAL s_Flush_EX : STD_LOGIC := '0';
	SIGNAL s_Flush_MEM : STD_LOGIC := '0';
	SIGNAL s_Flush_WB : STD_LOGIC := '0';
  SIGNAL s_Stall_ID : STD_LOGIC := '0';
	SIGNAL s_Stall_EX : STD_LOGIC := '0';
	SIGNAL s_Stall_MEM : STD_LOGIC := '0';
	SIGNAL s_Stall_WB : STD_LOGIC := '0';
  SIGNAL s_ID_Inst : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL s_EX_Inst : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL s_DM_Inst : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL s_WB_Inst : STD_LOGIC_VECTOR(31 DOWNTO 0);

BEGIN
-------------------
  Flush_Stall : Flush_And_Stall
  PORT MAP(
    iCLK => s_CLK,
    --Instruction In
    iInst => s_Inst_In,
    --Flush = 1 means flush is needed
    iFlush_ID => s_Flush_ID,
    iFlush_EX => s_Flush_EX,
    iFlush_MEM => s_Flush_MEM,
    iFlush_WB => s_Flush_WB,
    --Stall = 1 means stall is needed
    iStall_ID => s_Stall_ID,
    iStall_EX => s_Stall_EX,
    iStall_MEM => s_Stall_MEM,
    iStall_WB => s_Stall_WB,
    --Pipe instructions
    oInst_ID => s_ID_Inst,
		oInst_EX => s_EX_Inst,
	  oInst_MEM => s_DM_Inst,
	  oInst_WB => s_WB_Inst);

  P_CLK : PROCESS
  BEGIN
    s_CLK <= '0';
    WAIT FOR gCLK_HPER;
    s_CLK <= '1';
    WAIT FOR gCLK_HPER;
  END PROCESS;

  -- Testbench process  
  P_TB : PROCESS
  BEGIN

--Reset All
  s_Inst_In <= "00000000000000000000000000000000";
  s_Flush_ID <='1';
  s_Flush_EX <= '1';
  s_Flush_MEM <= '1';
  s_Flush_WB <= '1';
  s_Stall_ID <= '0';
  s_Stall_EX <= '0';
  s_Stall_MEM <= '0';
  s_Stall_WB <= '0';
  WAIT FOR cCLK_PER;
-----------Fill Pipeline
  s_Inst_In <= "00000000000000000000000000000101";
  s_Flush_ID <='0';
  s_Flush_EX <= '0';
  s_Flush_MEM <= '0';
  s_Flush_WB <= '0';
  s_Stall_ID <= '0';
  s_Stall_EX <= '0';
  s_Stall_MEM <= '0';
  s_Stall_WB <= '0';
  WAIT FOR cCLK_PER;

  s_Inst_In <= "00000000000000000000000000000110";
  s_Flush_ID <='0';
  s_Flush_EX <= '0';
  s_Flush_MEM <= '0';
  s_Flush_WB <= '0';
  s_Stall_ID <= '0';
  s_Stall_EX <= '0';
  s_Stall_MEM <= '0';
  s_Stall_WB <= '0';
  WAIT FOR cCLK_PER;

s_Inst_In <= "00000000000000000000000000000111";
  s_Flush_ID <='0';
  s_Flush_EX <= '0';
  s_Flush_MEM <= '0';
  s_Flush_WB <= '0';
  s_Stall_ID <= '0';
  s_Stall_EX <= '0';
  s_Stall_MEM <= '0';
  s_Stall_WB <= '0';
  WAIT FOR cCLK_PER;

s_Inst_In <= "00000000000000000000000000001110";
  s_Flush_ID <='0';
  s_Flush_EX <= '0';
  s_Flush_MEM <= '0';
  s_Flush_WB <= '0';
  s_Stall_ID <= '0';
  s_Stall_EX <= '0';
  s_Stall_MEM <= '0';
  s_Stall_WB <= '0';
  WAIT FOR cCLK_PER;
----------------------End Fill Pipeline
--Flush_ID
s_Inst_In <= "00000000000000000000000000001110";
  s_Flush_ID <='1';
  s_Flush_EX <= '0';
  s_Flush_MEM <= '0';
  s_Flush_WB <= '0';
  s_Stall_ID <= '0';
  s_Stall_EX <= '0';
  s_Stall_MEM <= '0';
  s_Stall_WB <= '0';
  WAIT FOR cCLK_PER;

--Flush_EX
s_Inst_In <= "00000000000000000000000000001110";
  s_Flush_ID <='1';
  s_Flush_EX <= '0';
  s_Flush_MEM <= '0';
  s_Flush_WB <= '0';
  s_Stall_ID <= '0';
  s_Stall_EX <= '0';
  s_Stall_MEM <= '0';
  s_Stall_WB <= '0';
  WAIT FOR cCLK_PER;
--Fill ID
s_Inst_In <= "00000000000000000000000000000001";
  s_Flush_ID <='0';
  s_Flush_EX <= '0';
  s_Flush_MEM <= '0';
  s_Flush_WB <= '0';
  s_Stall_ID <= '0';
  s_Stall_EX <= '0';
  s_Stall_MEM <= '0';
  s_Stall_WB <= '0';
  WAIT FOR cCLK_PER;

--Fill ID Again
s_Inst_In <= "00000000000000000000000000000010";
  s_Flush_ID <='0';
  s_Flush_EX <= '0';
  s_Flush_MEM <= '0';
  s_Flush_WB <= '0';
  s_Stall_ID <= '0';
  s_Stall_EX <= '0';
  s_Stall_MEM <= '0';
  s_Stall_WB <= '0';
  WAIT FOR cCLK_PER;

--Stall ID
s_Inst_In <= "00000000000000000000000000000010";
  s_Flush_ID <='0';
  s_Flush_EX <= '0';
  s_Flush_MEM <= '0';
  s_Flush_WB <= '0';
  s_Stall_ID <= '1';
  s_Stall_EX <= '0';
  s_Stall_MEM <= '0';
  s_Stall_WB <= '0';
  WAIT FOR cCLK_PER;

--Fill ID Again
s_Inst_In <= "00000000000000000000000000000011";
  s_Flush_ID <='0';
  s_Flush_EX <= '0';
  s_Flush_MEM <= '0';
  s_Flush_WB <= '0';
  s_Stall_ID <= '0';
  s_Stall_EX <= '0';
  s_Stall_MEM <= '0';
  s_Stall_WB <= '0';
  WAIT FOR cCLK_PER;


    
    WAIT;
  END PROCESS;

END behavior;