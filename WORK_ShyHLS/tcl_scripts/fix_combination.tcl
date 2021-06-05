

proc repeated_comb { areatot } {
  source ./tcl_scripts/setenv.tcl
  read_design ./data/DFGs/fir.dot
  read_library ./data/RTL_libraries/RTL_library_multi-resources.txt
  set nodes [get_nodes]
  set list_node_op [list] ;#all operation
  set count_operation [list] ;#how many for each operation
  set comb_general [list]
  set fileId [open "prova.txt" "w"]
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
  }
  #---------------------------------prendo la metà dei nodi-----------------------
  for {set i 0} {$i < [llength $count_operation]} {incr i} {
      set count_operation [lreplace $count_operation $i $i [expr {([lindex $count_operation $i]/2) + 1}]]
  }
  puts $count_operation
  #----------------------------FINE PRIMA PARTE---------------------------------
  #count_operation contain the occurrence of the operation
  #fu_operation contain all the fu for that operation 
  #------------------------ SECONDA PARTE----------------------------------
  #iterate for each operation
  for {set i 0} {$i < [llength $count_operation]} {incr i} {
    set leng [llength [get_lib_fus_from_op [lindex $list_node_op $i]]]
    set comb_operation [list]
    set comb_area [list]
    for {set z [expr {([lindex $count_operation $i]/2) + 1 } ]} {$z <=[lindex $count_operation $i]} {incr z} {
      set vett 0
      #vector of total zeros, one for each fu
      for {set j 1} {$j < $leng} {incr j} {
        lappend vett 0
      }
      set index 0
      set sum 0

      
      #finish of the combination when the last element reach the maximum number of that operation
      while { [lindex $vett end] != $z } {

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

        for { set in $index } {$in <$leng } {incr in } {
          #verify that all the element after in are all 0
          set verify_in $in
          incr verify_in
          set flag 0
          while { $verify_in < $leng && $flag == 0 } {
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
          } elseif {$sum < $z } {
            #if the sum is less than the number of operation for each fu
            #vett[in] take all the rest of the operation 
            set dec $z
            incr dec -$sum
            set sum $z
            set vett [lreplace $vett $in $in $dec]
          }
          
        }

        set in 0
        set area 0
        #set all the combination of the single operation in a variable
        set comb_unique [list]
        foreach element [get_lib_fus_from_op [lindex $list_node_op $i]] {
          #set the fu and the occurrence in the vect comb_unique if the occurrence is != 0 
          set occur [lindex $vett $in]
          if {$occur != 0} {
            set fu_occ $element
            lappend fu_occ $occur
            lappend comb_unique $fu_occ
            #calcolo area
            set area [expr {$area + ( [get_attribute $element area] * $occur)}]
          }
          incr in
        }
        #pruning molto piccolo!
        if {$area <= $areatot} {
          #the vector comb unique contain all the fu and occurrence
          #ordinati per area
          for {set indexArea [expr [llength $comb_area] -1]} {$indexArea >= 0 && $area < [lindex $comb_area $indexArea]} {incr indexArea -1} {
           #ordino in ordine crescente di numero di combinazioni all'interno di comb_general
          }
          #se è l'ultimo elemento o il primo con lista vuota
          if {[llength $comb_area] <= 0 || $indexArea == [expr [llength $comb_area]-1 ] } {
            lappend comb_area $area
            lappend comb_operation $comb_unique
          } elseif { $indexArea == -1} {
            #primo della lista ma lista non vuota
            set tmp_comb [list]
            set tmp_area [list]
            lappend tmp_comb $comb_unique
            lappend tmp_area $area
            foreach element $comb_operation {
              lappend tmp_comb $element
            }
            foreach element $comb_area {
              lappend tmp_area $element
            }
            set comb_operation $tmp_comb
            set comb_area $tmp_area
          } else {
            #prendo il vettore  da j+1 ad end
            set tmp_comb [lreplace $comb_operation 0 $indexArea]
            set tmp_area [lreplace $comb_area 0 $indexArea]
            incr indexArea
            #prendo il vettore da 0 a j
            set comb_operation [lreplace $comb_operation $indexArea end]
            set comb_area [lreplace $comb_area $indexArea end]
            #aggiungo comb_operation e poi ricongiungo
            lappend comb_operation $comb_unique
            lappend comb_area $area
            foreach element $tmp_comb {
              lappend comb_operation $element
            }
            foreach element $tmp_area {
              lappend comb_area $element
            }
          } 
        }
      }
    }
    #puts  $comb_operation
    puts  $comb_area
    puts $fileId $comb_operation
    puts $fileId $comb_area
    for {set q [expr [llength $comb_general]-1]} {$q >= 0 && [llength [lindex $comb_general $q]] < [llength $comb_operation]} {incr q -1} {
      #ordino in ordine crescente di numero di combinazioni all'interno di comb_general
    }
    #se è l'ultimo elemento o il primo con lista vuota
    if {[llength $comb_general] <= 0 || $q == [expr [llength $comb_general]-1 ] } {
        lappend comb_general $comb_operation
        puts $comb_operation
        puts $comb_general
    } elseif { $q == -1} {
      #primo della lista ma lista non vuota
      set tmp [list]
      lappend tmp $comb_operation
      foreach element $comb_general {
        lappend tmp $element
      }
      set comb_general $tmp
    } else {
      #prendo il vettore  da j+1 ad end
      set tmp [lreplace $comb_general 0 $q]
      incr q
      #prendo il vettore da 0 a j
      set comb_general [lreplace $comb_general $q end]
      #aggiungo comb_operation e poi ricongiungo
      lappend comb_general $comb_operation
      foreach element $tmp {
        lappend comb_general $element
      }
    }
    
    

  }
puts "FINE SECONDA PARTE"
puts $comb_general
foreach element $comb_general {
  puts "[llength $element]"
}
#------------------------------FINE SECONDA PARTE-----------------------------------------------
#OTTENGO UNA LISTA DI ELEMENTI, OGNI ELEMENTO è UNA LISTA DI COMBINAZIONI PER OGNI OPERAZIONE
#comb_general contiene tutte le combinazioni per ogni operazione, adesso bisogna combinare questi elementi di ogni lista 
#comb general è una lista di liste di combinazioni per ogni operazione
#------------------------------ INIZIO TERZA PARTE-------------------------------------------
  #set the index of the operand
  set vett -1
  set verif_comb -1
  set lung [llength $comb_general]
  #create the instance of comb to verify verif_comb
  for {set i 1} {$i < $lung} {incr i} {
    lappend vett 0
    lappend verif_comb [lindex [lindex $comb_general $i] 0]
  }
  #the vector begin with 000...000-1
  puts $vett
  puts $verif_comb
  set flag 0
  set r 0
  set index 0
  set pruningFlag 0
  while { $flag == 0 } {
    if { $pruningFlag == 0 } {
      set index 0
    } else {
      set pruningFlag 0
    }
      #check condition and exit from the cycle
      #if all the vett have reach the maximum exit with flag=1
      while {[lindex $vett $index] >= [expr {[llength [lindex $comb_general $index]] -1}]} {
        incr index 
        #aggiungo la condizione che se uno dei vettori ha lunghezza nulla allora si esce dal ciclo
        if {$index == [llength $comb_general] || [llength [lindex $comb_general $index]] == 0} {
          set flag 1 
        }
      }
    if {$flag == 0} {
      #vett[index]++
      set tmp [lindex $vett $index]
      incr tmp
      set vett [lreplace $vett $index $index $tmp]
      #replace
      for {set i [expr $index-1]} {$i >= 0} {incr i -1} {
         set vett [lreplace $vett $i $i 0]
         set verif_comb [lreplace $verif_comb $i $i [lindex [lindex $comb_general $i] 0]]
      }
      set verif_comb [lreplace $verif_comb $index $index [lindex [lindex $comb_general $index] $tmp]]
      #pruning
      #calcolo area
      set area 0
      for {set indexArea 0} {$indexArea < [llength $vett] } {incr indexArea} {
         #indexArea indica a quale operazione ci stiamo riferendo mentre 
         #l'elemento in vett ci dà l'indice del vettore
         set tmp [lindex [lindex $comb_general $indexArea] [lindex $vett $indexArea]]
         #in tmp avremo l'elemento del quale calcolare l'area composto da fus e occorrenze
         #se l'elemento è uno solo l'area si calcola in un altro modo
        foreach element $tmp {
          set fu_area [get_attribute [lindex $element 0] area]
          set occ [lindex $element 1
          set area [expr {$area + ( $fu_area * $occ )}]
        }

      }
      #verifico che l'area sia soddisfatta
      if {$area > $areatot} {
        #se non è soddisfatta elimino da comb_general tutti gli elementi del vettore 
        #con indice index da vett[index] a end
        #mi prendo il vettore con indice Index
        set pruningVector [lindex $comb_general $index]
        #elimino da vett[index] a end
        set pruningVector [lreplace $pruningVector [lindex $vett $index] end]
        #faccio il replace del vettore nell'indice pruningIndex
        set comb_general [lreplace $comb_general $index $index $pruningVector]

        incr index
        #se si arriva alla fine oppure il pruning arriva all'ultimo elemento
        if { $index >= [llength [lindex $comb_general $index]] || ($index == [expr {[llength [lindex $comb_general $index]] -1}] && [expr [lindex $vett $index] + 1] >= [llength [lindex $comb_general $index]]) } {
          set flag 1
          
        } else {
          set pruningFlag 1
        }
        puts "Area non soddisfatta $vett $area $r "
      } else {
        incr r
        #VERIFICA!!!
        #puts "$verif_comb $area"
        #puts $fileId $verif_comb
      }
      

    }
  }
#-------------------------------FINE TERZA PARTE---------------------------------
puts $fileId $r
#puts $fileId $comb_general
close $fileId
}