
# source ./tcl_scripts/setenv.tcl ; read_design ./data/DFGs/fir.dot ; read_library ./data/RTL_libraries/RTL_library_multi-resources.txt


source ./tcl_scripts/scheduling/list_mlac.tcl
source ./tcl_scripts/scheduling/mobility.tcl

# mobility for each node
set nodes_mobility [mobility]

set res_info {{L6 6} {L2 22} {L12 50} {L15 2}} 

set start_time [clock milliseconds]
set list_mlac_result [list_mlac $res_info $nodes_mobility]
set end_time [clock milliseconds]
set elapsed_time [expr {$end_time-$start_time}]
puts "Time: $elapsed_time"

# puts $list_mlac_result
set schedule [lindex $list_mlac_result 0]
set fu [lindex $list_mlac_result 1]
set latency [lindex $list_mlac_result 2]

# puts ""
# puts "##########"
# puts "SCHEDULING"
# puts "##########"
# puts ""
# foreach pair_time  $schedule {
#     set node_id [lindex $pair_time 0]
#     set start_time [lindex $pair_time 1]
#     puts "Node: $node_id starts @ $start_time"
# }

# puts ""
# puts "#######"
# puts "BINDING"
# puts "#######"
# puts ""
# foreach pair_fu  $fu {
#     set node_id [lindex $pair_fu 0]
#     set fu_id [lindex $pair_fu 1]
#     puts "Node: $node_id fu_id @ $fu_id"
# }
# puts ""

puts "LATENCY: $latency"


# print_scheduled_dfg $schedule ./data/out/fir_malc.dot
