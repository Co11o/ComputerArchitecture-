-- tb_forwarding_unit.vhd
-------------------------------------------------------------------------            
-- 11/13/24
-------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_textio.ALL; -- For logic types I/O
LIBRARY std;
USE std.env.ALL; -- For hierarchical/external signals
USE std.textio.ALL; -- For basic I/O

-- Usually name your testbench similar to below for clarity tb_<name>
ENTITY tb_forwarding_unit IS
	GENERIC (gCLK_HPER : TIME := 10 ns); -- Generic for half of the clock cycle period
END tb_forwarding_unit;

ARCHITECTURE behavior OF tb_forwarding_unit IS

	-- Define the total clock period time
	CONSTANT cCLK_PER : TIME := gCLK_HPER * 2;

	COMPONENT forwarding_unit IS
		PORT (
			EX_RS : IN STD_LOGIC_VECTOR(4 DOWNTO 0); --RS in the execute stage
			EX_RT : IN STD_LOGIC_VECTOR(4 DOWNTO 0); --RT in the execute stage
			DM_RD : IN STD_LOGIC_VECTOR(4 DOWNTO 0); --RD in the memory stage
			WB_RD : IN STD_LOGIC_VECTOR(4 DOWNTO 0); --RD in the write back stage
			DM_RegWr : IN STD_LOGIC; --Reg write in the memory stage
			WB_RegWr : IN STD_LOGIC; --Reg write in the wrte back stage
			select_RS : OUT STD_LOGIC_VECTOR(1 DOWNTO 0); --MUX select value to determine operand A into ALU
			select_RT : OUT STD_LOGIC_VECTOR(1 DOWNTO 0) --MUX select value to determine operand B into ALU
		);

	END COMPONENT;

	SIGNAL s_CLK, reset : STD_LOGIC := '0';
	SIGNAL s_EX_RS : STD_LOGIC_VECTOR(4 DOWNTO 0); --RS in the execute stage
	SIGNAL s_EX_RT : STD_LOGIC_VECTOR(4 DOWNTO 0); --RT in the execute stage
	SIGNAL s_DM_RD : STD_LOGIC_VECTOR(4 DOWNTO 0); --RD in the memory stage
	SIGNAL s_WB_RD : STD_LOGIC_VECTOR(4 DOWNTO 0); --RD in the write back stage
	SIGNAL s_DM_RegWr : STD_LOGIC; --Reg write in the memory stage
	SIGNAL s_WB_RegWr : STD_LOGIC; --Reg write in the wrte back stage
	SIGNAL s_select_RS : STD_LOGIC_VECTOR(1 DOWNTO 0); --MUX select value to determine operand A into ALU
	SIGNAL s_select_RT : STD_LOGIC_VECTOR(1 DOWNTO 0); --MUX select value to determine operand B into ALU

BEGIN
	control : forwarding_unit
	PORT MAP(
		EX_RS => s_EX_RS,
		EX_RT => s_EX_RT,
		DM_RD => s_DM_RD,
		WB_RD => s_WB_RD,
		DM_RegWr => s_DM_RegWr,
		WB_RegWr => s_WB_RegWr,
		select_RS => s_select_RS,
		select_RT => s_select_RT
	);

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

		-- No fowarding needed:
		s_EX_RS <= "00001";
		s_EX_RT <= "00010";
		s_DM_RD <= "00011";
		s_WB_RD <= "00100";
		s_DM_RegWr <= '1';
		s_WB_RegWr <= '1';
		WAIT FOR cCLK_PER;

		s_EX_RS <= "00001";
		s_EX_RT <= "00010";
		s_DM_RD <= "00001";
		s_WB_RD <= "00010";
		s_DM_RegWr <= '0';
		s_WB_RegWr <= '0';
		WAIT FOR cCLK_PER;
		-- Forward rs from memory stage
		s_EX_RS <= "00001";
		s_EX_RT <= "00000";
		s_DM_RD <= "00001";
		s_WB_RD <= "00000";
		s_DM_RegWr <= '1';
		s_WB_RegWr <= '0';
		WAIT FOR cCLK_PER;

		-- Forward rt from memory stage
		s_EX_RS <= "00000";
		s_EX_RT <= "00001";
		s_DM_RD <= "00001";
		s_WB_RD <= "00000";
		s_DM_RegWr <= '1';
		s_WB_RegWr <= '0';
		WAIT FOR cCLK_PER;
		-- Forward rs and rt from memory stage
		s_EX_RS <= "00001";
		s_EX_RT <= "00001";
		s_DM_RD <= "00001";
		s_WB_RD <= "00000";
		s_DM_RegWr <= '1';
		s_WB_RegWr <= '1';
		WAIT FOR cCLK_PER;
		-- Forward rt from write back stage
		s_EX_RS <= "00001";
		s_EX_RT <= "00010";
		s_DM_RD <= "00001";
		s_WB_RD <= "00010";
		s_DM_RegWr <= '1';
		s_WB_RegWr <= '1';
		WAIT FOR cCLK_PER;

		WAIT;
	END PROCESS;

END behavior;