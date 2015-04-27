# -----------------------------------------------------------------------------
#  run.sh
#  Author: Thierry Moreau
#  Email: moreau@cs.washington.edu
# -----------------------------------------------------------------------------

# You will need to update this path
SETTINGS_PATH=/opt/Xilinx/14.7/ISE_DS/settings64.sh
DESIGN_DIR=design

if [ ! SETTINGS_PATH]; then
    echo "Please modify the SETTINGS_PATH variable to point to the settings script of the ISE version you are using"
    echo "e.g. /opt/Xilinx/14.7/ISE_DS/settings64.sh"
fi

echo "Sourcing environment variables..."
. $SETTINGS_PATH

echo "Compiling hardware design..."
mkdir $DESIGN_DIR
cp hardware/make.tcl $DESIGN_DIR
cd $DESIGN_DIR
xtclsh make.tcl

echo "Compiling software..."
cd ../software/source
make

echo "Programming device and running the benchmark"
cd ../
xmd -tcl tcl/run_benchmark.tcl ../$DESIGN_DIR/system_top.bit tcl/ps7_init_167.tcl source/test.elf
