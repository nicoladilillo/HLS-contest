proc alap {lambda} {
    
    set node_start_time [list]

    foreach node [lreverse [get_sorted_nodes]] {
        # get delay of node that we re considering
        set op [get_attribute $node operation]
        set fu [lindex [get_lib_fus_from_op $op] 0]
        set delay [get_attribute $fu delay]

        set start_time [expr $lambda - $delay]
        foreach children [get_attribute $node children] {
            # use the schedule that i have already parse

            # take id of children that has been already scheduled
            set idx_children_start [lsearch -index 0 $node_start_time $children]
            # take value of start time
            set children_start_time [lindex [lindex $node_start_time $idx_children_start] 1]

            if { [expr $start_time + $delay] > $children_start_time } {
                set start_time [expr $children_start_time - $delay]
            }
        }
        lappend node_start_time "$node $start_time"
    }

  return $node_start_time

}