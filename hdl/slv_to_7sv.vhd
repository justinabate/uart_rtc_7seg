-- standard logic vector to active-high 7 segment vector

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity slv_to_7sv is port (
    i_clk       : in std_logic;
    i_rst       : in std_logic;
    --! input standard logic vector
	i_slv		: in std_logic_vector(7 downto 0);
    i_slv_vld   : in std_logic;
    --! output 7-segment vector
	o_7sv		: out std_logic_vector(6 downto 0); -- [G, F, E, D, C, B, A]
    o_7sv_vld   : out std_logic
); end slv_to_7sv;

architecture rtl of slv_to_7sv is
  
    signal r_7sv : std_logic_vector(6 downto 0);
    signal r_7sv_vld : std_logic;

begin  			

	p_numeric_to_7sv : process(i_clk) begin
        if rising_edge(i_clk) then
            if (i_rst = '1') then
                r_7sv <= (others => '0');
                r_7sv_vld <= '0';
            else
                if (i_slv_vld = '1') then
                    r_7sv_vld <= '1';

                    case i_slv is
                        when x"00" => r_7sv <= "0111111"; -- G
                        when x"01" => r_7sv <= "0000110"; -- B, C
                        when x"02" => r_7sv <= "1011011"; -- A, B, D, E, G, 
                        when x"03" => r_7sv <= "1001111";
                        when x"04" => r_7sv <= "1100110";
                        when x"05" => r_7sv <= "1101101";
                        when x"06" => r_7sv <= "1111101";
                        when x"07" => r_7sv <= "0000111";
                        when x"08" => r_7sv <= "1111111";
                        when x"09" => r_7sv <= "1101111";
                        -- when x"A" => r_7sv <= "1110111";
                        -- when x"B" => r_7sv <= "1111100";
                        -- when x"C" => r_7sv <= "0111001";
                        -- when x"D" => r_7sv <= "1011110";
                        -- when x"E" => r_7sv <= "1111001";
                        -- when x"F" => r_7sv <= "1110001";
                        when others => r_7sv <= (others => 'X');
                    end case;
                else
                    r_7sv_vld <= '0';
                    r_7sv <= r_7sv;
                end if;

            end if;
        end if;
	end process;		


	-- p_hex_to_7sv : process(i_slv) begin	
	-- 	case i_slv is
	-- 		when x"0" => r_7sv <= "0111111"; -- G
	-- 		when x"1" => r_7sv <= "0000110"; -- B, C
	-- 		when x"2" => r_7sv <= "1011011"; -- A, B, D, E, G, 
	-- 		when x"3" => r_7sv <= "1001111";
	-- 		when x"4" => r_7sv <= "1100110";
	-- 		when x"5" => r_7sv <= "1101101";
	-- 		when x"6" => r_7sv <= "1111101";
	-- 		when x"7" => r_7sv <= "0000111";
	-- 		when x"8" => r_7sv <= "1111111";
	-- 		when x"9" => r_7sv <= "1101111";
	-- 		when x"A" => r_7sv <= "1110111";
	-- 		when x"B" => r_7sv <= "1111100";
	-- 		when x"C" => r_7sv <= "0111001";
	-- 		when x"D" => r_7sv <= "1011110";
	-- 		when x"E" => r_7sv <= "1111001";
	-- 		when x"F" => r_7sv <= "1110001";
	-- 		when others => r_7sv <= (others => 'X');
	-- 	end case;
	-- end process p_hex_to_7sv;

-- 	p_ascii_to_7sv : process(i_slv) begin
-- 		case i_slv is
--             when x"00" => r_7sv <= "0000000"; -- null    -- [G, F, E, D, C, B, A]
--             when x"01" => r_7sv <= "1010000"; -- 1st half m    -- [G, F, E, D, C, B, A]
--             when x"02" => r_7sv <= "1010100"; -- 2nd half m    -- [G, F, E, D, C, B, A]
--             when x"41" => r_7sv <= "1110111"; -- upper A -- [G, F, E, D, C, B, A]
-- --            when x"42" => r_7sv <= "1111111"; -- upper B -- [G, F, E, D, C, B, A]
-- --            when x"43" => r_7sv <= "0111001"; -- upper C -- [G, F, E, D, C, B, A]
-- --            when x"44" => r_7sv <= "0011111"; -- upper D -- [G, F, E, D, C, B, A]
--             when x"45" => r_7sv <= "1111001"; -- upper E -- [G, F, E, D, C, B, A]
-- --            when x"46" => r_7sv <= "1110001"; -- upper F -- [G, F, E, D, C, B, A]
--             when x"47" => r_7sv <= "0111101"; -- upper G -- [G, F, E, D, C, B, A]
--             when x"48" => r_7sv <= "1110110"; -- upper H -- [G, F, E, D, C, B, A]
-- --            when x"49" => r_7sv <= "0110000"; -- upper I -- [G, F, E, D, C, B, A]
-- --            when x"4A" => r_7sv <= "0001110"; -- upper J -- [G, F, E, D, C, B, A]
-- --            when x"4B" => r_7sv <= "1110101"; -- upper K -- [G, F, E, D, C, B, A]
--             when x"4C" => r_7sv <= "0111000"; -- upper L -- [G, F, E, D, C, B, A]
--             when x"4D" => r_7sv <= "0101011"; -- upper M -- [G, F, E, D, C, B, A]
-- --            when x"4E" => r_7sv <= "0110111"; -- upper N -- [G, F, E, D, C, B, A]
--             when x"4F" => r_7sv <= "0111111"; -- upper O -- [G, F, E, D, C, B, A]
--             when x"50" => r_7sv <= "1110011"; -- upper P -- [G, F, E, D, C, B, A]
-- --            when x"51" => r_7sv <= "1101011"; -- upper Q -- [G, F, E, D, C, B, A]
-- --            when x"52" => r_7sv <= "1111011"; -- upper R -- [G, F, E, D, C, B, A]
--             when x"53" => r_7sv <= "1101101"; -- upper S -- [G, F, E, D, C, B, A]
-- --            when x"54" => r_7sv <= "0110001"; -- upper T -- [G, F, E, D, C, B, A]
-- --            when x"55" => r_7sv <= "0111110"; -- upper U -- [G, F, E, D, C, B, A]
-- --            when x"56" => r_7sv <= "0101110"; -- upper V -- [G, F, E, D, C, B, A]
-- --            when x"57" => r_7sv <= "0011101"; -- upper W -- [G, F, E, D, C, B, A]
-- --            when x"58" => r_7sv <= "1001001"; -- upper X -- [G, F, E, D, C, B, A]
-- --            when x"59" => r_7sv <= "1101010"; -- upper Y -- [G, F, E, D, C, B, A]
-- --            when x"5A" => r_7sv <= "1011011"; -- upper Z -- [G, F, E, D, C, B, A]
-- --            when x"61" => r_7sv <= "1001100"; -- lower a -- [G, F, E, D, C, B, A]
-- --            when x"62" => r_7sv <= "1111100"; -- lower b -- [G, F, E, D, C, B, A]
-- --            when x"63" => r_7sv <= "1011000"; -- lower c -- [G, F, E, D, C, B, A]
--             when x"64" => r_7sv <= "1011110"; -- lower d -- [G, F, E, D, C, B, A]
-- --            when x"65" => r_7sv <= "0011000"; -- lower e -- [G, F, E, D, C, B, A]
-- --            when x"66" => r_7sv <= "1110000"; -- lower f -- [G, F, E, D, C, B, A]
-- --            when x"67" => r_7sv <= "1011001"; -- lower g -- [G, F, E, D, C, B, A]
-- --            when x"68" => r_7sv <= "1110100"; -- lower h -- [G, F, E, D, C, B, A]
-- --            when x"69" => r_7sv <= "0011001"; -- lower i -- [G, F, E, D, C, B, A]
-- --            when x"6A" => r_7sv <= "0001101"; -- lower j -- [G, F, E, D, C, B, A]
-- --            when x"6B" => r_7sv <= "1101001"; -- lower k -- [G, F, E, D, C, B, A]
-- --            when x"6C" => r_7sv <= "0110000"; -- lower l -- [G, F, E, D, C, B, A]
-- --            when x"6D" => r_7sv <= "1010101"; -- lower m -- [G, F, E, D, C, B, A]
-- --            when x"6E" => r_7sv <= "1010100"; -- lower n -- [G, F, E, D, C, B, A]
--             when x"6F" => r_7sv <= "1011100"; -- lower o -- [G, F, E, D, C, B, A]
-- --            when x"70" => r_7sv <= "1110011"; -- lower p -- [G, F, E, D, C, B, A]
-- --            when x"71" => r_7sv <= "1100111"; -- lower q -- [G, F, E, D, C, B, A]
--             when x"72" => r_7sv <= "1010000"; -- lower r -- [G, F, E, D, C, B, A]
-- --            when x"73" => r_7sv <= "0001100"; -- lower s -- [G, F, E, D, C, B, A]
--             when x"74" => r_7sv <= "1110000"; -- lower t -- [G, F, E, D, C, B, A]
-- --            when x"75" => r_7sv <= "0011100"; -- lower u -- [G, F, E, D, C, B, A]
-- --            when x"76" => r_7sv <= "0001100"; -- lower v -- [G, F, E, D, C, B, A]
-- --            when x"77" => r_7sv <= "0101010"; -- lower w -- [G, F, E, D, C, B, A]
-- --            when x"78" => r_7sv <= "1001000"; -- lower x -- [G, F, E, D, C, B, A]
-- --            when x"79" => r_7sv <= "1101110"; -- lower y -- [G, F, E, D, C, B, A]
-- --            when x"7A" => r_7sv <= "1001000"; -- lower z -- [G, F, E, D, C, B, A]                    
-- 			when others => r_7sv <= (others => 'X');
-- 		end case;
-- 	end process p_ascii_to_7sv;	

    o_7sv <= r_7sv;
    o_7sv_vld <= r_7sv_vld;

end rtl;