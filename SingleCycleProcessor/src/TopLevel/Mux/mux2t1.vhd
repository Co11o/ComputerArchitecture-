-------------------------------------------------------------------------
-- Justin Sebahar
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- Mux2t1
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of a 2-to-1 mux structurally implemented

-- 9/4/24
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity mux2t1 is
	port ( i_D0 : in std_logic;
		i_D1 : in std_logic;
		i_S : in std_logic;
		o_O : out std_logic);
end mux2t1;

architecture structure of mux2t1 is

-- NOT gate --------------------------
component invg port(i_A : in std_logic;
			o_F : out std_logic);
end component;

-- AND gate --------------------------
component andg2 port(i_A : in std_logic;
			i_B : in std_logic;
			o_F : out std_logic);
end component;

-- OR gate --------------------------
component org2 port(i_A : in std_logic;
		i_B : in std_logic;
		o_F : out std_logic);
end component;

signal s1, s2, s3: std_logic;

begin
	g1: invg port map(i_A => i_S, o_F => s1);
	g2: andg2 port map(i_A => s1, i_B => i_D0, o_F => s2);
	g3: andg2 port map(i_A => i_D1, i_B => i_S, o_F => s3);
	g4: org2 port map(i_A => s2, i_B => s3, o_F => o_O);
end structure;