##########################################################################
### TO DO try to divide node in subset for type of operation #############       
##########################################################################
source ./tcl_scripts/scheduling/mobility.tcl

proc list_mlac {res_info} {
    set filename "output.txt"
    set fp [open $filename "w"]
    set data "ciao"
    puts -nonewline $fp $data

    # RETURN PARAMETER
    # list of node and assign start time: <node, start_time>
    set node_start_time [list]
    # list of node and assign fu: <node, fu>
    set node_fu [list]
    # latency total
    set latency 0

    # WORKING PARAMETER
    #all nodes gets in sorted way
    set  all_nodes [get_sorted_nodes] 
    # use to see amount of resources avaiable
    set resources_cnt [list]
    # mobility for each node
    set nodes_mobility [mobility]

    #group fus for operation
    set operations [list]
    foreach operation $res_info {
        set operation [lindex $operation 0]
        # puts $operation
        set op [get_attribute $operation operation]
        # puts $op
        set position [lsearch -index 0 $operations $op]
        # puts $position
        if { $position == -1 } {
            set app [list]
            lappend app $op
            lappend app $operation
            lappend operations $app
        } else {
            set fu [lindex [lindex $operations $position] 1]
            # puts $fu
            lappend fu $operation
            set app [list]
            lappend app $op
            lappend app $fu
            set operations [lreplace $operations $position $position $app]
        }
    }

    # print all possible group created
    foreach cell $operations {
        puts $cell
    }

    set done 1
    # untill all node are scheduled
    while {$done} {
        foreach opeation_group $operations {

            # LOOKINF FOR NODE TAHT CAN BE SCHEDULED WITH THIS OPERATION

            # starting at each cycle
            set operation [lindex $opeation_group 0]
            set fus [lindex $opeation_group 1]
            set nodes_to_schedule [list]
            set node_and_mobility [list]

            puts "*****"
            puts "OPERATION: $operation"

            ##########################################################################
            ### TO DO check if, when some node can't be scheduled, for can carry on ##       
            ##########################################################################
            foreach node $all_nodes {
                set operation_node [get_attribute $node operation]
                
                # same operation considered in the current for
                if { [string first $operation_node $operation] == 0 } {
                    set flag 1
                    # lookig for node with all parents scheduled
                    foreach parent [get_attribute $node parents] {
                        set position [lsearch -index 0 $node_start_time $parent]
                        if { $position == -1 } {
                            # means that some parents must be still scheduled
                            set flag 0
                            break
                        } else {
                            ### TO DO list of end delay
                            set parent_delay [get_attribute [lindex [lindex $node_fu $position] 1] delay] ; # get delay parent
                            set parent_start_time [lindex [lindex $node_start_time $position] 1] ; # get start time parent
                            if { [expr $parent_delay + $parent_start_time] >= $latency} {
                                # means that some parents must be still scheduled
                                set flag 0
                                break
                            }
                        }
                    }

                    if { $flag == 1 } {
                        # schedule node if all parents are schedule
                        set position [lsearch -index 0 $all_nodes $node]
                        lappend nodes_to_schedule $node
                    }
                }
            }

            # BINDING OPERATIONS

            # order nodes according mobility value of each node
            foreach node $nodes_to_schedule {
                set position [lsearch -index 0 $nodes_mobility $node]
                set app [lindex $nodes_mobility $position]
                lappend node_and_mobility $app
            }
            set node_and_mobility [lsort -index 1 -integer $node_and_mobility]
            puts "node: $node_and_mobility"

            # check avaiable resources
            set avaiable_resources [lindex $resources_cnt $latency]
            if { [string length $avaiable_resources] == 0} {
                puts "Allocate new"
                lappend resources_cnt $res_info
                set avaiable_resources [lindex $resources_cnt $latency]
            }

            # all fu dedicated avaiable in that moment
            foreach fu $fus {
                # if empty list of node to schedule
                if {[llength $node_and_mobility] == 0} {
                   break
                }
                set position [lsearch -index 0 $avaiable_resources $fu] ; # position of fu
                set occurency [lindex [lindex $avaiable_resources $position] 1] ; # occurency of fu
                set fu_delay [get_attribute $fu delay]
                puts "FU:$fus - LATENCY: $latency - DELAY: $fu_delay - OCC.: $occurency"

                # iterate untile more that zero occurency are avaiable
                while { $occurency > 0 } {
                    
                    # schedule node starting from lower mobility
                    set node_to_schedule [lindex [lindex $node_and_mobility 0] 0]
                    puts "node to schedule $node_to_schedule"
                    # puts "node and mobility before: $node_and_mobility"
                    set node_and_mobility [lreplace $node_and_mobility 0 0]
                    # puts "node and mobility after: $node_and_mobility"
                    set position_all_nodes [lsearch $all_nodes $node_to_schedule]
                    # puts "before --> $all_nodes"
                    set all_nodes [lreplace $all_nodes $position_all_nodes $position_all_nodes]
                    # puts "after --> $all_nodes"

                    set app [list]
                    lappend app $node_to_schedule
                    lappend app $latency
                    lappend node_start_time $app
                    
                    set app [list]
                    lappend app $node_to_schedule
                    lappend app $fu
                    lappend node_fu $app

                    # upgrade future occurency of fu
                    set i 1
                    while {$i < $fu_delay} {
                        set time [expr $latency+$i]

                        # check avaiable resources
                        set avaiable_resources_1 [lindex $resources_cnt $time]
                        if { [string length $avaiable_resources_1] == 0} {
                            puts "allocate new for future"
                            lappend resources_cnt $res_info
                            # set avaiable_resources_1 [lindex $resources_cnt $time]
                            set avaiable_resources_1 $res_info
                        }

                        set occurency_future [lindex [lindex $avaiable_resources_1 $position] 1] ; # occurency of fu
                        incr occurency_future -1 ; #decrement occurency

                        set app [list]
                        lappend app $fu
                        lappend app $occurency_future
                        set avaiable_resources_1 [lreplace $avaiable_resources_1 $position $position $app]
                        puts "after res. av.(time $time): $avaiable_resources_1"
                        set resources_cnt [lreplace $resources_cnt $time $time $avaiable_resources_1]

                        incr i 1
                    }
                    

                    incr occurency -1

                    #sequence of code not nedded maybe
                    set app [list]
                    lappend app $fu
                    lappend app $occurency
                    set avaiable_resources [lreplace $avaiable_resources $position $position $app]

                    # if empty list of node to schedule
                    if {[llength $node_and_mobility] == 0} {
                        break
                    }
                }
                
                set resources_cnt [lreplace $resources_cnt $latency $latency $avaiable_resources]
            }    
        }

        # check if all nodes have been scheduled
        if {[llength $all_nodes] == 0} {
            set done 0 ; # end
            incr latency $fu_delay ; # increment latancy with delay of last node
        } else {
            incr latency
        }
    }
   

    set myList {}
    lappend myList $node_start_time
    lappend myList $node_fu
    lappend myList $latency
    return $myList

}