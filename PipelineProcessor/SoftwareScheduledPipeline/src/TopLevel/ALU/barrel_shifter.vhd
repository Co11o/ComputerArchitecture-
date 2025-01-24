-- barrel_shifter.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of a 32-bit barrel shifter.

-- 10/8/24
-------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY barrel_shifter IS
	PORT (
		i_IN : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		i_SHAMT : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		i_DIRECTION : IN STD_LOGIC; -- If '0' then shift right; if '1' then shift left.
		i_TYPE : IN STD_LOGIC; -- If '0' then logical shift. If '1' then arithmetic shift
		o_OUT : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
END barrel_shifter;

ARCHITECTURE structure OF barrel_shifter IS

	-- 2-to-1 mux --------------------------
	COMPONENT mux2t1
		PORT (
			i_S : IN STD_LOGIC;
			i_D0 : IN STD_LOGIC;
			i_D1 : IN STD_LOGIC;
			o_O : OUT STD_LOGIC);
	END COMPONENT;

	COMPONENT mux2t1_N
		GENERIC (N : INTEGER := 32); -- Generic of type integer for input/output data width. Default value is 32.
		PORT (
			i_S : IN STD_LOGIC;
			i_D0 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
			i_D1 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
			o_O : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0));
	END COMPONENT;

	SIGNAL s_IN_REVERSED : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL s_IN : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL s_filler : STD_LOGIC := '0';
	SIGNAL logical : STD_LOGIC := '0';
	SIGNAL arithmetic : STD_LOGIC;
	SIGNAL s_SHAMT16 : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL s_SHAMT8 : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL s_SHAMT4 : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL s_SHAMT2 : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL s_SHAMT1 : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL s_OUT_REVERSED : STD_LOGIC_VECTOR(31 DOWNTO 0);

BEGIN

	arithmetic <= i_IN(31);
	
	-- Reverse i_IN and store in copy signal s_IN_REVERSED
	REVERSE : FOR i IN 31 DOWNTO 0 GENERATE
		s_IN_REVERSED(i) <= i_IN(31 - i);
	END GENERATE REVERSE;

	-- If i_direction==0, we shift right (use input i_IN); shift left otherwise (use reversed input s_IN_REVERSED).
	SHIFTER_INPUT : mux2t1_N PORT MAP(i_S => i_DIRECTION, i_D0 => i_IN, i_D1 => s_IN_REVERSED, o_O => s_IN);
	SHIFTER_FILL : mux2t1 PORT MAP(i_S => i_TYPE, i_D0 => logical, i_D1 => arithmetic, o_O => s_filler);

	-------------------------------------------------------

	SHAMT16a : FOR i IN 31 DOWNTO 16 GENERATE
		MUXI : mux2t1 PORT MAP(
			i_S => i_SHAMT(4),
			i_D0 => s_IN(i),
			i_D1 => s_filler,
			o_O => s_SHAMT16(i));
	END GENERATE SHAMT16a;

	SHAMT16b : FOR i IN 15 DOWNTO 0 GENERATE
		MUXI : mux2t1 PORT MAP(
			i_S => i_SHAMT(4),
			i_D0 => s_IN(i),
			i_D1 => s_IN(i + 16),
			o_O => s_SHAMT16(i));
	END GENERATE SHAMT16b;
	-------------------------------------------------------
	SHAMT8a : FOR i IN 31 DOWNTO 24 GENERATE
		MUXI : mux2t1 PORT MAP(
			i_S => i_SHAMT(3),
			i_D0 => s_SHAMT16(i),
			i_D1 => s_filler,
			o_O => s_SHAMT8(i));
	END GENERATE SHAMT8a;

	SHAMT8b : FOR i IN 23 DOWNTO 0 GENERATE
		MUXI : mux2t1 PORT MAP(
			i_S => i_SHAMT(3),
			i_D0 => s_SHAMT16(i),
			i_D1 => s_SHAMT16(i + 8),
			o_O => s_SHAMT8(i));
	END GENERATE SHAMT8b;
	-------------------------------------------------------
	SHAMT4a : FOR i IN 31 DOWNTO 28 GENERATE
		MUXI : mux2t1 PORT MAP(
			i_S => i_SHAMT(2),
			i_D0 => s_SHAMT8(i),
			i_D1 => s_filler,
			o_O => s_SHAMT4(i));
	END GENERATE SHAMT4a;

	SHAMT4b : FOR i IN 27 DOWNTO 0 GENERATE
		MUXI : mux2t1 PORT MAP(
			i_S => i_SHAMT(2),
			i_D0 => s_SHAMT8(i),
			i_D1 => s_SHAMT8(i + 4),
			o_O => s_SHAMT4(i));
	END GENERATE SHAMT4b;
	-------------------------------------------------------
	SHAMT2a : FOR i IN 31 DOWNTO 30 GENERATE
		MUXI : mux2t1 PORT MAP(
			i_S => i_SHAMT(1),
			i_D0 => s_SHAMT4(i),
			i_D1 => s_filler,
			o_O => s_SHAMT2(i));
	END GENERATE SHAMT2a;

	SHAMT2b : FOR i IN 29 DOWNTO 0 GENERATE
		MUXI : mux2t1 PORT MAP(
			i_S => i_SHAMT(1),
			i_D0 => s_SHAMT4(i),
			i_D1 => s_SHAMT4(i + 2),
			o_O => s_SHAMT2(i));
	END GENERATE SHAMT2b;
	-------------------------------------------------------
	SHAMT1a : FOR i IN 31 DOWNTO 31 GENERATE
		MUXI : mux2t1 PORT MAP(
			i_S => i_SHAMT(0),
			i_D0 => s_SHAMT2(i),
			i_D1 => s_filler,
			o_O => s_SHAMT1(i));
	END GENERATE SHAMT1a;

	SHAMT1b : FOR i IN 30 DOWNTO 0 GENERATE
		MUXI : mux2t1 PORT MAP(
			i_S => i_SHAMT(0),
			i_D0 => s_SHAMT2(i),
			i_D1 => s_SHAMT2(i + 1),
			o_O => s_SHAMT1(i));
	END GENERATE SHAMT1b;
	-------------------------------------------------------

	-- Reverse the output
	REVERSE2 : FOR i IN 31 DOWNTO 0 GENERATE
		s_OUT_REVERSED(i) <= s_SHAMT1(31 - i);
	END GENERATE REVERSE2;

	-- If left shift, we use the non-reversed output. Right shift use reversed.
	SHIFTER_OUTPUT : mux2t1_N PORT MAP(i_S => i_DIRECTION, i_D0 => s_SHAMT1, i_D1 => s_OUT_REVERSED, o_O => o_OUT);

END structure;