onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /mcu_tb/Instruction_out
add wave -noupdate -radix hexadecimal /mcu_tb/PC
add wave -noupdate -radix hexadecimal /mcu_tb/clock
add wave -noupdate -radix hexadecimal /mcu_tb/reset
add wave -noupdate -radix hexadecimal /mcu_tb/PC_ENA
add wave -noupdate -radix hexadecimal /mcu_tb/SW
add wave -noupdate -radix hexadecimal /mcu_tb/LEDR
add wave -noupdate -radix hexadecimal /mcu_tb/HEX0
add wave -noupdate -radix hexadecimal /mcu_tb/HEX1
add wave -noupdate -radix hexadecimal /mcu_tb/HEX2
add wave -noupdate -radix hexadecimal /mcu_tb/HEX3
add wave -noupdate -radix hexadecimal /mcu_tb/HEX4
add wave -noupdate -radix hexadecimal /mcu_tb/HEX5
add wave -noupdate -radix hexadecimal /mcu_tb/output_signal
add wave -noupdate -radix hexadecimal /mcu_tb/key1
add wave -noupdate -radix hexadecimal /mcu_tb/key2
add wave -noupdate -radix hexadecimal /mcu_tb/key3
add wave -noupdate -radix hexadecimal /mcu_tb/U_0/ICmap/interruptReg
add wave -noupdate -radix hexadecimal /mcu_tb/U_0/ICmap/GIE_read
add wave -noupdate -radix hexadecimal /mcu_tb/U_0/TimerMap/timer_cnt
add wave -noupdate -radix hexadecimal /mcu_tb/U_0/TimerMap/BTCTL_compare
add wave -noupdate -radix hexadecimal /mcu_tb/U_0/TimerMap/BTCL1
add wave -noupdate -radix hexadecimal /mcu_tb/U_0/TimerMap/BTCL0
add wave -noupdate -radix hexadecimal /mcu_tb/U_0/TimerMap/CS
add wave -noupdate -radix hexadecimal /mcu_tb/U_0/ICmap/INTR
add wave -noupdate /mcu_tb/U_0/TimerMap/Set_BTIFG
add wave -noupdate /mcu_tb/U_0/ICmap/KEY1rq
add wave -noupdate /mcu_tb/U_0/ICmap/key1prev
add wave -noupdate /mcu_tb/U_0/ICmap/KEY2rq
add wave -noupdate /mcu_tb/U_0/ICmap/key2prev
add wave -noupdate /mcu_tb/U_0/ICmap/KEY3rq
add wave -noupdate /mcu_tb/U_0/ICmap/key3prev
add wave -noupdate /mcu_tb/U_0/ICmap/IFGreg
add wave -noupdate /mcu_tb/U_0/ICmap/line__76/IFG_temp
add wave -noupdate -radix hexadecimal -childformat {{/mcu_tb/U_0/MIPSmap/ID/register_array(0) -radix hexadecimal} {/mcu_tb/U_0/MIPSmap/ID/register_array(1) -radix hexadecimal} {/mcu_tb/U_0/MIPSmap/ID/register_array(2) -radix hexadecimal} {/mcu_tb/U_0/MIPSmap/ID/register_array(3) -radix hexadecimal} {/mcu_tb/U_0/MIPSmap/ID/register_array(4) -radix hexadecimal} {/mcu_tb/U_0/MIPSmap/ID/register_array(5) -radix hexadecimal} {/mcu_tb/U_0/MIPSmap/ID/register_array(6) -radix hexadecimal} {/mcu_tb/U_0/MIPSmap/ID/register_array(7) -radix hexadecimal} {/mcu_tb/U_0/MIPSmap/ID/register_array(8) -radix hexadecimal} {/mcu_tb/U_0/MIPSmap/ID/register_array(9) -radix hexadecimal} {/mcu_tb/U_0/MIPSmap/ID/register_array(10) -radix hexadecimal} {/mcu_tb/U_0/MIPSmap/ID/register_array(11) -radix hexadecimal} {/mcu_tb/U_0/MIPSmap/ID/register_array(12) -radix hexadecimal} {/mcu_tb/U_0/MIPSmap/ID/register_array(13) -radix hexadecimal} {/mcu_tb/U_0/MIPSmap/ID/register_array(14) -radix hexadecimal} {/mcu_tb/U_0/MIPSmap/ID/register_array(15) -radix hexadecimal} {/mcu_tb/U_0/MIPSmap/ID/register_array(16) -radix hexadecimal} {/mcu_tb/U_0/MIPSmap/ID/register_array(17) -radix hexadecimal} {/mcu_tb/U_0/MIPSmap/ID/register_array(18) -radix hexadecimal} {/mcu_tb/U_0/MIPSmap/ID/register_array(19) -radix hexadecimal} {/mcu_tb/U_0/MIPSmap/ID/register_array(20) -radix hexadecimal} {/mcu_tb/U_0/MIPSmap/ID/register_array(21) -radix hexadecimal} {/mcu_tb/U_0/MIPSmap/ID/register_array(22) -radix hexadecimal} {/mcu_tb/U_0/MIPSmap/ID/register_array(23) -radix hexadecimal} {/mcu_tb/U_0/MIPSmap/ID/register_array(24) -radix hexadecimal} {/mcu_tb/U_0/MIPSmap/ID/register_array(25) -radix hexadecimal} {/mcu_tb/U_0/MIPSmap/ID/register_array(26) -radix hexadecimal} {/mcu_tb/U_0/MIPSmap/ID/register_array(27) -radix hexadecimal} {/mcu_tb/U_0/MIPSmap/ID/register_array(28) -radix hexadecimal} {/mcu_tb/U_0/MIPSmap/ID/register_array(29) -radix hexadecimal} {/mcu_tb/U_0/MIPSmap/ID/register_array(30) -radix hexadecimal} {/mcu_tb/U_0/MIPSmap/ID/register_array(31) -radix hexadecimal}} -expand -subitemconfig {/mcu_tb/U_0/MIPSmap/ID/register_array(0) {-height 20 -radix hexadecimal} /mcu_tb/U_0/MIPSmap/ID/register_array(1) {-height 20 -radix hexadecimal} /mcu_tb/U_0/MIPSmap/ID/register_array(2) {-height 20 -radix hexadecimal} /mcu_tb/U_0/MIPSmap/ID/register_array(3) {-height 20 -radix hexadecimal} /mcu_tb/U_0/MIPSmap/ID/register_array(4) {-height 20 -radix hexadecimal} /mcu_tb/U_0/MIPSmap/ID/register_array(5) {-height 20 -radix hexadecimal} /mcu_tb/U_0/MIPSmap/ID/register_array(6) {-height 20 -radix hexadecimal} /mcu_tb/U_0/MIPSmap/ID/register_array(7) {-height 20 -radix hexadecimal} /mcu_tb/U_0/MIPSmap/ID/register_array(8) {-height 20 -radix hexadecimal} /mcu_tb/U_0/MIPSmap/ID/register_array(9) {-height 20 -radix hexadecimal} /mcu_tb/U_0/MIPSmap/ID/register_array(10) {-height 20 -radix hexadecimal} /mcu_tb/U_0/MIPSmap/ID/register_array(11) {-height 20 -radix hexadecimal} /mcu_tb/U_0/MIPSmap/ID/register_array(12) {-height 20 -radix hexadecimal} /mcu_tb/U_0/MIPSmap/ID/register_array(13) {-height 20 -radix hexadecimal} /mcu_tb/U_0/MIPSmap/ID/register_array(14) {-height 20 -radix hexadecimal} /mcu_tb/U_0/MIPSmap/ID/register_array(15) {-height 20 -radix hexadecimal} /mcu_tb/U_0/MIPSmap/ID/register_array(16) {-height 20 -radix hexadecimal} /mcu_tb/U_0/MIPSmap/ID/register_array(17) {-height 20 -radix hexadecimal} /mcu_tb/U_0/MIPSmap/ID/register_array(18) {-height 20 -radix hexadecimal} /mcu_tb/U_0/MIPSmap/ID/register_array(19) {-height 20 -radix hexadecimal} /mcu_tb/U_0/MIPSmap/ID/register_array(20) {-height 20 -radix hexadecimal} /mcu_tb/U_0/MIPSmap/ID/register_array(21) {-height 20 -radix hexadecimal} /mcu_tb/U_0/MIPSmap/ID/register_array(22) {-height 20 -radix hexadecimal} /mcu_tb/U_0/MIPSmap/ID/register_array(23) {-height 20 -radix hexadecimal} /mcu_tb/U_0/MIPSmap/ID/register_array(24) {-height 20 -radix hexadecimal} /mcu_tb/U_0/MIPSmap/ID/register_array(25) {-height 20 -radix hexadecimal} /mcu_tb/U_0/MIPSmap/ID/register_array(26) {-height 20 -radix hexadecimal} /mcu_tb/U_0/MIPSmap/ID/register_array(27) {-height 20 -radix hexadecimal} /mcu_tb/U_0/MIPSmap/ID/register_array(28) {-height 20 -radix hexadecimal} /mcu_tb/U_0/MIPSmap/ID/register_array(29) {-height 20 -radix hexadecimal} /mcu_tb/U_0/MIPSmap/ID/register_array(30) {-height 20 -radix hexadecimal} /mcu_tb/U_0/MIPSmap/ID/register_array(31) {-height 20 -radix hexadecimal}} /mcu_tb/U_0/MIPSmap/ID/register_array
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {46091245 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
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
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {105 us}
