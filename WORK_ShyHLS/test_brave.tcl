# source ./tcl_scripts/setenv.tcl ; read_design ./data/DFGs/fir.dot ; read_library ./data/RTL_libraries/RTL_library_multi-resources.txt


source ./brave.tcl

set start_time [clock milliseconds]
set list_result [brave_opt -total_area 1000]
set end_time [clock milliseconds]
set elapsed_time [expr {$end_time-$start_time}]
puts "Time: $elapsed_time"

set schedule [lindex $list_result 0]
set fu [lindex $list_result 1]
set res_info [lindex $list_mlac_result 2]

puts "Resources used: $res_info"

puts ""
puts "##########"
puts "SCHEDULING"
puts "##########"
puts ""
foreach pair_time $schedule {
    set node_id [lindex $pair_time 0]
    set start_time [lindex $pair_time 1]
    set fu_id [lindex [lindex $fu [lsearch -index 0 $fu $node_id]] 1]
    set fu_delay [get_attribute $fu_id delay]
    set end_time [expr {$start_time+$fu_delay-1}]
    puts "$node_id starts at $start_time and end at $end_time with $fu_delay ($fu_id)"
}
