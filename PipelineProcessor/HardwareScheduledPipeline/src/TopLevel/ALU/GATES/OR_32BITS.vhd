--Author Jackson Collalti
-- 32 Bit OR gate
library IEEE;
use IEEE.std_logic_1164.all;

entity OR_32BITS is
  port(i_A          : in STD_LOGIC_VECTOR(31 DOWNTO 0);
       i_B          : in STD_LOGIC_VECTOR(31 DOWNTO 0);
       o_F          : out STD_LOGIC_VECTOR(31 DOWNTO 0));

end OR_32BITS;

architecture dataflow of OR_32BITS is
    begin

    OR32: for i in 0 to 31 generate
        o_F(i) <= i_A(i) OR i_B(i);
    end generate;
    
end dataflow;