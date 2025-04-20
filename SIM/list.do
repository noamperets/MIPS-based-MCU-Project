onerror {resume}
add list /mcu_tb/Instruction_out
add list /mcu_tb/PC
add list /mcu_tb/clock
add list /mcu_tb/reset
add list /mcu_tb/PC_ENA
add list /mcu_tb/SW
add list /mcu_tb/LEDR
add list /mcu_tb/HEX0
add list /mcu_tb/HEX1
add list /mcu_tb/HEX2
add list /mcu_tb/HEX3
add list /mcu_tb/HEX4
add list /mcu_tb/HEX5
add list /mcu_tb/output_signal
add list /mcu_tb/key1
add list /mcu_tb/key2
add list /mcu_tb/key3
configure list -usestrobe 0
configure list -strobestart {0 ps} -strobeperiod {0 ps}
configure list -usesignaltrigger 1
configure list -delta collapse
configure list -signalnamewidth 0
configure list -datasetprefix 0
configure list -namelimit 5
