# source ./tcl_scripts/setenv.tcl ; read_design ./data/DFGs/fir.dot ; read_library ./data/RTL_libraries/RTL_library_multi-resources.txt
source ./brave.tcl

proc print_scheduling {schedule fu} {

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
        set end_time [expr {$start_time+$fu_delay}]
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

proc calculate_time {area} {
    set total_score 0.0

    set start_time [clock milliseconds]
    set list_result [brave_opt -total_area $area]
    set end_time [clock milliseconds]
    set elapsed_time [expr {$end_time-$start_time}]
    puts "Time: $elapsed_time"

    set schedule [lindex $list_result 0]
    set fu [lindex $list_result 1]
    set res_info [lindex $list_result 2]
    set latency [lindex $list_result 3]
    
    puts "Resources used: $res_info"
    puts "Latency: $latency"
    puts "[llength [get_nodes]] vs [llength $schedule]"
    # print_scheduling $schedule $fu
    set lambda [calculate_lambda]

    set score [expr {(100.00*$lambda/($latency-1)*(1-$elapsed_time/900000.00))}]
    set total_score [expr {$total_score+$score}]
    puts "SCORE: $score"
    puts ""

    # set start_time [clock milliseconds]
    # set list_result [brave_opt -total_area 2125]
    # set end_time [clock milliseconds]
    # set elapsed_time [expr {$end_time-$start_time}]
    # puts "Time: $elapsed_time"
    # set schedule [lindex $list_result 0]
    # set fu [lindex $list_result 1]
    # set res_info [lindex $list_result 2]
    # set latency [lindex $list_result 3]

    # puts "Resources used: $res_info"
    # puts "Latency: $latency"

    # set lambda [calculate_lambda]

    # set score [expr {(100.00*$lambda/$latency*(1-$elapsed_time/900000.00))}]
    # set total_score [expr {$total_score+$score}]
    # puts "SCORE: $score"

    return $total_score
}

set total_score 0.0

remove_design
puts "read_design ./data/DFGs/arf.dot"
read_design ./data/DFGs/arf.dot

set score [calculate_time 179]
set total_score [expr {$total_score+$score}]

# puts ""
# puts ""

# remove_design
# puts "read_design ./data/DFGs/idctcol_dfg__3.dot"
# read_design ./data/DFGs/idctcol_dfg__3.dot

# set score [calculate_time 90]
# set total_score [expr {$total_score+$score}]

# puts ""
# puts ""

# remove_design
# puts "read_design ./data/DFGs/smooth_color_z_triangle_dfg__31.dot"
# read_design ./data/DFGs/smooth_color_z_triangle_dfg__31.dot

# set score [calculate_time 372]
# set total_score [expr {$total_score+$score}]

# puts ""
# puts ""

# remove_design
# puts "read_design ./data/DFGs/collapse_pyr_dfg__113.dot"
# read_design ./data/DFGs/collapse_pyr_dfg__113.dot

# set score [calculate_time]
# set total_score [expr {$total_score+$score}]

# puts ""
# puts ""

# remove_design
# puts "read_design ./data/DFGs/motion_vectors_dfg__7.dot"
# read_design ./data/DFGs/motion_vectors_dfg__7.dot

# set score [calculate_time]
# set total_score [expr {$total_score+$score}]

# puts ""
# puts ""

# remove_design
# puts "read_design ./data/DFGs/arf.dot"
# read_design ./data/DFGs/arf.dot

# set score [calculate_time]
# set total_score [expr {$total_score+$score}]

# puts ""
# puts ""

# remove_design
# puts "read_design ./data/DFGs/ewf.dot"
# read_design ./data/DFGs/ewf.dot

# set score [calculate_time]
# set total_score [expr {$total_score+$score}]

# puts ""
# puts ""

# remove_design
# puts "read_design ./data/DFGs/feedback_points_dfg__7.dot"
# read_design ./data/DFGs/feedback_points_dfg__7.dot

# set score [calculate_time]
# set total_score [expr {$total_score+$score}]

# puts ""
# puts ""

# remove_design
# puts "read_design ./data/DFGs/h2v2_smooth_downsample_dfg__6.dot"
# read_design ./data/DFGs/h2v2_smooth_downsample_dfg__6.dot

# set score [calculate_time]
# set total_score [expr {$total_score+$score}]

# puts ""
# puts ""

# remove_design
# puts "read_design ./data/DFGs/horner_bezier_surf_dfg__12.dot"
# read_design ./data/DFGs/horner_bezier_surf_dfg__12.dot

# set score [calculate_time]
# set total_score [expr {$total_score+$score}]

# puts ""
# puts ""

# remove_design
# puts "read_design ./data/DFGs/idctcol_dfg__3.dot"
# read_design ./data/DFGs/idctcol_dfg__3.dot

# set score [calculate_time]
# set total_score [expr {$total_score+$score}]

# puts ""
# puts ""

# remove_design
# puts "read_design ./data/DFGs/interpolate_aux_dfg__12.dot"
# read_design ./data/DFGs/interpolate_aux_dfg__12.dot

# set score [calculate_time]
# set total_score [expr {$total_score+$score}]

# puts ""
# puts ""

# remove_design
# puts "read_design ./data/DFGs/invert_matrix_general_dfg__3.dot"
# read_design ./data/DFGs/invert_matrix_general_dfg__3.dot

# set score [calculate_time]
# set total_score [expr {$total_score+$score}]

# puts ""
# puts ""

# remove_design
# puts "read_design ./data/DFGs/jpeg_fdct_islow_dfg__6.dot"
# read_design ./data/DFGs/jpeg_fdct_islow_dfg__6.dot

# set score [calculate_time]
# set total_score [expr {$total_score+$score}]

# puts ""
# puts ""

# remove_design
# puts "read_design ./data/DFGs/jpeg_idct_ifast_dfg__6.dot"
# read_design ./data/DFGs/jpeg_idct_ifast_dfg__6.dot

# set score [calculate_time]
# set total_score [expr {$total_score+$score}]

# puts ""
# puts ""

# remove_design
# puts "read_design ./data/DFGs/matmul_dfg__3.dot"
# read_design ./data/DFGs/matmul_dfg__3.dot

# set score [calculate_time]
# set total_score [expr {$total_score+$score}]

# puts ""
# puts ""

# remove_design
# puts "read_design ./data/DFGs/smooth_color_z_triangle_dfg__31.dot"
# read_design ./data/DFGs/smooth_color_z_triangle_dfg__31.dot

# set score [calculate_time]
# set total_score [expr {$total_score+$score}]

# puts ""
# puts ""

# remove_design
# puts "read_design ./data/DFGs/write_bmp_header_dfg__7.dot"
# read_design ./data/DFGs/write_bmp_header_dfg__7.dot

# set score [calculate_time]
# set total_score [expr {$total_score+$score}]

# puts ""
# puts ""

puts ""
puts "TOTAL SCORE: $total_score"