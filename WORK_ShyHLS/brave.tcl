proc asap {} {
  
  
  set node_start_time [list]

  foreach node [get_sorted_nodes] {
    set start_time 1
    foreach parent [get_attribute $node parents] {
      set parent_op [get_attribute $parent operation]
      set fu [lindex [get_lib_fus_from_op $parent_op] 0]
      set parent_delay [get_attribute $fu delay]
      set idx_parent_start [lsearch -index 0 $node_start_time $parent]
      set parent_start_time [lindex [lindex $node_start_time $idx_parent_start] 1]
      set parent_end_time [expr $parent_start_time + $parent_delay]
      if { $parent_end_time > $start_time } {
        set start_time $parent_end_time
      }
    }
    lappend node_start_time "$node $start_time"
  }

  return $node_start_time

}

proc alap {lambda} {
    incr lambda
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

proc mobility {} {

    set asap_schedule [asap]

    # find minimum lambda
    set lambda 0
    foreach pair $asap_schedule {
        set node_id [lindex $pair 0]
        set start_time [lindex $pair 1]
        set node_operation [get_attribute $node_id operation]
        set fu [get_lib_fu_from_op $node_operation]
        set delay_operation [get_attribute $fu delay]
        # puts "Node: $node_id is $node_operation starts @ $start_time + $delay_operation"
        set node_end_time [expr $start_time + $delay_operation]
        if { $lambda < $node_end_time } {
            set lambda $node_end_time
        }
    }

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

proc list_mlac {res_info nodes_mobility fus_delay} {
    # puts $res_info
    # puts $fus_delay
    # RETURN PARAMETER
    # list of node and assign start time and end time: <node, start_time>
    set node_start_time [list]
    set node_end_time [list]
    # list of node and assign fu: <node, fu>
    set node_fu [list]
    # latency total
    set latency 1

    # WORKING PARAMETER

    # PREEPARING PHASE
    set resources_cnt [list]
    lappend resources_cnt $res_info

    # group fus for operation
    set operations [list]
    foreach operation_sel $res_info {
        set operation [lindex $operation_sel 0]
        set op [get_attribute $operation operation]
        set position [lsearch -index 0 $operations $op]
        if { $position == -1 } {
            set app $op
            # puts $operation
            set delay [lindex [lindex $fus_delay [lsearch -index 0 $fus_delay $operation]] 1]
            # puts $delay
            set app_fu "{$operation $delay}"
            lappend app $app_fu
            lappend operations $app
        } else {
            set fu [lindex [lindex $operations $position] 1]
            # puts "before $fu"
            set app $op
            set delay [lindex [lindex $fus_delay [lsearch -index 0 $fus_delay $operation]] 1]
            # puts $delay
            set app_fu "{$operation $delay}"
            lappend fu $app_fu
            lappend app $fu
            set operations [lreplace $operations $position $position $app]
        }
    }
    # puts $operations
    
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
    # foreach cell $operations {
    #     foreach fu [lindex $cell 1] {
    #         set op [lindex $cell 0]
    #         set delay_fu [get_attribute $fu delay]
    #     }
    #     set all_node [lindex $cell 2]
    #     # puts "OPERATION: $op - FU: $fu - DELAY: $delay_fu - NODE: $all_node"
    # }

    set done 1
    set tot_node_number [llength [get_nodes]]
    set tot_node_start_time 0
    # untill all node are scheduled
    while { $done } {
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
                        if {$parent_end_time > $latency} {
                            # puts "for node $node ($operation) - $parent finish at $parent_end_time ($latency)"
                            # means that some parents must be finish its operation
                            set flag 0
                            break
                        }
                    }
                }

                if { $flag } {
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
                set nodes_to_schedule [lsort -index 1 -integer $nodes_to_schedule]
                #puts "NODE ($operation): $nodes_to_schedule - ($latency)"

                # check avaiable resources
                set avaiable_resources [lindex $resources_cnt $latency]
                # puts $avaiable_resources
                if { [string length $avaiable_resources] == 0} {
                    lappend resources_cnt $res_info
                    set avaiable_resources $res_info
                    # puts "Allocate new: $avaiable_resources"
                    # puts "$latency vs [llength $resources_cnt]"
                }

                # all fu dedicated avaiable in that moment
                foreach fu_and_delay $fus {
                    # puts $fu_and_delay
                    set fu [lindex $fu_and_delay 0]
                    set position [lsearch -index 0 $avaiable_resources $fu] ; # position of fu
                    set occurency [lindex [lindex $avaiable_resources $position] 1] ; # occurency of fu
                    set fu_delay [lindex $fu_and_delay 1]
                    # puts "FU:$fus - LATENCY: $latency - DELAY: $fu_delay - OCC.: $occurency"

                    # iterate untile more that zero occurency are avaiable
                    while { $occurency > 0 } {
                        # delete node from node to scheduled
                        set node_to_schedule [lindex [lindex $nodes_to_schedule 0] 0]
                        # puts "  remove $node_to_schedule"
                        set nodes_to_schedule [lreplace $nodes_to_schedule 0 0]
                        # puts "node and mobility after: $node_and_mobility"
                        # puts "node to schedule: $node_to_schedule at $latency"

                        # assign start time to node
                        set app $node_to_schedule
                        lappend app $latency
                        lappend node_start_time $app
                        incr tot_node_start_time
                        
                        # assign fu to node
                        set app $node_to_schedule
                        lappend app $fu
                        lappend node_fu $app

                        # determine end time
                        set app $node_to_schedule
                        lappend app [expr {$latency + $fu_delay}]
                        lappend node_end_time $app

                        # upgrade future occurency of fu
                        set k 1
                        while {$k < $fu_delay} {
                            set time [expr {$latency+$k}]

                            # check avaiable resources
                            set avaiable_resources_1 [lindex $resources_cnt $time]
                            while { [string length $avaiable_resources_1] == 0} {
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
            } else {
                # check avaiable resources
                set avaiable_resources [lindex $resources_cnt $latency]
                if { [string length $avaiable_resources] == 0} {
                    lappend resources_cnt $res_info
                    # puts "Allocate new: $avaiable_resources"
                    # puts "$latency vs [llength $resources_cnt]"
                }
            }

            set opeation_group [lreplace $opeation_group 2 2 $all_nodes]
            set opeation_group [lreplace $opeation_group 3 3 $nodes_to_schedule]
            set operations [lreplace $operations $j $j $opeation_group]

            # check if all nodes have been scheduled
        }

        if {$tot_node_start_time == $tot_node_number} { 
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

proc brave_opt args {
  array set options {-total_area 0}
  if { [llength $args] != 2 } {
    return -code error "Use brave_opt with -total_area \$area_value\$"
  }
  foreach {opt val} $args {
    if {![info exist options($opt)]} {
      return -code error "unknown option \"$opt\""
    }
    set options($opt) $val
  }
  set total_area $options(-total_area)

  puts $total_area

	#################################
	### INSERT YOUR COMMANDS HERE ###
	#################################
    
    set start_time [clock milliseconds]

  set nodes [get_nodes]
  set list_node_op [list]
  set count_operation [list]
  set tot_operations 0
  set best_res_assign 0

  # mobility for each node
  set nodes_mobility [mobility]

  #-------------------------------------------------------------------------
  #count of all the operation and preparation of the list of fu for each operation
  #--------------------------------PRIMA PARTE------------------------------
  set sort_operation [list]
  foreach element $nodes {
    # take from the nodes the operation
    set node_operation [get_attribute $element operation]
    # if lsearch dont match the operation return -1
    # take all the fu that perform that operation
    set index [lsearch -index 1 $sort_operation $node_operation]
    if { $index == -1 } {
      #count of operation
      set app 1
      lappend app $node_operation
      lappend sort_operation $app
    } else {
        set op_dec [lindex $sort_operation $index]
        set dec [lindex $op_dec 0]
        incr dec
        set op_dec [lreplace $op_dec 0 0 $dec]
        set sort_operation [lreplace $sort_operation $index $index $op_dec]
    }
    incr tot_operations
  }
  
  set sort_operation [lsort -index 0  -integer  $sort_operation]
  
  foreach var $sort_operation {
    lappend count_operation [lindex $var 0]
    lappend list_node_op [lindex $var 1]
  }

  # puts $count_operation
  # puts $list_node_op
  
  # puts "Total operation: $tot_operations"

  #----------------------------FINE PRIMA PARTE---------------------------------
  # count_operation contain the occurrence of the operation
  # fu_operation contain all the fu for that operation 
  #------------------------ SECONDA PARTE----------------------------------
  set comb_general [list]
  # set tot_comb 1
  set total_area_app $total_area
  set fus_delay_tot [list]
  #iterate for each operation
  for {set i 0} {$i < [llength $count_operation]} {incr i} {
    # set final 0
    set vett [list]
    set op [lindex $list_node_op $i]
    # order fus due to decreasing area
    set each_fus [get_lib_fus_from_op $op]
    set fus_sort [list] 
    set fus_delay [list] 
    foreach fu $each_fus {
      set app $fu
      lappend app [get_attribute $fu area]
      lappend fus_sort $app
      set app $fu
      lappend app [get_attribute $fu delay]
      lappend fus_delay $app
    }
    set fus [list]
    foreach fu [lsort -index 1 -integer -decreasing $fus_sort] {
      lappend fus [lindex $fu 0]
    }
    foreach fu $fus_delay {
        lappend fus_delay_tot $fu
    }
    set leng [llength $fus]

    # total amount of operation
    set count_operation_operation [lindex $count_operation $i]
    # puts ""
    # puts "$op - $count_operation_operation"
    # puts $fus_sort
    # puts $fus
    # puts $fus_delay

    # vector of tot zeros, one for each fu
    set fus_area [list]
    set area_avg 0
    set v 0
    foreach fu $fus {
      #set the vector that we use to make the combination
      lappend vett 0
      
      set fu_area [get_attribute $fu area]
      set app [list]
      lappend app $fu
      lappend app $fu_area
      lappend fus_area $app

      incr area_avg $fu_area
      incr v
    }
    # puts $fus
		set min_fu_area [lindex [lindex $fus_area end] 1]
    set max_fu_area [lindex [lindex $fus_area 0] 1]
    set area_avg [expr {$area_avg/$v}] ; # avg of fu area
    
		# puts "$fus_area => min($min_fu_area) avg ($area_avg)"
    # caluculate the min and the max number of fu for the corresponding operation
    if {$count_operation_operation <= [expr {$total_area_app/1000.0*5}]} {
      if {$max_fu_area > [expr {$total_area_app/10}] } {
        set memory_needed_max [expr $min_fu_area*$count_operation_operation]
      } else {
        set memory_needed_max [expr $max_fu_area*$count_operation_operation]
      }
      set total_area_app [expr {$total_area_app-$memory_needed_max}]
      set start 1
      set end $count_operation_operation
    } else {
      set memory_needed_max [expr {$total_area_app*$count_operation_operation/$tot_operations*1.3}]

      # critera for allocated memory formulated after tests
      # if {[expr {$total_area_app*$count_operation_operation/$tot_operations*1.3}] > [expr {$total_area_app/2}] && [expr {(0.0+$count_operation_operation)/$tot_operations}] < 0.5} {
      #   set memory_needed_max [expr {$total_area_app*$count_operation_operation/$tot_operations*1.2}]
      # } elseif {[expr {$total_area_app*$count_operation_operation/$tot_operations*1.3}] > [expr {$total_area_app/2}] && [expr {(0.0+$count_operation_operation)/$tot_operations}] < 0.3} { 
      #   set memory_needed_max [expr {$total_area_app*$count_operation_operation/$tot_operations*1.1}]
      # }  elseif {[expr {(0.0+$count_operation_operation)/$tot_operations}] < 0.25} {
      #   set memory_needed_max [expr {$total_area_app*$count_operation_operation/$tot_operations*1.2}]
      # } else {
      #   set memory_needed_max [expr {$total_area_app*$count_operation_operation/$tot_operations*1.3}]
      # }

      set start [expr {$memory_needed_max/$area_avg/2}]
      if { $start < 1 } {
        set start 1
      }
      if { $start > 1 && $start > [expr {$count_operation_operation/4.0}]} {
        set start [expr {$count_operation_operation/4.0}]
        set end [expr {$memory_needed_max/$area_avg}]
        if {$end > [expr $count_operation_operation/10.0*7] } { 
            set end [expr $count_operation_operation/10.0*7]
        } elseif { $end < $start } {
          set end [expr $start*3]
        }
      } else {
        set end [expr {$start*3}]
        if {$end > [expr {$count_operation_operation/3.0*2}]} { 
          set end [expr {$memory_needed_max/$area_avg}]
          if {$end > [expr $count_operation_operation/10.0*7]} { 
            set end [expr $count_operation_operation/10.0*7]
          }
        }
      }
      if {$end <  $start } {
        set end $start
      }

      if {$memory_needed_max < $min_fu_area} {
        set memory_needed_max $min_fu_area
      }
    }
    # min area for combination 
    set min_memory [expr {$memory_needed_max/3*2}]
    if {$min_memory < $min_fu_area || [expr $max_fu_area-$min_fu_area] > $min_fu_area || [expr {$min_memory/$count_operation_operation}] } {
      set min_memory $min_fu_area
    }
    # puts "$fus - $leng => $count_operation_operation ($min_memory-$memory_needed_max on $total_area)"
    # puts "$start to $end"

    set comb_operation [list]
    set comb_unique [list]
    set area_comb 0
    set occ_comb 0

    # set comb_unique
    foreach fu $fus_area {
      set app [list]
      lappend app [lindex $fu 0]
      lappend app 0
      lappend comb_unique $app
    } 
  
    # just one cycle, useless consider value of node lessere than the max
    for {set j $end} {$j <= $end} {incr j} {
      set j [expr int($j)]
      set done 1
      # finish of the combination when the last element reach max area delay
      while { $done } {
        set index 0
        set flag 1

        while { $flag } {
          set fu_area_comb [lindex [lindex $fus_area $index] 1]
          
          if { [expr {$fu_area_comb+$area_comb}] <= $memory_needed_max && $occ_comb < $j} {
            set comb [lindex $comb_unique $index]
            set occ [lindex $comb 1]

            set app [list]
            lappend app [lindex $comb 0]
            lappend app [expr {$occ+1} ]
            set comb $app
            set comb_unique [lreplace $comb_unique $index $index $comb]
            
            set area_comb [expr {$area_comb+$fu_area_comb}]
            incr occ_comb

            set flag 0
          } else {
            set comb [lindex $comb_unique $index]
            set occ [lindex $comb 1]
            # set fu_area_tot [expr {$occ*$fu_area_comb}]
            if {$occ > 0} {
              # area che libero
              set fu_area_tot [expr {$occ*$fu_area_comb}]

              set app [list]
              lappend app [lindex $comb 0]
              lappend app 0
              set comb $app
              set comb_unique [lreplace $comb_unique $index $index $comb]

              set area_comb [expr {$area_comb-$fu_area_tot}]
              incr occ_comb [expr -$occ]
            }

            incr index ; #diverso
          }

          if {$index == $leng} {
            set flag 0 
            set done 0
          }
        }
        
        # puts "$area_comb vs $min_memory"
        if { $area_comb >= $min_memory || $occ_comb == $j} {
          set app $area_comb
          lappend app $comb_unique
          if {[lsearch $comb_operation $comb_unique] == -1} {
            # incr final
            # puts "$app - $final -$j - $occ_comb - $memory_needed_max - $min_fu_area "
            lappend comb_operation $app
          }
        }
      }
    }

    # set all the combination in a variable
    lappend comb_general [lsort -index 0 -integer -dec $comb_operation]

    # foreach comb [lsort -index 0 -integer -dec $comb_operation] {
    #   puts $comb
    # }
    # puts "Tot combinazioni: $final"
    # set tot_comb [expr {$tot_comb*$final}]
  }

  # puts "Combinazioni totali: $tot_comb"

#------------------------------ FINE SECONDA PARTE -----------------------------------------------
#---------------------------------- TERZA PARTE --------------------------------------------------
  # calculated wich is the max value of area that can be reach
  set memory_needed_max_tot 0
  set memory_min 0
  foreach max_comb $comb_general {
    set area_max_comb [lindex [lindex $max_comb 0] 0]
    set area_min_comb  [lindex [lindex $max_comb end] 0]
    set memory_needed_max_tot [expr {$memory_needed_max_tot+$area_max_comb}]
    set memory_min [expr {$memory_min+$area_min_comb}]
  }

  if {$total_area > $memory_needed_max_tot} {
    set total_area $memory_needed_max_tot
  }

  # puts $total_area 

  # set verif_comb [list]
  #the vector begin with 000--000-1
  
  set flag_1 1
  # set final 0

  set remove [expr {$total_area/1000.00*5000}]
  if {$remove < 1000 } {
    set remove 1000
  }
  set percentage 0.99
  set low_boundary [expr {int($total_area*$percentage)}] 
  
  # puts $memory_needed_max_tot
  # puts $memory_min
  # puts $low_boundary  

  set best_latency 10000000
  set return_value [list]

  while { $flag_1 } {
    puts ""
    puts ""
    puts "LOW BOUNDARY: $low_boundary"
    puts "TOTAL AREA: $total_area"
    # max reach before to exit from cycle
    set value [expr {40000*($total_area/1000.00)}]
    if {$value > 40000} { 
      set value 40000 
    } elseif { $value < 20000 } {
      set value 20000 
    }
    # puts $value

    set flag 1
    set same [expr 0.0]

    #  set the index of the operand
    set vett [list]
    set verif_comb [list]
    set lung [llength $comb_general]
    #create the instance of comb to verify verif_comb
    lappend vett -1
    lappend verif_comb [lindex [lindex $comb_general 0] 0]
    for {set i 1} {$i < $lung} {incr i} {
      lappend vett 0
      lappend verif_comb [lindex [lindex $comb_general $i] 0]
      # puts [lindex $comb_general $i]
      # puts [llength [lindex $comb_general $i]]
    }

    while { $flag } {
      set index 0
      #check condition and exit from the cycle
      #if all the vett have reach the maximum exit with flag=1
      while {[lindex $vett $index] == [expr {[llength [lindex $comb_general $index]]-1}]} {
          incr index
          if {$index == [llength $comb_general]} {
            set flag 0
            break
          }
      }
    
      if { $flag } {
        #vett[index]++
        set tmp [lindex $vett $index]
        # upgrade
        incr tmp
        set vett [lreplace $vett $index $index $tmp]
        for {set i [expr $index-1]} {$i >= 0} {incr i -1} {
          set vett [lreplace $vett $i $i 0]
          set verif_comb [lreplace $verif_comb $i $i [lindex [lindex $comb_general $i] 0]]
        }
        set verif_comb [lreplace $verif_comb $index $index [lindex [lindex $comb_general $index] $tmp]]
        
        #VERIFICA!!!
        set fu_comb [list]
        set area 0
        foreach operation $verif_comb {
          # puts "op $operation"
          set area_seq  [lindex $operation 0]
          set op [lindex $operation 1]
          foreach fu $op {
            set occ [lindex $fu 1]
            if {$occ > 0} {
              lappend fu_comb $fu
            } 
          }

          incr area $area_seq
        }

        # limite area superiore e inferiore
        # puts "$area vs $total_area"
        if { $area  < $low_boundary} {
          for {set i [expr $index]} {$i >= 0} {incr i -1} {
            set tmp [expr {[llength [lindex $comb_general $i]]-1}]
            set vett [lreplace $vett $i $i $tmp]
            # set verif_comb [lreplace $verif_comb $i $i [lindex [lindex $comb_general $i] tmp]]
          }

          set same [expr {$same+0.3}]
        } elseif { $area <= $total_area } {
          set flag_1 0
          incr final
          set list_mlac_result [list_mlac $fu_comb $nodes_mobility $fus_delay_tot]
          set latency [lindex $list_mlac_result 2]
          if { $latency < $best_latency } {
            puts ""
            puts "OLD ($best_latency): $best_res_assign"
            puts "NEW ($latency): $fu_comb"
            puts "vett: $vett"
            # puts $value
            puts "$area vs $total_area"
            set best_res_assign $fu_comb
            set best_latency $latency
            set return_value $list_mlac_result
            set value [expr {$value-$remove}]
            set same [expr 0.0]
          } else {
            set same [expr {$same+1.0}]
          }

        } else {
          set same [expr {$same+0.3}]
        }
        
        set end_time [clock milliseconds]
        # puts [expr {$end_time-$start_time}]
        if { $flag_1 == 0 && ($same >= $value || [expr {$end_time-$start_time}] > 240000)} {
            set flag 0
        }
        # puts "$same - $value - $fu_comb - $area - $final - $vett - $best_latency"      
      }
    }

    set percentage [expr {$percentage-0.01}]
    set total_area $low_boundary
    set low_boundary [expr {int($total_area*$percentage)}] 
  }
  #-------------------------------FINE TERZA PARTE---------------------------------

    # puts "Combination used $final on $tot_comb"
    set return_value [lreplace $return_value end end $best_res_assign]
    # incr best_latency
    lappend return_value $best_latency

    return $return_value
}
