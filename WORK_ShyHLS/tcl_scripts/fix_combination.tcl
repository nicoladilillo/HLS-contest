

proc repeated_comb {} {
  source ./tcl_scripts/setenv.tcl
  read_design ./data/DFGs/fir.dot
  read_library ./data/RTL_libraries/RTL_library_multi-resources.txt
  set nodes [get_nodes]
  set list_node_op 0
  set count_operation 0
#count of all the operation and preparation of the list of fu for each operation
#--------------------------------PRIMA PARTE------------------------------
  foreach element $nodes {
    #take from the nodes the operation
    set node_operation [get_attribute $element operation]
    #if lsearch dont match the operation return -1
    #take all the fu that perform that operation
    set index [lsearch $list_node_op $node_operation]
    if { $index == -1} {
      #count of operation
      lappend count_operation 1
      lappend list_node_op $node_operation
    } else {
        set dec [lindex $count_operation $index ]
        incr dec
        set count_operation [lreplace $count_operation $index $index $dec]
    }
  }
  set list_node_op [lreplace $list_node_op 0 0]
  set count_operation [lreplace $count_operation 0 0]
  #----------------------------FINE PRIMA PARTE---------------------------------
  #count_operation contain the occurrence of the operation
  #fu_operation contain all the fu for that operation 
  #------------------------ SECONDA PARTE----------------------------------
  #iterate for each operation
  for {set i 0} {$i < [llength $count_operation]} {incr i} {
    set vett 0
    set leng [llength [get_lib_fus_from_op [lindex $list_node_op $i]]]
    #vector of tot zeros, one for each fu
    for {set j 1} {$j < $leng} {incr j} {
      #set the vector that we use to make the combination
      lappend vett 0
    }
    set index 0
    set sum 0
    set comb_operation 0
    #finish of the combination when the last element reach the maximum number of that operation
    while { [lindex $vett end] != [lindex $count_operation $i]} {
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
        if {$occur != 0} {
          set fu_occ $element
          lappend fu_occ $occur
          lappend comb_unique $fu_occ
        }
        incr in
      }
      set comb_unique [lreplace $comb_unique 0 0]
      #the vector comb unique contain all the fu and occurrence
      lappend comb_operation $comb_unique
    }
    #set all the combination in a variable
    set comb_operation [lreplace $comb_operation 0 0]
    lappend comb_general $comb_operation
  }

#------------------------------FINE SECONDA PARTE-----------------------------------------------
#OTTENGO UNA LISTA DI ELEMENTI, OGNI ELEMENTO è UNA LISTA DI COMBINAZIONI PER OGNI OPERAZIONE
#comb_general contiene tutte le combinazioni per ogni operazione, adesso bisogna combinare questi elementi di ogni lista 
#comb general è una lista di liste di combinazioni per ogni operazione
#------------------------------ INIZIO TERZA PARTE-------------------------------------------
  #setto gli indici di tutti gli operandi
  set vett 0
  for {set i 1} {$i < [llength $comb_general]} {incr i} {
    lappend vett 0
  }
  set flag 0
  while {flag ==0} {
  #prendo tot indici uno per ogni operazione
    for {set i 0} {$i < [llength $comb_general]} {incr i} {
      #seleziono le combinazioni per ogni operazione
        
    }
    #verify it is the last combination
    set i 0
    set flag 1
    while {flag == 1 && $i < [llength $comb_general]} {
      if {[lindex $vett $i] != [llength [lindex $comb_general $i]]} {
        set flag 0
      }
    }
  }
#-------------------------------FINE TERZA PARTE---------------------------------
}