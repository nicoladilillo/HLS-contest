
proc repeated_comb {area} {
  source ./tcl_scripts/setenv.tcl
  read_design ./data/DFGs/fir.dot
  read_library ./data/RTL_libraries/RTL_library_multi-resources.txt

  set nodes [get_nodes]
  set list_node_op [list]
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
    } else {
        set dec [lindex $count_operation $index ]
        incr dec
        set count_operation [lreplace $count_operation $index $index $dec]
    }
    incr tot_operations
  }

  puts "Total operation: $tot_operations"

  #----------------------------FINE PRIMA PARTE---------------------------------
  #count_operation contain the occurrence of the operation
  #fu_operation contain all the fu for that operation 
  #------------------------ SECONDA PARTE----------------------------------
  set comb_general [list]
  #iterate for each operation
  for {set i 0} {$i < [llength $count_operation]} {incr i} {
    set final 0
    set vett [list]
    set fus [get_lib_fus_from_op [lindex $list_node_op $i]]
    set leng [llength $fus]
    set count_operation_operation [lindex $count_operation $i]
    #max area for each operation
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
		set min_fu_area [lindex [lindex $fus_area end] 1]
		puts "$fus_area => min($min_fu_area)"

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
    # finish of the combination when the last element reach max area delay
    while { $done == 0 } {
      set index 0
      set flag 0

      while { $flag == 0 } {
        set fu_area_comb [lindex [lindex $fus_area $index] 1]
        # aggiorna le aree dentro
        if { [expr {$fu_area_comb+$area_comb}] <= $memory_needed } {
          set comb [lindex $comb_unique $index]
          set occ [lindex $comb 1]

          set app [list]
          lappend app [lindex $comb 0]
          lappend app [expr {$occ+1} ]
          set comb $app
          set comb_unique [lreplace $comb_unique $index $index $comb]
          
          set area_comb [expr {$area_comb+$fu_area_comb}]

					set flag 1
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
          }

          incr index ; #diverso
        }

        if {$index == $leng} {
          set flag 1 
          set done 1
        }
      }

			if { [expr {$memory_needed-$area_comb}] < $min_fu_area } {
				incr final
				# puts "$comb_unique - $area_comb - $final"
				lappend comb_operation $comb_unique
			}
    }

    #set all the combination in a variable
    lappend comb_general $comb_operation
    puts "Tot combinazioni: $final"
  }

	return
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
  set flag 0
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