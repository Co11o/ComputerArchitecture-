-------------------------------------------------------------------------
-- Justin Sebahar
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- ripple_carry_adder
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of a N-bit ripple-carry adder structurally implemented

-- 9/4/24
-------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY ripple_carry_adder IS
	GENERIC (N : INTEGER := 32);
	PORT (
		i_X : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
		i_Y : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
		i_RCin : IN STD_LOGIC;
		o_S : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
		o_RCout : OUT STD_LOGIC);
END ripple_carry_adder;

ARCHITECTURE structure OF ripple_carry_adder IS

	-- Full adder --------------------------
	COMPONENT full_adder IS
		PORT (
			i_X : IN STD_LOGIC;
			i_Y : IN STD_LOGIC;
			i_Cin : IN STD_LOGIC;
			o_S : OUT STD_LOGIC;
			o_Cout : OUT STD_LOGIC);
	END COMPONENT;

	SIGNAL internal_carry : STD_LOGIC_VECTOR(N - 1 DOWNTO 0);

BEGIN
	Adder0 : FOR i IN 0 TO 0 GENERATE
		Add : full_adder PORT MAP(
			i_X => i_X(i),
			i_Y => i_Y(i),
			i_Cin => i_RCin,
			o_S => o_S(i),
			o_Cout => internal_carry(i));
	END GENERATE Adder0;

	Adder1 : FOR i IN 1 TO N - 2 GENERATE
		Add : full_adder PORT MAP(
			i_X => i_X(i),
			i_Y => i_Y(i),
			i_Cin => internal_carry(i - 1),
			o_S => o_S(i),
			o_Cout => internal_carry(i));
	END GENERATE Adder1;

	Adder2 : FOR i IN N - 1 TO N - 1 GENERATE
		Add : full_adder PORT MAP(
			i_X => i_X(i),
			i_Y => i_Y(i),
			i_Cin => internal_carry(i - 1),
			o_S => o_S(i),
			o_Cout => o_RCout);
	END GENERATE Adder2;

	internal_carry(N - 1) <= '0';
END structure;