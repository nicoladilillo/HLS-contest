# SCHEDULING

## Introduzione

L'algoritmo di scheduling è diviso in due parti, una preparatoria e l'altra iterativa:

1) la parte preapratoria reggruppa ogni unità funzionale in basse all'operazione che svolgono;
2) la parte iterativa cicla fin quando tutti i nodi non sono stato allocati, cercando i nodi che posso essere elaborati in uno specificato instante di tempo, raggruppadoli in base all'operazione che svolgono.


## Parte preparatoria

Nella parte preparatoria:

1) Per ogni nodo si calcola la mobilià che viene calcolata con la seguente formula: M(i) = ALAP(i) - ASAP(i) (per Alap viene considera la fu con delay maggiore, mentre per ASAP viene considerata la unità funzionale con delay minore);
2) raggruppa ogni unità funzionale in basse all'operazione che svolgono.


## Parte iterativa

La parte iterativa può essere suddivisa in due parti:

1) La prima parte cerca di capire se il nodo che stiamo considerando ha tutti i parenti già elaborati o se ha parenti ancora in elaborazione o che devono essere ancora considerati;
2) La seconda parte, in base alla mobilità di un nodo che nella prima parte è stato segnato come uno di quelli che può essere elaborato, assegna l'unità funzioanle per quella operazione più oppurtuna

### Nodi che possono essere elaborati

Per ogni nodo che stiamo considerando vediamo se tutti i suoi parenti sono stati schedulati e se nessuno di essi è ancora in elaborazione. Una volta assicurato questo inseriamo il nostro nodo nella lista dei nodi che posso essere elaborati.

### Assegnazione unità funzionale

Questa parte è divisa in due:

1) Ordina ogni nodo che può essere elaborato con mobilità crescente;
2) per ogni fu disponibile, in quel dato istante di tempo e se non ci sono ancora nodi fa elaborare, assegna un nodo dove minore sarà la mobilità del nodo e più veloce sarà la fu assegnata. Se non sono più disponibile fu da assegnare i nodi da schedulare verranno persi e dovranno essere rielaborati nella prima fase nel successivo istante di tempo (operazioni con mobilità minore potrebbere presentarsi). Ogni volta che viene assegnata una fu ad un node esso viene eliminato dalla lista dei nodi da elaborare e vengono aggiornata le occorrenza di disponibilità future di quella fu in basse ai suoi delay.

## Possibili miglioramenti per risparmiare tempo
1) essendo i nodi ordinati in ordine topologico vedere se, quando un nodo non può essere schedulato, se si puù stoppare il controllo dei nodi successivi [NO]
2) non "buttare" i nodi da schedulari, ma conservarli così da non perderli nelle successive eleborazioni, ovviamente suddividili per operazione
3) dividere nodi per operazione e vedere se possono essere elaborati o no
4) salvare lo stesso valore di posizione senza doverlo calcolare ogni volta

