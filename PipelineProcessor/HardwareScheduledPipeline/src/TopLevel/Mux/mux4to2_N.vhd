-------------------------------------------------------------------------
-- Justin Sebahar
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- mux4to2_N.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of an N-bit wide 4:2
-- 11/12/24
-------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY mux4to2_N IS
  GENERIC (N : INTEGER := 32);
  PORT (
    i_S : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    i_D0 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
    i_D1 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
    i_D2 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
    i_D3 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
    o_O : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0)
  );

END mux4to2_N;

ARCHITECTURE dataflow OF mux4to2_N IS
BEGIN
  o_O <= i_D0 WHEN (i_S = "00") ELSE
    i_D1 WHEN (i_S = "01") ELSE
    i_D2 WHEN (i_S = "10") ELSE
    i_D3 WHEN (i_S = "11");
END dataflow;