-------------------------------------------------------------------------
-- Justin Sebahar
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- full_adder
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of a full adder

-- 9/4/24
-------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY full_adder IS
	PORT (
		i_X : IN STD_LOGIC;
		i_Y : IN STD_LOGIC;
		i_Cin : IN STD_LOGIC;
		o_S : OUT STD_LOGIC;
		o_Cout : OUT STD_LOGIC);
END full_adder;

ARCHITECTURE structure OF full_adder IS

	-- XOR gate --------------------------
	COMPONENT xorg2 PORT (i_A : IN STD_LOGIC;
		i_B : IN STD_LOGIC;
		o_F : OUT STD_LOGIC);
	END COMPONENT;

	-- AND gate --------------------------
	COMPONENT andg2 PORT (i_A : IN STD_LOGIC;
		i_B : IN STD_LOGIC;
		o_F : OUT STD_LOGIC);
	END COMPONENT;

	-- OR gate --------------------------
	COMPONENT org2 PORT (i_A : IN STD_LOGIC;
		i_B : IN STD_LOGIC;
		o_F : OUT STD_LOGIC);
	END COMPONENT;

	SIGNAL s1, s2, s3 : STD_LOGIC;

BEGIN
	g1 : xorg2 PORT MAP(i_A => i_X, i_B => i_Y, o_F => s1);
	g2 : xorg2 PORT MAP(i_A => s1, i_B => i_Cin, o_F => o_S);
	g3 : andg2 PORT MAP(i_A => s1, i_B => i_Cin, o_F => s2);
	g4 : andg2 PORT MAP(i_A => i_X, i_B => i_Y, o_F => s3);
	g5 : org2 PORT MAP(i_A => s2, i_B => s3, o_F => o_Cout);
END structure;