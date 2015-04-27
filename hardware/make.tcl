# -----------------------------------------------------------------------------
# make.tcl
# Author: Thierry Moreau
# Email: moreau@cs.washington.edu
# -----------------------------------------------------------------------------

# Path variables
set curr_dir        [pwd]
set src_dir         ../hardware
set system_dir      $src_dir/system

# Create Project
project new x8_npu
project set family Zynq
project set device XC7Z020
project set package CLG484
project set speed -1
project set top_level_module_type "HDL"
project set synthesis_tool "XST (VHDL/Verilog)"
project set simulator "ISim (VHDL/Verilog)"
project set "Preferred Language" "Verilog"

# Copy files over
exec cp -r $system_dir .
exec cp $src_dir/macros.inc .
exec cp $src_dir/params.inc .
exec cp $src_dir/system_top.v .
exec cp $src_dir/zynqWrapper.v .
exec cp $src_dir/BRAMFIFO.v .

# Add files to the project
xfile add system/system.xmp
xfile add macros.inc
xfile add params.inc
xfile add system_top.v
xfile add zynqWrapper.v
xfile add BRAMFIFO.v

# Set top level file in the project
set top system_top.v

# Launch compilation job
process run "Implement Design" -force rerun_all
process run "Generate Programming File" -force rerun_all
