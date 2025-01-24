-------------------------------------------------------------------------
-- Jackson Collalti
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- adder_subtractor
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of a N-bit adder_subtractor

-- 9/8/24
-------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY adder_subtractorOverflow IS
	GENERIC (N : INTEGER := 32);
	PORT (
		i_A : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
		i_B : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
		i_nAdd_Sub : IN STD_LOGIC;
		o_O : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
		o_Cout : OUT STD_LOGIC;
		o_Overflow : OUT STD_LOGIC);
END adder_subtractorOverflow;

ARCHITECTURE structure OF adder_subtractorOverflow IS

	-- N-bit ripple_carry_adder --------------------------
	COMPONENT ripple_carry_adder_overflow
		GENERIC (N : INTEGER := 32);
		PORT (
			i_X : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
			i_Y : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
			i_RCin : IN STD_LOGIC;
			o_S : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
			o_RCout : OUT STD_LOGIC;
			o_Overflow : OUT STD_LOGIC);
	END COMPONENT;

	-- N-bit 2-to-1 mux --------------------------
	COMPONENT mux2t1_N
		GENERIC (N : INTEGER := 32);
		PORT (
			i_S : IN STD_LOGIC;
			i_D0 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
			i_D1 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
			o_O : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0));
	END COMPONENT;

	-- N-bit inverter --------------------------
	COMPONENT ones_complementor
		GENERIC (N : INTEGER := 32);
		PORT (
			i_X : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
			o_O : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0));
	END COMPONENT;

	SIGNAL b_inverted, mux_output : STD_LOGIC_VECTOR(N - 1 DOWNTO 0);

BEGIN

	g1 : ones_complementor PORT MAP(i_X => i_B, o_O => b_inverted);
	g2 : mux2t1_N PORT MAP(i_S => i_nAdd_Sub, i_D0 => i_B, i_D1 => b_inverted, o_O => mux_output);
	g3 : ripple_carry_adder_overflow PORT MAP(i_X => i_A, i_Y => mux_output, i_RCin => i_nAdd_Sub, o_S => o_O, o_RCout => o_Cout,o_Overflow =>o_Overflow);

END structure;