LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY Flush_And_Stall IS
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
		
		oInst_ID : OUT STD_LOGIC_VECTOR(N-1 DOWNTO 0);
		oInst_EX : OUT STD_LOGIC_VECTOR(N-1 DOWNTO 0);
		oInst_MEM : OUT STD_LOGIC_VECTOR(N-1 DOWNTO 0);
		oInst_WB : OUT STD_LOGIC_VECTOR(N-1 DOWNTO 0)
		);
END Flush_And_Stall;

ARCHITECTURE structure OF Flush_And_Stall IS

	COMPONENT invg is
	port(i_A          : in std_logic;
		 o_F          : out std_logic);
	end COMPONENT;

	COMPONENT register_N IS
	GENERIC (N : INTEGER := 32);
	PORT (
		i_CLK : IN STD_LOGIC;
		i_Reset : IN STD_LOGIC;
		i_W : IN STD_LOGIC;
		i_IN : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
		o_Q : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0));
	END COMPONENT;

	SIGNAL s_ID_Inst : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL s_EX_Inst : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL s_DM_Inst : STD_LOGIC_VECTOR(31 DOWNTO 0);

	SIGNAL s_Stall_ID : STD_LOGIC;
	SIGNAL s_Stall_EX : STD_LOGIC;
	SIGNAL s_Stall_MEM : STD_LOGIC;
	SIGNAL s_Stall_WB : STD_LOGIC;

	BEGIN

	IDFLUSH : invg PORT MAP (i_A => iStall_ID, o_F => s_Stall_ID);
	EXFLUSH : invg PORT MAP (i_A => iStall_ID, o_F => s_Stall_EX);
	MEMFLUSH : invg PORT MAP (i_A => iStall_ID, o_F => s_Stall_MEM);
	WBFLUSH : invg PORT MAP (i_A => iStall_ID, o_F => s_Stall_WB);

	--IF/ID
	IF_INST : register_N GENERIC MAP(N => 32) PORT MAP(i_CLK => iCLK, i_Reset => iFlush_ID, i_W => s_Stall_ID, i_IN => iInst, o_Q => s_ID_Inst);
	oInst_ID <= s_ID_Inst;
	
	--ID/EX register
	ID_INST : register_N GENERIC MAP(N => 32) PORT MAP(i_CLK => iCLK, i_Reset => iFlush_EX, i_W => s_Stall_EX, i_IN => s_ID_Inst, o_Q => s_EX_Inst);
	oInst_EX <= s_EX_Inst;
	
	--EX/MEM
	EX_INST : register_N GENERIC MAP(N => 32) PORT MAP(i_CLK => iCLK, i_Reset => iFlush_MEM, i_W => s_Stall_MEM, i_IN => s_EX_Inst, o_Q => s_DM_Inst);
	oInst_MEM <= s_DM_Inst;
	
	--MEM/WB
	DM_INST : register_N GENERIC MAP(N => 32) PORT MAP(i_CLK => iCLK, i_Reset => iFlush_WB, i_W => s_Stall_WB, i_IN => s_DM_Inst, o_Q => oInst_WB);
	

END structure;