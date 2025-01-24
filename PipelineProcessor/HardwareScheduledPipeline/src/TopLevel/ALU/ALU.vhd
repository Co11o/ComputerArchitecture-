--Author Jackson Collalti
-- 32 Bit ALU
library IEEE;
use IEEE.std_logic_1164.all;
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
entity ALU is
  port(i_Operand_A          : in STD_LOGIC_VECTOR(31 DOWNTO 0);
       i_Operand_B          : in STD_LOGIC_VECTOR(31 DOWNTO 0);
       i_ShiftAmount          : in STD_LOGIC_VECTOR(4 DOWNTO 0);
       i_ALUOP : in STD_LOGIC_VECTOR(3 DOWNTO 0);
       o_Result          : out STD_LOGIC_VECTOR(31 DOWNTO 0);
       o_CarryOut : OUT STD_LOGIC;
       o_Overflow : OUT STD_LOGIC;
       o_Zero : OUT STD_LOGIC);
end ALU;

architecture structural of ALU is
    
    component AND_32BITS is
        port(
            i_A          : in STD_LOGIC_VECTOR(31 DOWNTO 0);
            i_B          : in STD_LOGIC_VECTOR(31 DOWNTO 0);
            o_F          : out STD_LOGIC_VECTOR(31 DOWNTO 0));
    end component;

    component OR_32BITS is
        port(
            i_A          : in STD_LOGIC_VECTOR(31 DOWNTO 0);
            i_B          : in STD_LOGIC_VECTOR(31 DOWNTO 0);
            o_F          : out STD_LOGIC_VECTOR(31 DOWNTO 0));
    end component;

    component XOR_32BITS is
        port(
            i_A          : in STD_LOGIC_VECTOR(31 DOWNTO 0);
             i_B          : in STD_LOGIC_VECTOR(31 DOWNTO 0);
             o_F          : out STD_LOGIC_VECTOR(31 DOWNTO 0));
    end component;

    component NOR_32BITS is
        port(
            i_A          : in STD_LOGIC_VECTOR(31 DOWNTO 0);
             i_B          : in STD_LOGIC_VECTOR(31 DOWNTO 0);
             o_F          : out STD_LOGIC_VECTOR(31 DOWNTO 0));
    end component;

    component barrel_shifter is
		port(
            i_IN : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		    i_SHAMT : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		    i_DIRECTION : IN STD_LOGIC; -- If '0' then shift right; if '1' then shift left.
            i_TYPE : IN STD_LOGIC; -- If '0' then logical shift. If '1' then arithmetic shift
		    o_OUT : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
    end component;

    component adder_subtractorOverflow IS
	GENERIC (N : INTEGER := 32);
        port (
            i_A : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            i_B : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            i_nAdd_Sub : IN STD_LOGIC;
            o_O : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            o_Cout : OUT STD_LOGIC;
            o_Overflow : OUT STD_LOGIC);
    end component;

    component adder_subtractor
	GENERIC (N : INTEGER := 32);
	PORT (
		i_A : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
		i_B : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
		i_nAdd_Sub : IN STD_LOGIC;
		o_O : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
		o_Cout : OUT STD_LOGIC);
    end component;

    component Repl is
        port(i_A          : in STD_LOGIC_VECTOR(7 DOWNTO 0); --Const8
             o_F          : out STD_LOGIC_VECTOR(31 DOWNTO 0));
    end component;

--------Signals-------

SIGNAL s_AND_OUT : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL s_OR_OUT : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL s_NOR_OUT : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL s_XOR_OUT : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL s_SUMU_OUT : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL s_SUBU_OUT : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL s_SUM_OUT : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL s_SUB_OUT : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL s_BARRELLEFT_OUT : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL s_BARRELRIGHT_OUT : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL s_REPL_IN : STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL s_REPL_OUT : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL s_carry_add : STD_LOGIC;
SIGNAL s_carry_addu : STD_LOGIC;
SIGNAL s_carry_sub : STD_LOGIC;
SIGNAL s_carry_subu : STD_LOGIC;
SIGNAL s_SET_LESS_THAN : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL s_SET_EQUAL : STD_LOGIC;
SIGNAL s_SRA_OUT : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL s_LUI_OUT : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL s_SUBOverflow : STD_LOGIC;
SIGNAL s_ADDOverflow : STD_LOGIC;
----------------------
    
    begin

        add : adder_subtractorOverflow 
        PORT MAP(
            i_A => i_Operand_A,
            i_B => i_Operand_B, 
            i_nAdd_Sub => '0', 
            o_O => s_SUM_OUT, 
            o_Cout => s_carry_add,
            o_Overflow => s_ADDOverflow
        );

        addu : adder_subtractor 
        PORT MAP(
            i_A => i_Operand_A,
            i_B => i_Operand_B, 
            i_nAdd_Sub => '0', 
            o_O => s_SUMU_OUT, 
            o_Cout => s_carry_addu
        );

        sub : adder_subtractorOverflow 
        PORT MAP(
            i_A => i_Operand_A,
            i_B => i_Operand_B, 
            i_nAdd_Sub => '1', 
            o_O => s_SUB_OUT, 
            o_Cout => s_carry_sub,
            o_Overflow => s_SUBOverflow
        );

        subu : adder_subtractor 
        PORT MAP(
            i_A => i_Operand_A,
            i_B => i_Operand_B, 
            i_nAdd_Sub => '1', 
            o_O => s_SUBU_OUT, 
            o_Cout => s_carry_subu
        );

        barrelLeft: barrel_shifter
		PORT MAP(
            i_IN => i_Operand_B, --RT
		    i_SHAMT => i_ShiftAmount,
            i_TYPE => '0', -- If '0' then logical shift. If '1' then arithmetic shift
		    i_DIRECTION => '1', --'1' then shift left.
		    o_OUT => s_BARRELLEFT_OUT)
        ;

        barrelRight: barrel_shifter
		PORT MAP(
            i_IN => i_Operand_B, --RT
		    i_SHAMT => i_ShiftAmount,
            i_TYPE => '0', -- If '0' then logical shift. If '1' then arithmetic shift
		    i_DIRECTION => '0', --'0' then shift right.
		    o_OUT => s_BARRELRIGHT_OUT);

        barrelSRA: barrel_shifter
        PORT MAP(
            i_IN => i_Operand_B, --RT
            i_SHAMT => i_ShiftAmount,
            i_TYPE => '1', -- If '0' then logical shift. If '1' then arithmetic shift
            i_DIRECTION => '0', --'0' then shift right.
            o_OUT => s_SRA_OUT);

        barrelLUI: barrel_shifter
        PORT MAP(
            i_IN => i_Operand_B, --RT
            i_SHAMT => "10000",
            i_TYPE => '0', -- If '0' then logical shift. If '1' then arithmetic shift
            i_DIRECTION => '1', --'1' then shift left.
            o_OUT => s_LUI_OUT);

        AND32: AND_32BITS
        port MAP(
            i_A => i_Operand_A,
            i_B => i_Operand_B,
            o_F => s_AND_OUT
        );
        
        OR32: OR_32BITS
        port MAP(
            i_A => i_Operand_A,
            i_B => i_Operand_B,
            o_F => s_OR_OUT
        );

        NOR32: NOR_32BITS
        port MAP(
            i_A => i_Operand_A,
            i_B => i_Operand_B,
            o_F => s_NOR_OUT
        );

        XOR32: XOR_32BITS
        port MAP(
            i_A => i_Operand_A,
            i_B => i_Operand_B,
            o_F => s_XOR_OUT
        );


        REPL_IN: FOR i IN 7 DOWNTO 0 generate
            s_REPL_IN(i) <= i_Operand_B(i);
        END generate REPL_IN;
	
        --repl.qb
        repl0: Repl
        port MAP(
            i_A  => s_REPL_IN,
            o_F  => s_REPL_OUT
        );

        --set less than
        --s_SET_LESS_THAN <= 1 when(i_Operand_A < i_Operand_B);
        --Sign s_Sub_OUT[31] = '0' Pos-Pos
                            --     Pos-Neg
                            --     Neg-Pos
                            --     Neg-Neg
        s_SET_LESS_THAN <= x"00000001" when (i_Operand_A(31) = '0' and i_Operand_B(31) = '0' and s_SUB_OUT > x"80000000") else
                        x"00000000" when (i_Operand_A(31) = '0' and i_Operand_B(31) = '1') else 
                        x"00000001" when (i_Operand_A(31) = '1' and i_Operand_B(31) = '0') else
                        x"00000001" when (i_Operand_A(31) = '1' and i_Operand_B(31) = '1' and s_SUB_OUT > x"80000000") else 
                        x"00000000";
	    s_SET_EQUAL <= '1' when (s_SUB_OUT = x"00000000") else '0';
        --

        --Add and Subtract
        o_CarryOut <= s_carry_sub when (i_ALUOP = "0101") else 
                      s_carry_add when (i_ALUOP = "0110") else 
                      '0';

        o_Zero <= s_SET_EQUAL;
        --Zero = 1 when beq and bne should still branch to location
        --Zero = 0 when conditions aren't met

        o_Overflow <= s_SUBOverflow when (i_ALUOP = "0101") else 
                      s_ADDOverflow when (i_ALUOP = "0110") else 
                     '0';

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


        o_Result <= s_SET_LESS_THAN when (i_ALUOP = "0000") else 
                    s_NOR_OUT when (i_ALUOP = "0001") else 
                    s_XOR_OUT when (i_ALUOP = "0010") else 
                    s_OR_OUT when (i_ALUOP = "0011") else 
                    s_AND_OUT when (i_ALUOP = "0100") else 
                    s_SUB_OUT when (i_ALUOP = "0101") else 
                    s_SUM_OUT when (i_ALUOP = "0110") else 
                    s_BARRELRIGHT_OUT when (i_ALUOP = "0111") else 
                    s_BARRELLEFT_OUT when (i_ALUOP = "1000") else 
                    s_SRA_OUT when (i_ALUOP = "1001") else 
                    s_LUI_OUT when (i_ALUOP = "1010") else 
                    s_SUMU_OUT when (i_ALUOP = "1011") else 
                    s_SUBU_OUT when (i_ALUOP = "1100") else 
                    s_REPL_OUT when (i_ALUOP = "1101") else 
                    x"00000000";
    
end structural;