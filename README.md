# zynqWrapper
A low-latency and simple hardware interface for the Zynq SoC complemented with software driver code. The code currently supports the Zynq ZC702 Development board but can be modified to support differe nt Zynq boards or devices easily.

## Getting started

### Installing Xilinx ISE
First you'll need to install Xilinx ISE (note: the flow hasn't been tested on Xilinx Vivado which is set to replace ISE in the long term). The code has been tested on ISE 14.7 but should work on earlier versions. Instructions on installing Xilinx ISE can be found on Xilinx' website.
Once the files have been installed, there is a settings script that needs to be sourced in order to add the Xilinx executable to your path. If for instance you install the Xilinx ISE v.14.7 under `/opt/Xilinx/14.7` the settings path can be found under the path: `/opt/Xilinx/14.7/ISE_DS/settings64.sh`.

### Configuring the run.sh script
This repository contains a script that is supposed to automate the ISE project creation, hardware compilation, bitstream generation, software compilation as well as FPGA programming and binary execution out of the box. However you are still expected to modify the run.sh script under `zynqWrapper` to point to the ISE settings file. The default path is  `/opt/Xilinx/14.7/ISE_DS/settings64.sh` but it is likely that the file won't be found on your computer. Therefore make sure to update the path to point to a valid location.

### Terminal emulator setup
The design is configured to run on the Zynq ZC702 board. Ensure that you have connected the board to your host PC through the JTAG (programming) and UART (terminal) USB connections. In order to interact with programs that execute on the board you'll have to run a terminal emulator. I recommend using [gtkterm](https://fedorahosted.org/gtkterm/), which you can install on Fedora with `yum install gtkterm` or Ubuntu with `apt-get install gtkterm`. Select the appropriate port which you'll find under `/dev/` (the board appears as ttyUSB0 on my machine), and make sure to set the baud rate to `115200`, set parity to `none`, bits to `8`, stopbits to `1` and flow control to `none`.

### Running the compilation script
You should be ready now to generate the ISE project, compile the hardware designs, generate the bitstream, compile the test program, program the FPGA and execute the program binary on the FPGA.
All you have to do is run `./run.sh`. Yes that's it! 
Once the board is programmed, and the program starts executing, you should see in the terminal emulator the word `Success` being printed to standard out. This indicates that the hardware design and that the driver are working correctly.

## Code structure
* `/hardware` contains the verilog source and other design files necessary to generate a hardware project
  * `/hardware/system` contains the processing system files created in Xilinx XPS which define the ARM Cortex A9 interface with the programmable logic
  * `/hardware/make.tcl` is the TCL script that when executed by `xtclsh` will generate a new ISE project, compile the source and generate the bitstream
* `/software` contains the driver code, and various tcl scripts that are used to configure the FPGA and program the ARM processing system
  * `/software/lib` contains the driver code, static libraries, linker scripts as well as performance monitoring code used to obtain detailed profiles of applications running on the Zynq
  * `/software/source` contains the source code of the test application; it can be compiled by typing `Make` in that directory
  * `/software/tcl` contains the tcl scripts used to configure the processing system (memory, IO and PLL initialization)

### Contact
If you have any questions, feel free to contact Thierry Moreau - moreau@cs.washington.edu
