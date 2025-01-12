# Fully Automatic Washing Machine Control System  

This project implements a control system for an automatic washing machine using Verilog HDL. It is designed as a finite state machine (FSM) and prototyped on the DE10-Lite FPGA board, featuring Intel® MAX® 10 FPGA. The system manages various washing machine operations, including timer-based state transitions, user input handling, and real-time feedback via a seven-segment display.

## Features  
- **Finite State Machine (FSM)**: Controls operations with states like IDLE, READY, SOAK, WASH, RINSE, and SPIN.  
- **Timer-Based Transitions**: Each state operates for a predefined duration based on the selected mode.  
- **Mode Selection**: Supports three washing modes based on load weight (<2kg, 2–4kg, 4–6kg).  
- **Lid Detection**: Pauses operations when the lid is open.  
- **Real-Time Feedback**: Displays the current state and operation progress using seven-segment displays.  
- **Coin Return**: Refunds inserted coins if the cycle is canceled.  

## Hardware Requirements  
- **DE10-Lite FPGA Board**: Utilizes the Intel® MAX® 10 FPGA with 50K logic elements and on-die ADC.  
- **Seven-Segment Display**: To indicate the current state of the washing machine.  
- **Input Controls**: Buttons for start, cancel, and mode selection.  

## Getting Started  
1. Clone the repository:  
   ```bash  
   git clone https://github.com/yourusername/fully-automatic-washing-machine.git  
