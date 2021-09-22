library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all; -- for constant calculations

use std.textio.all;
use std.env.finish;

--! project libraries 
-- library rtl_lib; 
-- use rtl_lib.rtl_pkg.all; 


entity tb is
end tb;

architecture sim of tb is

    --! 4-digit, 7-segment display
	type sev_seg_arr_t is array (3 downto 0) of std_logic_vector(6 downto 0); -- := (others => '0');
	signal r_7segv_digit : sev_seg_arr_t;


    constant c_i_clk_frq : integer := 12e6;
    constant c_i_clk_per : time := 1 sec / c_i_clk_frq;
    constant c_clk_period : real := 1.0/real(c_i_clk_frq);

    signal i_clk : std_logic := '1';
    signal w_rst : std_logic;

    --! wires to AXIS slave input
    constant c_iws     : natural := 8;
    signal w_i_s_axis_d : std_logic_vector(c_iws-1 downto 0);
    signal w_i_s_axis_v : std_logic;

    --! output wires from wishbone accumulator
    signal w_rtc_init_wr : std_logic;
    signal w_rtc_init_vld : std_logic_vector(2 downto 0);
    signal w_rtc_init : std_logic_vector(21 downto 0);

    --! output wires from RTC module
    signal w_rtc_current : std_logic_vector(21 downto 0);
    signal w_rtc_current_vld : std_logic;
    signal w_rtc_H_top_slv, w_rtc_H_bot_slv, w_rtc_M_top_slv, w_rtc_M_bot_slv : std_logic_vector(7 downto 0);

    --! output from MUX
    signal w_mux_byte : std_logic_vector(7 downto 0);
    signal w_mux_byte_vld : std_logic;
    signal w_mux_byte_sel : std_logic_vector(1 downto 0);

    --! output wires from 7-segement vector translator
    signal w_7sv : std_logic_vector(6 downto 0);
    signal w_7sv_vld : std_logic;
 
    --! PPS
    constant c_pps_N : integer := integer(1.0/c_clk_period); --! 12048192 cycles
	constant c_pps_cntr_size : natural := integer( ceil( log2( real(c_pps_N) ) ) ); --! 24 bits
    signal   r_pps_cntr : unsigned(c_pps_cntr_size-1 downto 0);
    signal   r_pps : std_logic; --! active-high pulse


    --! https://goodcalculators.com/simple-moving-average-calculator/
    type   test_vector_t is array (0 to 5) of std_logic_vector(c_iws-1 downto 0);
    signal test_vector1  : test_vector_t := (
        x"30",
        x"31",
        x"32",
        x"33",
        x"34",
        x"35"
    );


    --! zipcpu RTC
    component rtcbare 
    generic (
		OPT_PREVALIDATED_INPUT : std_logic_vector(0 downto 0) := "0"
	);
    port (	
		i_clk : in std_logic;
		i_reset : in std_logic;
		i_pps : in std_logic;
        --! WB
        i_wr : in std_logic;
        --! HH MM SS, where each digit is 4 bits except 1st 'H' (2 bits, range 0-2)
		i_data: in std_logic_vector(21 downto 0);
        --! HH valid; MM valid; SS valid
		i_valid: in std_logic_vector(2 downto 0);
        --! HH MM SS, where each digit is 4 bits except 1st 'H' (2 bits, range 0-2)
        o_data : out std_logic_vector(21 downto 0);
		o_vld : out std_logic;
		--! A once-per-day strobe on the last clock of the day
		o_ppd : out std_logic
	);
    end component rtcbare;



begin


    i_clk <= not i_clk after c_i_clk_per / 2;


    --! accumulate 6x UART bytes, translate to 6x BCD digits
    inst_uart8_to_wb24 : entity work.uart8_to_wb24(rtl)
    port map (
        i_clk => i_clk,
        i_rst => w_rst,
        --! input
        i_uart_byte => w_i_s_axis_d,
        i_uart_byte_vld => w_i_s_axis_v,
        --! output
        o_wr => w_rtc_init_wr,
        o_data => w_rtc_init,
        o_data_vld => w_rtc_init_vld
    );


    --! zipcpu rtc
    inst_rtcbare: rtcbare 
    generic map (
		OPT_PREVALIDATED_INPUT => "0"
	)
    port map (	
        i_clk => i_clk,
        i_reset => w_rst,
		i_pps => r_pps, --in std_logic;
        --! WB
        i_wr => w_rtc_init_wr, --in std_logic;
        --! HH MM SS, where each digit is 4 bits except 1st 'H' (2 bits, range 0-2)
		i_data => w_rtc_init, --in std_logic_vector(21 downto 0);
        --! HH valid; MM valid; SS valid
		i_valid=> w_rtc_init_vld, --in std_logic_vector(2 downto 0);
        --! HH MM SS, where each digit is 4 bits except 1st 'H' (2 bits, range 0-2)
        o_data => w_rtc_current, --out std_logic_vector(21 downto 0);
        o_vld => w_rtc_current_vld,
		--! A once-per-day strobe on the last clock of the day
		o_ppd => open --out std_logic
	);

    w_rtc_H_top_slv <= x"0" & "00" & w_rtc_current(w_rtc_current'high-0 downto w_rtc_current'high-1);
    w_rtc_H_bot_slv <= x"0" & w_rtc_current(w_rtc_current'high-2 downto w_rtc_current'high-5);
    w_rtc_M_top_slv <= x"0" & w_rtc_current(w_rtc_current'high-6 downto w_rtc_current'high-9);
    w_rtc_M_bot_slv <= x"0" & w_rtc_current(w_rtc_current'high-10 downto w_rtc_current'high-13);

    --! MUX 4-to-1 BCD bytes
    inst_mux_4to1 : entity work.mux_4to1(rtl)
    port map (
        i_clk  => i_clk, -- in std_logic;
        i_rst  => w_rst, -- in std_logic;
        
        i_d0   => w_rtc_H_top_slv, -- in std_logic_vector(7 downto 0);
        i_d1   => w_rtc_H_bot_slv, -- in std_logic_vector(7 downto 0);
        i_d2   => w_rtc_M_top_slv, -- in std_logic_vector(7 downto 0);
        i_d3   => w_rtc_M_bot_slv, -- in std_logic_vector(7 downto 0);
        i_dvld => w_rtc_current_vld, -- in std_logic;
    
        o_q    => w_mux_byte, -- out std_logic_vector(7 downto 0);
        o_dvld => w_mux_byte_vld, -- out std_logic;
        o_sel  => w_mux_byte_sel  -- out std_logic_vector(1 downto 0)
    );


    --! translate 1x UART ASCII byte into 7-segement vector
    inst_slv_to_7sv : entity work.slv_to_7sv(rtl) 
    port map (
        i_clk => i_clk,
        i_rst => w_rst,
        i_slv => w_mux_byte,
        i_slv_vld => w_mux_byte_vld,
        o_7sv => w_7sv,
        o_7sv_vld => w_7sv_vld
	);


    --! demux 1-to-4 7-segment vectors
    --! 'slv_to_7sv' takes 1 cycle; i_sel is held high for 2 cycles at a time
    inst_demux_1to4 : entity work.demux_1to4(rtl)
    port map (
        i_clk  => i_clk, -- in std_logic;
        i_rst  => w_rst, -- in std_logic;

        i_d    => w_7sv, -- in std_logic_vector(6 downto 0);
        i_dvld => w_7sv_vld,
        i_sel  => w_mux_byte_sel, -- in std_logic_vector(1 downto 0);
        
        o_q0   => r_7segv_digit(0), -- out std_logic_vector(6 downto 0);
        o_q1   => r_7segv_digit(1), -- out std_logic_vector(6 downto 0);
        o_q2   => r_7segv_digit(2), -- out std_logic_vector(6 downto 0);
        o_q3   => r_7segv_digit(3)  -- out std_logic_vector(6 downto 0)        
    );


    p_pps : process(i_clk) begin
        if rising_edge(i_clk) then
            if w_rst = '1' then
                r_pps_cntr <= to_unsigned(0, r_pps_cntr'length);
                r_pps <= '0';
            else
                if ( r_pps_cntr = to_unsigned(c_pps_N-1, r_pps_cntr'length) ) then
                    r_pps_cntr <= to_unsigned(0, r_pps_cntr'length);
                    r_pps <= '1';
                else 
                    r_pps_cntr <= r_pps_cntr + 1;
                    r_pps <= '0';
                end if;
            end if;
        end if;
    end process;


    --! main
    SEQUENCER_PROC : process begin

        w_rst <= '0';
        wait for c_i_clk_per * 1;
        w_rst <= '1';
        wait for c_i_clk_per * 1;
        w_rst <= '0';

        loop_driver : for k in 0 to test_vector1'length-1 loop
            wait until i_clk = '1';
                w_i_s_axis_d <= test_vector1(k);
                w_i_s_axis_v <= '1';
        end loop loop_driver;
        
        wait until i_clk = '1';
            w_i_s_axis_v <= '0';

        wait; -- for c_i_clk_per * 30;

    end process;


end architecture;