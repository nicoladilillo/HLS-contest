#dont need any attributes because the list of node and fu is global
#source ./tcl_scripts/setenv.tcl
#read_design ./data/DFGs/fir.dot
#nodes vector of nodes
#vett_index lung= lung nodes 
#soluz vector of temporary solution
#better_soluz the best of the solution
#vett_fu vector of all fu

proc repeated_comb {} {
  source ./tcl_scripts/setenv.tcl
  read_design ./data/DFGs/fir.dot
  read_library ./data/RTL_libraries/RTL_library_multi-resources.txt
  set nodes [get_nodes]
  set list_node 0
#count of all the operation and preparation of the list of fu for each operation
  foreach element $nodes {
    #take from the nodes the operation
    set node_operation [get_attribute $element operation]
    #if lsearch dont match the operation return -1
    #take all the fu that perform that operation
    set index [lsearch $list_node $node_operation]
    if { $index == -1} {
      #count of operation
      lappend count_operation 1
      lappend list_node_op $node_operation
    } else {
      incr [lindex $count_operation $index]
    }
  }
  #count_operation contain the occurrence of the operation
  #fu_operation contain all the fu for that operation 
  for {set i 0} {$i<[llength $count_operation]} {incr i} {
    set leng [llength [get_lib_fus_from_op [lindex $list_node_op $i]]]
    for {set j 0} {$j<$leng} {incr j} {
      #set the vector that we use to make the combination
      lappend vett 0
    }
    set index -1
    set sum 0
    #while used for iterate to take all the combination (while the combination dont finish: the last element is = to the maximum)
    while { [lindex $vett end] != [lindex $count_operation end]} }
      if { [lindex $vett end] != 0} {
        # UNICO PROBLEMA SE (-1)%N NON DA 0 allora qui bisogna cambiare!!!!!!!!!
        incr index
        #sum=sum-vett[end] VERIFICARE SE SUCCEDE
        incr sum (-[lindex $vett end])
        #vett[end]=0
        set vett [lreplace $vett end end 0]    
      }
      #in=index%(length(fu_operation)-1) DA VERIFICARE CHE SI POSSA FARE
      for {set in ((($index)% $leng) -1)} {$in <$leng } {incr in } {
        #verify that all the element after in are all 0
        set verify_in $in
        incr verify_in
        set flag 0
        while {$verify_in < $length } {
          #if exist at least an element != 0 set the flag
          if { [lindex $vett $verify_in] != 0} {
            set flag 1
            #VERIFICARE SE ESCE DAL CICLO
            break
          }
          incr verify_in
        }
        #if there is all 0 after the in the flag=0
        #if vett[in]!=0 && allvett after ==0
        if {[lindex $vett $in] !=0 && $flag == 0} {
          #decrement sum
          incr sum (-1)
          #decrement vett[in]
          set dec [lindex $vett $in] 
          incr dec (-1)
          set vett [lreplace $vett $in $in $dec]
        } elseif {$sum < [lindex $count_operation $i ]} {
          #if the sum is less than the number of operation for each fu
          #vett[in] take all the rest of the operation 
          set dec [lindex $count_operation $i ]
          incr dec (- $sum)
          set $sum [lindex $count_operation $i ]
          set vett [lreplace $vett $in $in $dec]
        }
      }
      set in 0
      #set all the combination of the single operation in a variable
      foreach element [get_lib_fus_from_op [lindex $list_node_op $i]] {
        #set the fu and the occurrence in the vect comb_unique if the occurrence is != 0 
        if {[lindex $vett $in] != 0} {
          set fu_occ $element
          lappend fu_occ [lindex $vett $in]
          lappend comb_unique $fu_occ
        }
        incr in
      }
      #the vector comb unique contain all the fu and occurrence
      lappend comb_operation $comb_unique
    }
    #set all the combination in a variable
    lappend comb_general $comb_operation
  }
}
#OTTENGO UNA LISTA DI ELEMENTI, OGNI ELEMENTO è UNA LISTA DI COMBINAZIONI PER OGNI OPERAZIONE
#comb_general contiene tutte le combinazioni per ogni operazione, adesso bisogna combinare questi elementi di ogni lista 
#comb general è una lista di liste di combinazioni per ogni operazione
