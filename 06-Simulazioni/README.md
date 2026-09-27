# Simulazioni d'esame

Sei temi d'esame inediti, costruiti sul formato, sulla struttura dei punteggi e sulle domande ricorrenti dei temi reali in [`04-Esami/`](../04-Esami/), ma con testi, schemi e domande **completamente diversi**.

> Guida allo studio → [`GUIDA-ESAME.md`](../GUIDA-ESAME.md) · Indice del materiale → [`INDEX.md`](../INDEX.md)

## Come usarle

1. **Non leggere le soluzioni prima.** Le tracce e le soluzioni sono in cartelle separate proprio per questo.
2. **Cronometra.** Le durate indicate su ogni traccia sono quelle reali (2h15 per la teoria, 2h15 + 1h30 per tecnologie e laboratorio). La gestione del tempo è metà dell'esame.
3. **Scrivi a mano gli schemi ER e i B+-tree**, come dovrai fare all'esame.
4. Solo dopo, confronta con la soluzione. Ogni soluzione spiega **perché** una scelta è corretta e segnala gli errori tipici, quindi vale come ripasso anche a esercizio già svolto.

## Prova 1 — Teoria

| Traccia | Dominio dell'esercizio di progettazione | Domanda a) | Domanda c) | Focus |
|---|---|---|---|---|
| [Simulazione 1](Teoria-Simulazione-1.md) | Comprensorio sciistico | identificatore interno ed esterno | embedding vs referencing | entità con identificatore esterno; ridondanze |
| [Simulazione 2](Teoria-Simulazione-2.md) | Rete di ricarica per veicoli elettrici | generalizzazione | struttura JSON; collezione vs tabella | generalizzazione **parziale**; relazione ternaria e ricorsiva |
| [Simulazione 3](Teoria-Simulazione-3.md) | Festival musicale | cardinalità | superchiave; attributi multivalore | relazione vs entità; generalizzazione nei document DB |

Ogni traccia contiene: 3 domande preliminari di sbarramento, un esercizio di progettazione (ER + schema logico), un esercizio di traduzione verso collezioni JSON, 3 interrogazioni in algebra relazionale, query MongoDB e calcolo relazionale.

**Soluzioni:** [1](Soluzioni/Teoria-Simulazione-1-SOLUZIONI.md) · [2](Soluzioni/Teoria-Simulazione-2-SOLUZIONI.md) · [3](Soluzioni/Teoria-Simulazione-3-SOLUZIONI.md)

## Prova 2 — Tecnologie e Laboratorio

| Traccia | Guasto | Schedule | Ottimizzazione | B+-tree |
|---|---|---|---|---|
| [Simulazione 1](Tecnologie-Lab-Simulazione-1.md) | ripresa a **caldo** | VSR ✅ CSR ✅ 2PL ❌ | e-commerce, indice prof. 3 | fan-out 5: split + **prestito** da destra |
| [Simulazione 2](Tecnologie-Lab-Simulazione-2.md) | ripresa a **caldo** (azioni pre-checkpoint da rifare) | VSR ✅ CSR ❌ 2PL ❌ | biblioteca, indice prof. 2 | fan-out 4: split + **fusione** |
| [Simulazione 3](Tecnologie-Lab-Simulazione-3.md) | ripresa a **freddo** (con DUMP) | VSR ✅ CSR ✅ 2PL ✅ | palestra, indice prof. 3 | fan-out 5: split + **prestito** da sinistra |

I tre schedule coprono deliberatamente le **tre combinazioni possibili** di risposte, così da non poter indovinare; i tre esercizi sul B+-tree coprono i tre esiti di una cancellazione.

Ogni traccia contiene: domande di teoria (**una è sempre sulle proprietà ACID**, una sulle strutture di accesso, una su MongoDB), esercizio sul gestore dell'affidabilità, esercizio di concorrenza, esercizio di stima dei costi, esercizio sul B+-tree, e la parte di laboratorio (DDL PostgreSQL con vincoli, 4 query SQL, query MongoDB, anomalie di concorrenza, programma Python).

**Soluzioni:** [1](Soluzioni/Tecnologie-Lab-Simulazione-1-SOLUZIONI.md) · [2](Soluzioni/Tecnologie-Lab-Simulazione-2-SOLUZIONI.md) · [3](Soluzioni/Tecnologie-Lab-Simulazione-3-SOLUZIONI.md)

## Argomenti coperti dalle domande di teoria della Prova 2

Per non ripetere le stesse domande, le tre simulazioni distribuiscono gli argomenti così:

| Argomento | Sim. 1 | Sim. 2 | Sim. 3 |
|---|:--:|:--:|:--:|
| Proprietà ACID + moduli del DBMS | ● | ● (atomicità e persistenza in dettaglio) | ● (+ verifica immediata/differita) |
| Struttura hash, collisioni, hash vs B+-tree | ● | | |
| Gestore del buffer, primitive, steal/force | | ● | |
| Indice secondario vs primario | | | ● |
| Tipi di guasto, WAL e Commit-Precedenza | | ● | |
| Sharding, shard key, mongos, config server | ● | | |
| Replica set, oplog, elezione Raft, arbitro | | ● | |
| ACID in MongoDB, write concern, read preference | | | ● |
| Anomalie (parte laboratorio) | perdita di aggiornamento / lettura sporca | lettura inconsistente / inserimento fantasma | aggiornamento fantasma / lettura sporca |

## Avvertenza

Questi temi sono **simulazioni**, non testi d'esame reali: sono stati scritti ricalcando il formato dei temi in `04-Esami/`, ma non provengono dal docente. Le soluzioni sono ragionate e verificate, e dove una traccia ammette più letture legittime la soluzione lo dichiara esplicitamente — all'esame conviene fare lo stesso, scrivendo l'interpretazione adottata.
