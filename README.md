# packetizer
# UART Transmitter Design

This repository contains a Verilog implementation of a UART transmitter synthesized using open-source tools. The design includes a FIFO buffer and a finite state machine (FSM) controller that handles data serialization and transmission timing.

## Repository Structure

```
uart_transmitter/
├── rtl2/                     # Verilog source files
│   ├── uart_transmitter.v   # Top-level module
│   ├── packetizer_fsm.v     # FSM controller with baud rate generator
│   └── fifo.v               # FIFO buffer implementation
├── synth/                   # Synthesis output files
│   └── uart_transmitter_synth.v
├── testbench/               # Simulation testbench
│   └── tb_uart_transmitter.v
└── README.md                # This file
```

## Design Overview

The UART transmitter consists of two main components:

1. **FIFO Buffer** (16x8-bit)
   - Buffers incoming parallel data
   - Handles flow control with full/empty flags
   - Synchronous read/write operations

2. **Packetizer FSM**
   - Manages UART transmission protocol
   - Implements configurable baud rate (divisor = 5 for simulation)
   - Serializes data with start bit, 8 data bits, and stop bit
   - Handles transmission timing and status signals

## Key Features

- 8-bit data transmission
- Configurable baud rate (via divisor parameter)
- FIFO buffering for smooth data handling
- Full-duplex ready/busy signaling
- Reset initialization

## Tools Used

Since I don't have access to Xilinx Vivado (due to hardware compatibility issues), this project was implemented using open-source tools:

- **Synthesis**: Yosys 0.29+23
- **Simulation**: Icarus Verilog (iverilog)
- **Waveform Viewing**: GTKWave

## Synthesis Note

The design was synthesized but **not place-and-routed** due to the use of open-source tools rather than vendor-specific FPGA toolchains. The synthesis process focused on:

1. RTL elaboration
2. Technology-independent optimization
3. Generic gate-level mapping
4. Basic timing constraints

Without proprietary place-and-route tools, we cannot generate:
- Device-specific implementation
- Timing closure reports
- Bitstream files
- Power consumption estimates

## Getting Started

### Prerequisites
- Icarus Verilog (`iverilog`)
- GTKWave (`gtkwave`)
- Yosys (for synthesis)

### Simulation
```bash
cd testbench
iverilog -o sim tb_uart_transmitter.v ../rtl/*.v
vvp sim
gtkwave waveform.vcd
```

### Synthesis with Yosys
```bash
yosys
> read_verilog rtl/uart_transmitter.v
> synth -top uart_transmitter
> write_verilog synth/uart_transmitter_synth.v
```

## Future Work

With access to vendor tools (Vivado/Quartus), we could:
1. Perform place-and-route for specific FPGAs
2. Generate timing reports and analyze constraints
3. Create bitstream files for physical implementation
4. Validate actual performance metrics

