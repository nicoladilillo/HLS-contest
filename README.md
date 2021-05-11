# HLS-contest

## Introduzione

L'algoritmo si divide in due parti:

1) la parte iniziale, non iterativa, comprende un algoritmo che serve a definire un primo scheduling basato sulle risorse di base necessarie (una risorsa per unità a latenza minore);
2) la seconda parte, iterativa, è formata da un loop di operazioni ripetute sino ad ottenere uno scheduling che abbia un ritardo accettabile e un numero di risorse allocate inferiore (o uguale) al limite consentito.

## Prima parte

L'insieme delle risorse inizialmente disponibili è una lista composta da un'unità per tipo di funzione (tra diverse istanze scegliamo la più veloce, ovvero quella che occupa più area) che verrà utilizzata per definire il nostro scheduling iniziale (list-minimun resource).

## Seconda parte

Parte iterativa che avrà termine solo se le metriche valutate soddisferanno determinati requisiti.

### Assegnazione risorse

Assegnazione di risorse effettuate tramite calcolo combinatorio.

### Update Scheduling

Tramite la nuova lista di risorse ricevuta verrà effettuato un nuovo scheduling, basato su di essa.

### Valutazione metriche

Controlla se possiamo uscire dal loop e restituire il risultato calcolato. Nel caso combinatorio scegliamo un numero **N** di iterazione da compiere che ci diano valore di latenza inferiori a quella ottenuta **N** cicli prima. **N** potrebbe essere 100.
