
# source ./tcl_scripts/setenv.tcl ; read_design ./data/DFGs/fir.dot ; read_library ./data/RTL_libraries/RTL_library_multi-resources.txt


source ./tcl_scripts/scheduling/list_mlac.tcl
source ./tcl_scripts/scheduling/mobility.tcl

# mobility for each node
set nodes_mobility [mobility]

set res_info {{L4 0} {L5 0} {L6 6} {L0 0} {L1 0} {L2 22} {L10 0} {L11 0} {L12 50} {L13 0} {L14 0} {L15 2} } 

set start_time [clock milliseconds]
set list_mlac_result [list_mlac $res_info $nodes_mobility]
set end_time [clock milliseconds]
set elapsed_time [expr {$end_time-$start_time}]
puts "Time: $elapsed_time"

# puts $list_mlac_result
set schedule [lindex $list_mlac_result 0]
set fu [lindex $list_mlac_result 1]
set res_info [lindex $list_mlac_result 2]

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

puts "LATENCY: $latency"


# print_scheduled_dfg $schedule ./data/out/fir_malc.dot
