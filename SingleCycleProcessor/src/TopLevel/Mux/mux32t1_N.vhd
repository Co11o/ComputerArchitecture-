-------------------------------------------------------------------------
-- Justin Sebahar
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- mux32t1_N.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of an N-bit wide 32:1
-- 9/12/24
-------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY mux32t1_N IS
  GENERIC (N : INTEGER := 32);
  PORT (
    i_S : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
    i_D0 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
    i_D1 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
    i_D2 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
    i_D3 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
    i_D4 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
    i_D5 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
    i_D6 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
    i_D7 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
    i_D8 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
    i_D9 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
    i_D10 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
    i_D11 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
    i_D12 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
    i_D13 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
    i_D14 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
    i_D15 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
    i_D16 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
    i_D17 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
    i_D18 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
    i_D19 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
    i_D20 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
    i_D21 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
    i_D22 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
    i_D23 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
    i_D24 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
    i_D25 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
    i_D26 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
    i_D27 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
    i_D28 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
    i_D29 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
    i_D30 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
    i_D31 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
    o_O : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0));

END mux32t1_N;

ARCHITECTURE dataflow OF mux32t1_N IS
BEGIN
  o_O <= i_D0 WHEN (i_S = "00000") ELSE
    i_D1 WHEN (i_S = "00001") ELSE
    i_D2 WHEN (i_S = "00010") ELSE
    i_D3 WHEN (i_S = "00011") ELSE
    i_D4 WHEN (i_S = "00100") ELSE
    i_D5 WHEN (i_S = "00101") ELSE
    i_D6 WHEN (i_S = "00110") ELSE
    i_D7 WHEN (i_S = "00111") ELSE
    i_D8 WHEN (i_S = "01000") ELSE
    i_D9 WHEN (i_S = "01001") ELSE
    i_D10 WHEN (i_S = "01010") ELSE
    i_D11 WHEN (i_S = "01011") ELSE
    i_D12 WHEN (i_S = "01100") ELSE
    i_D13 WHEN (i_S = "01101") ELSE
    i_D14 WHEN (i_S = "01110") ELSE
    i_D15 WHEN (i_S = "01111") ELSE
    i_D16 WHEN (i_S = "10000") ELSE
    i_D17 WHEN (i_S = "10001") ELSE
    i_D18 WHEN (i_S = "10010") ELSE
    i_D19 WHEN (i_S = "10011") ELSE
    i_D20 WHEN (i_S = "10100") ELSE
    i_D21 WHEN (i_S = "10101") ELSE
    i_D22 WHEN (i_S = "10110") ELSE
    i_D23 WHEN (i_S = "10111") ELSE
    i_D24 WHEN (i_S = "11000") ELSE
    i_D25 WHEN (i_S = "11001") ELSE
    i_D26 WHEN (i_S = "11010") ELSE
    i_D27 WHEN (i_S = "11011") ELSE
    i_D28 WHEN (i_S = "11100") ELSE
    i_D29 WHEN (i_S = "11101") ELSE
    i_D30 WHEN (i_S = "11110") ELSE
    i_D31 WHEN (i_S = "11111");
END dataflow;