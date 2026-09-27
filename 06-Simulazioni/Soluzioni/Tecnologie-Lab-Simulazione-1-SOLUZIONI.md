# Soluzioni — Prova di Tecnologie e Laboratorio, Simulazione 1

> Traccia: [`Tecnologie-Lab-Simulazione-1.md`](../Tecnologie-Lab-Simulazione-1.md)

---

# PARTE A — TECNOLOGIE

## a) Proprietà delle transazioni **(4)**

Una **transazione** è un'unità elementare di lavoro svolta da un'applicazione, alla quale si vogliono associare particolari caratteristiche di correttezza, robustezza e isolamento. È racchiusa fra `begin transaction` e `end transaction` e termina con un `commit work` (successo) o un `rollback work` (fallimento). Una transazione è **ben formata** se inizia con `begin transaction`, termina con `end transaction`, contiene **al più un** comando di `commit` o `rollback` e non esegue alcuna operazione sulla base di dati dopo di esso.

Le quattro proprietà — l'acronimo **ACID** — sono:

| Proprietà | Enunciato | Implicazioni | Modulo del DBMS | Meccanismo |
|---|---|---|---|---|
| **A**tomicità (*Atomicity*) | La transazione è un'unità **indivisibile** di esecuzione: o vengono resi definitivi tutti i suoi effetti, o nessuno. Non sono ammesse esecuzioni parziali | se la transazione fallisce prima del commit, la base di dati deve essere riportata allo stato precedente l'inizio della transazione (**UNDO**); se fallisce dopo il commit, gli effetti vanno resi comunque definitivi (**REDO**) | **Gestore dell'affidabilità** | file di **log** con immagini *before* e *after*, regola **WAL**, procedure di UNDO/REDO |
| **C**onsistenza (*Consistency*) | La transazione porta la base di dati da uno stato **consistente** a un altro stato consistente, rispettando i vincoli di integrità | la verifica dei vincoli può essere **immediata** (durante la transazione: l'applicazione può reagire alla violazione) oppure **differita** (al commit: l'intera transazione viene disfatta) | **Gestore dell'integrità** (parte del gestore delle interrogazioni / DDL) | controllo dei vincoli di dominio, di tupla, di chiave e di integrità referenziale; trigger |
| **I**solamento (*Isolation*) | L'esecuzione di una transazione deve essere **indipendente** dall'esecuzione concorrente delle altre: il risultato deve essere lo stesso che si otterrebbe eseguendole in isolamento | evita le anomalie da esecuzione concorrente (perdita di aggiornamento, lettura sporca, lettura inconsistente, aggiornamento e inserimento fantasma) | **Gestore della concorrenza** (*scheduler*) | **locking a due fasi (2PL)**, lock condivisi/esclusivi, timestamp, livelli di isolamento SQL |
| **D**urabilità o Persistenza (*Durability*) | Gli effetti di una transazione che ha eseguito con successo il `commit` sono **permanenti**, anche in caso di guasto successivo al commit | la registrazione del commit sul log deve precedere la comunicazione dell'esito all'applicazione | **Gestore dell'affidabilità** | scrittura del log su **memoria stabile**, regola di **Commit-Precedenza**, REDO in fase di ripresa |

> **Osservazione da fare all'esame:** atomicità e persistenza sono garantite dallo **stesso** modulo (il gestore dell'affidabilità), ma da due meccanismi opposti — l'UNDO serve l'atomicità, il REDO serve la persistenza. Le due regole di scrittura sul log riflettono questa dualità: **WAL** (*Write-Ahead Log*: la *before image* va scritta sul log prima di modificare la pagina su disco) rende possibile l'UNDO e serve l'**atomicità**; la **regola di Commit-Precedenza** (la *after image* va sul log prima del record di commit) rende possibile il REDO e serve la **persistenza**.

---

## b) Struttura ad accesso calcolato (hash) **(4)**

### Caratteristiche

Una struttura **hash** organizza un file in `B` unità di memorizzazione dette **bucket** (tipicamente un bucket = un blocco, o pochi blocchi contigui). Una **funzione di hash** `H` mappa il valore della chiave nell'indirizzo del bucket:

```
H : dominio della chiave  →  { 0, 1, …, B-1 }
```

La funzione deve distribuire le chiavi il più **uniformemente** possibile fra i bucket. Una tecnica classica è interpretare la chiave come un intero e prendere il resto della divisione per `B` (con `B` primo), oppure applicare una funzione di *folding* e poi il modulo.

### Ricerca di una tupla di chiave K

```
1. calcola  b = H(K)                        (costo: 0 accessi — è un calcolo in memoria centrale)
2. leggi il bucket b                        (costo: 1 accesso a memoria secondaria)
3. cerca K fra le tuple del bucket (scansione in memoria centrale)
4. se non trovata e il bucket ha una catena di overflow,
   segui la catena leggendo un blocco alla volta finché K è trovata o la catena finisce
```

**Costo:** nel caso ideale **1 solo accesso** a memoria secondaria — è il grande vantaggio di questa struttura. Il costo degenera a `1 + lunghezza media della catena di overflow`.

### Inserimento di una tupla di chiave K

```
1. calcola  b = H(K)
2. leggi il bucket b
3. se c'è spazio libero, inserisci la tupla e riscrivi il bucket     (2 accessi)
4. se il bucket è pieno → COLLISIONE gestita con overflow:
   - alloca (o segui fino all'ultimo) un blocco di overflow
   - inserisci lì la tupla e aggiorna il puntatore di catena
```

### Collisioni

Si ha una **collisione** quando due chiavi diverse `K₁ ≠ K₂` vengono mappate sullo stesso bucket: `H(K₁) = H(K₂)`. Le collisioni sono **inevitabili**, perché il dominio delle chiavi è tipicamente molto più grande del numero di bucket. Finché il bucket ha spazio la collisione è innocua (le tuple convivono nello stesso blocco); diventa un problema quando il bucket è **pieno**, situazione detta di **overflow**.

**Gestione dell'overflow — catena di overflow (*chaining*).** Al bucket saturo viene collegato un blocco di overflow, e a questo eventualmente un altro, formando una lista concatenata. Ogni blocco di overflow aggiunge **un accesso** al costo di ricerca e di inserimento.

Il numero medio di accessi cresce rapidamente con il **fattore di riempimento** `T / (B · F)` (dove `T` = numero di tuple, `B` = numero di bucket, `F` = tuple per bucket). Per questo si dimensiona il file lasciando i bucket riempiti a circa l'**80 %**: si sacrifica spazio per mantenere le catene corte. La struttura hash **statica** ha inoltre il difetto di non adattarsi alla crescita del file: se il numero di tuple aumenta molto, le catene si allungano e le prestazioni degradano, e occorre una riorganizzazione completa (*rehashing*).

### Quando l'hash è più vantaggioso di un B+-tree

| Situazione | Struttura preferibile | Perché |
|---|---|---|
| Ricerca **puntuale** su **uguaglianza** della chiave (`WHERE K = valore`) | **hash** | 1 accesso contro `profondità + 1` accessi del B+-tree (tipicamente 3–4) |
| Chiave con valori **uniformemente distribuiti** e numero di tuple **stabile** e noto a priori | **hash** | le catene di overflow restano corte, il vantaggio dell'accesso singolo si mantiene |
| Join su uguaglianza fra chiavi (hash join) | **hash** | la partizione hash sostituisce l'ordinamento |
| Ricerca su **intervallo** (`WHERE K BETWEEN a AND b`, `>`, `<`) | **B+-tree** | l'hash **non conserva l'ordine**: chiavi vicine finiscono in bucket qualsiasi. Servirebbe una scansione completa. Il B+-tree trova la prima chiave e poi scorre le foglie concatenate |
| Necessità di leggere le tuple in **ordine di chiave** (`ORDER BY`, merge-scan join) | **B+-tree** | le foglie sono concatenate in ordine |
| Ricerca su **prefisso** della chiave o su parte di una chiave composta | **B+-tree** | l'hash richiede la chiave **completa** per calcolare `H` |
| File di dimensione **molto variabile** nel tempo | **B+-tree** | è auto-bilanciante; l'hash statico degrada e richiede riorganizzazione |

---

## c) Sharding in MongoDB **(4)**

### A cosa serve e perché si usa

Lo **sharding** (*frammentazione*) è la tecnica con cui MongoDB distribuisce i documenti di una **collezione** su più istanze del database server, ospitate su macchine fisiche diverse. Serve a ottenere **scalabilità orizzontale**: invece di potenziare un singolo server (*scale-up*, costoso e con un limite fisico), si aggiungono macchine (*scale-out*).

Se ne ha bisogno quando:
- il volume dei dati supera la capacità di memorizzazione di un singolo server;
- il *working set* (l'insieme dei dati acceduti di frequente) non entra più nella RAM di un singolo server, e le prestazioni crollano per l'eccesso di accessi a disco;
- il carico di scrittura supera il throughput di un singolo nodo (la replicazione **non** aiuta in scrittura, perché tutte le scritture passano dal primario).

Lo sharding si contrappone e si affianca alla **replicazione**: la replicazione crea copie **complete** dello stesso dataset (ridondanza, alta disponibilità, migliori prestazioni in lettura); lo sharding **partiziona** il dataset in porzioni disgiunte (scalabilità in scrittura e in capacità). In produzione ogni shard è a sua volta un **replica set**.

### Come viene implementato: i componenti

```
                       ┌─────────────┐        ┌──────────────────┐
        applicazioni ──►│   mongos    │◄──────►│  config server   │
                       │  (router)   │        │  (replica set)   │
                       └──────┬──────┘        └──────────────────┘
              ┌───────────────┼───────────────┐
        ┌─────▼─────┐   ┌─────▼─────┐   ┌─────▼─────┐
        │  Shard 1  │   │  Shard 2  │   │  Shard 3  │
        │ Primary   │   │ Primary   │   │ Primary   │
        │ Sec  Sec  │   │ Sec  Sec  │   │ Sec  Sec  │
        └───────────┘   └───────────┘   └───────────┘
```

| Componente | Ruolo |
|---|---|
| **Shard** | contiene un sottoinsieme dei dati della collezione. In produzione è un **replica set** completo, così ogni frammento è a sua volta ridondato |
| **mongos** (*query router*) | è il punto di ingresso per le applicazioni: riceve l'interrogazione, consulta i metadati per capire quali shard la riguardano, inoltra la richiesta **solo** a quelli, raccoglie le risposte parziali e le combina nel risultato definitivo. È *stateless* e se ne possono avere più istanze |
| **Config server** | mantiene i **metadati** dello sharding: quali collezioni sono frammentate, qual è la shard key, come i chunk sono distribuiti fra gli shard. È esso stesso un replica set, perché la sua perdita renderebbe il cluster inutilizzabile |
| **Balancer** | processo in esecuzione sul primario dei config server; monitora la distribuzione dei chunk e li **migra** da uno shard all'altro quando rileva uno sbilanciamento, in modo trasparente per le applicazioni |

Lo sharding si applica **a livello di collezione**: in uno stesso database possono coesistere collezioni frammentate e collezioni non frammentate. È possibile anche il **micro-sharding**, in cui più shard risiedono sullo stesso host fisico.

### Il ruolo della shard key

La **shard key** è il campo (o l'insieme di campi indicizzati) sul cui valore MongoDB decide **in quale shard** collocare ciascun documento. Lo spazio dei valori della shard key viene suddiviso in intervalli contigui detti **chunk**; ogni chunk è assegnato a uno shard, e il balancer li ridistribuisce quando serve.

Due strategie di partizionamento:

- **Ranged sharding**: i chunk corrispondono a intervalli contigui di valori. Vantaggio: le interrogazioni su **intervallo** della shard key vengono indirizzate a pochi shard (*targeted query*). Svantaggio: se la shard key è monotona crescente (es. un timestamp o un `ObjectId`), tutte le nuove scritture finiscono sullo stesso chunk e quindi sullo stesso shard — un *hotspot* che annulla il beneficio dello sharding.
- **Hashed sharding**: si applica una funzione di hash al valore della shard key. Vantaggio: distribuzione **uniforme** delle scritture, nessun hotspot. Svantaggio: le interrogazioni su intervallo devono essere inviate a **tutti** gli shard (*scatter-gather*), perché l'ordine è perduto.

**Criteri per una buona shard key:** alta **cardinalità** (molti valori distinti, altrimenti il numero di chunk possibili è limitato), bassa **frequenza** (nessun valore molto più comune degli altri), assenza di **monotonia**, e presenza nella maggior parte delle interrogazioni (altrimenti ogni query diventa scatter-gather). La shard key è **immutabile** e, una volta scelta, condiziona tutte le prestazioni del cluster: è la decisione più importante nella progettazione di un cluster sharded.

---

## d) Gestore dell'affidabilità — ripresa a caldo **(4)**

Il guasto è **di sistema** (perdita della memoria centrale, memoria secondaria intatta) → si applica la **ripresa a caldo** (*warm restart*), eseguita dal **gestore dell'affidabilità** al riavvio.

### Numerazione del log

| # | record | | # | record |
|---|---|---|---|---|
| 1 | `B(T1)` | | 11 | `D(T2,O5,B5)` |
| 2 | `B(T2)` | | 12 | `C(T2)` |
| 3 | `U(T1,O1,B1,A1)` | | 13 | `B(T5)` |
| 4 | `B(T3)` | | 14 | `U(T5,O6,B6,A6)` |
| 5 | `I(T2,O2,A2)` | | 15 | `U(T3,O1,B7,A7)` |
| 6 | `U(T3,O3,B3,A3)` | | 16 | `A(T4)` |
| 7 | `C(T1)` | | 17 | `I(T5,O7,A8)` |
| 8 | **`CK(T2,T3)`** | | 18 | `C(T3)` |
| 9 | `B(T4)` | | 19 | `U(T5,O8,B9,A9)` |
| 10 | `U(T4,O4,B4,A4)` | | — | **guasto** |

### Passo 1 — Individuazione dell'ultimo checkpoint

L'ultimo record di checkpoint è `CK(T2,T3)` alla posizione **8**. Esso attesta che, in quel momento, le transazioni **attive** (iniziate e non ancora terminate) erano `T2` e `T3`, e che le pagine di tutte le transazioni **già concluse** prima del checkpoint — quindi anche di `T1`, che ha eseguito il commit alla posizione 7 — sono state **forzate su disco**.

### Passo 2 — Costruzione degli insiemi UNDO e REDO

Inizializzazione: `UNDO = {T2, T3}` (le transazioni del checkpoint), `REDO = { }`.
Si percorre il log **in avanti** dalla posizione 9 alla fine:

| # | record | azione | UNDO | REDO |
|---|---|---|---|---|
| — | — | inizializzazione | `{T2,T3}` | `{ }` |
| 9 | `B(T4)` | aggiungi `T4` a UNDO | `{T2,T3,T4}` | `{ }` |
| 12 | `C(T2)` | sposta `T2` da UNDO a REDO | `{T3,T4}` | `{T2}` |
| 13 | `B(T5)` | aggiungi `T5` a UNDO | `{T3,T4,T5}` | `{T2}` |
| 16 | `A(T4)` | `T4` **resta** in UNDO | `{T3,T4,T5}` | `{T2}` |
| 18 | `C(T3)` | sposta `T3` da UNDO a REDO | `{T4,T5}` | `{T2,T3}` |

> ⚠️ Il record di **abort** `A(T4)` **non** rimuove `T4` da UNDO: significa che la transazione ha deciso di abortire, ma le sue scritture possono essere già finite su disco e vanno comunque **disfatte**.

**Risultato:**

```
UNDO = { T4, T5 }
REDO = { T2, T3 }
```

### Passo 3 — Ripercorrimento all'indietro (UNDO)

Si risale il log **all'indietro** fino al record di `begin` della transazione **più vecchia** appartenente a `UNDO ∪ REDO = {T2, T3, T4, T5}`. Il `begin` più vecchio è **`B(T2)` alla posizione 2**: ci si spinge quindi **oltre il checkpoint**, fino alla posizione 2.

Disfacendo, in ordine inverso, le azioni delle sole transazioni in UNDO (`T4`, `T5`):

| # | record | azione di UNDO |
|---|---|---|
| 19 | `U(T5,O8,B9,A9)` | `O8 = B9` (ripristina la *before image*) |
| 17 | `I(T5,O7,A8)` | **cancella** l'oggetto `O7` |
| 14 | `U(T5,O6,B6,A6)` | `O6 = B6` |
| 10 | `U(T4,O4,B4,A4)` | `O4 = B4` |

### Passo 4 — Ripercorrimento in avanti (REDO)

Si ripercorre il log **in avanti** dalla posizione 2, rifacendo le azioni delle sole transazioni in REDO (`T2`, `T3`):

| # | record | azione di REDO |
|---|---|---|
| 5 | `I(T2,O2,A2)` | **inserisce** `O2` con valore `A2` |
| 6 | `U(T3,O3,B3,A3)` | `O3 = A3` (applica la *after image*) |
| 11 | `D(T2,O5,B5)` | **cancella** l'oggetto `O5` |
| 15 | `U(T3,O1,B7,A7)` | `O1 = A7` |

### Osservazioni da riportare all'esame

1. **L'azione di `T1` non viene rifatta.** `U(T1,O1,B1,A1)` alla posizione 3 riguarda una transazione che ha committato **prima** del checkpoint: il checkpoint garantisce che le sue pagine siano già su disco. Rifarla sarebbe inutile (e comunque innocuo, perché il REDO è idempotente).
2. **Perché ci si spinge indietro oltre il checkpoint.** Se ci si fermasse al checkpoint si perderebbero le azioni di `T2` e `T3` da rifare che precedono la posizione 8 (le posizioni 5 e 6). Per questo la regola richiede di risalire al `begin` più vecchio fra **tutte** le transazioni di `UNDO ∪ REDO`, non solo di UNDO.
3. **L'ordine UNDO-poi-REDO è obbligatorio** e non invertibile: garantisce che, quando più transazioni hanno agito sullo stesso oggetto, prevalga sempre l'ultimo valore committato.

---

## e) Esecuzione concorrente **(6)**

```
S: r3(y), r1(x), w1(x), r2(x), w3(y), w1(y), w2(z), r4(z), r4(y), w3(t), r1(t), w2(t)
      1       2       3       4       5       6       7       8       9      10      11      12
```

Operazioni per transazione:

```
T1:  r1(x)@2   w1(x)@3   w1(y)@6   r1(t)@11
T2:  r2(x)@4   w2(z)@7   w2(t)@12
T3:  r3(y)@1   w3(y)@5   w3(t)@10
T4:  r4(z)@8   r4(y)@9
```

### Conflict-serializzabilità (CSR)

Due operazioni sono **in conflitto** se agiscono sullo stesso oggetto, appartengono a transazioni diverse e almeno una delle due è una scrittura.

| Oggetto | Operazioni | Conflitti (arco `Ti → Tj`) |
|---|---|---|
| `x` | `r1@2, w1@3, r2@4` | `w1@3 – r2@4` → **T1→T2** |
| `y` | `r3@1, w3@5, w1@6, r4@9` | `r3@1 – w1@6` → **T3→T1**; `w3@5 – w1@6` → **T3→T1**; `w3@5 – r4@9` → **T3→T4**; `w1@6 – r4@9` → **T1→T4** |
| `z` | `w2@7, r4@8` | `w2@7 – r4@8` → **T2→T4** |
| `t` | `w3@10, r1@11, w2@12` | `w3@10 – r1@11` → **T3→T1**; `w3@10 – w2@12` → **T3→T2**; `r1@11 – w2@12` → **T1→T2** |

**Grafo dei conflitti:**

```
                 ┌───────────────────────────────┐
                 │                               ▼
      (T3) ────► (T1) ────────► (T2) ──────────► (T4)
        │  │                                      ▲
        │  └──────────────────────────────────────┘
        └─────────────────────────────────────────┘
```

Archi: `T3→T1`, `T3→T2`, `T3→T4`, `T1→T2`, `T1→T4`, `T2→T4`

Il grafo è **aciclico**: `T3` è una sorgente (non ha archi entranti), `T4` è un pozzo (non ha archi uscenti), e fra `T1` e `T2` esiste il solo arco `T1→T2`. L'ordinamento topologico è `T3, T1, T2, T4`.

> ### ✅ **S è CSR**, conflict-equivalente allo schedule seriale `T3 T1 T2 T4`.

### View-serializzabilità (VSR)

Poiché **CSR ⊂ VSR**, ogni schedule conflict-serializzabile è anche view-serializzabile.

> ### ✅ **S è VSR.**

*Verifica diretta (facoltativa).* Nello schedule `S`:
- **LEGGE-DA:** `w1(y)@6` è l'ultima scrittura su `y` prima di `r4(y)@9` → `(T4, y, T1)`; `w3(t)@10` precede `r1(t)@11` → `(T1, t, T3)`; `w2(z)@7` precede `r4(z)@8` → `(T4, z, T2)`; `w1(x)@3` precede `r2(x)@4` → `(T2, x, T1)`. Le letture `r3(y)@1` e `r1(x)@2` leggono il valore iniziale.
- **Scritture finali:** `x → w1@3` (T1), `y → w1@6` (T1), `z → w2@7` (T2), `t → w2@12` (T2).

Lo schedule seriale `T3 T1 T2 T4` produce esattamente le stesse letture-da e le stesse scritture finali, quindi è view-equivalente a `S`.

### Locking a due fasi (2PL)

Regola: per ogni transazione, **tutte** le richieste di lock devono precedere **tutti** i rilasci (fase crescente seguita da fase calante, senza sovrapposizioni).

Si analizza `T1`, che è il punto critico.

**Vincolo 1 — `T1` deve RILASCIARE il lock su `x` prima dell'istante 4.**
`T1` esegue `w1(x)@3`, quindi possiede un lock **esclusivo** su `x` almeno fino all'istante 3. All'istante 4, `T2` esegue `r2(x)` e ha bisogno di un lock **condiviso** su `x`, incompatibile con quello esclusivo di `T1`. Dunque `T1` deve rilasciare `x` in un istante compreso fra 3 e 4.

**Vincolo 2 — `T1` non può ACQUISIRE il lock su `y` prima dell'istante 5.**
`T1` esegue `w1(y)@6` e ha quindi bisogno di un lock esclusivo su `y`. Ma `T3` esegue `r3(y)@1` e `w3(y)@5`: per rispettare a sua volta il 2PL, `T3` deve **mantenere ininterrottamente** il lock su `y` dall'istante 1 (o prima) all'istante 5 (o dopo) — non potrebbe rilasciarlo dopo `r3(y)@1` e riacquisirlo per `w3(y)@5`, perché ciò violerebbe le due fasi di `T3`. Il lock esclusivo richiesto da `T1` su `y` è incompatibile sia con il lock condiviso sia con quello esclusivo di `T3`, quindi `T1` **non può in alcun modo anticipare** l'acquisizione di `y` prima dell'istante 5.

**Conclusione.**

```
   T1 rilascia il lock su x   in un istante ∈ (3, 4)
   T1 acquisisce il lock su y in un istante ∈ (5, 6]
   ⇒  un RILASCIO (< 4) precede una ACQUISIZIONE (> 5)
   ⇒  la fase calante di T1 inizia prima che la fase crescente sia terminata
```

> ### ❌ **S non è 2PL.**

**Riepilogo:** `S` è VSR ✅, è CSR ✅, **non** è 2PL ❌.
Il risultato è coerente con l'inclusione **stretta** `2PL ⊂ CSR ⊂ VSR`: `S` è proprio un esempio di schedule conflict-serializzabile che nessuno scheduler 2PL potrebbe produrre.

> ⚠️ **Attenzione a un errore frequente.** Per concludere che uno schedule non è 2PL **non basta** osservare che una transazione accede a un oggetto *dopo* aver dovuto rilasciarne un altro: il 2PL non impone di richiedere il lock nell'istante del primo accesso, quindi una transazione può in linea di principio **anticipare** l'acquisizione all'inizio. La violazione è dimostrata solo se si prova che l'anticipazione è **impossibile**, perché nel frattempo un'altra transazione detiene un lock incompatibile — come qui fa `T3` sull'oggetto `y`.

## f) Ottimizzazione **(5)**

### Parte 1 — Costo senza indice

**Dati:** `NP(CLIENTE) = 400`, `NR(CLIENTE) = 24000`, `NP(ORDINE) = 3600`, `NR(ORDINE) = 432000`, `VAL(Regione, CLIENTE) = 20`, `VAL(Cliente, ORDINE) = 24000`.

**Passo 1 — selezione su `CLIENTE` (scansione, risultato nel buffer)**

```
costo = NP(CLIENTE) = 400 accessi
```
Cardinalità del risultato (fattore di selettività di una selezione di uguaglianza):
```
NR(CLIENTE con Regione='Veneto') = NR(CLIENTE) / VAL(Regione, CLIENTE)
                                 = 24000 / 20 = 1200 tuple
```
Il risultato resta **nel buffer** → nessun costo di scrittura e nessun costo di rilettura.

**Passo 2 — selezione su `ORDINE` (scansione, risultato salvato su disco)**

```
lettura   = NP(ORDINE)  = 3600 accessi
scrittura =                1200 accessi   (le 1200 pagine indicate dal testo)
──────────────────────────────────────
subtotale =                4800 accessi
```
Cardinalità del risultato: 144000 righe in 1200 pagine (dato dal testo).

**Passo 3 — Nested Loop Join `CLIENTE ⋈ ORDINE`**

Formula generale con una pagina di buffer per tabella:
```
costo(NLJ) = NP(esterna) + NR(esterna) × NP(interna)
```
L'operando **esterno** è `CLIENTE` selezionato, che si trova **già nel buffer** → il termine `NP(esterna)` vale **0**.
L'operando **interno** è `ORDINE` selezionato, che occupa **1200 pagine** su disco e va riletto per ogni tupla esterna.

```
costo(NLJ) = 0 + 1200 × 1200 = 1.440.000 accessi
```

**Costo totale**

```
       400          (scansione CLIENTE)
+    4.800          (scansione ORDINE + scrittura del risultato)
+ 1.440.000         (Nested Loop Join)
─────────────
= 1.445.200 accessi a memoria secondaria
```

### Parte 2 — Costo con indice B+-tree di profondità 3 su `ORDINE.Cliente`

Con l'indice **non serve più** né scandire né materializzare `ORDINE`: per ogni cliente selezionato si accede direttamente agli ordini che lo riguardano (*Nested Loop Join con indice*).

Numero di ordini per cliente:
```
NR(ORDINE) / VAL(Cliente, ORDINE) = 432000 / 24000 = 18 ordini per cliente
```

Costo per ogni tupla esterna: `3` accessi per attraversare il B+-tree fino alla foglia, più `18` accessi per leggere le tuple corrispondenti (indice **secondario**, quindi ogni tupla può stare in una pagina diversa):

```
costo per cliente = 3 + 18 = 21 accessi
```

```
       400              (scansione CLIENTE)
+ 1200 × 21 = 25.200    (accesso indicizzato a ORDINE)
─────────────
=    25.600 accessi a memoria secondaria
```

Il predicato `O.Data > '01/01/2025'` viene valutato **al volo** sulle tuple recuperate tramite indice, senza costo aggiuntivo di accesso.

> **Confronto:** `1.445.200 → 25.600`, un miglioramento di circa **56 volte**. Il guadagno deriva dall'eliminazione della rilettura ripetuta delle 1200 pagine di `ORDINE` per ciascuna delle 1200 tuple di `CLIENTE`, sostituita da un accesso mirato.

---

## g) B+-tree, fan-out = 5 **(5)**

**Vincoli di riempimento con fan-out `n = 5`:**

```
NODO FOGLIA:   ⌈(n-1)/2⌉ ≤ #chiavi ≤ n-1        →   2 ≤ #chiavi ≤ 4
NODO INTERNO:  ⌈n/2⌉ ≤ #puntatori ≤ n           →   3 ≤ #puntatori ≤ 5
                                                →   2 ≤ #chiavi ≤ 4
NODO RADICE:   almeno 2 puntatori (se non è anche foglia)
```

### a) Costruzione dell'albero

Le 5 foglie richiedono 5 puntatori dalla radice, con 4 chiavi separatrici pari alla **prima chiave** di ciascuna foglia successiva alla prima: `H`, `M`, `R`, `U`.

```
                        ┌───┬───┬───┬───┐
                        │ H │ M │ R │ U │            radice: 4 chiavi, 5 puntatori (al massimo)
                        └─┬─┴─┬─┴─┬─┴─┬─┘
            ┌─────────────┘   │   │   └─────────────┐
            │           ┌─────┘   └─────┐           │
            ▼           ▼               ▼           ▼           ▼
       (B,C,E) ──── (H,I) ──── (M,N,O,P) ──── (R,S) ──── (U,V,Z)
```
Tutte le foglie hanno da 2 a 4 chiavi ✓ · la radice ha 5 puntatori ✓ · le foglie sono concatenate in ordine ✓

### b) Inserimento della chiave `Q`

**Ricerca della foglia:** `M ≤ Q < R` → si scende nel terzo puntatore → foglia `(M,N,O,P)`.

**Inserimento:** `(M,N,O,P,Q)` = **5 chiavi > 4** → **overflow della foglia → split**.

Split della foglia: le 5 chiavi si ripartiscono in `⌈5/2⌉ = 3` a sinistra e `2` a destra; la **prima chiave del nodo destro** (`P`) viene **copiata** (non spostata) nel padre:

```
(M,N,O)   (P,Q)          nuova chiave separatrice da inserire nella radice: P
```

**Propagazione nella radice:** `[H | M | P | R | U]` = **5 chiavi, 6 puntatori > 5** → **overflow del nodo interno → split**.

Split del nodo interno: la chiave **mediana** (la 3ª di 5, cioè `P`) viene **spostata** (non copiata) al livello superiore, creando una nuova radice; le restanti si ripartiscono.

```
                              ┌───┐
                              │ P │                       nuova radice: 1 chiave, 2 puntatori ✓
                              └─┬─┘
                  ┌─────────────┴─────────────┐
            ┌───┬───┐                   ┌───┬───┐
            │ H │ M │                   │ R │ U │         3 puntatori ciascuno ✓
            └─┬─┴─┬─┘                   └─┬─┴─┬─┘
        ┌─────┘   │   └───┐          ┌─────┘   │   └───┐
        ▼         ▼       ▼          ▼         ▼       ▼
    (B,C,E)    (H,I)   (M,N,O)    (P,Q)     (R,S)   (U,V,Z)
```

L'**altezza dell'albero è aumentata** da 2 a 3 livelli: è l'unico modo in cui un B+-tree può crescere in altezza, e il motivo per cui resta sempre **bilanciato** (tutte le foglie allo stesso livello).

### c) Rimozione della chiave `S`

**Ricerca della foglia:** `R ≤ S < U` → foglia `(R,S)`.

**Rimozione:** `(R)` = **1 chiave < 2** → **underflow della foglia**.

**Tentativo di prestito da un fratello adiacente** (con lo stesso padre `[R | U]`):
- fratello **sinistro** `(P,Q)`: ha 2 chiavi = il **minimo**, non può prestarne nessuna senza andare a sua volta in underflow;
- fratello **destro** `(U,V,Z)`: ha 3 chiavi > 2 → **può prestare**.

**Prestito dal fratello destro:** la chiave più piccola del fratello destro (`U`) si sposta nella foglia in underflow.

```
(R)  +  U   →   (R,U)          ✓ 2 chiavi
(U,V,Z)     →   (V,Z)          ✓ 2 chiavi
```

**Aggiornamento del separatore nel padre:** la chiave che separava le due foglie era `U`; ora la prima chiave della foglia destra è `V`, quindi il separatore diventa `V`.

```
                              ┌───┐
                              │ P │
                              └─┬─┘
                  ┌─────────────┴─────────────┐
            ┌───┬───┐                   ┌───┬───┐
            │ H │ M │                   │ R │ V │      ← separatore aggiornato da U a V
            └─┬─┴─┬─┘                   └─┬─┴─┬─┘
        ┌─────┘   │   └───┐          ┌─────┘   │   └───┐
        ▼         ▼       ▼          ▼         ▼       ▼
    (B,C,E)    (H,I)   (M,N,O)    (P,Q)     (R,U)   (V,Z)
```

Nessuna propagazione ulteriore: il padre non ha perso chiavi, quindi non va in underflow. Tutti i vincoli di riempimento sono rispettati.

> **Regola generale in caso di underflow di una foglia:** si tenta prima il **prestito** (*borrow*) da un fratello adiacente che abbia più del minimo di chiavi; solo se **nessuno** dei fratelli può prestare si procede alla **fusione** (*merge*) con un fratello, che comporta la rimozione di una chiave dal padre e può propagare l'underflow verso l'alto.

---

# PARTE B — LABORATORIO

## h) Dichiarazione PostgreSQL con vincoli **(3)**

```sql
CREATE TABLE Prodotto (
  cod_prodotto  CHAR(10)      PRIMARY KEY,                         -- (i)
  nome_prod     VARCHAR(64)   NOT NULL,                            -- (iv)
  categoria     VARCHAR(32),
  prezzo        NUMERIC(8,2)  NOT NULL  CHECK (prezzo > 0),        -- (iv) (vi)
  giacenza      INTEGER       DEFAULT 0 CHECK (giacenza >= 0),     -- (vi) (vii)

  CONSTRAINT sk_nome_categoria UNIQUE (nome_prod, categoria)       -- (iii)
);

CREATE TABLE Ordine (
  cod_ordine    CHAR(12)      PRIMARY KEY,                         -- (i)
  cliente       CHAR(10)      NOT NULL                             -- (iv)
                REFERENCES Cliente(cod_cliente)
                ON DELETE NO ACTION  ON UPDATE CASCADE,            -- (ii)
  data_ordine   DATE          NOT NULL,                            -- (iv)
  importo       NUMERIC(10,2),
  stato         VARCHAR(20)   NOT NULL                             -- (iv)
                DEFAULT 'in preparazione'                          -- (vii)
                CHECK (stato IN ('in preparazione','spedito',
                                 'consegnato','annullato')),       -- (v)
  corriere      CHAR(6)
);
```

**Note sui punti che si sbagliano più spesso:**

- **(ii)** *"la cancellazione di un cliente sia impedita se esistono suoi ordini"* → `ON DELETE NO ACTION` (equivalente a `RESTRICT`, ed è anche il comportamento **di default** in SQL, quindi ometterlo è ugualmente corretto). **Sbagliato** usare `ON DELETE CASCADE`, che cancellerebbe gli ordini, o `ON DELETE SET NULL`, incompatibile con il `NOT NULL` su `cliente`.
- **(iii)** una superchiave **composta** si dichiara con un **vincolo di tabella** `UNIQUE (nome_prod, categoria)`. **Sbagliato** scrivere `nome_prod VARCHAR(64) UNIQUE, categoria VARCHAR(32) UNIQUE`: sarebbero due vincoli distinti, ciascuno su una sola colonna, molto più restrittivi di quanto richiesto.
- **(vi)** i vincoli che coinvolgono un solo attributo sono **vincoli di dominio** e si possono scrivere in linea; se coinvolgessero due attributi della stessa riga sarebbero **vincoli di tupla** e andrebbero dichiarati a livello di tabella.
- Il `DEFAULT` e il `NOT NULL` sono **indipendenti**: il default fornisce un valore quando l'attributo è omesso nella `INSERT`, ma non impedisce di inserirvi esplicitamente `NULL` — serve comunque il `NOT NULL`.

## i) Query SQL

### i. [5] Clienti che nel 2025 hanno speso più di 1000 € in prodotti di categoria 'Informatica'

```sql
SELECT c.cognome, c.nome, c.email
FROM   cliente  c
       JOIN ordine   o ON c.cod_cliente = o.cliente
       JOIN riga     r ON o.cod_ordine  = r.ordine
       JOIN prodotto p ON r.prodotto    = p.cod_prodotto
WHERE  p.categoria = 'Informatica'
  AND  o.data_ordine >= DATE '2025-01-01'
  AND  o.data_ordine <  DATE '2026-01-01'
GROUP BY c.cod_cliente, c.cognome, c.nome, c.email
HAVING SUM(r.quantita * r.prezzo_unitario) > 1000;
```

> La spesa va calcolata sulle **righe d'ordine** (`quantita × prezzo_unitario`) e non sull'`importo` dell'ordine, perché quest'ultimo comprende anche prodotti di altre categorie. Si raggruppa su `cod_cliente` (la chiave) e non solo su cognome e nome, per non fondere omonimi.

### ii. [4] Per ogni provincia, numero e importo medio degli ordini consegnati (min. 50)

```sql
SELECT c.provincia,
       COUNT(*)        AS num_ordini,
       AVG(o.importo)  AS importo_medio
FROM   cliente c JOIN ordine o ON c.cod_cliente = o.cliente
WHERE  o.stato = 'consegnato'
GROUP BY c.provincia
HAVING COUNT(*) >= 50;
```

> `WHERE` filtra le **righe** prima del raggruppamento, `HAVING` filtra i **gruppi** dopo l'aggregazione: la condizione sullo stato va nel `WHERE`, quella sul numero di ordini nell'`HAVING`.

### iii. [5] Prodotti mai ordinati da clienti della regione 'Veneto'

```sql
SELECT p.cod_prodotto, p.nome_prod
FROM   prodotto p
WHERE  NOT EXISTS (
         SELECT *
         FROM   riga    r
                JOIN ordine  o ON r.ordine  = o.cod_ordine
                JOIN cliente c ON o.cliente = c.cod_cliente
         WHERE  r.prodotto  = p.cod_prodotto      -- correlazione con la query esterna
           AND  c.regione   = 'Veneto'
       );
```

*Formulazione alternativa con `NOT IN`:*

```sql
SELECT p.cod_prodotto, p.nome_prod
FROM   prodotto p
WHERE  p.cod_prodotto NOT IN (
         SELECT r.prodotto
         FROM   riga r JOIN ordine o ON r.ordine = o.cod_ordine
                       JOIN cliente c ON o.cliente = c.cod_cliente
         WHERE  c.regione = 'Veneto'
       );
```

> ⚠️ `NOT IN` è pericoloso se la sottoquery può restituire `NULL`: in tal caso l'intera condizione diventa `UNKNOWN` e il risultato è **vuoto**. Qui `r.prodotto` è chiave esterna `NOT NULL`, quindi la forma è sicura; in generale è preferibile `NOT EXISTS`.

### iv. [3] Clienti di Verona con email registrata, e indici utili

```sql
SELECT *
FROM   cliente
WHERE  citta = 'Verona'
  AND  email IS NOT NULL;
```

**Indici possibili e loro valutazione:**

| Indice | Valutazione |
|---|---|
| `CREATE INDEX ON cliente(citta);` — **B+-tree** su `citta` | il predicato è di **uguaglianza**, quindi un indice è potenzialmente utile. Conviene però solo se la **selettività** è buona: se i clienti sono distribuiti su molte città, poche tuple hanno `citta = 'Verona'` e l'indice paga; se invece la maggior parte dei clienti è di Verona, l'ottimizzatore preferirà comunque una **scansione sequenziale**, perché l'accesso indicizzato a molte tuple sparse costa più della scansione |
| `CREATE INDEX ON cliente USING hash (citta);` — **hash** | ammissibile perché il predicato è di sola uguaglianza, e costa un solo accesso. Ma non supporta interrogazioni su intervallo né ordinamenti su `citta`, quindi è meno versatile |
| `CREATE INDEX ON cliente(citta) WHERE email IS NOT NULL;` — **indice parziale** | ⭐ la soluzione migliore: l'indice contiene **solo** le righe che soddisfano già il secondo predicato, risulta più piccolo, più veloce da attraversare e non richiede di verificare `email IS NOT NULL` sulle tuple recuperate |
| `CREATE INDEX ON cliente(citta, email);` — **composito** | permette un *index-only scan* se la query proiettasse solo queste due colonne; qui la `SELECT *` obbliga comunque ad accedere alle tuple, quindi il vantaggio si riduce |

**Osservazione importante:** un indice su `email` da solo sarebbe inutile per questa query, perché `IS NOT NULL` non è un predicato selettivo (nella maggior parte dei casi quasi tutte le righe lo soddisfano) e in molti sistemi i valori nulli non sono nemmeno indicizzati.

## j) Query MongoDB **(3)**

**i.** Prodotti di 'Informatica' sotto i 500 € e disponibili:

```js
db.prodotti.find(
  {
    categoria: "Informatica",
    prezzo:    { $lt: 500 },
    giacenza:  { $gt: 0 }
  },
  { _id: 0, nome: 1, prezzo: 1 }
)
```

**ii.** Voto medio delle recensioni per categoria:

```js
db.prodotti.aggregate([
  { $unwind: "$recensioni" },
  { $group: {
      _id:       "$categoria",
      votoMedio: { $avg: "$recensioni.voto" },
      numRecensioni: { $sum: 1 }
  }},
  { $sort: { votoMedio: -1 } }
])
```

> `$unwind` produce un documento per ogni elemento dell'array `recensioni`; i prodotti **senza** recensioni vengono eliminati dalla pipeline (per conservarli servirebbe `{ $unwind: { path: "$recensioni", preserveNullAndEmptyArrays: true } }`).

## k) Transazioni: perdita di aggiornamento e lettura sporca **(6)**

### Perdita di aggiornamento (*lost update*)

**Definizione.** Due transazioni leggono lo **stesso** valore, lo modificano ciascuna in base al valore letto e lo riscrivono: la seconda scrittura sovrascrive la prima, che va **perduta**. Il risultato finale riflette **una sola** delle due modifiche.

```
   t1: bot  r1(x)  x = x + 1  w1(x)  commit  eot
   t2: bot  r2(x)  x = x + 1  w2(x)  commit  eot
```

```
        t1                    t2              valore di x su DB
        bot                                          [2]
        r1(x) → legge 2                              [2]
                              bot                    [2]
                              r2(x) → legge 2        [2]
        x = 3
        w1(x)                                        [3]
        commit                                       [3]
                              x = 3
                              w2(x)                  [3]   ← l'aggiornamento di t1 è perduto
                              commit                 [3]
```

Il valore corretto sarebbe `4` (due incrementi); il risultato è `3`. **Entrambe le transazioni committano**: l'anomalia non dipende da alcun fallimento.

**Esempio SQL concreto** (prenotazione di posti):

```sql
-- T1                                        -- T2
BEGIN;                                       BEGIN;
SELECT posti FROM evento WHERE id = 7;       SELECT posti FROM evento WHERE id = 7;
-- legge 100                                 -- legge 100
UPDATE evento SET posti = 99 WHERE id = 7;   UPDATE evento SET posti = 99 WHERE id = 7;
COMMIT;                                      COMMIT;
-- risultato: 99 invece di 98
```

**Livello di isolamento minimo per evitarla: `REPEATABLE READ`.** Il lock condiviso acquisito sulla lettura viene mantenuto fino alla fine della transazione, quindi la seconda transazione non può ottenere il lock esclusivo necessario alla scrittura finché la prima non ha concluso. `READ COMMITTED` **non basta**, perché rilascia il lock di lettura subito dopo la `SELECT`.

> *Nota pratica:* la stessa anomalia si evita anche a `READ COMMITTED` riscrivendo l'aggiornamento in forma atomica (`UPDATE evento SET posti = posti - 1 WHERE id = 7`) oppure usando `SELECT … FOR UPDATE`, che acquisisce subito il lock esclusivo.

### Lettura sporca (*dirty read*)

**Definizione.** Una transazione legge un valore scritto da un'altra transazione **non ancora committata**; se quest'ultima esegue in seguito un `rollback`, il valore letto **non è mai esistito** nella base di dati e ogni decisione presa su di esso è priva di fondamento.

```
   t1: bot  r1(x)  x = x + 1  w1(x)  ...  rollback  eot
   t2: bot                          r2(x)  ...  commit  eot
```

```
        t1                    t2              valore di x su DB
        bot                                          [2]
        r1(x) → legge 2                              [2]
        x = 3
        w1(x)                                        [3]
                              bot                    [3]
                              r2(x) → legge 3        [3]   ← lettura SPORCA
                              commit                 [3]
        rollback                                     [2]   ← x torna a 2
        eot
```

`t2` ha letto e usato il valore `3`, che dopo il rollback di `t1` non esiste più.

**Esempio SQL concreto:**

```sql
-- T1                                        -- T2
BEGIN;
UPDATE conto SET saldo = saldo + 5000
  WHERE numero = 15;
                                             BEGIN;
                                             SELECT saldo FROM conto WHERE numero = 15;
                                             -- legge il saldo GONFIATO, non committato
                                             INSERT INTO bonifico ...  -- decisione sbagliata
                                             COMMIT;
ROLLBACK;   -- il versamento non è mai avvenuto
```

**Livello di isolamento minimo per evitarla: `READ COMMITTED`.** È il primo livello che impedisce di leggere dati non committati; solo `READ UNCOMMITTED` la consente.

### Confronto riassuntivo

| | Perdita di aggiornamento | Lettura sporca |
|---|---|---|
| Operazioni coinvolte | scrittura – scrittura (entrambe precedute da lettura) | scrittura – lettura |
| Serve un `rollback` perché sia un'anomalia? | **No**: si manifesta anche se entrambe committano | **Sì**: diventa dannosa solo se lo scrittore esegue rollback |
| Effetto | un aggiornamento sparisce | una transazione decide su un dato mai esistito |
| Livello di isolamento minimo | `REPEATABLE READ` | `READ COMMITTED` |

**Tabella dei livelli di isolamento SQL** (✗ = anomalia possibile, ✓ = anomalia impedita):

| Livello | Lettura sporca | Perdita di aggiornamento / Lettura inconsistente | Inserimento fantasma |
|---|---|---|---|
| `READ UNCOMMITTED` | ✗ | ✗ | ✗ |
| `READ COMMITTED` | ✓ | ✗ | ✗ |
| `REPEATABLE READ` | ✓ | ✓ | ✗ |
| `SERIALIZABLE` | ✓ | ✓ | ✓ |

## l) Programma Python **(4)**

```python
import psycopg2

DSN = "dbname=negozio user=studente password=segreta host=localhost port=5432"

QUERY = """
    SELECT cod_prodotto, nome_prod, prezzo, giacenza
    FROM   prodotto
    WHERE  categoria = %s
      AND  prezzo   <= %s
      AND  giacenza  > 0
    ORDER BY prezzo ASC
"""


def main():
    categoria = input("Categoria: ").strip()

    while True:
        try:
            prezzo_max = float(input("Prezzo massimo (euro): ").strip().replace(",", "."))
            if prezzo_max <= 0:
                print("Il prezzo deve essere positivo.")
                continue
            break
        except ValueError:
            print("Valore non valido: inserire un numero.")

    conn = None
    try:
        conn = psycopg2.connect(DSN)
        with conn.cursor() as cur:
            cur.execute(QUERY, (categoria, prezzo_max))
            righe = cur.fetchall()

        if not righe:
            print(f"Nessun prodotto disponibile nella categoria {categoria} "
                  f"sotto i {prezzo_max:.2f} euro")
        else:
            print(f"\nProdotti disponibili in '{categoria}' fino a {prezzo_max:.2f} euro:\n")
            print(f"{'CODICE':<12} {'NOME':<40} {'PREZZO':>10} {'GIACENZA':>10}")
            print("-" * 76)
            for cod, nome, prezzo, giacenza in righe:
                print(f"{cod:<12} {nome:<40} {prezzo:>10.2f} {giacenza:>10}")
            print(f"\n{len(righe)} prodotti trovati.")

    except psycopg2.Error as e:
        print(f"Errore nell'accesso alla base di dati: {e}")
    finally:
        if conn is not None:
            conn.close()


if __name__ == "__main__":
    main()
```

**Punti che il docente valuta:**
- uso dei **parametri** `%s` invece della concatenazione di stringhe — evita la *SQL injection* e lascia al driver la formattazione corretta dei tipi;
- `ORDER BY prezzo ASC` **dentro la query**, non un ordinamento in Python: è il DBMS a saper ordinare in modo efficiente, eventualmente sfruttando un indice;
- gestione del **caso vuoto** con il messaggio richiesto dal testo;
- **chiusura** della connessione nel blocco `finally` (o uso del *context manager* `with`);
- gestione degli **errori** di connessione e di input.
