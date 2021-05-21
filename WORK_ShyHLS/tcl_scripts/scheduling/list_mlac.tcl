proc list_mlac {res_info} {
   
    #all nodes gets in sorted way
    set  all_nodes [get_sorted_nodes] 
    set node_start_time [list]
    set resources_cnt [list]
    set latency 0

    #group fus for operation
    set operations [list]
    foreach operation $res_info {
        set operation [lindex $operation 0]
        puts $operation
        set op [get_attribute $operation operation]
        puts $op
        set position [lsearch -index 0 $operations $op]
        puts $position
        if { $position == -1 } {
            set app [list]
            lappend app $op
            lappend app $operation
            lappend operations $app
        } else {
            set fu [lindex [lindex $operations $position] 1]
            puts $fu
            lappend fu $operation
            set app [list]
            lappend app $op
            lappend app $fu
            set operations [lreplace $operations $position $position $app]
        }
    }

    # scheduled each node
    foreach resources $operations {
        puts $resources
    }

    set myList {}
    lappend myList $node_start_time
    lappend myList $latency
    return $myList

}