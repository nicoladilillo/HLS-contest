# source ./tcl_scripts/setenv.tcl ; read_design ./data/DFGs/fir.dot ; read_library ./data/RTL_libraries/RTL_library_multi-resources.txt
source ./brave.tcl

proc print_scheduling {schedule} {
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
}

proc calculate_lambda {} {
    set asap_schedule [asap]

    # find minimum lambda
    set pair [lindex $asap_schedule end]
    set node_id [lindex $pair 0]
    set start_time [lindex $pair 1]
    set node_operation [get_attribute $node_id operation]
    set fu [get_lib_fu_from_op $node_operation]
    set delay_operation [get_attribute $fu delay]
    set lambda [expr $start_time + $delay_operation]

    return $lambda
}

proc calculate_time {} {
    set total_score 0.0

    set start_time [clock milliseconds]
    set list_result [brave_opt -total_area 1000]
    set end_time [clock milliseconds]
    set elapsed_time [expr {$end_time-$start_time}]
    puts "Time: $elapsed_time"

    set schedule [lindex $list_result 0]
    set fu [lindex $list_result 1]
    set res_info [lindex $list_result 2]
    set latency [lindex $list_result 3]

    puts "Resources used: $res_info"
    puts "Latency: $latency"

    set lambda [calculate_lambda]

    set score [expr {(100.00*$lambda/$latency*(1-$elapsed_time/900000.00))}]
    set total_score [expr {$total_score+$score}]
    puts "SCORE: $score"

    puts ""

    set start_time [clock milliseconds]
    set list_result [brave_opt -total_area 500]
    set end_time [clock milliseconds]
    set elapsed_time [expr {$end_time-$start_time}]
    puts "Time: $elapsed_time"

    set schedule [lindex $list_result 0]
    set fu [lindex $list_result 1]
    set res_info [lindex $list_result 2]
    set latency [lindex $list_result 3]

    puts "Resources used: $res_info"
    puts "Latency: $latency"

    set lambda [calculate_lambda]

    set score [expr {(100.00*$lambda/$latency*(1-$elapsed_time/900000.00))}]
    set total_score [expr {$total_score+$score}]
    puts "SCORE: $score"

    return $total_score
}

set total_score 0.0

remove_design
puts "read_design ./data/DFGs/fir.dot"
read_design ./data/DFGs/fir.dot

set score [calculate_time]
set total_score [expr {$total_score+$score}]

puts ""
puts ""

remove_design
puts "read_design ./data/DFGs/collapse_pyr_dfg__113.dot"
read_design ./data/DFGs/collapse_pyr_dfg__113.dot

set score [calculate_time]
set total_score [expr {$total_score+$score}]

puts ""
puts ""

remove_design
puts "read_design ./data/DFGs/motion_vectors_dfg__7.dot"
read_design ./data/DFGs/motion_vectors_dfg__7.dot

set score [calculate_time]
set total_score [expr {$total_score+$score}]

puts ""
puts ""

puts ""
puts "TOTAL SCORE: $total_score"