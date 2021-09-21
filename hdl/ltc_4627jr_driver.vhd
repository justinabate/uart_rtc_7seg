library ieee;
use ieee.STD_LOGIC_1164.ALL;
use ieee.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.all;
use ieee.math_real.all; -- for constant calculations

-- mux (i_dig_3 downto i_seg_0) at c_shift_rate
entity ltc_4627jr_driver is generic (
	g_clk_frq	  : integer := 12000000;	                      -- 12 MHz = 12e6
	g_ref_frq 	: integer := 360;                           -- 180 Hz
	g_num_seg   : integer := 7;                               -- number of segments per digit
	g_num_dig   : integer := 4                                -- number of digits on display
); port (
	i_clk		: in  std_logic;                              -- clock 
	i_rst		: in  std_logic;                              -- synchronous
	i_dig_1 	: in  std_logic_vector(g_num_seg-1 downto 0); -- segment data for digit 1, pin 1
	i_dig_2 	: in  std_logic_vector(g_num_seg-1 downto 0); -- segment data for digit 2, pin 2
	i_dig_3 	: in  std_logic_vector(g_num_seg-1 downto 0); -- segment data for digit 3, pin g_num_seg-1
	i_dig_4 	: in  std_logic_vector(g_num_seg-1 downto 0); -- segment data for digit 3, pin 8
	i_dec		: in  std_logic_vector(g_num_dig-1 downto 0); -- decimal points to display
	o_drive_dig	: out std_logic_vector(g_num_dig-1 downto 0); -- digit select; toggle b/w 1-4	
	o_drive_seg : out std_logic_vector(g_num_seg-1 downto 0); -- current segment output
	o_drive_dec	: out std_logic                               -- decimal select
); end ltc_4627jr_driver;

architecture rtl of ltc_4627jr_driver is

	constant c_shift_rate : integer := (g_clk_frq / g_ref_frq);	-- num cycles; 8k cycles @ 10ns = 80k ns = 80us = 12.5 kHz 
--  constant c_shift_rate : integer := 255;	-- num cycles; 8k cycles @ 10ns = 80k ns = 80us = 12.5 kHz 
	constant c_counter_size : natural := integer(ceil(log2(real(c_shift_rate))));

	signal r_shift_counter : std_logic_vector(c_counter_size-1 downto 0);
	signal sr_digit_select : std_logic_vector(g_num_dig-1 downto 0); --! selects which segment is currently driven
	signal r_segment_data : std_logic_vector(g_num_seg-1 downto 0); --! current output 7-segment data vector
	signal r_decimal_data : std_logic; --! 7-segment data vector --! current output decimal

begin

	p_count_or_shift : process(i_clk) begin
		if (i_rst = '1') then
				r_shift_counter <= (others => '0');
				sr_digit_select(sr_digit_select'high) <= '1';
				sr_digit_select(sr_digit_select'high-1 downto 0) <= (others => '0');
		elsif(rising_edge(i_clk)) then
		
			if( r_shift_counter = std_logic_vector(to_unsigned(c_shift_rate, c_counter_size)) ) then
				r_shift_counter <= (others => '0');
				sr_digit_select <= sr_digit_select( sr_digit_select'high-1 downto 0) & sr_digit_select(sr_digit_select'high); -- shift MSb to LSb
			else
				r_shift_counter <= r_shift_counter + 1;
			end if;
			
		end if;
	end process p_count_or_shift;	
	
	p_output_mux : process(i_clk) begin
        if (i_rst = '1') then
            r_segment_data <= (others => '0');
            r_decimal_data <= '0';
		elsif(rising_edge(i_clk)) then
        
            if ( sr_digit_select(sr_digit_select'low) = '1' ) then
                r_segment_data <= i_dig_1;
                r_decimal_data <= i_dec(i_dec'low);
            elsif ( sr_digit_select(sr_digit_select'low+1) = '1') then
                r_segment_data <= i_dig_2;
                r_decimal_data <= i_dec(i_dec'low+1);            
            elsif ( sr_digit_select(sr_digit_select'low+2) = '1') then
                r_segment_data <= i_dig_3;
                r_decimal_data <= i_dec(i_dec'low+2);            
            elsif ( sr_digit_select(sr_digit_select'low+3) = '1') then
                r_segment_data <= i_dig_4;
                r_decimal_data <= i_dec(i_dec'low+3);
            end if;
            
		end if;
	end process p_output_mux;
	
	o_drive_dig <= sr_digit_select;
  o_drive_seg <= not r_segment_data; -- active low
  o_drive_dec <= not r_decimal_data; -- active low
	
end rtl;