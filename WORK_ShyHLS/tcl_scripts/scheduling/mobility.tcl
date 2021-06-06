################################################################################
### TO DO try make ASAP with slowest fu and ALAP with fastest, and viceversa ###      
################################################################################

source ./tcl_scripts/scheduling/asap.tcl
source ./tcl_scripts/scheduling/alap.tcl

proc mobility {} {

    set asap_schedule [asap]

    # find minimum lambda
    set pair [lindex $asap_schedule end]
    set node_id [lindex $pair 0]
    set start_time [lindex $pair 1]
    set node_operation [get_attribute $node_id operation]
    set fu [get_lib_fu_from_op $node_operation]
    set delay_operation [get_attribute $fu delay]
    set lambda [expr $start_time + $delay_operation]

    # puts $lambda

    set alap_schedule [alap $lambda]
    # foreach pair $alap_schedule {
    #     set node_id [lindex $pair 0]
    #     set start_time [lindex $pair 1]
    #     puts "Node: $node_id starts @ $start_time"
    # }

    set mobility_result [list]
    foreach pair $asap_schedule {
        set node_id [lindex $pair 0]
        set asap_time [lindex $pair 1]
        set position [lsearch -index 0 $alap_schedule $node_id]
        set alap_time [lindex [lindex $alap_schedule $position] 1]
        set mobility [expr $alap_time-$asap_time]
        set app [list]
        lappend app $node_id
        lappend app $mobility
        lappend mobility_result $app
        # puts "$node_id @mobility $mobility = $alap_time - $asap_time"
    }

    return $mobility_result
}