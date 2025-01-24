-------------------------------------------------------------------------
-- Justin Sebahar
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- ones_complementor
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of an N-bit inverter

-- 9/4/24
-------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY ones_complementor IS
	GENERIC (N : INTEGER := 32);
	PORT (
		i_X : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
		o_O : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0));
END ones_complementor;

ARCHITECTURE structure OF ones_complementor IS

	-- NOT gate --------------------------
	COMPONENT invg PORT (i_A : IN STD_LOGIC;
		o_F : OUT STD_LOGIC);
	END COMPONENT;

BEGIN
	G_NBit_Inverter : FOR i IN 0 TO N - 1 GENERATE
		INVERT : invg PORT MAP(
			i_A => i_X(i), -- ith instance's data 0 input hooked up to ith data 0 input.
			o_F => o_O(i)); -- ith instance's data output hooked up to ith data output.
	END GENERATE G_NBit_Inverter;
END structure;