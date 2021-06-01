

proc repeated_comb {area} {
  source ./tcl_scripts/setenv.tcl
  read_design ./data/DFGs/fir.dot
  read_library ./data/RTL_libraries/RTL_library_multi-resources.txt
  set nodes [get_nodes]
  set list_node_op 0
  set count_operation 0
  set tot_operations 0

  #count of all the operation and preparation of the list of fu for each operation
  #--------------------------------PRIMA PARTE------------------------------
  foreach element $nodes {
    #take from the nodes the operation
    set node_operation [get_attribute $element operation]
    #if lsearch dont match the operation return -1
    #take all the fu that perform that operation
    set index [lsearch $list_node_op $node_operation]
    if { $index == -1 } {
      #count of operation
      lappend count_operation 1
      lappend list_node_op $node_operation
    } else {
        set dec [lindex $count_operation $index ]
        incr dec
        set count_operation [lreplace $count_operation $index $index $dec]
    }
    incr tot_operations
  }

  set list_node_op [lreplace $list_node_op 0 0] ; # all operation
  set count_operation [lreplace $count_operation 0 0] ; # how many for each operation

  puts "Total operation: $tot_operations"

  #----------------------------FINE PRIMA PARTE---------------------------------
  #count_operation contain the occurrence of the operation
  #fu_operation contain all the fu for that operation 
  #------------------------ SECONDA PARTE----------------------------------
  #iterate for each operation
  for {set i 0} {$i < [llength $count_operation]} {incr i} {
    set final_comb 0
    set final 0
    set vett [list]
    set fus [get_lib_fus_from_op [lindex $list_node_op $i]]
    set leng [llength $fus]
    set count_operation_operation [lindex $count_operation $i]
    set memory_needed [expr {(($area+0.0)/$tot_operations)*$count_operation_operation}]
    puts "$fus - $leng => $count_operation_operation ($memory_needed on $area)"

    #vector of tot zeros, one for each fu
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
    # set vett [lreplace $vett 0 0]
    puts $fus_area

    set index 0
    set sum 0
    set comb_operation 0

    # finish of the combination when the last element reach the maximum number of that operation
    while { [lindex $vett end] != $count_operation_operation} {

      if { [lindex $vett end] != 0} {
        set verify_in [llength $vett]
        incr verify_in -2
        set flag 0
        #deve andare nel primo diverso da 0
        while {$verify_in >= 0 && $flag == 0 } {
          #if exist at least an element != 0 set the flag
          if { [lindex $vett $verify_in] != 0} {
            set flag 1
            set index $verify_in
          }
          incr verify_in -1
        }
        #sum=sum-vett[end]
        incr sum -[lindex $vett end]
        #vett[end]=0
        set vett [lreplace $vett end end 0]  
      }

      for {set in $index } {$in <$leng } {incr in } {
        #verify that all the element after in are all 0
        set verify_in $in
        incr verify_in
        set flag 0
        while {$verify_in < $leng && $flag == 0 } {
          #if exist at least an element != 0 set the flag
          if { [lindex $vett $verify_in] != 0} {
            set flag 1
          }
          incr verify_in
        }
        #if there is all 0 after the in the flag=0
        #if vett[in]!=0 && allvett after ==0
        if {[lindex $vett $in] !=0 && $flag == 0} {
          #decrement sum
          incr sum -1
          #decrement vett[in]
          set dec [lindex $vett $in] 
          incr dec -1
          set vett [lreplace $vett $in $in $dec]
        } elseif {$sum < [lindex $count_operation $i ]} {
          #if the sum is less than the number of operation for each fu
          #vett[in] take all the rest of the operation 
          set dec [lindex $count_operation $i ]
          incr dec -$sum
          set sum [lindex $count_operation $i ]
          set vett [lreplace $vett $in $in $dec]
        }
        
      }

      set in 0
      #set all the combination of the single operation in a variable
      set comb_unique 0
      foreach element [get_lib_fus_from_op [lindex $list_node_op $i]] {
        #set the fu and the occurrence in the vect comb_unique if the occurrence is != 0 
        set occur [lindex $vett $in]
        # if {$occur != 0} {
          set fu_occ $element
          lappend fu_occ $occur
          lappend comb_unique $fu_occ
        # }
        incr in
      }
      set comb_unique [lreplace $comb_unique 0 0]

      set area_comb 0
      foreach var $comb_unique {
        set fu_unit [lindex $var 0]
        set fu_occurency [lindex $var 1]
        set fu_area [lindex [lindex $fus_area [lsearch -index 0 $fus_area $fu_unit]] 1]
        incr area_comb [expr {$fu_area * $fu_occurency}]
      }

      if {$area_comb < $memory_needed} {
        puts "$comb_unique - $area_comb"

        #the vector comb unique contain all the fu and occurrence
        lappend comb_operation $comb_unique
        incr final_comb
      }

      incr final
    }

    #set all the combination in a variable
    set comb_operation [lreplace $comb_operation 0 0]
    lappend comb_general $comb_operation
    puts "Tot combinazioni: $final_comb vs $final"
  }

  set comb_general [lreplace $comb_general 0 0]
#------------------------------FINE SECONDA PARTE-----------------------------------------------
#OTTENGO UNA LISTA DI ELEMENTI, OGNI ELEMENTO è UNA LISTA DI COMBINAZIONI PER OGNI OPERAZIONE
#comb_general contiene tutte le combinazioni per ogni operazione, adesso bisogna combinare questi elementi di ogni lista 
#comb general è una lista di liste di combinazioni per ogni operazione
#------------------------------ INIZIO TERZA PARTE-------------------------------------------
  #  set the index of the operand
  set vett [list]
  set verif_comb [list]
  set lung [llength $comb_general]
  #create the instance of comb to verify verif_comb
  for {set i 0} {$i < $lung} {incr i} {
    if {$i == 0} {
      lappend vett -1
    } else {
      lappend vett 0
    }
    lappend verif_comb [lindex [lindex $comb_general $i] 0]
    # puts [lindex $comb_general $i]
    puts [llength [lindex $comb_general $i]]
  }

  # set verif_comb [list]
  #the vector begin with 000--000-1
  set flag 1
  set final 0
  
  while {$flag == 0} {
    set index 0
    #check condition and exit from the cycle
    #if all the vett have reach the maximum exit with flag=1
    while {[lindex $vett $index] == [expr {[llength [lindex $comb_general $index]]-1}]} {
        incr index
        if {$index == [llength $comb_general]} {
          set flag 1 
        }
    }

    # if {[lindex $vett $index] == 50} {break;}

    if {$flag == 0} {
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
      puts "$verif_comb - $vett"
      puts $final
      incr final
    }
  }
#-------------------------------FINE TERZA PARTE---------------------------------
}