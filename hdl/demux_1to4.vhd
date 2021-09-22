library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all; -- for constant calculations


entity demux_1to4 is
port (
    i_clk  : in std_logic;
    i_rst  : in std_logic;

    i_d    : in std_logic_vector(6 downto 0);
    i_dvld : in std_logic;
    i_sel  : in std_logic_vector(1 downto 0);
    
    o_q0   : out std_logic_vector(6 downto 0);
    o_q1   : out std_logic_vector(6 downto 0);
    o_q2   : out std_logic_vector(6 downto 0);
    o_q3   : out std_logic_vector(6 downto 0)
);
end demux_1to4;

architecture rtl of demux_1to4 is


begin

    p_demux : process(i_clk) begin
        if rising_edge(i_clk) then
            if i_rst = '1' then
                o_q0 <= (others => '0'); 
                o_q1 <= (others => '0'); 
                o_q2 <= (others => '0'); 
                o_q3 <= (others => '0'); 
                
            else

                if ( i_dvld = '1' and i_sel = "00" ) then
                    o_q0 <= i_d;
                end if;
                if ( i_dvld = '1' and i_sel = "01" ) then
                    o_q1 <= i_d;
                end if;
                if ( i_dvld = '1' and i_sel = "10" ) then
                    o_q2 <= i_d;
                end if;
                if ( i_dvld = '1' and i_sel = "11" ) then
                    o_q3 <= i_d;
                end if;
                     
            end if;
        end if;
    end process;

end architecture;