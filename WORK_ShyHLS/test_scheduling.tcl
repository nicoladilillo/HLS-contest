source ./tcl_scripts/setenv.tcl
# source ./tcl_scripts/scheduling/mobility.tcl
source ./tcl_scripts/scheduling/list_mlac.tcl

read_design ./data/DFGs/fir.dot
read_library ./data/RTL_libraries/RTL_library_multi-resources.txt


# set mobility_result [mobility]
# foreach pair $mobility_result {
#     set node_id [lindex $pair 0]
#     set mobility [lindex $pair 1]
#     puts "Node: $node_id mobility @ $mobility"
# }

set res_info {{L1 3} {L5 3} {L12 3} {L15 1}} 
set list_mlac_result [list_mlac $res_info]
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
