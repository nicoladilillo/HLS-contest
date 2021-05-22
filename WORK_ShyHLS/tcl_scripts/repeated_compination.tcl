#dont need any attributes because the list of node and fu is global
#source ./tcl_scripts/setenv.tcl
#read_design ./data/DFGs/fir.dot
#devo dare in pasto alla procedura 0 vettore_di_fu vettore_soluzione lunghezza_vettore_fu lunghezza_vettore soluz 0 0
proc repeated_comb_recursive {posix vett_fu soluz lung_fu lung_sol start } {
  if {$posix >= $lung_sol} {
    for{set i 0} {$i<$lung_sol} {incr $i} {
        #setto vettore da verificare
    }
    #verifica
    return
  }
  for {set i $start} {$i< $lung_fu} {incr i} {
    #verifico che l'op di fu sia compatibile con l'op del nodo
    set $sol($posix) $val($i)
    incr $posix
    repeated_comb_recursive {$pos $val $sol $n $k $start }
    incr $start
  }
}
#next step fare questa cosa per ogni operazione vettore di nodi a cui serve e vettore di fu dell'operazione