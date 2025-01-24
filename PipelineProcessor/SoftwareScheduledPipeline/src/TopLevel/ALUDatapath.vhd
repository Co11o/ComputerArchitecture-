--ALU datapath
--Jackson Collalti
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY ALUDatapath IS
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
END ALUDatapath;

ARCHITECTURE structure OF ALUDatapath IS

	-- 32-bit register file --------------------------
	COMPONENT register_file
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

	COMPONENT ALU is
        port(
            i_Operand_A          : in STD_LOGIC_VECTOR(31 DOWNTO 0);
            i_Operand_B          : in STD_LOGIC_VECTOR(31 DOWNTO 0);
            i_ShiftAmount          : in STD_LOGIC_VECTOR(4 DOWNTO 0);
            i_ALUOP : in STD_LOGIC_VECTOR(3 DOWNTO 0);
            o_Result          : out STD_LOGIC_VECTOR(31 DOWNTO 0);
            o_CarryOut : OUT STD_LOGIC;
            o_Overflow : OUT STD_LOGIC;
            o_Zero : OUT STD_LOGIC);
    end COMPONENT;

	COMPONENT mux2t1_N
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

	COMPONENT mem IS
		GENERIC (
			DATA_WIDTH : NATURAL := 32;
			ADDR_WIDTH : NATURAL := 10);
		PORT (
			clk : IN STD_LOGIC;
			addr : IN STD_LOGIC_VECTOR((ADDR_WIDTH - 1) DOWNTO 0);
			data : IN STD_LOGIC_VECTOR((DATA_WIDTH - 1) DOWNTO 0);
			we : IN STD_LOGIC;
			q : OUT STD_LOGIC_VECTOR((DATA_WIDTH - 1) DOWNTO 0));
	END COMPONENT;

	SIGNAL rs_val : STD_LOGIC_VECTOR(31 DOWNTO 0) := "00000000000000000000000000000000";
	SIGNAL rt_val : STD_LOGIC_VECTOR(31 DOWNTO 0) := "00000000000000000000000000000000";
	SIGNAL s_immExt : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL s_Mux1Out : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL s_result : STD_LOGIC_VECTOR(31 DOWNTO 0) := "00000000000000000000000000000000";
	SIGNAL s_addr : STD_LOGIC_VECTOR(9 DOWNTO 0);
	SIGNAL s_carry : STD_LOGIC;
    SIGNAL s_Overflow : STD_LOGIC;
    SIGNAL s_Zero : STD_LOGIC;
	SIGNAL s_dataOut : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL s_Mux2Out : STD_LOGIC_VECTOR(31 DOWNTO 0);

BEGIN
	s_addr <= s_result(11 DOWNTO 2);

	reg_file : register_file PORT MAP(
		i_CLOCK => i_CLK, i_RESET => i_RST, i_WriteTo => rd, i_WEN => regWrite, i_INPUT => s_Mux2Out,
		i_MUX_SELECT1 => rs, i_MUX_SELECT2 => rt, o_OUT1 => rs_val, o_OUT2 => rt_val);

	extender : bit_extender PORT MAP(i_select => extender_select, i_immediate => immediate, o_extended => s_immExt);

	mux : mux2t1_N PORT MAP(i_S => ALUSrc, i_D0 => rt_val, i_D1 => s_immExt, o_O => s_Mux1Out);

	DatapathALU : ALU PORT MAP(
        i_Operand_A => rs_val,
        i_Operand_B => s_Mux1Out,
        i_ShiftAmount => i_ShiftAmount,
        i_ALUOP => i_ALUOP,
        o_Result => s_result,
        o_CarryOut => s_carry,
        o_Overflow => s_Overflow,
        o_Zero => s_Zero);

	memory : mem PORT MAP(clk => i_CLK, addr => s_addr, data => rt_val, we => memWrite, q => s_dataOut);

	mux2 : mux2t1_N PORT MAP(i_S => memToReg, i_D0 => s_result, i_D1 => s_dataOut, o_O => s_Mux2Out);
END structure;