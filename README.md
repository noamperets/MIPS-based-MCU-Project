						Final project - MIPS based MCU Architecture and Design
						By:  Noam Perets , Noam Vaknin


list of the *.vhd files with their brief functional description:

BasicTimer.vhd:
basic timer module. It has inputs for clock, reset, data bus, control signals, and memory interface. It includes functionality to configure the timer's control registers, load compare values, count cycles, and generate output signals based on duty cycle. The timer can also set specific bits for interrupt generation. The output signal represents the timer's state, and it has a frequency divider component inside for clock scaling.

freqdiv.vhd:
frequency divider module. It takes a clock input and generates three divided clock outputs: mclk2, mclk4, and mclk8. The division factor is controlled by counting clock cycles and toggling the divided outputs based on a rising edge of the clock.

GPIO.vhd:
general-purpose input/output (GPIO) module. It includes inputs for control signals, data bus, address bit (A0), and memory interface. Depending on the control signals and memory interface, it can read from or write to registers, updating LEDs and seven-segment displays (Hexadecimal decoders).

HexDecoder.vhd:
hexadecimal decoder component. Given a 4-bit binary input, it generates a 7-segment display output that represents the corresponding hexadecimal digit.

InterruptController.vhd:
includes various interrupt request signals and control inputs, and manages interrupt handling based on priority and conditions. It supports interrupt types like BasicTimer and external key presses (KEY1rq, KEY2rq, KEY3rq). The controller maintains interrupt flags (IFG) and interrupt enable flags (IE) in response to memory writes and external events. It generates interrupt outputs (INTR) based on enabled interrupts and their conditions.

Optimized_Addr_Decoder.vhd:
It takes a 5-bit address bus as input and generates a 12-bit chip select signal (CS) as output. This module is designed to efficiently decode specific addresses and map them to corresponding chip select values for various peripheral devices. It allows for quick and efficient selection of devices based on the input address. The module supports specific addresses for LEDR, HEX displays, switches, interrupts, and timer-related functionalities. 

MCU.vhd:
top-level Microcontroller Unit (MCU) design. It connects a MIPS core, an optimized address decoder, GPIO, and a basic timer. The MCU has various inputs (reset, clock, switches) and outputs (LEDs, HEX displays). Components handle interrupts, timers, data decoding, and control signals, enabling communication and control in the MCU. 

IFETCH.vhd:

Implements the instruction fetch stage of the MIPS processor.
Fetches instructions from the instruction memory based on the program counter (PC) value. It provides the fetched instruction to the subsequent stages of the processor pipeline.

IDECODE.vhd:

Implements the instruction decode stage of the MIPS processor.
Decodes the instruction by extracting opcode, register addresses, and immediate values. It also generates control signals used to control subsequent stages based on the instruction type.

CONTROL.vhd:

Implements the control unit for the MIPS processor.
Generates control signals based on the opcode of the instruction and responsible for register write enable, memory read/write enable, ALU operation selection and more.

EXECUTE.vhd:

Implements the execute stage of the MIPS processor.
Executes arithmetic and logical operations based on the ALU operation and input data. It performs operations such as addition, subtraction, logical AND/OR, and compares values to determine branch and jump conditions.

DMEMORY.vhd:

Implements the data memory module for the MIPS processor.
Represents the data memory component that stores data used by the processor. It provides read and write operations to access memory locations based on the provided address.

MIPS.vhd:

The CPU Core that integrates all the components of the MIPS processor.
Combines all the processor components, including instruction memory, data memory, control unit, instruction fetch, decode, execute, memory, write-back. It defines the interconnections between these components and controls the overall operation of the MIPS processor.

