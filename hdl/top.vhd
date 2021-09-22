library ieee;
use ieee.std_logic_1164.all;
use ieee.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.all;
use ieee.math_real.all; -- for constant calculations


entity top is 
port (
    --! global
    i_clk : in std_logic;
    i_rst_n : in std_logic; -- Pullup
    --! UART RX
    i_uart_rxd : in std_logic;
    --! 7seg
    o_drive_dig : out std_logic_vector(3 downto 0);
    o_drive_seg : out std_logic_vector(6 downto 0);
    --! PCB LEDs
    o_board_led : out std_logic_vector(4 downto 0)
); 
end top;

architecture rtl of top is

    signal w_rst : std_logic;

    --! 4-digit, 7-segment display
	type sev_seg_arr_t is array (3 downto 0) of std_logic_vector(6 downto 0); -- := (others => '0');
	signal r_7segv_digit : sev_seg_arr_t;

    --! output wires from UART receiver
    signal w_uart_byte : std_logic_vector(7 downto 0);
    signal w_uart_byte_vld : std_logic;

    --! output wires from wishbone accumulator
    signal w_rtc_init_wr : std_logic;
    signal w_rtc_init_vld : std_logic_vector(2 downto 0);
    signal w_rtc_init : std_logic_vector(21 downto 0);

    --! output wires from RTC module
    signal w_rtc_current : std_logic_vector(21 downto 0);
    signal w_rtc_current_vld : std_logic;
    signal w_rtc_H_top_slv, w_rtc_H_bot_slv, w_rtc_M_top_slv, w_rtc_M_bot_slv, w_rtc_S_top_slv, w_rtc_S_bot_slv : std_logic_vector(7 downto 0);

    --! output from MUX
    signal w_mux_byte : std_logic_vector(7 downto 0);
    signal w_mux_byte_vld : std_logic;
    signal w_mux_byte_sel : std_logic_vector(1 downto 0);

    --! output wires from 7-segement vector translator
    signal w_7sv : std_logic_vector(6 downto 0);
    signal w_7sv_vld : std_logic;

    --! PPS
    constant c_clk_period : real := 8.3e-8; --! 12 MHz
    constant c_pps_N : integer := integer(1.0/c_clk_period)-0; --! 12048192 +/- 1 cycles
	constant c_pps_cntr_size : natural := integer( ceil( log2( real(c_pps_N) ) ) ); --! 24 bits
    signal   r_pps_cntr : unsigned(c_pps_cntr_size-1 downto 0);
    signal   r_pps : std_logic; --! active-high pulse

    --! LED counter logic 
    constant c_led_strobe_len_T : real := 0.025; --! seconds
    constant c_led_strobe_len_N : integer := integer(c_led_strobe_len_T/c_clk_period); --! 1,204,819 cycles
	constant c_led_strobe_ctr_len : natural := integer( ceil( log2( real(c_led_strobe_len_N) ) ) ); --! 21 bits
    constant c_led_strobe_ctr_set : natural := integer( 2**c_led_strobe_ctr_len - c_led_strobe_len_N ); --! 2,097,152 - 1,204,819
    signal   r_led_strobe_ctr_uart_rxd : unsigned(c_led_strobe_ctr_len-1 downto 0);
    signal   r_led_strobe_ctr_rtc_init : unsigned(c_led_strobe_ctr_len-1 downto 0);


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
        --! format = HHMMSS, where each digit is 4 bits except 1st 'H' (2 bits, range 0-2)
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


    --! active low reset in, active high reset out
    inst_reset : entity work.reset(rtl)
    port map (
      clk => i_clk,
      rst_n => i_rst_n,
      rst => w_rst
    );


    --! deserialize UART RX input into 1x byte
    inst_uart_rx : entity work.uart_rx(rtl)
    port map (
        i_clk => i_clk,
        i_rst => w_rst,
        i_rxd => i_uart_rxd,
        o_rx_byte => w_uart_byte,
        o_rx_vld => w_uart_byte_vld
    );


    --! accumulate 6x UART bytes, translate to 6x BCD digits
    inst_uart8_to_wb24 : entity work.uart8_to_wb24(rtl)
    port map (
        i_clk => i_clk,
        i_rst => w_rst,
        --! input
        i_uart_byte => w_uart_byte,
        i_uart_byte_vld => w_uart_byte_vld,
        --! output
        o_wr => w_rtc_init_wr,
        o_data => w_rtc_init,
        o_data_vld => w_rtc_init_vld
    );


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
    w_rtc_S_top_slv <= x"0" & w_rtc_current(w_rtc_current'high-14 downto w_rtc_current'high-17);
    w_rtc_S_bot_slv <= x"0" & w_rtc_current(w_rtc_current'high-18 downto w_rtc_current'high-21);


    --! MUX 4-to-1 BCD bytes
    inst_mux_4to1 : entity work.mux_4to1(rtl)
    port map (
        i_clk  => i_clk, -- in std_logic;
        i_rst  => w_rst, -- in std_logic;
        i_d0   => w_rtc_M_top_slv, -- in std_logic_vector(7 downto 0);
        i_d1   => w_rtc_M_bot_slv, -- in std_logic_vector(7 downto 0);
        i_d2   => w_rtc_S_top_slv, -- in std_logic_vector(7 downto 0);
        i_d3   => w_rtc_S_bot_slv, -- in std_logic_vector(7 downto 0);
        i_dvld => w_rtc_current_vld, -- in std_logic;
        o_q    => w_mux_byte, -- out std_logic_vector(7 downto 0);
        o_dvld => w_mux_byte_vld, -- out std_logic;
        o_sel  => w_mux_byte_sel  -- out std_logic_vector(1 downto 0)
    );


    --! translate standard logic vector byte into 7-segement vector
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
    --! 'slv_to_7sv' takes 1 cycle; i_sel is held high for 4 cycles at a time
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


    --! drive the 4-digit, 7-segment display
    inst_ltc_4627 : entity work.ltc_4627jr_driver 
	generic map (
        g_clk_frq => 12000000, -- 12 MHz
        g_ref_frq => 360, -- Hz
        g_num_seg => 7,
        g_num_dig => 4
	)
	port map (
        --! clock
        i_clk			=> i_clk, -- : in  std_logic;
        i_rst           => w_rst,
        --! input segment data
        i_dig_1 		=> r_7segv_digit(0), -- : in  std_logic_vector(6 downto 0);
        i_dig_2 		=> r_7segv_digit(1), -- : in  std_logic_vector(6 downto 0);
        i_dig_3 		=> r_7segv_digit(2), -- : in  std_logic_vector(6 downto 0);
        i_dig_4 		=> r_7segv_digit(3), -- : in  std_logic_vector(6 downto 0);
        --! input decimal points
        i_dec			=> "0000", -- : in  std_logic_vector(g_num_digits-1 downto 0); 
        --! digit select driver
        o_drive_dig		=> o_drive_dig, -- : out std_logic_vector(g_num_digits-1 downto 0);
        --! segment select driver
        o_drive_seg 	=> o_drive_seg, -- : out std_logic_vector(6 downto 0);	
        --! decimal select driver
        o_drive_dec		=> open -- : out std_logic
	);


    --! every 1 second, issue an active-high strobe for 1 cycle
    p_pps : process(i_clk) begin
        if rising_edge(i_clk) then
            if w_rst = '1' then
                r_pps_cntr <= to_unsigned(0, r_pps_cntr'length);
                r_pps <= '0';
            else
                if ( r_pps_cntr = to_unsigned(c_pps_N, r_pps_cntr'length) ) then
                    r_pps_cntr <= to_unsigned(0, r_pps_cntr'length);
                    r_pps <= '1';
                else 
                    r_pps_cntr <= r_pps_cntr + 1;
                    r_pps <= '0';
                end if;
            end if;
        end if;
    end process;


    --! when a new byte from 'uart_rx' is valid, kick a counter for driving an on-board LED
    --! when a new word from 'uart8_to_wb24' is valid, kick a counter for driving an on-board LED
    p_kick_LED_counters : process(i_clk) begin
        if rising_edge(i_clk) then
            if (w_rst = '1') then
                r_led_strobe_ctr_uart_rxd <= (others => '0'); 
                r_led_strobe_ctr_rtc_init <= (others => '0'); 
            else

                --! kick
                if (w_uart_byte_vld = '1') then
                    r_led_strobe_ctr_uart_rxd <= to_unsigned(c_led_strobe_ctr_set, r_led_strobe_ctr_uart_rxd'length);
                --! run
                elsif (r_led_strobe_ctr_uart_rxd /= 0) then
                    r_led_strobe_ctr_uart_rxd <= r_led_strobe_ctr_uart_rxd + 1;
                --! terminate on rollover
                else
                    r_led_strobe_ctr_uart_rxd <= (others => '0');
                end if;

                --! kick
                if (w_rtc_init_wr = '1') then
                    r_led_strobe_ctr_rtc_init <= to_unsigned(c_led_strobe_ctr_set, r_led_strobe_ctr_rtc_init'length);
                --! run
                elsif (r_led_strobe_ctr_rtc_init /= 0) then
                    r_led_strobe_ctr_rtc_init <= r_led_strobe_ctr_rtc_init + 1;
                --! terminate on rollover
                else
                    r_led_strobe_ctr_rtc_init <= (others => '0');
                end if;

            end if;
        end if;
    end process;


    --! drive the on-board LEDs; active-high
    p_board_leds : process(i_clk) begin
        if rising_edge(i_clk) then
            if w_rst = '1' then
                o_board_led <= (others => '1');
            else

                --! strobe center LED high
                if (r_led_strobe_ctr_uart_rxd /= 0) then
                    o_board_led(o_board_led'high-0) <= '1';
                else 
                    o_board_led(o_board_led'high-0) <= '0';            
                end if;

                --! strobe left LED high
                if (r_led_strobe_ctr_rtc_init /= 0) then
                    o_board_led(o_board_led'high-1) <= '1';
                else 
                    o_board_led(o_board_led'high-1) <= '0';            
                end if;

                --! pull others low
                o_board_led(o_board_led'high-2 downto 0) <= (others => '0');            

            end if;
        end if;
    end process;


end rtl;