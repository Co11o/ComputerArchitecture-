--Author Jackson Collalti
--Fetch Logic

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY FetchLogic IS
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
END FetchLogic;

ARCHITECTURE structure OF FetchLogic IS

	--Adder-----------------------------
	COMPONENT ripple_carry_adder IS
		GENERIC (N : INTEGER := 32);
		PORT (
			i_X : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
			i_Y : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
			i_RCin : IN STD_LOGIC;
			o_S : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
			o_RCout : OUT STD_LOGIC);
	END COMPONENT;

	COMPONENT barrel_shifter IS
		PORT (
			i_IN : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			i_SHAMT : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
			i_DIRECTION : IN STD_LOGIC; -- If '0' then shift right; if '1' then shift left.
			i_TYPE : IN STD_LOGIC; -- If '0' then logical shift. If '1' then arithmetic shift
			o_OUT : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
	END COMPONENT;

	--Mux 2 to 1_N bits-----------------------------
	COMPONENT mux2t1_N IS
		GENERIC (N : INTEGER := 32);
		PORT (
			i_S : IN STD_LOGIC;
			i_D0 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
			i_D1 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
			o_O : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0));
	END COMPONENT;

	COMPONENT mux2t1 IS
		PORT (
			i_D0 : IN STD_LOGIC;
			i_D1 : IN STD_LOGIC;
			i_S : IN STD_LOGIC;
			o_O : OUT STD_LOGIC);
	END COMPONENT;

	COMPONENT andg2 IS
		PORT (
			i_A : IN STD_LOGIC;
			i_B : IN STD_LOGIC;
			o_F : OUT STD_LOGIC);
	END COMPONENT;

	COMPONENT invg IS
		PORT (
			i_A : IN STD_LOGIC;
			o_F : OUT STD_LOGIC);
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

	SIGNAL s_NOT_Zero : STD_LOGIC; --For unused adder carry outs
	SIGNAL s_BRANCH_ENABLE_ADDER : STD_LOGIC;
	SIGNAL s_PC_PLUS_4, s_JUMP_ADDRESS_32_BIT, s_BRANCH_ADDRESS_SHIFTED,
	s_BRANCH_ADDRESS, s_MUX_JUMP_ADDRESS, s_MUX_BRANCH_ADDRESS, s_TEMP_PC_OUT : STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
	SIGNAL s_BRANCH_TYPE_OUT : STD_LOGIC_VECTOR(0 DOWNTO 0);
	SIGNAL s_ID_PC_PLUS_4 : STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
	SIGNAL s_EX_PC_PLUS_4 : STD_LOGIC_VECTOR(N - 1 DOWNTO 0);

	-----------------------------
BEGIN
	---IF
	-- Get PC + 4
	g_Adder_PC_PLUS_4 : ripple_carry_adder PORT MAP(
		i_X => i_PC,
		i_Y => "00000000000000000000000000000100",
		i_RCin => '0',
		o_S => s_PC_PLUS_4,
		o_RCout => OPEN
	);

	--Branch Address or (PC+4)
	g_BranchMux : mux2t1_N PORT MAP(
		i_S => s_BRANCH_ENABLE_ADDER,
		i_D0 => s_PC_PLUS_4,
		i_D1 => s_BRANCH_ADDRESS,
		o_O => s_MUX_BRANCH_ADDRESS
	);

	g_FinalJumpMux : mux2t1_N PORT MAP(
		i_S => i_JumpEnable,
		i_D0 => s_MUX_BRANCH_ADDRESS,
		i_D1 => s_MUX_JUMP_ADDRESS,
		o_O => s_TEMP_PC_OUT
	);

	IF_PC_4 : register_N GENERIC MAP(N => 32) PORT MAP(i_CLK => i_CLK, i_Reset => i_RST, i_W => '1', i_IN => s_PC_PLUS_4, o_Q => s_ID_PC_PLUS_4);

	------------------------------------------------------------------------------------------------
	---ID
	ID_PC_4 : register_N GENERIC MAP(N => 32) PORT MAP(i_CLK => i_CLK, i_Reset => i_RST, i_W => '1', i_IN => s_ID_PC_PLUS_4, o_Q => s_EX_PC_PLUS_4);

	------------------------------------------------------------------------------------------------
	---EX

	--Jump Address Shift and Combine
	--Jump Address [31:28] = PC+4 (31:28) 
	--Jump Address [27:2] = i_JumpAddress (Instuction[25:0])
	--Jump Address [1:0] = "00" Alignment 
	s_JUMP_ADDRESS_32_BIT <= (s_EX_PC_PLUS_4(31 DOWNTO 28) & i_JumpAddress & "00");

	--Jump Address Shift and Combine
	--Branch Address [31:2] = Branch Address shifted 2
	--Branch Address [1:0] = "00" for shifting in replacements
	--s_BRANCH_ADDRESS_SHIFTED <= (i_BranchAddress(31 downto 2) & "00");
	SHIFT_BRANCH_ADDRESS : barrel_shifter PORT MAP(
		i_IN => i_BranchAddress,
		i_SHAMT => "00010",
		i_DIRECTION => '1',
		i_TYPE => '0',
		o_OUT => s_BRANCH_ADDRESS_SHIFTED
	);

	g_NOT_ZERO : invg PORT MAP(
		i_A => i_Zero,
		o_F => s_NOT_Zero
	);

	--Branch Type Mux BNE or BEQ selects the zero type
	--If BNE, we want zero to be 0, meaning not equal then send 1 (inverter of i_Zero) to branch AND Gate
	--If BEQ, we want zero to be 1, meaning equal then send 1 (i_Zero) to branch AND Gate
	g_BranchTypeMux : mux2t1 PORT MAP(
		i_S => i_BranchType,
		i_D0 => s_NOT_Zero,
		i_D1 => i_Zero,
		o_O => s_BRANCH_TYPE_OUT(0)
	);

	-- Get Branch Address + (PC + 4)
	g_Adder_Branch_PC_PLUS_4 : ripple_carry_adder PORT MAP(
		i_X => s_BRANCH_ADDRESS_SHIFTED,
		i_Y => s_EX_PC_PLUS_4,
		i_RCin => '0',
		o_S => s_BRANCH_ADDRESS,
		o_RCout => OPEN
	);

	--Jump Type Mux JumpRegister or Jump
	g_JRMux : mux2t1_N PORT MAP(
		i_S => i_JREnable,
		i_D0 => s_JUMP_ADDRESS_32_BIT,
		i_D1 => i_JRAddress,
		o_O => s_MUX_JUMP_ADDRESS
	);

	g_ANDBranch : andg2 PORT MAP(
		i_A => s_BRANCH_TYPE_OUT(0),
		i_B => i_BranchEnable,
		o_F => s_BRANCH_ENABLE_ADDER
	);

	------------------------------------------------------------------------------------------------
	---DM
	PROCESS (i_CLK)
	BEGIN
		IF ((rising_edge(i_CLK)) AND (i_RST = '0')) THEN
			o_PC <= s_TEMP_PC_OUT;
		ELSIF ((rising_edge(i_CLK)) AND (i_RST = '1')) THEN
			o_PC <= x"00400000";
		END IF;
	END PROCESS;
END structure;