--Fetch Logic Testbench
--Jackson Collalti
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_textio.ALL; -- For logic types I/O
LIBRARY std;
USE std.env.ALL; -- For hierarchical/external signals
USE std.textio.ALL; -- For basic I/O

-- Usually name your testbench similar to below for clarity tb_<name>
-- TODO: change all instances of tb_TPU_MV_Element to reflect the new testbench.
ENTITY tb_fetchLogic IS
  GENERIC (gCLK_HPER : TIME := 10 ns); -- Generic for half of the clock cycle period
END tb_fetchLogic;

ARCHITECTURE behavior OF tb_fetchLogic IS

  -- Define the total clock period time
  CONSTANT cCLK_PER : TIME := gCLK_HPER * 2;

    COMPONENT FetchLogic IS
        GENERIC (N : INTEGER := 32;
                M : INTEGER := 26);
        PORT (
            i_CLK : IN STD_LOGIC;
            i_RST: IN STD_LOGIC;
            i_Zero : IN STD_LOGIC; --Zero from ALU component
            i_PC  : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0); --Previous PC
            i_JRAddress: IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            i_JREnable : IN STD_LOGIC;
            i_JumpAddress : IN STD_LOGIC_VECTOR(M - 1 DOWNTO 0);
            i_JumpEnable : IN STD_LOGIC;
            i_BranchAddress : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            i_BranchEnable : IN STD_LOGIC;
            i_BranchType : IN STD_LOGIC; --BNE = 0, BEQ = 1
            o_PC  : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0)); --Next PC
    END COMPONENT;


    SIGNAL s_CLK : STD_LOGIC := '0';
    SIGNAL s_RST : STD_LOGIC := '0';
    SIGNAL s_Zero : STD_LOGIC := '0';
    SIGNAL s_PC : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL s_JRAddress : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL s_JREnable : STD_LOGIC := '0';
    SIGNAL s_JumpAddress : STD_LOGIC_VECTOR(25 DOWNTO 0);
    SIGNAL s_JumpEnable : STD_LOGIC := '0';
    SIGNAL s_BranchEnable: STD_LOGIC := '0';
    SIGNAL s_BranchType: STD_LOGIC := '0';
    SIGNAL s_BranchAddress : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL s_PC_Out : STD_LOGIC_VECTOR(31 DOWNTO 0);

BEGIN
-------------------
  datapath : FetchLogic
  PORT MAP(
    i_CLK => s_CLK,
    i_RST => s_RST,
    i_Zero => s_Zero,
    i_PC => s_PC,
    i_JRAddress => s_JRAddress,
    i_JREnable => s_JREnable,
    i_JumpAddress => s_JumpAddress,
    i_JumpEnable => s_JumpEnable,
    i_BranchAddress => s_BranchAddress,
    i_BranchType => s_BranchType,
    i_BranchEnable => s_BranchEnable,
    o_PC => s_PC_Out);

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
    --Reset
    s_RST <= '1';
    WAIT FOR cCLK_PER;

    --PC + 4
    s_BranchType <= '1';
    s_RST <= '0';
    s_Zero <= '0';
    s_PC <= "00000000000000000000000000000000";
    s_JRAddress <= "00000000000000000000000000000000";
    s_JREnable <= '0';
    s_JumpAddress <= "00000000000000000000000000";
    s_JumpEnable <= '0';
    s_BranchEnable <= '0';
    s_BranchAddress <= "00000000000000000000000000000000";
    WAIT FOR cCLK_PER;

    --Standard Jump
    s_RST <= '0';
    s_PC <= "00000000000000000000000000000000";
    s_Zero <= '0';
    s_JRAddress <= "00000000000000000000000000000000";
    s_JREnable <= '0';
    s_JumpAddress <= "00000001100000000000000000";
    s_JumpEnable <= '1';
    s_BranchEnable <= '0';
    s_BranchAddress <= "00000000000000000000000000000000";
    WAIT FOR cCLK_PER;

    --Jump Register
    s_RST <= '0';
    s_PC <= "00000000000000000000000000000000";
    s_Zero <= '0';
    s_JRAddress <= "00000011000000000000000000000000";
    s_JREnable <= '1';
    s_JumpAddress <= "00000001100000000000000000";
    s_JumpEnable <= '1';
    s_BranchEnable <= '0';
    s_BranchAddress <= "00000000000000000000000000000000";
    WAIT FOR cCLK_PER;

    --Branch Without Zero, BEQ
    s_BranchType <= '1';
    s_RST <= '0';
    s_PC <= "00000000000000000000000000000000";
    s_Zero <= '0';
    s_JRAddress <= "00000000000000000000000000000000";
    s_JREnable <= '0';
    s_JumpAddress <= "00000001100000000000000000";
    s_JumpEnable <= '0';
    s_BranchEnable <= '1';
    s_BranchAddress <= "00110000000000000000000000000000";
    WAIT FOR cCLK_PER;

    --Branch With Zero, BEQ
    s_BranchType <= '1';
    s_RST <= '0';
    s_PC <= "00000000000000000000000000000000";
    s_Zero <= '1';
    s_JRAddress <= "00000000000000000000000000000000";
    s_JREnable <= '0';
    s_JumpAddress <= "00000001100000000000000000";
    s_JumpEnable <= '0';
    s_BranchEnable <= '1';
    s_BranchAddress <= "00110000000000000000000000000000";
    WAIT FOR cCLK_PER;

    --Branch Without Zero, BNE
    s_BranchType <= '0';
    s_RST <= '0';
    s_PC <= "00000000000000000000000000000000";
    s_Zero <= '0';
    s_JRAddress <= "00000000000000000000000000000000";
    s_JREnable <= '0';
    s_JumpAddress <= "00000001100000000000000000";
    s_JumpEnable <= '0';
    s_BranchEnable <= '1';
    s_BranchAddress <= "00110000000000000000000000000000";
    WAIT FOR cCLK_PER;

    --Branch With Zero, BNE
    s_BranchType <= '0';
    s_RST <= '0';
    s_PC <= "00000000000000000000000000000000";
    s_Zero <= '1';
    s_JRAddress <= "00000000000000000000000000000000";
    s_JREnable <= '0';
    s_JumpAddress <= "00000001100000000000000000";
    s_JumpEnable <= '0';
    s_BranchEnable <= '1';
    s_BranchAddress <= "00110000000000000000000000000000";
    WAIT FOR cCLK_PER;

    --PC + 4, Where PC isn't 0x00000000
    s_RST <= '0';
    s_PC <= "00000000110001000000000000000000";
    s_Zero <= '0';
    s_JRAddress <= "00000000000000000000000000000000";
    s_JREnable <= '0';
    s_JumpAddress <= "00000001100000000000000000";
    s_JumpEnable <= '0';
    s_BranchEnable <= '0';
    s_BranchAddress <= "00110000000000000000000000000000";
    WAIT FOR cCLK_PER;
--
    WAIT;
  END PROCESS;

END behavior;