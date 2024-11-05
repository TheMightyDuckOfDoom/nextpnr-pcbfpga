# Usage
# tcl synth_pcbfpga.tcl {out.json}
yosys -import

set LUT_K 4

yosys read_verilog -lib [file dirname [file normalize $argv0]]/prims.v
yosys read_verilog [lindex $argv 0]
hierarchy -check -top [lindex $argv 1]
yosys proc
flatten
tribuf -logic
deminout
synth -run coarse
memory_map
opt -full
iopadmap -bits -inpad IBUF O:PAD -outpad OBUF I:PAD
stat
techmap -map +/techmap.v
opt -full
dfflegalize -cell \$_DFF_P_ x -cell \$_DFFE_PP_ x -cell \$_SDFF_PN0_ x -cell \$_SDFFE_PN0P_ x -mince 4 -minsrst 4
stat
abc9 -lut $LUT_K
clean
techmap -D LUT_K=$LUT_K -map [file dirname [file normalize $argv0]]/cells_map.v
opt_merge -share_all
clean
stat
#extract -map [file dirname [file normalize $argv0]]/combine_lut3.v
#stat
hierarchy -check
stat

yosys write_json [lindex $argv 1]_synth.json
yosys write_verilog [lindex $argv 1]_synth.v
