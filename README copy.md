# HLS-contest

## Introduzione

L'algoritmo si divide in due parti:

1) la parte iniziale, non iterativa, comprende un algoritmo che serve a definire un primo scheduling basato sulle risorse di base necessarie (una risorsa per unità a latenza minore);
2) la seconda parte, iterativa, è formata da un loop di operazioni ripetute sino ad ottenere uno scheduling che abbia un ritardo accettabile e un numero di risorse allocate inferiore (o uguale) al limite consentito.

## Prima parte

L'insieme delle risorse inizialmente disponibili è una lista composta da un'unità per tipo di funzione (tra diverse istanze scegliamo la più veloce, ovvero quella che occupa più area) che verrà utilizzata per definire il nostro scheduling iniziale (list-minimun resource).

## Seconda parte
Parte iterativa divisa in tre sottoparti:
-PRIMA PARTE preparazione dei vettori che servono durante l'iterazione. Si inserisce all'interno del vettore count_operation il numero di nodi che performano quella operazione mentre in list_node_op le operazioni da eseguire.
Si itera per ogni nodo del DFG si controlla se l'operazione di quel nodo è stata inserita nei vettori, se non è stata inserita la si inserisce altrimenti si incrementa il contatore
-SECONDA PARTE Scopo della seconda parte è arrivare ad avere tutte le combinazioni di tutte le operazioni, divise per operazione nella lista finale comb_general
In questa seconda parte fondamentale è l'utilizzo di vett, il vettore che verrà inizializato a 0 ogni volta che si cambierà operazione, lungo a seconda di quante fu eseguono quella determinata operazione.
Le combinazioni per ogni operazione finiscono quando l'ultimo elemento raggiunge il massimo del numero di operazione ( 11 10 22 1 in questo caso), quando tutte le combinazioni saranno finite verranno salvate nella lista comb_general.
Per comporre le combinazioni abbiamo tre condizioni (tre if) la prima che controlla quando l'ultimo elemento è diverso da 0, in questo caso particolare si setta un indice che serve per bloccare tutti gli elementi precedenti e variare solo quelli antecedenti ad esso ad es 1 0 3 10, si va da 1 a 10, primo elemento diverso da 0 è 3 quindi il prossimo ciclo avrà il 10 fisso e dal 3 al 1 cambieranno 1 1 2 10.
Le altre due condizioni sono più semplici e sono dipendenti l'una dall altra, la prima verifica che l'elemento sia != 0 e che tutti gli elementi prima di lui siano 0, in questo caso è lui a dover cambiare nella nuova combinazione e quindi si decrementa (decrementando anche la somma che deve sempre essere pari al numero di nodi che performa quell'operazione), la terza condizione (la più banale) controlla che la somma sia valida, se non lo è il nodo assumerà la differenza tra il numero di operazione e la somma che poi verrà decrementato nel prossimo ciclo.Le ultime righe dello step DUE preparano le combinazioni per lo step TRE
es. numero di operazione 10 elementi 3 0 0 0 vettore di partenza somma=0
 index =0 entra nella terza condizione quindi 0 0 10  gli altri die indici non soddisfano nessuna condizione fine primo ciclo
 secondo ciclo index=0 entra in 10 seconda condizione attiva e diminuisce a 9 la somma ora è 9, index 1 entra nella terza condizione secondo elemento 1 ora la somma è 10, vettore finale 0 1 9 etc etc
-TERZA PARTE 
In questa parte le combinazioni di ogni operazione vengono messe insieme e verificate per trovare la migliore
### Assegnazione risorse

Assegnazione di risorse effettuate tramite calcolo combinatorio.

### Update Scheduling

Tramite la nuova lista di risorse ricevuta verrà effettuato un nuovo scheduling, basato su di essa.

### Valutazione metriche

Controlla se possiamo uscire dal loop e restituire il risultato calcolato. Nel caso combinatorio scegliamo un numero **N** di iterazione da compiere che ci diano valore di latenza inferiori a quella ottenuta **N** cicli prima. **N** potrebbe essere 100.
