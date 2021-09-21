----------------------------------------------------------------------
-- File Downloaded from http://www.nandland.com
----------------------------------------------------------------------
-- This file contains the UART Receiver.  This receiver is able to
-- receive 8 bits of serial data, one start bit, one stop bit,
-- and no parity bit.  When receive is complete o_rx_dv will be
-- driven high for one clock cycle.
-- 
-- Set Generic g_CLKS_PER_BIT as follows:
-- g_CLKS_PER_BIT = (Frequency of i_clk)/(Frequency of UART)
-- Example: 10 MHz Clock, 115200 baud UART
-- (10000000)/(115200) = 87
--
library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
 
entity uart_rx is
    generic (
        g_CLKS_PER_BIT : integer := 115     -- Needs to be set correctly
    );
    port (
        i_clk       : in  std_logic;
        i_rst       : in  std_logic;
        i_rxd       : in  std_logic;
        o_rx_vld    : out std_logic;
        o_rx_byte   : out std_logic_vector(7 downto 0)
    );
end uart_rx;
 
 
architecture rtl of uart_rx is
 
  type t_fsm is (IDLE, RX_START, RX_DATA, RX_STOP, RX_CLEAN);
  signal r_state : t_fsm;
 
  signal r_syncronizer : std_logic_vector(1 downto 0);
  signal w_rxd_sync : std_logic;
   
  signal r_clk_cnt : integer range 0 to g_CLKS_PER_BIT-1;
  signal r_bit_idx : integer range 0 to 7;  -- 8 Bits Total
  signal r_rx_byte : std_logic_vector(7 downto 0); -- := (others => '0');
  signal r_rx_vld  : std_logic;
   
begin
 

    -- Purpose: Double-register the incoming data.
    -- This allows it to be used in the UART RX Clock Domain.
    -- (It removes problems caused by metastabiliy)
    p_sync : process (i_clk) begin
        if rising_edge(i_clk) then
            if (i_rst = '1') then
                r_syncronizer <= (others => '0'); 
            else
                r_syncronizer <= r_syncronizer(r_syncronizer'high-1 downto 0) & i_rxd;
            end if;
        end if;
    end process p_sync;


    --! wire from the 2nd DFF in the synchronizer
    w_rxd_sync <= r_syncronizer(r_syncronizer'high);
 

    -- Purpose: Control RX state machine
    p_fsm : process (i_clk) begin
        if rising_edge(i_clk) then
            if (i_rst = '1') then
                r_state   <= IDLE;
                r_clk_cnt <= 0;
                r_bit_idx <= 0;
                r_rx_vld  <= '0';
                r_rx_byte <= (others => '0'); 
            else 
                case r_state is
            
                    when IDLE =>
                        r_rx_vld  <= '0';
                        r_clk_cnt <= 0;
                        r_bit_idx <= 0;
                
                        -- Start bit detected
                        if w_rxd_sync = '0' then       
                            r_state <= RX_START;
                        else
                            r_state <= IDLE;
                        end if;
            
                    
                    -- Check middle of start bit to make sure it's still low
                    when RX_START =>
                        if (r_clk_cnt = (g_CLKS_PER_BIT-1)/2) then
                            if w_rxd_sync = '0' then
                                r_clk_cnt <= 0;  -- reset counter since we found the middle
                                r_state   <= RX_DATA;
                            else
                                r_state   <= IDLE;
                            end if;
                        else
                            r_clk_cnt <= r_clk_cnt + 1;
                            r_state   <= RX_START;
                        end if;
            
                    
                    -- Wait g_CLKS_PER_BIT-1 clock cycles to sample serial data
                    when RX_DATA =>
                        if (r_clk_cnt /= g_CLKS_PER_BIT-1) then
                            r_state   <= RX_DATA;
                            r_clk_cnt <= r_clk_cnt + 1;
                        else
                            r_clk_cnt            <= 0;
                            r_rx_byte(r_bit_idx) <= w_rxd_sync;
                            
                            -- Check if we have sent out all bits
                            if (r_bit_idx /= 7) then
                                r_state   <= RX_DATA;
                                r_bit_idx <= r_bit_idx + 1;
                            else
                                r_state   <= RX_STOP;
                                r_bit_idx <= 0;
                            end if;
                        end if;
            
            
                    -- Receive Stop bit.  Stop bit = 1
                    when RX_STOP =>
                        -- Wait g_CLKS_PER_BIT-1 clock cycles for Stop bit to finish
                        if (r_clk_cnt /= g_CLKS_PER_BIT-1) then
                            r_state   <= RX_STOP;
                            r_clk_cnt <= r_clk_cnt + 1;
                        else
                            r_state   <= RX_CLEAN;
                            r_rx_vld  <= '1';
                            r_clk_cnt <= 0;
                        end if;
            
                            
                    -- Stay here 1 clock
                    when RX_CLEAN =>
                        r_state  <= IDLE;
                        r_rx_vld <= '0';
            
                        
                    when others =>
                        r_state <= IDLE;
            
                end case;
            end if;
        end if;
    end process p_fsm;

    --! wires
    o_rx_vld  <= r_rx_vld;
    o_rx_byte <= r_rx_byte;
   
end rtl;