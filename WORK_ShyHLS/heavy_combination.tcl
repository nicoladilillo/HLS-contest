
proc heavy_repeated_comb {area} {
    source ./tcl_scripts/setenv.tcl
    read_design ./data/DFGs/fir.dot
    read_library ./data/RTL_libraries/RTL_library_multi-resources.txt

    set nodes [get_nodes]
    set list_node_op [list]
    set fus [list]
    set count_operation [list]
    set tot_operations 0

    #-------------------------------------------------------------------------
    #count of all the operation and preparation of the list of fu for each operation
    #--------------------------------PRIMA PARTE------------------------------
    foreach element $nodes {
        # take from the nodes the operation
        set node_operation [get_attribute $element operation]
        # if lsearch dont match the operation return -1
        # take all the fu that perform that operation
        set index [lsearch $list_node_op $node_operation]
        if { $index == -1 } {
            #count of operation
            lappend count_operation 1
            lappend list_node_op $node_operation
            foreach fu [get_lib_fus_from_op $node_operation] {
                lappend fus $fu
            }
        } else {
            set dec [lindex $count_operation $index ]
            incr dec
            set count_operation [lreplace $count_operation $index $index $dec]
        }

        incr tot_operations
    }

    puts $list_node_op
    puts $fus
    puts "Total operation: $tot_operations"

    
    # #----------------------------FINE PRIMA PARTE---------------------------------
    # #count_operation contain the occurrence of the operation
    # #fu_operation contain all the fu for that operation 
    # #------------------------ SECONDA PARTE----------------------------------

    set comb_general [list]
    set final 0
    set leng [llength $fus]
    #max area for each operation
    set memory_needed $area
    

    #vector of tot zeros, one for each fu
    set vett [list]
    set fus_area [list]
    foreach fu $fus {
        #set the vector that we use to make the combination
        lappend vett 0

        set fu_area [get_attribute $fu area]
        set app [list]
        lappend app $fu
        lappend app $fu_area
        lappend fus_area $app
    }
    set fus_area [lsort -integer -decreasing -index 1 $fus_area] 
    puts "$fus - $leng => $tot_operations ($memory_needed on $area)"
    puts $fus_area

    set comb_operation [list]
    set comb_unique [list]
    set area_comb 0

    # set comb_unique
    foreach fu $fus_area {
        set app [list]
        lappend app [lindex $fu 0]
        lappend app 0
        lappend comb_unique $app
    }

    set done 0
    while {$done == 0 } {
        set flag 0
        set index 0

        while { $flag == 0} {
            set fu_area_comb [lindex [lindex $fus_area $index] 1]
            # controllo se posso aggiungere un solo componente
            if { [expr {$fu_area_comb+$area_comb}] <= $memory_needed } {
                # ne inserisco solo uno
                set comb [lindex $comb_unique $index]
                set occ [lindex $comb 1]

                # increment unit of that fu
                set app [list]
                lappend app [lindex $comb 0]
                lappend app [expr {$occ+1} ]
                set comb $app
                set comb_unique [lreplace $comb_unique $index $index $comb]
                
                set area_comb [expr {$area_comb+$fu_area_comb}]

                set flag 1

            } else {
                incr final
                puts "$comb_unique - $area_comb - $final"
                lappend comb_operation $comb_unique

                # non posso inserirlo, azzero tutta la sua istanza
                set comb [lindex $comb_unique $index]
                set occ [lindex $comb 1]
                # area che libero
                set fu_area_tot [expr {$occ*$fu_area_comb}]

                set app [list]
                lappend app [lindex $comb 0]
                set occ 0
                lappend app $occ
                set comb $app
                set comb_unique [lreplace $comb_unique $index $index $comb]
                set area_comb [expr {$area_comb-$fu_area_tot}]
                # provo ad incrementare il prossimo
                incr index
            }
            
            # come capire se sono arrivato alla fine
            if {$index == $leng} {
                set done 1
                set flag 1
            }

        }
    }

    #set all the combination in a variable
    puts "Tot combinazioni: $final"
}