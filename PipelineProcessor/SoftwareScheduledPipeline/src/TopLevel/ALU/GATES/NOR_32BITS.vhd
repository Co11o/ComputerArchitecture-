--Author Jackson Collalti
-- 32 Bit NOR gate
library IEEE;
use IEEE.std_logic_1164.all;

entity NOR_32BITS is
  port(i_A          : in STD_LOGIC_VECTOR(31 DOWNTO 0);
       i_B          : in STD_LOGIC_VECTOR(31 DOWNTO 0);
       o_F          : out STD_LOGIC_VECTOR(31 DOWNTO 0));

end NOR_32BITS;

architecture dataflow of NOR_32BITS is
    begin

    NOR32: for i in 0 to 31 generate
        o_F(i) <= i_A(i) NOR i_B(i);
    end generate;
    
end dataflow;