-------------------------------------------------------------------------
-- Justin Sebahar
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- register
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of a register structurally implemented

-- 9/11/24
-------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY register_N IS
	GENERIC (N : INTEGER);
	PORT (
		i_CLK : IN STD_LOGIC;
		i_Reset : IN STD_LOGIC;
		i_W : IN STD_LOGIC;
		i_IN : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
		o_Q : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0));
END register_N;

ARCHITECTURE structure OF register_N IS

	-- D flip-flop --------------------------
	COMPONENT dffg
		PORT (
			i_CLK : IN STD_LOGIC; -- Clock input
			i_RST : IN STD_LOGIC; -- Reset input
			i_WE : IN STD_LOGIC; -- Write enable input
			i_D : IN STD_LOGIC; -- Data value input
			o_Q : OUT STD_LOGIC); -- Data value output
	END COMPONENT;
	SIGNAL s1, s2, s3 : STD_LOGIC;

BEGIN

	NbitRegister : FOR i IN N - 1 DOWNTO 0 GENERATE
		reg : dffg PORT MAP(
			i_CLK => i_CLK,
			i_RST => i_Reset,
			i_WE => i_W,
			i_D => i_IN(i),
			o_Q => o_Q(i));
	END GENERATE NbitRegister;

END structure;