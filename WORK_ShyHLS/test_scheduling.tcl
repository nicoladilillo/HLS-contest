source ./tcl_scripts/setenv.tcl
source ./tcl_scripts/scheduling/list_mlac.tcl
source ./tcl_scripts/scheduling/mobility.tcl

read_design ./data/DFGs/fir.dot
read_library ./data/RTL_libraries/RTL_library_multi-resources.txt


set mobility_result [mobility]
foreach pair $mobility_result {
    set node_id [lindex $pair 0]
    set mobility [lindex $pair 1]
    puts "Node: $node_id mobility @ $mobility"
}

# set res_info {{L0 3} {L1 2} {L4 3} {L10 3} {L13 1}} 
# set list_mlac_result [list_mlac $res_info]
# set schedule [lindex $list_mlac_result 0]
# set latency [lindex $list_mlac_result 1]
# foreach pair $schedule {
#     set node_id [lindex $pair 0]
#     set start_time [lindex $pair 1]
#     puts "Node: $node_id starts @ $start_time"
# }
# puts "Latency $latency"


# print_scheduled_dfg $schedule ./data/out/fir_malc.dot
