library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all; -- for constant calculations


entity mux_4to1 is
port (
    i_clk  : in std_logic;
    i_rst  : in std_logic;

    i_d0   : in std_logic_vector(7 downto 0);
    i_d1   : in std_logic_vector(7 downto 0);
    i_d2   : in std_logic_vector(7 downto 0);
    i_d3   : in std_logic_vector(7 downto 0);
    i_dvld : in std_logic;

    o_q    : out std_logic_vector(7 downto 0);
    o_dvld : out std_logic;
    o_sel  : out std_logic_vector(1 downto 0)
);
end mux_4to1;

architecture rtl of mux_4to1 is

    signal   r_sel, r_cnt      : unsigned(1 downto 0);
    signal   r_vld, r_vld_dly      : std_logic;

begin

    p_mux : process(i_clk) begin
        if rising_edge(i_clk) then
            if i_rst = '1' then
                r_cnt <= to_unsigned(0, r_sel'length);
                r_sel <= to_unsigned(0, r_sel'length);
                o_q <= (others => '0'); 
                r_vld <= '0';
                
            else

                r_cnt <= r_cnt + 1;

                if (r_cnt = 3) then
                    r_sel <= r_sel + 1;
                    r_vld <= '1';
                else
                    r_vld <= '0';                
                end if;

                r_vld_dly <= r_vld;

                --! no priority
                if ( r_sel = to_unsigned(0, r_sel'length) ) then
                    o_q <= i_d0;
                end if;
                if ( r_sel = to_unsigned(1, r_sel'length) ) then
                    o_q <= i_d1;
                end if;
                if ( r_sel = to_unsigned(2, r_sel'length) ) then
                    o_q <= i_d2;
                end if;
                if ( r_sel = to_unsigned(3, r_sel'length) ) then
                    o_q <= i_d3;
                end if;
                

            end if;
        end if;
    end process;

    o_dvld <= r_vld_dly;
    o_sel <= std_logic_vector(r_sel);


end architecture;