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
  set vett_fu 0
  #preparation of the vett_index
  #preparation of vett_fu with the fu that perform the operations of the dfg
  foreach element $nodes {
    lappend vett_index  -1
    lappend node_fu 0
    #take from all the nodes all the operations
    set node_operation [get_attribute $element operation]
    #if lsearch dont match the operation return -1
    #take all the fu that perform that operation and append to the vector vett_fu
    if {[lsearch $list_node $node_operation]== -1} {
      set fu_operations [get_lib_fus_from_op $node_operation]
      if { [llength $fu_operations] == 0} {
        return
      }
      set vett_fu [concat $vett_fu  [get_lib_fus_from_op $node_operation]]
      lappend list_node $node_operation
    }
  }
  set vett_fu [lreplace $vett_fu 0 0]
  puts $vett_fu
  set lung_fu [llength $vett_fu]
  while {[lindex $vett_index end]< $lung_fu } {
    for {set i 0} {$i<[llength $nodes]} {incr i} {
      set element [lindex $vett_index $i]
      if {(($i != 0 && [lindex $vett_index [expr $i -1]] ==$lung_fu)|| $element == -1 || $i == 0) && ($element < $lung_fu)} {
        #needs only the fu that made the same operation
        incr element
        while {$element < $lung_fu} {
          set node_operation [get_attribute [lindex $nodes $i] operation]
          set fu [lindex $vett_fu $element]
          if {[lsearch [get_lib_fus_from_op $node_operation] $fu] != -1} {
            set node_fu [lreplace $node_fu $i $i $fu]
            set vett_index [lreplace $vett_index $i $i  $element]
            break
          }
          incr element
        }
        set vett_index [lreplace $vett_index $i $i  $element]
        #pruning
      }
    }
    set verify_list 0
    set fu_operations 0
    foreach element $node_fu {
      #devo creare una lista {fu amount}
      
      set index_list [lsearch $fu_operations $element]
      if { $index_list == -1} {
        set app $element
        lappend app 1
        lappend verify_list $app
        lappend fu_operations $element
      } else {
        set number [lindex [lindex $verify_list $index_list] 1]
        puts 
        incr number
        set app $element
        lappend app $number
        set verify_list [lreplace $verify_list $index_list $index_list $app ]
      }
    }
    set verify_list [lreplace $verify_list 0 0]
    puts $node_fu
    puts $verify_list 

    #verifica
  }
}
#next step fare questa cosa per ogni operazione vettore di nodi a cui serve e vettore di fu dell'operazione