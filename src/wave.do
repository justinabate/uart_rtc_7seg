onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/i_clk
add wave -noupdate /tb/w_rst
add wave -noupdate /tb/r_pps
add wave -noupdate -radix hexadecimal -radixshowbase 1 /tb/r_pps_cntr
add wave -noupdate -expand -group u8_to_wb24 /tb/inst_uart8_to_wb24/i_clk
add wave -noupdate -expand -group u8_to_wb24 /tb/inst_uart8_to_wb24/i_rst
add wave -noupdate -expand -group u8_to_wb24 -radix hexadecimal /tb/inst_uart8_to_wb24/i_uart_byte
add wave -noupdate -expand -group u8_to_wb24 /tb/inst_uart8_to_wb24/i_uart_byte_vld
add wave -noupdate -expand -group u8_to_wb24 -radix unsigned /tb/inst_uart8_to_wb24/idx
add wave -noupdate -expand -group u8_to_wb24 -radix hexadecimal /tb/inst_uart8_to_wb24/o_data
add wave -noupdate -expand -group u8_to_wb24 /tb/inst_uart8_to_wb24/o_data_vld
add wave -noupdate -expand -group u8_to_wb24 /tb/inst_uart8_to_wb24/o_wr
add wave -noupdate -expand -group rtc /tb/inst_rtcbare/bcd_clock
add wave -noupdate -expand -group rtc /tb/inst_rtcbare/carry
add wave -noupdate -expand -group rtc /tb/inst_rtcbare/i_clk
add wave -noupdate -expand -group rtc -radix hexadecimal /tb/inst_rtcbare/i_data
add wave -noupdate -expand -group rtc /tb/inst_rtcbare/i_pps
add wave -noupdate -expand -group rtc /tb/inst_rtcbare/i_reset
add wave -noupdate -expand -group rtc /tb/inst_rtcbare/i_valid
add wave -noupdate -expand -group rtc /tb/inst_rtcbare/i_wr
add wave -noupdate -expand -group rtc /tb/inst_rtcbare/next_clock
add wave -noupdate -expand -group rtc -radix hexadecimal /tb/inst_rtcbare/o_data
add wave -noupdate -expand -group rtc /tb/inst_rtcbare/o_ppd
add wave -noupdate -expand -group rtc /tb/inst_rtcbare/o_vld
add wave -noupdate -expand -group rtc /tb/inst_rtcbare/OPT_PREVALIDATED_INPUT
add wave -noupdate -expand -group rtc /tb/inst_rtcbare/pre_bcd_clock
add wave -noupdate -expand -group rtc /tb/inst_rtcbare/pre_ppd
add wave -noupdate -expand -group rtc /tb/inst_rtcbare/pre_valid
add wave -noupdate -expand -group rtc /tb/inst_rtcbare/suppress_count
add wave -noupdate -expand -group rtc /tb/inst_rtcbare/suppressed
add wave -noupdate -expand -group mux /tb/inst_mux_4to1/i_clk
add wave -noupdate -expand -group mux /tb/inst_mux_4to1/i_rst
add wave -noupdate -expand -group mux -radix hexadecimal /tb/inst_mux_4to1/i_d0
add wave -noupdate -expand -group mux -radix hexadecimal /tb/inst_mux_4to1/i_d1
add wave -noupdate -expand -group mux -radix hexadecimal /tb/inst_mux_4to1/i_d2
add wave -noupdate -expand -group mux -radix hexadecimal /tb/inst_mux_4to1/i_d3
add wave -noupdate -expand -group mux /tb/inst_mux_4to1/i_dvld
add wave -noupdate -expand -group mux -radix hexadecimal /tb/inst_mux_4to1/o_q
add wave -noupdate -expand -group mux /tb/inst_mux_4to1/o_dvld
add wave -noupdate -expand -group mux /tb/inst_mux_4to1/o_sel
add wave -noupdate -expand -group mux /tb/inst_mux_4to1/r_toggle
add wave -noupdate -expand -group mux /tb/inst_mux_4to1/r_sel
add wave -noupdate -expand -group mux /tb/inst_mux_4to1/r_vld
add wave -noupdate -expand -group slv_to_7sv /tb/inst_slv_to_7sv/i_clk
add wave -noupdate -expand -group slv_to_7sv /tb/inst_slv_to_7sv/i_rst
add wave -noupdate -expand -group slv_to_7sv -radix hexadecimal /tb/inst_slv_to_7sv/i_slv
add wave -noupdate -expand -group slv_to_7sv /tb/inst_slv_to_7sv/i_slv_vld
add wave -noupdate -expand -group slv_to_7sv /tb/inst_slv_to_7sv/o_7sv
add wave -noupdate -expand -group slv_to_7sv /tb/inst_slv_to_7sv/o_7sv_vld
add wave -noupdate -expand -group slv_to_7sv /tb/inst_slv_to_7sv/r_7sv
add wave -noupdate -expand -group slv_to_7sv /tb/inst_slv_to_7sv/r_7sv_vld
add wave -noupdate -expand -group demux /tb/inst_demux_1to4/i_clk
add wave -noupdate -expand -group demux /tb/inst_demux_1to4/i_rst
add wave -noupdate -expand -group demux /tb/inst_demux_1to4/i_d
add wave -noupdate -expand -group demux /tb/inst_demux_1to4/i_sel
add wave -noupdate -expand -group demux /tb/inst_demux_1to4/o_q0
add wave -noupdate -expand -group demux /tb/inst_demux_1to4/o_q1
add wave -noupdate -expand -group demux /tb/inst_demux_1to4/o_q2
add wave -noupdate -expand -group demux /tb/inst_demux_1to4/o_q3
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 3} {1000000150666664 fs} 0} {{Cursor 2} {166666666 fs} 0}
quietly wave cursor active 2
configure wave -namecolwidth 210
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits us
update
WaveRestoreZoom {999937799236892 fs} {1000078898161641 fs}
