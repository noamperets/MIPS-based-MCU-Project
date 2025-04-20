# MIPS-Based MCU Architecture and Design

Final project for the Advanced Microprocessor Architecture and Hardware Accelerators Lab Course 
👨‍💻 By: Noam Perets & Noam Vaknin

## 📘 Project Overview

This project implements a **Microcontroller Unit (MCU)** architecture based on a MIPS CPU core.  
The design includes peripherals such as a basic timer, GPIO, interrupt controller, and an optimized address decoder — all written in VHDL.

📝 For full documentation and RTL schematics, see the [PDF Report](./final.pdf).

## 📁 Project Structure

Below is a list of the main VHDL modules with short functional descriptions:

### 🔷 CPU Components

- **`MIPS.vhd`** – The full MIPS CPU core: fetch, decode, execute, memory access, and writeback.
- **`IFETCH.vhd`** – Instruction fetch stage.
- **`IDECODE.vhd`** – Instruction decode and control signal generation.
- **`EXECUTE.vhd`** – ALU logic, branch and jump decisions.
- **`CONTROL.vhd`** – Generates control signals based on instruction opcode.
- **`DMEMORY.vhd`** – Data memory access.

### 🔷 MCU Components

- **`MCU.vhd`** – Top-level design connecting CPU and peripherals.
- **`Optimized_Addr_Decoder.vhd`** – Maps 5-bit address inputs to 12-bit chip select lines for peripherals.
- **`GPIO.vhd`** – Drives LEDs and HEX displays; handles memory-mapped I/O.
- **`HexDecoder.vhd`** – Converts 4-bit binary values to 7-segment display.
- **`BasicTimer.vhd`** – Timer module with interrupt generation and PWM-style output.
- **`freqdiv.vhd`** – Frequency divider generating mclk2, mclk4, and mclk8.
- **`InterruptController.vhd`** – Manages multiple interrupt sources (timer, keys) with prioritization.

## 💡 Key Features

- Modular MIPS-based processor architecture
- Memory-mapped I/O (LEDs, switches, hex displays)
- Custom interrupt controller with hardware-generated signals
- Peripheral integration via chip-select decoding
- Signal-level simulation in ModelSim and real-time testing using Quartus SignalTap

## 🔬 Results & Testing

- ✅ Verified waveforms using **ModelSim**
- ✅ Measured system response using **Quartus SignalTap**
- 📈 Achieved expected `fmax` and identified the **critical path** from the MIPS core to the GPIO write logic
