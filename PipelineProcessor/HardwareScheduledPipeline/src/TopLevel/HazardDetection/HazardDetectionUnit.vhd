LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY HazardDetectionUnit IS
	GENERIC (N : INTEGER := 32);
	PORT (
		i_CLK : IN STD_LOGIC;
		--Jump
		i_JUMP_EN : IN STD_LOGIC;
		i_JR_IDEX : IN STD_LOGIC;
		i_JR : IN STD_LOGIC;
		i_JAL : IN STD_LOGIC;
		--Branch
		i_BRANCH_TYPE : IN STD_LOGIC;--BNE = 0, BEQ = 1
		i_BRANCH : IN STD_LOGIC;
		--Load Word
		i_MemRead_IDEX : IN STD_LOGIC;
		i_MemRead_EXMEM : IN STD_LOGIC;
		--Important Register Values
		i_RegRT_IF : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		i_RegRS_IF : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		i_RegRT_IDEX : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		i_RegRD_IDEX : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		i_RegRD_EXMEM : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		i_RegRD_MEMWB : IN STD_LOGIC_VECTOR(4 DOWNTO 0);

		i_RegRT_IFID : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		i_RegRS_IFID : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		i_RegRTVal_IFID : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		i_RegRSVal_IFID : IN STD_LOGIC_VECTOR(31 DOWNTO 0);

		i_BRANCH_TYPE_IDEX : IN STD_LOGIC;--BNE = 0, BEQ = 1
		i_BRANCH_IDEX : IN STD_LOGIC;
		i_RegRTVal_IDEX : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		i_RegRSVal_IDEX : IN STD_LOGIC_VECTOR(31 DOWNTO 0);

		--Flush = 1 means flush is needed
		oFlush_IFID : OUT STD_LOGIC;
		oFlush_IDEX : OUT STD_LOGIC;
		oFlush_EXMEM : OUT STD_LOGIC;
		oFlush_MEMWB : OUT STD_LOGIC;
		--Stall = 1 means stall is needed
		oStall_IF : OUT STD_LOGIC;
		oStall_IFID : OUT STD_LOGIC;
		oStall_IDEX : OUT STD_LOGIC;
		oStall_EXMEM : OUT STD_LOGIC;
		oStall_MEMWB : OUT STD_LOGIC
	);
END HazardDetectionUnit;

ARCHITECTURE dataflow OF HazardDetectionUnit IS

BEGIN
	PROCESS (i_CLK)
	BEGIN
		--LW Works
		IF (((i_MemRead_IDEX = '1') AND ((i_RegRT_IDEX = i_RegRT_IFID) OR (i_RegRT_IDEX = i_RegRS_IFID))) AND ((i_CLK = '0'))) THEN
			oFlush_IFID <= '0';
			oFlush_IDEX <= '0';
			oFlush_EXMEM <= '0';
			oFlush_MEMWB <= '0';
			oStall_IF <= '0';
			oStall_IFID <= '0';
			oStall_IDEX <= '0';
			oStall_EXMEM <= '1';
			oStall_MEMWB <= '1';
			--LW second stall
		ELSIF (((i_MemRead_EXMEM = '1') AND ((i_RegRD_EXMEM = i_RegRT_IF) OR (i_RegRD_EXMEM = i_RegRS_IF))) AND ((i_CLK = '0'))) THEN
			oFlush_IFID <= '0';
			oFlush_IDEX <= '0';
			oFlush_EXMEM <= '0';
			oFlush_MEMWB <= '0';
			oStall_IF <= '0';
			oStall_IFID <= '0';
			oStall_IDEX <= '0';
			oStall_EXMEM <= '1';
			oStall_MEMWB <= '1';
			--Branch IF/ID
		ELSIF ((i_BRANCH = '1') AND (
			((i_RegRD_IDEX = i_RegRS_IFID) AND (i_RegRD_IDEX /= "00000")) OR ((i_RegRD_EXMEM = i_RegRS_IFID) AND (i_RegRD_EXMEM /= "00000")) OR ((i_RegRD_MEMWB = i_RegRS_IFID) AND (i_RegRD_MEMWB /= "00000")) OR
			((i_RegRD_IDEX = i_RegRS_IFID) AND (i_RegRD_IDEX /= "00000")) OR ((i_RegRD_EXMEM = i_RegRS_IFID) AND (i_RegRD_EXMEM /= "00000")) OR ((i_RegRD_MEMWB = i_RegRS_IFID) AND (i_RegRD_MEMWB /= "00000"))
			) AND ((i_CLK = '0'))) THEN
			oFlush_IFID <= '0';
			oFlush_IDEX <= '0';
			oFlush_EXMEM <= '0';
			oFlush_MEMWB <= '0';
			oStall_IF <= '0';
			oStall_IFID <= '0';
			oStall_IDEX <= '0';--
			oStall_EXMEM <= '1';
			oStall_MEMWB <= '1';

			--BEQ Works     
		ELSIF ((i_BRANCH_IDEX = '1') AND (i_BRANCH_TYPE_IDEX = '1') AND (i_RegRTVal_IDEX = i_RegRSVal_IDEX) AND (i_CLK = '0')) THEN
			oFlush_IFID <= '1';
			oFlush_IDEX <= '0';
			oFlush_EXMEM <= '0';
			oFlush_MEMWB <= '0';
			oStall_IF <= '0';
			oStall_IFID <= '1';
			oStall_IDEX <= '1';
			oStall_EXMEM <= '1';
			oStall_MEMWB <= '1';
			--BNE Works
		ELSIF ((i_BRANCH_IDEX = '1') AND (i_BRANCH_TYPE_IDEX = '0') AND (i_RegRTVal_IDEX /= i_RegRSVal_IDEX) AND (i_CLK = '0')) THEN
			oFlush_IFID <= '1';
			oFlush_IDEX <= '0';
			oFlush_EXMEM <= '0';
			oFlush_MEMWB <= '0';
			oStall_IF <= '0';
			oStall_IFID <= '1';
			oStall_IDEX <= '1';
			oStall_EXMEM <= '1';
			oStall_MEMWB <= '1';
			--Jr IF/ID
		ELSIF ((i_JR_IDEX = '1') AND ((i_RegRD_IDEX = i_RegRS_IFID) OR (i_RegRD_EXMEM = i_RegRS_IFID) OR (i_RegRD_MEMWB = i_RegRS_IFID)) AND (i_CLK = '0')) THEN
			oFlush_IFID <= '0';
			oFlush_IDEX <= '0';
			oFlush_EXMEM <= '0';
			oFlush_MEMWB <= '0';
			oStall_IF <= '0';
			oStall_IFID <= '0';
			oStall_IDEX <= '0';--
			oStall_EXMEM <= '1';
			oStall_MEMWB <= '1';
			--JR EX/MEM
		ELSIF ((i_JR = '1') AND (i_CLK = '0')) THEN
			oFlush_IFID <= '1';
			oFlush_IDEX <= '0';
			oFlush_EXMEM <= '0';
			oFlush_MEMWB <= '0';
			oStall_IF <= '0';
			oStall_IFID <= '0';
			oStall_IDEX <= '0';
			oStall_EXMEM <= '1';
			oStall_MEMWB <= '1';
			--Jump and JAL
		ELSIF ((i_JUMP_EN = '1') AND (NOT(i_JR = '1')) AND (i_CLK = '0')) THEN
			oFlush_IFID <= '1';
			oFlush_IDEX <= '0';
			oFlush_EXMEM <= '0';
			oFlush_MEMWB <= '0';
			oStall_IF <= '0';
			oStall_IFID <= '1';
			oStall_IDEX <= '1';
			oStall_EXMEM <= '1';
			oStall_MEMWB <= '1';
		ELSE
			oFlush_IFID <= '0';
			oFlush_IDEX <= '0';
			oFlush_EXMEM <= '0';
			oFlush_MEMWB <= '0';
			oStall_IF <= '1';
			oStall_IFID <= '1';
			oStall_IDEX <= '1';
			oStall_EXMEM <= '1';
			oStall_MEMWB <= '1';
		END IF;
	END PROCESS;
END dataflow;