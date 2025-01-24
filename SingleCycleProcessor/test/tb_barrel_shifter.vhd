-- tb_barrel_shifter.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a testbench for the barrel_shifter component.
--              
-- 10/8/24
-------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_textio.ALL; -- For logic types I/O
LIBRARY std;
USE std.env.ALL; -- For hierarchical/external signals
USE std.textio.ALL; -- For basic I/O

ENTITY tb_barrel_shifter IS
    GENERIC (gCLK_HPER : TIME := 10 ns); -- Generic for half of the clock cycle period
END tb_barrel_shifter;

ARCHITECTURE behavior OF tb_barrel_shifter IS

    -- Define the total clock period time
    CONSTANT cCLK_PER : TIME := gCLK_HPER * 2;

    -- TODO: change component declaration as needed.
    COMPONENT barrel_shifter IS
        PORT (
            i_IN : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            i_SHAMT : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
            i_DIRECTION : IN STD_LOGIC; -- If '0' then shift right; if '1' then shift left.
            i_TYPE : IN STD_LOGIC; -- If '0' then logical shift. If '1' then arithmetic shift
            o_OUT : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
    END COMPONENT;

    -- TODO: change input and output signals as needed.
    SIGNAL s_CLK : STD_LOGIC := '0';
    SIGNAL s_IN : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL s_SHAMT : STD_LOGIC_VECTOR(4 DOWNTO 0);
    SIGNAL s_DIRECTION : STD_LOGIC;
    SIGNAL s_TYPE : STD_LOGIC;
    SIGNAL s_OUT : STD_LOGIC_VECTOR(31 DOWNTO 0);

BEGIN

    -- TODO: Actually instantiate the component to test and wire all signals to the corresponding
    -- input or output.
    shifter : barrel_shifter
    PORT MAP(
        i_IN => s_IN,
        i_SHAMT => s_SHAMT,
        i_DIRECTION => s_DIRECTION,
        i_TYPE => s_TYPE,
        o_OUT => s_OUT);

    P_CLK : PROCESS
    BEGIN
        s_CLK <= '0';
        WAIT FOR gCLK_HPER;
        s_CLK <= '1';
        WAIT FOR gCLK_HPER;
    END PROCESS;

    P_TB : PROCESS
    BEGIN

        -- Test right shift logical

        s_IN <= "10000000000000000000000000000000";
        s_DIRECTION <= '0';
        s_TYPE <= '0';
        s_SHAMT <= "00001";
        WAIT FOR cCLK_PER;

        s_IN <= "10000000000000000000000000000000";
        s_DIRECTION <= '0';
        s_TYPE <= '0';
        s_SHAMT <= "00010";
        WAIT FOR cCLK_PER;

        s_IN <= "10000000000000000000000000000000";
        s_DIRECTION <= '0';
        s_TYPE <= '0';
        s_SHAMT <= "00100";
        WAIT FOR cCLK_PER;

        s_IN <= "10000000000000000000000000000000";
        s_DIRECTION <= '0';
        s_TYPE <= '0';
        s_SHAMT <= "01000";
        WAIT FOR cCLK_PER;

        s_IN <= "10000000000000000000000000000000";
        s_DIRECTION <= '0';
        s_TYPE <= '0';
        s_SHAMT <= "10000";
        WAIT FOR cCLK_PER;

        s_IN <= "10000000000000000000000000000000";
        s_DIRECTION <= '0';
        s_TYPE <= '0';
        s_SHAMT <= "11111";
        WAIT FOR cCLK_PER;

        ----------------------------------------------

        -- Test left shift logical

        s_IN <= "00000000000000000000000000000001";
        s_DIRECTION <= '1';
        s_TYPE <= '0';
        s_SHAMT <= "00001";
        WAIT FOR cCLK_PER;

        s_IN <= "00000000000000000000000000000001";
        s_DIRECTION <= '1';
        s_TYPE <= '0';
        s_SHAMT <= "00010";
        WAIT FOR cCLK_PER;

        s_IN <= "00000000000000000000000000000001";
        s_DIRECTION <= '1';
        s_TYPE <= '0';
        s_SHAMT <= "00100";
        WAIT FOR cCLK_PER;

        s_IN <= "00000000000000000000000000000001";
        s_DIRECTION <= '1';
        s_TYPE <= '0';
        s_SHAMT <= "01000";
        WAIT FOR cCLK_PER;

        s_IN <= "00000000000000000000000000000001";
        s_DIRECTION <= '1';
        s_SHAMT <= "10000";
        WAIT FOR cCLK_PER;

        s_IN <= "00000000000000000000000000000001";
        s_DIRECTION <= '1';
        s_TYPE <= '0';
        s_SHAMT <= "11111";
        WAIT FOR cCLK_PER;

        ----------------------------------------------

        -- Test right shift arithmetic

        s_IN <= "10000000000000000000000000000000";
        s_DIRECTION <= '0';
        s_TYPE <= '1';
        s_SHAMT <= "00001";
        WAIT FOR cCLK_PER;

        s_IN <= "10000000000000000000000000000000";
        s_DIRECTION <= '0';
        s_TYPE <= '1';
        s_SHAMT <= "00010";
        WAIT FOR cCLK_PER;

        s_IN <= "10000000000000000000000000000000";
        s_DIRECTION <= '0';
        s_TYPE <= '1';
        s_SHAMT <= "00100";
        WAIT FOR cCLK_PER;

        s_IN <= "10000000000000000000000000000000";
        s_DIRECTION <= '0';
        s_TYPE <= '1';
        s_SHAMT <= "01000";
        WAIT FOR cCLK_PER;

        s_IN <= "10000000000000000000000000000000";
        s_DIRECTION <= '0';
        s_TYPE <= '1';
        s_SHAMT <= "10000";
        WAIT FOR cCLK_PER;

        s_IN <= "10000000000000000000000000000000";
        s_DIRECTION <= '0';
        s_TYPE <= '1';
        s_SHAMT <= "11111";
        WAIT FOR cCLK_PER;

        WAIT;
    END PROCESS;

END behavior;