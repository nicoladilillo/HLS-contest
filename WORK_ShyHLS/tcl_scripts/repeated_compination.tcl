#dont need any attributes because the list of node and fu is global
#source ./tcl_scripts/setenv.tcl
#read_design ./data/DFGs/fir.dot
#nodes vector of nodes
#vett_index lung= lung nodes 
#soluz vector of temporary solution
#better_soluz the best of the solution
#vett_fu vector of all fu

proc repeated_comb {} {
  set nodes [get_nodes]
  #preparation of the vett_index
  foreach element $nodes {
    lappend vett_index  0
  }
  set vett_fu [get_lib_fus]
  set lung_fu [llength $vett_fu]
  while {[lindex $vett_index end]<lung_fu} {
    for {set i 0} {$i<[llength $nodes]} {incr $i} {
      set element [lindex $vett_index $i]
      if {(($i != 0 && [lindex $vett_index $i+1] == $lung_fu)|| $i == 0) && ($element < $lung_fu)} {
          incr $element
          set vett_index [lreplace $vett_index $i $i $element]
          #pruning
      }
    }
    #verifica
  }
}
#next step fare questa cosa per ogni operazione vettore di nodi a cui serve e vettore di fu dell'operazione