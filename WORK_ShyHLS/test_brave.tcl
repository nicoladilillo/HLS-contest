# source ./tcl_scripts/setenv.tcl ; read_design ./data/DFGs/fir.dot ; read_library ./data/RTL_libraries/RTL_library_multi-resources.txt


source ./brave.tcl

set start_time [clock milliseconds]
set list_mlac_result [brave_opt -total_area 1000]
set end_time [clock milliseconds]
set elapsed_time [expr {$end_time-$start_time}]
puts "Time: $elapsed_time"