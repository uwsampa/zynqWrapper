# -----------------------------------------------------------------------------
#  run_benchmarks.tcl
#  Author: Thierry Moreau
#  Email: moreau@cs.washington.edu
# -----------------------------------------------------------------------------

# Read arguments
if {$argc != 3 && $argc != 4} {
    puts "The script requires one arguments to be inputed."
    puts "\tUsage: xmd -tcl tcl/run_benchmark.tcl [bitfile] [ps7init] [elffile]"
    exit 1
} else {
    set bitfile [lindex $argv 0]
    set ps7init [lindex $argv 1]
    set elffile [lindex $argv 2]
}

# Program the FPGA
fpga -f $bitfile
# Connect to the PS section
connect arm hw
# Reset the system
rst
# Initialize the PS section (Clock PLL, MIO, DDR etc.)
source $ps7init
ps7_init
ps7_post_config
# Load the elf program
dow $elffile
# Start execution
con