library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use ieee.math_real.all;
 
entity uart8_to_wb24 is
    generic (
        g_CLKS_PER_BIT : integer := 115     -- Needs to be set correctly
    );
    port (
        i_clk       : in  std_logic;
        i_rst       : in  std_logic;
        --! UART
        i_uart_byte     : in std_logic_vector(7 downto 0);
        i_uart_byte_vld : in std_logic;
        --! WB
        o_data : out std_logic_vector(21 downto 0);
        o_data_vld : out std_logic_vector(2 downto 0);
        o_wr : out std_logic
    );
end uart8_to_wb24;
 
 
architecture rtl of uart8_to_wb24 is
 
 
  --! 6-digit BCD vector: HH MM SS; 6*4 = 24; slice off the top 2 MSBs
  signal sr :  std_logic_vector(23 downto 0); 
  constant c_tc : natural := 6; --! load 6 digits max
  constant c_tc_size : natural := integer( ceil( log2( real(c_tc) ) ) ); --! 3 bits
  signal idx : unsigned(c_tc_size-1 downto 0);
   
   
begin
 

    p_sr : process (i_clk) begin
    if rising_edge(i_clk) then
        if (i_rst = '1') then
            sr <= (others => '0'); 
            idx <= to_unsigned(0, idx'length);
        else
            if (idx = to_unsigned(c_tc, idx'length)) then
                idx <= to_unsigned(0, idx'length);
                o_wr <= '1';
                o_data_vld <= "111";
            elsif (i_uart_byte_vld = '1') then
                idx <= idx + 1; --! increment the index
                sr <= sr(sr'high-4 downto 0) & i_uart_byte(i_uart_byte'low+3 downto i_uart_byte'low); --! shift by 4 bits
            else
                o_wr <= '0';
                o_data_vld <= "000";
            end if;

        end if;
    end if;
    end process p_sr;

    o_data <= sr(sr'high-2 downto sr'low);
 
   
end rtl;