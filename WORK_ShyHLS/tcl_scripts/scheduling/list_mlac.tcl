proc list_mlac {res_info} {
   
    set node_start_time [list]
    set resources_cnt [list]
    set latency 0

    # scheduled each node
    foreach node [get_sorted_nodes] {
        set start_time 1
        # find the last scheduled parents and define the start time
        foreach parent [get_attribute $node parents] {
            set parent_op [get_attribute $parent operation]
            set fu [get_lib_fu_from_op $parent_op]
            # find delay parents operation
            set parent_delay [get_attribute $fu delay]
            # find start time parents scheduled
            set idx_parent_start [lsearch -index 0 $node_start_time $parent]
            set parent_start_time [lindex [lindex $node_start_time $idx_parent_start] 1]
            # parse end time parents
            set parent_end_time [expr $parent_start_time + $parent_delay]

            # find the correct start time after scheduled last parent 
            if { $parent_end_time > $start_time } {
                # value just after scheduling parent
                set start_time $parent_end_time
            }
        }

        # if time scheduled has been parse, otherwise add it
        if { [llength $resources_cnt] < $start_time } {
            # add
            lappend resources_cnt $res_info
        }

        # see what operaion has to been performed
        set node_op [get_attribute $node operation]
        # find duration of operation
        set fu [get_lib_fu_from_op $node_op]
        set node_delay [get_attribute $fu delay]
        
        set flag 0
        
        # untill find a moment when resources is nedded
        while { $flag == 0 } {
            # select the instance of time when perfomed the operation
            set inst_op [lindex $resources_cnt [expr $start_time - 1]]
            set idx_op [lsearch -index 0 $inst_op $node_op]
            # select the aviability of the resource that want be used
            set avb_op [lindex $inst_op $idx_op]
            # select just occurences
            set occ_op [lindex $avb_op 1]

            if { $occ_op == 0 } {
                # non resources avaiable, repet all operations to find a slot
                incr start_time
            } else {

                set start 0
                while { $node_delay != $start } {
                    # select the instance of time to upgrade
                    set time [expr $start_time + $start]
                    # if time scheduled has been parse once, otherwise add it
                    if { [llength $resources_cnt] < $time } {
                        lappend resources_cnt $res_info
                    }
                    # select the instance of time when perfomed the operation
                    set inst_op [lindex $resources_cnt [expr $time - 1]]
                    set idx_op [lsearch -index 0 $inst_op $node_op]
                    # select the aviability of the resource that want be used
                    set avb_op [lindex $inst_op $idx_op]
                    # select just occurence
                    set occ_op [lindex $avb_op 1]
                    # upgrade occurance
                    set newItem {}
                    lappend newItem $node_op
                    lappend newItem [expr $occ_op -1]
                    set inst_op [lreplace $inst_op $idx_op  $idx_op $newItem]
                    set resources_cnt [lreplace $resources_cnt [expr $time - 1] [expr $time - 1] $inst_op]
                    incr start
                }
                set flag 1;
            }
        }
        lappend node_start_time "$node $start_time"
        if { [expr $start_time + $node_delay ] > $latency } {
            set latency [expr $start_time + $node_delay ]
        }
    }

    set myList {}
    lappend myList $node_start_time
    lappend myList $latency
    return $myList

}