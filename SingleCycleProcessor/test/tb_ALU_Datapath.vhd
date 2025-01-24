--tb ALU and datapath
--Jackson Collalti
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_textio.ALL; -- For logic types I/O
LIBRARY std;
USE std.textio.ALL; -- For basic I/O

-- Usually name your testbench similar to below for clarity tb_<name>
-- TODO: change all instances of tb_TPU_MV_Element to reflect the new testbench.
ENTITY tb_MyALUDatapath IS
    GENERIC (gCLK_HPER : TIME := 10 ns); -- Generic for half of the clock cycle period
END tb_MyALUDatapath;

ARCHITECTURE behavior OF tb_MyALUDatapath IS

    -- Define the total clock period time
    CONSTANT cCLK_PER : TIME := gCLK_HPER * 2;

    COMPONENT ALUDatapath IS
	PORT (
		i_CLK : IN STD_LOGIC;
		i_RST : IN STD_LOGIC;
		rs : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		rt : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		rd : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		i_ShiftAmount : in STD_LOGIC_VECTOR(4 DOWNTO 0);
		i_ALUOP : in STD_LOGIC_VECTOR(3 DOWNTO 0);
		immediate : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		nAddSub : IN STD_LOGIC;
		extender_select : IN STD_LOGIC;
		ALUSrc : IN STD_LOGIC;
		regWrite : IN STD_LOGIC;
		memWrite : IN STD_LOGIC;
		memToReg : IN STD_LOGIC);
    END COMPONENT;

    SIGNAL s_CLK : STD_LOGIC := '0';
    SIGNAL s_RST : STD_LOGIC := '0';
    SIGNAL s_rs : STD_LOGIC_VECTOR(4 DOWNTO 0);
    SIGNAL s_rt : STD_LOGIC_VECTOR(4 DOWNTO 0);
    SIGNAL s_rd : STD_LOGIC_VECTOR(4 DOWNTO 0);
    SIGNAL s_ALUOP : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL s_immediate : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL s_ShiftAmount : STD_LOGIC_VECTOR(4 DOWNTO 0);
    SIGNAL s_nAddSub : STD_LOGIC := '0';
    SIGNAL s_extender_select : STD_LOGIC;
    SIGNAL s_ALUSrc : STD_LOGIC := '0';
    SIGNAL s_regWrite : STD_LOGIC := '0';
    SIGNAL s_memWrite : STD_LOGIC;
    SIGNAL s_memToReg : STD_LOGIC;

BEGIN

    datapath : ALUDatapath
    PORT MAP(
        i_CLK => s_CLK,
        i_RST => s_RST,
        rs => s_rs,
        rt => s_rt,
        rd => s_rd,
	i_ShiftAmount => s_ShiftAmount,
        i_ALUOP => s_ALUOP,
        immediate => s_immediate,
        nAddSub => s_nAddSub,
        extender_select => s_extender_select,
        ALUSrc => s_ALUSrc,
        regWrite => s_regWrite,
        memWrite => s_memWrite,
        memToReg => s_memToReg);


--Operation             |   ALUOP
------------------------|------------
--replicate             |	1101
--sub unsigned          |	1100
--add unsigned          |	1011
--load upper immediate  |	1010
--shift righ arithmetic |	1001
--shift left logical    |	1000
--shift right logical   |	0111
--add                   |	0110
--subtract              |	0101
--and                   |	0100
--or                    |	0011
--xor                   |	0010
--nor                   |   0001
--slt                   |	0000


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

        s_RST <= '1';
        WAIT FOR cCLK_PER;
        WAIT FOR cCLK_PER;

        --addi $25, $0, 2
        s_RST <= '0';
        s_rs <= "00000";
        s_rt <= "00000";
        s_rd <= "11001";
        s_ALUOP <= "0110";
        s_ShiftAmount <= "00000";
        s_immediate <= "0000000000000010";
        s_nAddSub <= '0';
        s_extender_select <= '0';
        s_ALUSrc <= '1';
        s_regWrite <= '1';
        s_memWrite <= '0';
        s_memToReg <= '0';
        WAIT FOR cCLK_PER;

        --addi $26, $0, 256
        s_rs <= "00000";
        s_rt <= "00000";
        s_rd <= "11010";
        s_ALUOP <= "0110";
        s_ShiftAmount <= "00000";
        s_immediate <= "0000000100000000";
        s_nAddSub <= '0';
        s_extender_select <= '0';
        s_ALUSrc <= '1';
        s_regWrite <= '1';
        s_memWrite <= '0';
        s_memToReg <= '0';
        WAIT FOR cCLK_PER;

	--subi $25, $25, 1
        s_RST <= '0';
        s_rs <= "11001";
        s_rt <= "00000";
        s_rd <= "11001";
        s_ALUOP <= "0000";
        s_ShiftAmount <= "00000";
        s_immediate <= "0000000000000001";
        s_nAddSub <= '0';
        s_extender_select <= '0';
        s_ALUSrc <= '1';
        s_regWrite <= '1';
        s_memWrite <= '0';
        s_memToReg <= '0';
        WAIT FOR cCLK_PER;

	--sub $26, $26, $25
        s_rs <= "11010";
        s_rt <= "11001";
        s_rd <= "11010";
        s_ALUOP <= "0101";
        s_ShiftAmount <= "00000";
        s_immediate <= "0000000100000000";
        s_nAddSub <= '0';
        s_extender_select <= '0';
        s_ALUSrc <= '0';
        s_regWrite <= '1';
        s_memWrite <= '0';
        s_memToReg <= '0';
        WAIT FOR cCLK_PER;

	--False
	--slt $27, $26, $25
        s_rs <= "11010";
        s_rt <= "11001";
        s_rd <= "11011";
        s_ALUOP <= "0000";
        s_ShiftAmount <= "00000";
        s_immediate <= "0000000100000000";
        s_nAddSub <= '0';
        s_extender_select <= '0';
        s_ALUSrc <= '0';
        s_regWrite <= '1';
        s_memWrite <= '0';
        s_memToReg <= '0';
        WAIT FOR cCLK_PER;

	--True
	--slt $27, $25, $26
        s_rs <= "11001";
        s_rt <= "11010";
        s_rd <= "11011";
        s_ALUOP <= "0000";
        s_ShiftAmount <= "00000";
        s_immediate <= "0000000100000000";
        s_nAddSub <= '0';
        s_extender_select <= '0';
        s_ALUSrc <= '0';
        s_regWrite <= '1';
        s_memWrite <= '0';
        s_memToReg <= '0';
        WAIT FOR cCLK_PER;

	--NOR $26, $26, $27
        s_rs <= "11001";
        s_rt <= "11010";
        s_rd <= "11011";
        s_ALUOP <= "0001";
        s_ShiftAmount <= "00000";
        s_immediate <= "0000000100000000";
        s_nAddSub <= '0';
        s_extender_select <= '0';
        s_ALUSrc <= '0';
        s_regWrite <= '1';
        s_memWrite <= '0';
        s_memToReg <= '0';
        WAIT FOR cCLK_PER;

    --addi $24, $0, 255
        s_rs <= "00000";
        s_rt <= "00000";
        s_rd <= "11000";
        s_ALUOP <= "0110";
        s_ShiftAmount <= "00000";
        s_immediate <= "0000000011111111";
        s_nAddSub <= '0';
        s_extender_select <= '0';
        s_ALUSrc <= '1';
        s_regWrite <= '1';
        s_memWrite <= '0';
        s_memToReg <= '0';
        WAIT FOR cCLK_PER;

    --XOR $24, $24, $27
        s_rs <= "11000";
        s_rt <= "11011";
        s_rd <= "11000";
        s_ALUOP <= "0010";
        s_ShiftAmount <= "00000";
        s_immediate <= "0000000100000000";
        s_nAddSub <= '0';
        s_extender_select <= '0';
        s_ALUSrc <= '0';
        s_regWrite <= '1';
        s_memWrite <= '0';
        s_memToReg <= '0';
        WAIT FOR cCLK_PER;

    --OR $26, $25, $24
        s_rs <= "11001";
        s_rt <= "11000";
        s_rd <= "11010";
        s_ALUOP <= "0011";
        s_ShiftAmount <= "00000";
        s_immediate <= "0000000100000000";
        s_nAddSub <= '0';
        s_extender_select <= '0';
        s_ALUSrc <= '0';
        s_regWrite <= '1';
        s_memWrite <= '0';
        s_memToReg <= '0';
        WAIT FOR cCLK_PER;

    --AND $26, $26, $27
        s_rs <= "11010";
        s_rt <= "11011";
        s_rd <= "11010";
        s_ALUOP <= "0100";
        s_ShiftAmount <= "00000";
        s_immediate <= "0000000100000000";
        s_nAddSub <= '0';
        s_extender_select <= '0';
        s_ALUSrc <= '0';
        s_regWrite <= '1';
        s_memWrite <= '0';
        s_memToReg <= '0';
        WAIT FOR cCLK_PER;

    --addi $22, $0, 255
        s_rs <= "00000";
        s_rt <= "00000";
        s_rd <= "10110";
        s_ALUOP <= "0110";
        s_ShiftAmount <= "00000";
        s_immediate <= "0000000011111111";
        s_nAddSub <= '0';
        s_extender_select <= '0';
        s_ALUSrc <= '1';
        s_regWrite <= '1';
        s_memWrite <= '0';
        s_memToReg <= '0';
        WAIT FOR cCLK_PER;

    --Repl $23, $23
        s_rs <= "10111";
        s_rt <= "10111";
        s_rd <= "10111";
        s_ALUOP <= "1101";
        s_ShiftAmount <= "00000";
        s_immediate <= "0000000011111111";
        s_nAddSub <= '0';
        s_extender_select <= '0';
        s_ALUSrc <= '1';
        s_regWrite <= '1';
        s_memWrite <= '0';
        s_memToReg <= '0';
        WAIT FOR cCLK_PER;

    --LUI $23, 0xFFFF
        s_rs <= "10000";
        s_rt <= "10111";
        s_rd <= "10111";
        s_ALUOP <= "1010";
        s_ShiftAmount <= "00000";
        s_immediate <= "1111111111111111";
        s_nAddSub <= '0';
        s_extender_select <= '0';
        s_ALUSrc <= '1';
        s_regWrite <= '1';
        s_memWrite <= '0';
        s_memToReg <= '0';
        WAIT FOR cCLK_PER; 
    
--SRL $23, 8
    s_rs <= "10000";
    s_rt <= "10111";
    s_rd <= "10111";
    s_ALUOP <= "0111";
    s_ShiftAmount <= "01000";
    s_immediate <= "1111111111111111";
    s_nAddSub <= '0';
    s_extender_select <= '0';
    s_ALUSrc <= '1';
    s_regWrite <= '1';
    s_memWrite <= '0';
    s_memToReg <= '0';
    WAIT FOR cCLK_PER;

--SLL $23, 16
    s_rs <= "10000";
    s_rt <= "10111";
    s_rd <= "10111";
    s_ALUOP <= "1000";
    s_ShiftAmount <= "10000";
    s_immediate <= "1111111111111111";
    s_nAddSub <= '0';
    s_extender_select <= '0';
    s_ALUSrc <= '1';
    s_regWrite <= '1';
    s_memWrite <= '0';
    s_memToReg <= '0';
    WAIT FOR cCLK_PER;

--SRA $23, 8
    s_rs <= "10000";
    s_rt <= "10111";
    s_rd <= "10111";
    s_ALUOP <= "1001";
    s_ShiftAmount <= "01000";
    s_immediate <= "1111111111111111";
    s_nAddSub <= '0';
    s_extender_select <= '0';
    s_ALUSrc <= '1';
    s_regWrite <= '1';
    s_memWrite <= '0';
    s_memToReg <= '0';
    WAIT FOR cCLK_PER;

    
    --Repl $22, 0x00FF
    s_rs <= "10111";
    s_rt <= "10111";
    s_rd <= "10110";
    s_ALUOP <= "1101";
    s_ShiftAmount <= "00000";
    s_immediate <= "0000000011111111";
    s_nAddSub <= '0';
    s_extender_select <= '0';
    s_ALUSrc <= '1';
    s_regWrite <= '1';
    s_memWrite <= '0';
    s_memToReg <= '0';
    WAIT FOR cCLK_PER;

    --addiu $22, $0, 1
    s_rs <= "10110";
    s_rt <= "00000";
    s_rd <= "10110";
    s_ALUOP <= "1011";
    s_ShiftAmount <= "00000";
    s_immediate <= "0000000000000001";
    s_nAddSub <= '0';
    s_extender_select <= '0';
    s_ALUSrc <= '1';
    s_regWrite <= '1';
    s_memWrite <= '0';
    s_memToReg <= '0';
    WAIT FOR cCLK_PER;

    --Repl $23, 0x00FF
    s_rs <= "10111";
    s_rt <= "10111";
    s_rd <= "10111";
    s_ALUOP <= "1101";
    s_ShiftAmount <= "00000";
    s_immediate <= "0000000011111111";
    s_nAddSub <= '0';
    s_extender_select <= '0';
    s_ALUSrc <= '1';
    s_regWrite <= '1';
    s_memWrite <= '0';
    s_memToReg <= '0';
    WAIT FOR cCLK_PER;

    --subiu $22, $23, 0x7FFFF
    s_rs <= "10110";
    s_rt <= "00000";
    s_rd <= "10110";
    s_ALUOP <= "1100";
    s_ShiftAmount <= "00000";
    s_immediate <= "0111111111111111";
    s_nAddSub <= '0';
    s_extender_select <= '0';
    s_ALUSrc <= '1';
    s_regWrite <= '1';
    s_memWrite <= '0';
    s_memToReg <= '0';
    WAIT FOR cCLK_PER;

    -----------------
    --Repl $22, 0x00FF
    s_rs <= "10111";
    s_rt <= "10111";
    s_rd <= "10110";
    s_ALUOP <= "1101";
    s_ShiftAmount <= "00000";
    s_immediate <= "0000000011111111";
    s_nAddSub <= '0';
    s_extender_select <= '0';
    s_ALUSrc <= '1';
    s_regWrite <= '1';
    s_memWrite <= '0';
    s_memToReg <= '0';
    WAIT FOR cCLK_PER;

    --addi $22, $0, 1
    s_rs <= "10110";
    s_rt <= "00000";
    s_rd <= "10110";
    s_ALUOP <= "0110";
    s_ShiftAmount <= "00000";
    s_immediate <= "0000000000000001";
    s_nAddSub <= '0';
    s_extender_select <= '0';
    s_ALUSrc <= '1';
    s_regWrite <= '1';
    s_memWrite <= '0';
    s_memToReg <= '0';
    WAIT FOR cCLK_PER;

    --Repl $23, 0x00FF
    s_rs <= "10111";
    s_rt <= "10111";
    s_rd <= "10111";
    s_ALUOP <= "1101";
    s_ShiftAmount <= "00000";
    s_immediate <= "0000000011111111";
    s_nAddSub <= '0';
    s_extender_select <= '0';
    s_ALUSrc <= '1';
    s_regWrite <= '1';
    s_memWrite <= '0';
    s_memToReg <= '0';
    WAIT FOR cCLK_PER;

    --subi $22, $23, 0x7FFFF
    s_rs <= "10110";
    s_rt <= "00000";
    s_rd <= "10110";
    s_ALUOP <= "0101";
    s_ShiftAmount <= "00000";
    s_immediate <= "0111111111111111";
    s_nAddSub <= '0';
    s_extender_select <= '0';
    s_ALUSrc <= '1';
    s_regWrite <= '1';
    s_memWrite <= '0';
    s_memToReg <= '0';
    WAIT FOR cCLK_PER;


        WAIT;
    END PROCESS;

END behavior;