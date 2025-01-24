-------------------------------------------------------------------------
-- Justin Sebahar
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- bit_extender.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of a bit_extender
--
--
-- NOTES:
-- 9/23/24
-------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY bit_extender IS
  PORT (
    i_select : IN STD_LOGIC;
    i_immediate : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    o_extended : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
END bit_extender;

ARCHITECTURE structural OF bit_extender IS

  SIGNAL s_0 : STD_LOGIC := '0';
  SIGNAL s_zero : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL s_sign : STD_LOGIC_VECTOR(31 DOWNTO 0);
BEGIN
  upper : FOR i IN 31 DOWNTO 16 GENERATE
    s_sign(i) <= i_immediate(15);
    s_zero(i) <= s_0;
  END GENERATE upper;

  lower : FOR i IN 15 DOWNTO 0 GENERATE
    s_sign(i) <= i_immediate(i);
    s_zero(i) <= i_immediate(i);
  END GENERATE lower;

  o_extended <= s_zero WHEN (i_select = '0') ELSE
    s_sign;
END structural;