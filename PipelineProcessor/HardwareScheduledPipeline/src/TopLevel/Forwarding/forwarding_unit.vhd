-------------------------------------------------------------------------
-- forwarding_unit.vhd
-------------------------------------------------------------------------
-- 11/12/24
-------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY forwarding_unit IS
  PORT (
    EX_RS : IN STD_LOGIC_VECTOR(4 DOWNTO 0); --RS in the execute stage
    EX_RT : IN STD_LOGIC_VECTOR(4 DOWNTO 0); --RT in the execute stage
    DM_RD : IN STD_LOGIC_VECTOR(4 DOWNTO 0); --RD in the memory stage
    WB_RD : IN STD_LOGIC_VECTOR(4 DOWNTO 0); --RD in the write back stage
    DM_RegWr : IN STD_LOGIC; --Reg write in the memory stage
    WB_RegWr : IN STD_LOGIC; --Reg write in the wrte back stage
    select_RS : OUT STD_LOGIC_VECTOR(1 DOWNTO 0); --MUX select value to determine operand A into ALU
    select_RT : OUT STD_LOGIC_VECTOR(1 DOWNTO 0) --MUX select value to determine operand B into ALU
  );

END forwarding_unit;

ARCHITECTURE dataflow OF forwarding_unit IS
BEGIN

  select_RS <= "01" WHEN (DM_RegWr = '1' AND DM_RD /= "00000" AND DM_RD = EX_RS) ELSE
    "10" WHEN (WB_RegWr = '1' AND WB_RD /= "00000" AND NOT (DM_RegWr = '1' AND (DM_RD /= "00000") AND (DM_RD = EX_RS)) AND WB_RD = EX_RS) ELSE
    "00";

  select_RT <= "01" WHEN (DM_RegWr = '1' AND DM_RD /= "00000" AND DM_RD = EX_RT) ELSE
    "10" WHEN (WB_RegWr = '1' AND WB_RD /= "00000" AND NOT (DM_RegWr = '1' AND (DM_RD /= "00000") AND (DM_RD = EX_RT)) AND WB_RD = EX_RT) ELSE
    "00";

END dataflow;