##########################################################################
### TO DO try to divide node in subset for type of operation #############       
##########################################################################

proc list_mlac {res_info nodes_mobility} {
    # RETURN PARAMETER
    # list of node and assign start time and end time: <node, start_time>
    set node_start_time [list]
    set node_end_time [list]
    # list of node and assign fu: <node, fu>
    set node_fu [list]
    # latency total
    set latency 0

    # WORKING PARAMETER
    # use to see amount of resources avaiable
    set resources_cnt [list]

    # PREEPARING PHASE

    # group fus for operation
    set operations [list]
    foreach operation $res_info {
        set operation [lindex $operation 0]
        set op [get_attribute $operation operation]
        set position [lsearch -index 0 $operations $op]
        if { $position == -1 } {
            set app $op
            lappend app $operation
            lappend operations $app
        } else {
            set fu [lindex [lindex $operations $position] 1]
            # puts $fu
            lappend fu $operation
            set app $op
            lappend app $fu
            set operations [lreplace $operations $position $position $app]
        }
    }
    puts $operations
    # group each node for type of operation
    foreach node [get_nodes] {
        set op [get_attribute $node operation]
        set position [lsearch -index 0 $operations $op]
        set operation [lindex $operations $position]
        set all_node_op [lindex $operation 2]
        lappend all_node_op $node
        set operation [lreplace $operation 2 2 $all_node_op]
        set operations [lreplace $operations $position $position $operation]
    }
    
    # print all possible group created
    foreach cell $operations {
        foreach fu [lindex $cell 1] {
            set op [lindex $cell 0]
            set delay_fu [get_attribute $fu delay]
        }
        set all_node [lindex $cell 2]
        # puts "OPERATION: $op - FU: $fu - DELAY: $delay_fu - NODE: $all_node"
    }

    set done 1
    # untill all node are scheduled
    while {$done} {
        set flag_final 1
        for {set j 0} {$j < [llength $operations]} {incr j} {

            # LOOKINF FOR NODE THAT CAN BE SCHEDULED WITH THIS OPERATION

            # starting at each cycle
            set opeation_group [lindex $operations $j]
            set operation [lindex $opeation_group 0]
            set fus [lindex $opeation_group 1]
            set all_nodes [lindex $opeation_group 2]
            set nodes_to_schedule [lindex $opeation_group 3]

            # puts "*****"
            # puts "OPERATION: $operation"

            set length [llength $all_nodes]
            for {set i 0} {$i < $length} {incr i} {
                set node [lindex $all_nodes $i]    
            
                # same operation considered in the current for
                set flag 1
                # lookig for node with all parents scheduled
                foreach parent [get_attribute $node parents] {
                    set position [lsearch -index 0 $node_start_time $parent]
                    if { $position == -1 } {
                        # means that some parents must be still scheduled
                        # puts "for node $node ($operation) - $parent not still scheduled ($latency)"
                        set flag 0
                        break
                    } else {
                        set parent_end_time [lindex [lindex $node_end_time [lsearch -index 0 $node_end_time $parent]] 1]
                        if {$parent_end_time >= $latency} {
                            # puts "for node $node ($operation) - $parent finish at $parent_end_time ($latency)"
                            # means that some parents must be finish its operation
                            set flag 0
                            break
                        }
                    }
                }

                if { $flag == 1 } {
                    # schedule node if all parents are schedule
                    # add node to list of nodes that can be scheduled
                    set position [lsearch -index 0 $nodes_mobility $node]
                    lappend nodes_to_schedule [lindex $nodes_mobility $position]
                    # delete node in all nodes list
                    set all_nodes [lreplace $all_nodes $i $i]
                    incr i -1
                    incr length -1
                }
            }

            # BINDING OPERATIONS

            # order nodes according mobility value of each node
            if {[llength $nodes_to_schedule] > 0} {
                # puts "NODE ($operation): $nodes_to_schedule - ($latency)"
                set nodes_to_schedule [lsort -index 1 -integer -decreasing $nodes_to_schedule]

                # check avaiable resources
                set avaiable_resources [lindex $resources_cnt $latency]
                if { [string length $avaiable_resources] == 0} {
                    lappend resources_cnt $res_info
                    set avaiable_resources $res_info
                    # puts "Allocate new: $avaiable_resources"
                    # puts "$latency vs [llength $resources_cnt]"
                }

                # all fu dedicated avaiable in that moment
                foreach fu $fus {

                    set position [lsearch -index 0 $avaiable_resources $fu] ; # position of fu
                    set occurency [lindex [lindex $avaiable_resources $position] 1] ; # occurency of fu
                    set fu_delay [get_attribute $fu delay]
                    # puts "FU:$fus - LATENCY: $latency - DELAY: $fu_delay - OCC.: $occurency"

                    # iterate untile more that zero occurency are avaiable
                    while { $occurency > 0 } {
                        # delete node from node to scheduled
                        set node_to_schedule [lindex [lindex $nodes_to_schedule 0] 0]
                        # puts "  remove $node_to_schedule"
                        set nodes_to_schedule [lreplace $nodes_to_schedule 0 0]
                        # puts "node and mobility after: $node_and_mobility"
                        # puts "node to schedule: $node_to_schedule"

                        # assign start time to node
                        set app $node_to_schedule
                        lappend app $latency
                        lappend node_start_time $app
                        
                        # assign fu to node
                        set app $node_to_schedule
                        lappend app $fu
                        lappend node_fu $app

                        # determine end time
                        set app $node_to_schedule
                        lappend app [expr {$latency + $fu_delay -1}]
                        lappend node_end_time $app

                        # upgrade future occurency of fu
                        set k 1
                        while {$k < $fu_delay} {
                            set time [expr {$latency+$k}]

                            # check avaiable resources
                            set avaiable_resources_1 [lindex $resources_cnt $time]
                            if { [string length $avaiable_resources_1] == 0} {
                                # puts "allocate new for future"
                                lappend resources_cnt $res_info
                                # set avaiable_resources_1 [lindex $resources_cnt $time]
                                set avaiable_resources_1 $res_info
                            }

                            set occurency_future [lindex [lindex $avaiable_resources_1 $position] 1] ; # occurency of fu
                            incr occurency_future -1 ; #decrement occurency

                            set app $fu
                            lappend app $occurency_future
                            set avaiable_resources_1 [lreplace $avaiable_resources_1 $position $position $app]
                            # puts "after res. av.(time $time): $avaiable_resources_1"
                            set resources_cnt [lreplace $resources_cnt $time $time $avaiable_resources_1]

                            incr k 1
                        }

                        incr occurency -1

                        # upgrade current occurency of fu
                        set app $fu
                        lappend app $occurency
                        set avaiable_resources [lreplace $avaiable_resources $position $position $app]
                        set resources_cnt [lreplace $resources_cnt $latency $latency $avaiable_resources]

                        # if empty list of node to schedule
                        if {[llength $nodes_to_schedule] == 0} {
                            break
                        }
                    }  

                    # if empty list of node to schedule
                    if {[llength $nodes_to_schedule] == 0} {
                        break
                    }                 
                }
            } 

            set opeation_group [lreplace $opeation_group 2 2 $all_nodes]
            set opeation_group [lreplace $opeation_group 3 3 $nodes_to_schedule]
            set operations [lreplace $operations $j $j $opeation_group]

            # check if all nodes have been scheduled
            if {[llength $all_nodes] > 0} {
                set flag_final 0
                # puts "$latency - $operation - $all_nodes - $nodes_to_schedule"
            }
        }

        if {$flag_final == 1} { 
            set done 0 
        } else {
            incr latency
        }

    }
    
    set latency [llength $resources_cnt]

    set myList [list]
    lappend myList $node_start_time
    lappend myList $node_fu
    lappend myList $latency
    return $myList
}