-------------------------------------------------------------------------
-- Justin Sebahar
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------
-- register_file.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains an implementation of a register-file structurally implemented

-- 9/12/24
-------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY register_file IS
	PORT (
		i_CLOCK : IN STD_LOGIC;
		i_RESET : IN STD_LOGIC;
		i_WriteTo : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		i_WEN : IN STD_LOGIC;
		i_INPUT : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		i_MUX_SELECT1 : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		i_MUX_SELECT2 : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		o_OUT1 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		o_OUT2 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
END register_file;

ARCHITECTURE structure OF register_file IS

	-- Register --------------------------
	COMPONENT register_N
		GENERIC (N : INTEGER := 32);
		PORT (
			i_CLK : IN STD_LOGIC;
			i_Reset : IN STD_LOGIC;
			i_W : IN STD_LOGIC;
			i_IN : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
			o_Q : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0));
	END COMPONENT;

	-- Decoder --------------------------
	COMPONENT decoder5t32
		PORT (
			i_IN : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
			i_EN : IN STD_LOGIC;
			o_OUT : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
	END COMPONENT;

	-- 32-to-1 Mux --------------------------
	COMPONENT mux32t1_N
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
	END COMPONENT;
	SIGNAL s_Decoder : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL s_Reg0, s_Reg1, s_Reg2, s_Reg3, s_Reg4, s_Reg5, s_Reg6, s_Reg7, s_Reg8, s_Reg9, s_Reg10, s_Reg11, s_Reg12, s_Reg13, s_Reg14, s_Reg15 : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL s_Reg16, s_Reg17, s_Reg18, s_Reg19, s_Reg20, s_Reg21, s_Reg22, s_Reg23, s_Reg24, s_Reg25, s_Reg26, s_Reg27, s_Reg28, s_Reg29, s_Reg30, s_Reg31 : STD_LOGIC_VECTOR(31 DOWNTO 0);

BEGIN
	-- Determine decoder output for write
	decoder : decoder5t32 PORT MAP(i_IN => i_WriteTo, i_EN => i_WEN, o_OUT => s_Decoder);

	-- Connect each of the 32 registers to its corresponding output signal and decoder output bit
	reg0 : register_N PORT MAP(i_CLK => i_CLOCK, i_Reset => '1', i_W => '0', i_IN => i_INPUT, o_Q => s_Reg0);
	reg1 : register_N PORT MAP(i_CLK => i_CLOCK, i_Reset => i_RESET, i_W => s_Decoder(1), i_IN => i_INPUT, o_Q => s_Reg1);
	reg2 : register_N PORT MAP(i_CLK => i_CLOCK, i_Reset => i_RESET, i_W => s_Decoder(2), i_IN => i_INPUT, o_Q => s_Reg2);
	reg3 : register_N PORT MAP(i_CLK => i_CLOCK, i_Reset => i_RESET, i_W => s_Decoder(3), i_IN => i_INPUT, o_Q => s_Reg3);
	reg4 : register_N PORT MAP(i_CLK => i_CLOCK, i_Reset => i_RESET, i_W => s_Decoder(4), i_IN => i_INPUT, o_Q => s_Reg4);
	reg5 : register_N PORT MAP(i_CLK => i_CLOCK, i_Reset => i_RESET, i_W => s_Decoder(5), i_IN => i_INPUT, o_Q => s_Reg5);
	reg6 : register_N PORT MAP(i_CLK => i_CLOCK, i_Reset => i_RESET, i_W => s_Decoder(6), i_IN => i_INPUT, o_Q => s_Reg6);
	reg7 : register_N PORT MAP(i_CLK => i_CLOCK, i_Reset => i_RESET, i_W => s_Decoder(7), i_IN => i_INPUT, o_Q => s_Reg7);
	reg8 : register_N PORT MAP(i_CLK => i_CLOCK, i_Reset => i_RESET, i_W => s_Decoder(8), i_IN => i_INPUT, o_Q => s_Reg8);
	reg9 : register_N PORT MAP(i_CLK => i_CLOCK, i_Reset => i_RESET, i_W => s_Decoder(9), i_IN => i_INPUT, o_Q => s_Reg9);
	reg10 : register_N PORT MAP(i_CLK => i_CLOCK, i_Reset => i_RESET, i_W => s_Decoder(10), i_IN => i_INPUT, o_Q => s_Reg10);
	reg11 : register_N PORT MAP(i_CLK => i_CLOCK, i_Reset => i_RESET, i_W => s_Decoder(11), i_IN => i_INPUT, o_Q => s_Reg11);
	reg12 : register_N PORT MAP(i_CLK => i_CLOCK, i_Reset => i_RESET, i_W => s_Decoder(12), i_IN => i_INPUT, o_Q => s_Reg12);
	reg13 : register_N PORT MAP(i_CLK => i_CLOCK, i_Reset => i_RESET, i_W => s_Decoder(13), i_IN => i_INPUT, o_Q => s_Reg13);
	reg14 : register_N PORT MAP(i_CLK => i_CLOCK, i_Reset => i_RESET, i_W => s_Decoder(14), i_IN => i_INPUT, o_Q => s_Reg14);
	reg15 : register_N PORT MAP(i_CLK => i_CLOCK, i_Reset => i_RESET, i_W => s_Decoder(15), i_IN => i_INPUT, o_Q => s_Reg15);
	reg16 : register_N PORT MAP(i_CLK => i_CLOCK, i_Reset => i_RESET, i_W => s_Decoder(16), i_IN => i_INPUT, o_Q => s_Reg16);
	reg17 : register_N PORT MAP(i_CLK => i_CLOCK, i_Reset => i_RESET, i_W => s_Decoder(17), i_IN => i_INPUT, o_Q => s_Reg17);
	reg18 : register_N PORT MAP(i_CLK => i_CLOCK, i_Reset => i_RESET, i_W => s_Decoder(18), i_IN => i_INPUT, o_Q => s_Reg18);
	reg19 : register_N PORT MAP(i_CLK => i_CLOCK, i_Reset => i_RESET, i_W => s_Decoder(19), i_IN => i_INPUT, o_Q => s_Reg19);
	reg20 : register_N PORT MAP(i_CLK => i_CLOCK, i_Reset => i_RESET, i_W => s_Decoder(20), i_IN => i_INPUT, o_Q => s_Reg20);
	reg21 : register_N PORT MAP(i_CLK => i_CLOCK, i_Reset => i_RESET, i_W => s_Decoder(21), i_IN => i_INPUT, o_Q => s_Reg21);
	reg22 : register_N PORT MAP(i_CLK => i_CLOCK, i_Reset => i_RESET, i_W => s_Decoder(22), i_IN => i_INPUT, o_Q => s_Reg22);
	reg23 : register_N PORT MAP(i_CLK => i_CLOCK, i_Reset => i_RESET, i_W => s_Decoder(23), i_IN => i_INPUT, o_Q => s_Reg23);
	reg24 : register_N PORT MAP(i_CLK => i_CLOCK, i_Reset => i_RESET, i_W => s_Decoder(24), i_IN => i_INPUT, o_Q => s_Reg24);
	reg25 : register_N PORT MAP(i_CLK => i_CLOCK, i_Reset => i_RESET, i_W => s_Decoder(25), i_IN => i_INPUT, o_Q => s_Reg25);
	reg26 : register_N PORT MAP(i_CLK => i_CLOCK, i_Reset => i_RESET, i_W => s_Decoder(26), i_IN => i_INPUT, o_Q => s_Reg26);
	reg27 : register_N PORT MAP(i_CLK => i_CLOCK, i_Reset => i_RESET, i_W => s_Decoder(27), i_IN => i_INPUT, o_Q => s_Reg27);
	reg28 : register_N PORT MAP(i_CLK => i_CLOCK, i_Reset => i_RESET, i_W => s_Decoder(28), i_IN => i_INPUT, o_Q => s_Reg28);
	reg29 : register_N PORT MAP(i_CLK => i_CLOCK, i_Reset => i_RESET, i_W => s_Decoder(29), i_IN => i_INPUT, o_Q => s_Reg29);
	reg30 : register_N PORT MAP(i_CLK => i_CLOCK, i_Reset => i_RESET, i_W => s_Decoder(30), i_IN => i_INPUT, o_Q => s_Reg30);
	reg31 : register_N PORT MAP(i_CLK => i_CLOCK, i_Reset => i_RESET, i_W => s_Decoder(31), i_IN => i_INPUT, o_Q => s_Reg31);

	-- Use Mux to find which register to read from
	mux1 : mux32t1_N PORT MAP(
		i_S => i_MUX_SELECT1,
		i_D0 => s_Reg0,
		i_D1 => s_Reg1,
		i_D2 => s_Reg2,
		i_D3 => s_Reg3,
		i_D4 => s_Reg4,
		i_D5 => s_Reg5,
		i_D6 => s_Reg6,
		i_D7 => s_Reg7,
		i_D8 => s_Reg8,
		i_D9 => s_Reg9,
		i_D10 => s_Reg10,
		i_D11 => s_Reg11,
		i_D12 => s_Reg12,
		i_D13 => s_Reg13,
		i_D14 => s_Reg14,
		i_D15 => s_Reg15,
		i_D16 => s_Reg16,
		i_D17 => s_Reg17,
		i_D18 => s_Reg18,
		i_D19 => s_Reg19,
		i_D20 => s_Reg20,
		i_D21 => s_Reg21,
		i_D22 => s_Reg22,
		i_D23 => s_Reg23,
		i_D24 => s_Reg24,
		i_D25 => s_Reg25,
		i_D26 => s_Reg26,
		i_D27 => s_Reg27,
		i_D28 => s_Reg28,
		i_D29 => s_Reg29,
		i_D30 => s_Reg30,
		i_D31 => s_Reg31,
		o_O => o_OUT1);

	-- Use Mux to find which register to read from
	mux2 : mux32t1_N PORT MAP(
		i_S => i_MUX_SELECT2,
		i_D0 => s_Reg0,
		i_D1 => s_Reg1,
		i_D2 => s_Reg2,
		i_D3 => s_Reg3,
		i_D4 => s_Reg4,
		i_D5 => s_Reg5,
		i_D6 => s_Reg6,
		i_D7 => s_Reg7,
		i_D8 => s_Reg8,
		i_D9 => s_Reg9,
		i_D10 => s_Reg10,
		i_D11 => s_Reg11,
		i_D12 => s_Reg12,
		i_D13 => s_Reg13,
		i_D14 => s_Reg14,
		i_D15 => s_Reg15,
		i_D16 => s_Reg16,
		i_D17 => s_Reg17,
		i_D18 => s_Reg18,
		i_D19 => s_Reg19,
		i_D20 => s_Reg20,
		i_D21 => s_Reg21,
		i_D22 => s_Reg22,
		i_D23 => s_Reg23,
		i_D24 => s_Reg24,
		i_D25 => s_Reg25,
		i_D26 => s_Reg26,
		i_D27 => s_Reg27,
		i_D28 => s_Reg28,
		i_D29 => s_Reg29,
		i_D30 => s_Reg30,
		i_D31 => s_Reg31,
		o_O => o_OUT2);

END structure;