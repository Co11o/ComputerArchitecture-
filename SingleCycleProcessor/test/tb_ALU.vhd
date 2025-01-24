--ALU Testbench
--Jackson Collalti
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_textio.ALL; -- For logic types I/O
LIBRARY std;
USE std.env.ALL; -- For hierarchical/external signals
USE std.textio.ALL; -- For basic I/O

-- Usually name your testbench similar to below for clarity tb_<name>
-- TODO: change all instances of tb_TPU_MV_Element to reflect the new testbench.
ENTITY tb_ALU IS
    GENERIC (gCLK_HPER : TIME := 10 ns); -- Generic for half of the clock cycle period
END tb_ALU;

ARCHITECTURE behavior OF tb_ALU IS

    -- Define the total clock period time
    CONSTANT cCLK_PER : TIME := gCLK_HPER * 2;

    component ALU is
        port(i_Operand_A          : in STD_LOGIC_VECTOR(31 DOWNTO 0);
             i_Operand_B          : in STD_LOGIC_VECTOR(31 DOWNTO 0);
             i_ShiftAmount          : in STD_LOGIC_VECTOR(4 DOWNTO 0);
             i_ALUOP : in STD_LOGIC_VECTOR(3 DOWNTO 0);
             o_Result          : out STD_LOGIC_VECTOR(31 DOWNTO 0);
             o_CarryOut : OUT STD_LOGIC;
             o_Overflow : OUT STD_LOGIC;
             o_Zero : OUT STD_LOGIC);
    end component;

    SIGNAL s_CLK : STD_LOGIC := '0';
    SIGNAL s_Operand_A : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL s_Operand_B : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL s_ShiftAmount : STD_LOGIC_VECTOR(4 DOWNTO 0);
    SIGNAL s_ALUOP : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL s_Result: STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL s_CarryOut : STD_LOGIC;
    SIGNAL s_Overflow : STD_LOGIC;
    SIGNAL s_Zero : STD_LOGIC;

BEGIN

    ALU_TB : ALU
    PORT MAP(
        i_Operand_A => s_Operand_A,
        i_Operand_B => s_Operand_B,
        i_ShiftAmount => s_ShiftAmount,
        i_ALUOP => s_ALUOP,
        o_Result => s_Result,
        o_CarryOut => s_CarryOut,
        o_Overflow => s_Overflow,
        o_Zero => s_Zero);

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

        WAIT FOR cCLK_PER;
        WAIT FOR cCLK_PER;

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

    
        --slt true
        s_Operand_A <= "00000000000000000000000000000000";
        s_Operand_B <= "10000000000000000000000000000000";
        s_ShiftAmount <= "00000";
        s_ALUOP <= "0000";
        WAIT FOR cCLK_PER;

        --slt false
        s_Operand_A <= "10000000000000000000000000000000";
        s_Operand_B <= "01000000000000000000000000000000";
        s_ShiftAmount <= "00000";
        s_ALUOP <= "0000";
        WAIT FOR cCLK_PER;

        --slt false A = B, Zero Flag should also be triggered
        s_Operand_A <= "10000000000000000000000000000000";
        s_Operand_B <= "10000000000000000000000000000000";
        s_ShiftAmount <= "00000";
        s_ALUOP <= "0000";
        WAIT FOR cCLK_PER;

        --slt false A = B, Zero Flag should also be triggered
        s_Operand_A <= "10000000000000000000000000000000";
        s_Operand_B <= "10000000000000000000000000000000";
        s_ShiftAmount <= "00000";
        s_ALUOP <= "0000";
        WAIT FOR cCLK_PER;
    
    ---------
    --Gates--
    ---------

        --NOR, Expected-00000000000000000000000100100010 = 0x00000122
        s_Operand_A <= "11111111111111111111110001001001";
        s_Operand_B <= "10000000000000000000001010010100";
        s_ShiftAmount <= "00000";
        s_ALUOP <= "0001";
        WAIT FOR cCLK_PER;

        --XOR, Expected-00000000000000000000001011011101 = 0x00002DD
        s_Operand_A <= "11111111111111111111110001001001";
        s_Operand_B <= "11111111111111111111111010010100";
        s_ShiftAmount <= "00000";
        s_ALUOP <= "0010";
        WAIT FOR cCLK_PER;

        --OR, Expected- 10000000000000000000001011011101 = 0x800002DD
        s_Operand_A <= "00000000000000000000000001001101";
        s_Operand_B <= "10000000000000000000001010010100";
        s_ShiftAmount <= "00000";
        s_ALUOP <= "0011";
        WAIT FOR cCLK_PER;

        --AND, Expected-10000000000000000000000000000001 = 0x80000001
        s_Operand_A <= "11111111111111111111110001001001";
        s_Operand_B <= "10000000000000000000001010010101";
        s_ShiftAmount <= "00000";
        s_ALUOP <= "0100";
        WAIT FOR cCLK_PER;
--------
--Math--
--------
        --SUB, Expected-11111111111111111111111111111111 = 0xFFFFFFFF
        s_Operand_A <= "00000000000000000000000000000000";
        s_Operand_B <= "00000000000000000000000000000001";
        s_ShiftAmount <= "00000";
        s_ALUOP <= "0101";
        WAIT FOR cCLK_PER;

        --ADD, Expected-11111111111111111111111111111111 = 0xFFFFFFFE
        s_Operand_A <= "11111111111111101111111111011101";
        s_Operand_B <= "00000000000000010000000000100001";
        s_ShiftAmount <= "00000";
        s_ALUOP <= "0110";
        WAIT FOR cCLK_PER;

        --SUB Overflow = 1, Expected-11111111111111111111111111111111 = 0x40000001
        s_Operand_A <= "11000000000000000000000000000000";
        s_Operand_B <= "01111111111111111111111111111111";
        s_ShiftAmount <= "00000";
        s_ALUOP <= "0101";
        WAIT FOR cCLK_PER;

        --ADD Overflow = 1, Expected-11111111111111111111111011011110 = 0xBFFFFFFD
        s_Operand_A <= "10111111111111111111111111111111";
        s_Operand_B <= "11111111111111111111111111111110";
        s_ShiftAmount <= "00000";
        s_ALUOP <= "0110";
        WAIT FOR cCLK_PER;
----------------------------
        --SUBU, Expected-11111111111111111111111111111111 = 0xFFFFFFFF
        s_Operand_A <= "00000000000000000000000000000000";
        s_Operand_B <= "00000000000000000000000000000001";
        s_ShiftAmount <= "00000";
        s_ALUOP <= "1100";
        WAIT FOR cCLK_PER;

        --ADDU, Expected-11111111111111111111111111111111 = 0xFFFFFFFE
        s_Operand_A <= "11111111111111101111111111011101";
        s_Operand_B <= "00000000000000010000000000100001";
        s_ShiftAmount <= "00000";
        s_ALUOP <= "1011";
        WAIT FOR cCLK_PER;

        --SUBU Overflow = 0 (Not triggered, but is overflow), Expected-11111111111111111111111111111111 = 0x40000001
        s_Operand_A <= "11000000000000000000000000000000";
        s_Operand_B <= "01111111111111111111111111111111";
        s_ShiftAmount <= "00000";
        s_ALUOP <= "1100";
        WAIT FOR cCLK_PER;

        --ADDU Overflow = 0 (Not triggered, but is overflow), Expected-11111111111111111111111011011110 = 0xBFFFFFFD
        s_Operand_A <= "10111111111111111111111111111111";
        s_Operand_B <= "11111111111111111111111111111110";
        s_ShiftAmount <= "00000";
        s_ALUOP <= "1011";
        WAIT FOR cCLK_PER;

----------
--Shifts--
----------
        --SRL, Shift 8 Right Expect 0x00000180
        s_Operand_A <= "11111111111111111111110001001000"; 
        s_Operand_B <= "00000000000000011000000000000001";--0x00018001
        s_ShiftAmount <= "01000";
        s_ALUOP <= "0111";
        WAIT FOR cCLK_PER;

        --SLL, Shift 8 Left Expect 0x01800100
        s_Operand_A <= "11111111111111111111110001001000";
        s_Operand_B <= "00000000000000011000000000000001";--0x00018001
        s_ShiftAmount <= "01000";
        s_ALUOP <= "1000";
        WAIT FOR cCLK_PER;

        --SRA, Shift 8 Right Expect 0xFF000180
        s_Operand_A <= "11111111111111111111110001001000";
        s_Operand_B <= "00000000000000011000000000000001";--0x00018001
        s_ShiftAmount <= "01000";
        s_ALUOP <= "1001";
        WAIT FOR cCLK_PER;

        --LUI, Shift 16 Right Expect 0x80010000
        s_Operand_A <= "11111111111111111111110001001000";
        s_Operand_B <= "00000000000000011000000000000001";--0x00018001
        s_ShiftAmount <= "01000";
        s_ALUOP <= "1010";
        WAIT FOR cCLK_PER;
---------
--Other--
---------
        --Replicate, Expect 0xFFFFFFFF
        s_Operand_A <= "11111111111111111111110001001000";
        s_Operand_B <= "00000000001000001111111111111111";
        s_ShiftAmount <= "00000";
        s_ALUOP <= "1101";
        WAIT FOR cCLK_PER;

        WAIT;
    END PROCESS;

END behavior;