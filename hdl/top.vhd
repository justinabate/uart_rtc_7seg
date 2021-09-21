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
	type data_array_t is array (3 downto 0) of std_logic_vector(6 downto 0); -- := (others => '0');
	signal r_7segv_digit : data_array_t;

    --! output wires from UART receiver
    signal w_uart_byte : std_logic_vector(7 downto 0);
    signal w_uart_byte_vld : std_logic;

    --! output wires from 7-segement vector translator
    signal w_7sv : std_logic_vector(6 downto 0);
    signal w_7sv_vld : std_logic;

    --! UART RX LED counter logic 
    constant c_clk_period : real := 8.3e-8;
    constant c_uart_stretch_t : real := 0.025; --! seconds
    constant c_uart_stretch_N : integer := integer(c_uart_stretch_t/c_clk_period); --! 1,204,819 cycles
	constant c_uart_stretch_cntr_size : natural := integer( ceil( log2( real(c_uart_stretch_N) ) ) ); --! 21 bits
    constant c_uart_stretch_cntr_preset : natural := integer( 2**c_uart_stretch_cntr_size - c_uart_stretch_N ); --! 2,097,152 - 1,204,819
    signal   r_uart_stretch_counter : unsigned(c_uart_stretch_cntr_size-1 downto 0);

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
   

    --! translate 1x UART ASCII byte into 7-segement vector
    inst_slv_to_7sv : entity work.slv_to_7sv(rtl) 
    port map (
        i_clk => i_clk,
        i_rst => w_rst,
        i_slv => w_uart_byte,
        i_slv_vld => w_uart_byte_vld,
        o_7sv => w_7sv,
        o_7sv_vld => w_7sv_vld
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


    --! when a new byte from 'inst_slv_to_7sv' is valid, shift it into the high index of 'r_7segv_digit'
    p_update_7sv_array : process(i_clk) begin
        if rising_edge(i_clk) then
            if w_rst = '1' then
                r_7segv_digit <= (others=>(others => '0'));
            else
                if (w_7sv_vld = '1') then
                    r_7segv_digit <= w_7sv & r_7segv_digit(r_7segv_digit'high downto r_7segv_digit'low+1);
                else
                    r_7segv_digit <= r_7segv_digit;
                end if;
            end if;
        end if;
    end process;


    --! when a new byte from 'inst_uart_rx' is valid, kick a counter for driving an on-board LED
    p_stretch_uart_rxd_indicator : process(i_clk) begin
        if rising_edge(i_clk) then
            if (w_rst = '1') then
                r_uart_stretch_counter <= (others => '0'); 
            else
                --! kick
                if (w_uart_byte_vld = '1') then
                    r_uart_stretch_counter <= to_unsigned(c_uart_stretch_cntr_preset, r_uart_stretch_counter'length);
                --! run
                elsif (r_uart_stretch_counter /= 0) then
                    r_uart_stretch_counter <= r_uart_stretch_counter + 1;
                --! terminate on rollover
                else
                    r_uart_stretch_counter <= r_uart_stretch_counter;
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
                o_board_led(o_board_led'high-1 downto 0) <= (others => '0');            

                if (r_uart_stretch_counter /= 0) then
                    o_board_led(o_board_led'high) <= '1';
                else 
                    o_board_led(o_board_led'high) <= '0';            
                end if;
            end if;
        end if;
    end process;


end rtl;