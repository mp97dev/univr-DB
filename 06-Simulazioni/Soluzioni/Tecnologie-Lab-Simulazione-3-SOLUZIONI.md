# Soluzioni — Prova di Tecnologie e Laboratorio, Simulazione 3

> Traccia: [`Tecnologie-Lab-Simulazione-3.md`](../Tecnologie-Lab-Simulazione-3.md)

---

# PARTE A — TECNOLOGIE

## a) Proprietà delle transazioni e verifica dei vincoli **(4)**

Una **transazione** è un'unità elementare di lavoro delimitata da `begin transaction` … `end transaction`, che termina con `commit work` o `rollback work`. Le sue quattro proprietà sono **ACID**:

| Proprietà | Enunciato | Modulo del DBMS che la garantisce | Meccanismo |
|---|---|---|---|
| **A**tomicità | la transazione è indivisibile: o tutti i suoi effetti sono resi definitivi, o nessuno | **Gestore dell'affidabilità** | log, regola **WAL**, procedura di **UNDO** |
| **C**onsistenza | la transazione porta la base di dati da uno stato consistente a un altro, rispettando i vincoli di integrità | **Gestore dell'integrità** (parte del gestore delle interrogazioni) | verifica dei vincoli di dominio, di tupla, di chiave, di integrità referenziale; trigger |
| **I**solamento | l'esecuzione di una transazione è indipendente da quella delle altre concorrenti | **Gestore della concorrenza** (*scheduler*) | locking a due fasi (**2PL**), lock condivisi/esclusivi, timestamp, livelli di isolamento |
| **D**urabilità | gli effetti di una transazione committata sono permanenti anche in caso di guasto | **Gestore dell'affidabilità** | log su memoria stabile, regola di **Commit-Precedenza**, procedura di **REDO** |

### Verifica immediata e verifica differita dei vincoli

La distinzione riguarda la proprietà di **CONSISTENZA**, ed è governata dal **gestore dell'integrità**.

Un vincolo di integrità è una condizione che deve valere sugli **stati** della base di dati. La proprietà di consistenza impone che lo stato **finale** della transazione sia consistente, ma **non** che lo siano tutti gli stati intermedi. Questo apre due possibilità:

**Verifica immediata.**
Il vincolo viene controllato **durante** l'esecuzione della transazione, subito dopo ogni istruzione che potrebbe violarlo.

- se il vincolo è violato, l'operazione viene rifiutata immediatamente e viene segnalato l'errore all'applicazione;
- il vantaggio è che **l'applicazione può reagire** alla violazione: può correggere i dati, intraprendere un'azione alternativa e proseguire, senza che l'intera transazione venga persa;
- lo svantaggio è che **non consente stati intermedi inconsistenti**, che in alcuni casi sono inevitabili.

**Verifica differita.**
Il controllo viene rimandato al momento del **commit**, quando si verificano tutti i vincoli in sospeso.

- se un vincolo risulta violato, l'intera transazione viene **disfatta** (`rollback`): l'applicazione non ha modo di reagire selettivamente;
- il vantaggio è che **consente stati intermedi inconsistenti**, purché lo stato finale sia consistente.

**Il caso in cui la verifica differita è indispensabile.** Si consideri un vincolo di integrità referenziale circolare, o più semplicemente un trasferimento fra due conti con il vincolo *"la somma dei saldi delle due filiali deve restare costante"*:

```sql
begin transaction;
    update CONTO set saldo = saldo - 1200 where numero = 15;
    -- ← in questo istante il vincolo è VIOLATO: mancano 1200 euro
    update CONTO set saldo = saldo + 1200 where numero = 205;
    -- ← ora il vincolo è di nuovo soddisfatto
commit work;
end transaction;
```

Con la verifica **immediata** la prima `update` verrebbe rifiutata e la transazione non potrebbe mai essere eseguita, pur essendo perfettamente legittima. Con la verifica **differita** lo stato intermedio inconsistente è tollerato e il controllo avviene solo al commit.

In SQL la modalità si specifica dichiarando il vincolo `DEFERRABLE` e impostando `SET CONSTRAINTS … DEFERRED`.

---

## b) L'indice secondario **(4)**

### (i) Caratteristiche della struttura

Un **indice** è una struttura ausiliaria che consente di accedere alle tuple di un file **senza scandirlo integralmente**. È organizzato come una sequenza di coppie

```
( valore della chiave di ricerca ,  puntatore alla tupla )
```

ordinate per valore della chiave, tipicamente realizzata come **B+-tree**.

Un indice è **secondario** (o *unclustered*, o *non clusterizzato*) quando **l'ordine delle chiavi nell'indice NON corrisponde all'ordine fisico delle tuple nel file dati**. Caratteristiche conseguenti:

- è necessariamente **denso**: deve contenere una voce per **ogni** tupla del file, perché dalla posizione di una tupla non si può dedurre nulla sulla posizione delle altre. (Un indice primario può invece essere **sparso**, con una sola voce per blocco, perché il file è ordinato.)
- il file dati può essere organizzato in qualunque modo (heap, ordinato su un altro attributo, hash su un altro attributo);
- su una stessa tabella si possono definire **molti** indici secondari, uno per ogni attributo o combinazione di attributi che si vuole rendere efficiente — mentre l'indice **primario** può essere uno solo, perché il file può essere ordinato fisicamente in un solo modo;
- la chiave di ricerca **non** deve necessariamente essere una chiave della relazione: può ammettere duplicati, nel qual caso a un valore corrispondono più puntatori (o una lista di puntatori).

### (ii) Algoritmo di ricerca di una tupla con chiave K

```
1. Si accede alla RADICE dell'indice (B+-tree) e la si carica in memoria centrale.
2. Si confronta K con le chiavi separatrici del nodo e si sceglie il puntatore
   verso il figlio corrispondente. Si ripete scendendo di livello in livello.
      → costo: un accesso a memoria secondaria per ogni livello attraversato,
        cioè PROFONDITÀ dell'albero (tipicamente 2-4 accessi)
3. Si raggiunge il NODO FOGLIA e vi si cerca K.
      - se K non è presente, la ricerca termina senza risultato;
      - se K è presente, si legge il PUNTATORE alla tupla.
4. Si segue il puntatore e si legge il BLOCCO DEL FILE DATI che contiene la tupla.
      → costo: 1 accesso ulteriore
5. Se la chiave ammette duplicati, si ripete il passo 4 per ogni puntatore
   associato a K, seguendo eventualmente le foglie concatenate.
      → costo: 1 accesso PER OGNI tupla corrispondente
```

**Costo complessivo per una ricerca puntuale:**

```
costo = profondità dell'indice  +  numero di tuple con chiave K
```

È esattamente la formula usata negli esercizi di ottimizzazione: `3 + 18`, `2 + 10`, e così via.

### (iii) Differenza rispetto a un indice primario (clustered)

| | Indice **primario** (*clustered*) | Indice **secondario** (*unclustered*) |
|---|---|---|
| Ordine fisico delle tuple | **coincide** con l'ordine delle chiavi dell'indice | **indipendente** dall'ordine delle chiavi |
| Densità | può essere **sparso** (una voce per blocco) → indice molto più piccolo, meno livelli | necessariamente **denso** (una voce per tupla) → indice più grande, più livelli |
| Quanti per tabella | **uno solo** | **molti** |
| Costo di lettura di `k` tuple consecutive (ricerca su intervallo) | `profondità + ⌈k / F⌉` accessi, dove `F` è il numero di tuple per blocco: le tuple sono **fisicamente contigue**, un blocco ne restituisce molte | `profondità + k` accessi **nel caso peggiore**: ogni tupla può stare in un blocco diverso, quindi ogni tupla costa un accesso |
| Costo di lettura su intervallo, esempio | 10 000 tuple con 100 tuple/blocco → `3 + 100 = 103` accessi | 10 000 tuple → `3 + 10 000 = 10 003` accessi |
| Manutenzione in inserimento | costosa: mantenere l'ordine fisico può richiedere lo spostamento di tuple o l'uso di aree di overflow | economica: la tupla si scrive dove c'è posto, si aggiorna solo l'indice |

**La differenza determinante è nel costo di una ricerca su intervallo**, dove l'indice primario è di ordini di grandezza più efficiente. Per una ricerca puntuale che restituisce **una sola** tupla i due indici hanno invece costo praticamente identico.

### (iv) Quando l'ottimizzatore preferisce la scansione sequenziale

L'accesso via indice secondario costa **un accesso per ogni tupla** recuperata, e le tuple stanno in blocchi sparsi. La scansione sequenziale costa `NP(R)` accessi ma legge **tutti** i blocchi, ciascuno una sola volta e in modo sequenziale (quindi con letture anticipate efficienti). Il confronto è dunque:

```
costo via indice secondario ≈ profondità + NR_selezionate
costo scansione sequenziale = NP(R)
```

L'indice **non conviene** nei casi seguenti:

1. **Bassa selettività del predicato.** Se il predicato seleziona una frazione elevata delle tuple, `NR_selezionate` supera `NP(R)` e la scansione vince. La soglia empirica è intorno al **10–15 %** delle righe: oltre, la scansione è preferibile. Esempio: `WHERE sesso = 'M'` su un milione di righe seleziona ~500 000 tuple → 500 000 accessi sparsi contro, poniamo, 10 000 blocchi da scandire.
2. **Tabella piccola.** Se la tabella occupa pochi blocchi (o entra interamente nel buffer), la scansione costa pochissimo e attraversare l'indice è puro sovraccarico.
3. **Predicato non utilizzabile dall'indice.** Funzioni applicate all'attributo (`WHERE UPPER(cognome) = 'ROSSI'`), `LIKE '%rossi'` con carattere jolly iniziale, confronti fra attributi diversi della stessa tabella, o predicati su un attributo che non è **prefisso** di un indice composito.
4. **Query che deve comunque leggere tutte le tuple**, ad esempio un aggregato senza `WHERE` (`SELECT COUNT(*)`, `SELECT AVG(…)`) — a meno che l'indice non consenta un *index-only scan*.
5. **Statistiche non aggiornate.** L'ottimizzatore decide sulla base dei **profili** (`NP`, `NR`, `VAL`); se le statistiche sono obsolete può scegliere male. In PostgreSQL si aggiornano con `ANALYZE`.

Al contrario, l'indice conviene quando la selettività è alta, quando la query può essere risolta **interamente dall'indice** (*index-only scan*, cioè quando tutti gli attributi proiettati sono nell'indice: si evita del tutto l'accesso al file dati), e quando l'indice serve a evitare un ordinamento (`ORDER BY` sulla chiave dell'indice).

---

## c) Proprietà ACID in MongoDB **(4)**

### Atomicità a livello di singolo documento

La garanzia fondamentale e nativa di MongoDB è che **ogni operazione di scrittura su un singolo documento è atomica**, per quanto complesso sia il documento. Un'operazione che aggiorna più campi, o che modifica più elementi di un array annidato, o vi aggiunge un sottodocumento, viene applicata **interamente o per nulla**: nessun altro client può osservare uno stato intermedio.

Questa è la ragione per cui, nella progettazione document-based, **l'incapsulamento non è solo un'ottimizzazione di lettura ma anche una scelta di correttezza**: mettendo in un solo documento tutto ciò che deve essere aggiornato insieme, si ottiene gratuitamente l'atomicità senza bisogno di transazioni. Se invece le informazioni correlate sono distribuite su documenti o collezioni diverse, la scrittura non è più atomica per default.

Storicamente questa era **l'unica** garanzia offerta: le operazioni multi-documento (`updateMany`, `insertMany`) sono atomiche sul singolo documento ma **non nel loro insieme** — un fallimento a metà lascia alcuni documenti modificati e altri no.

### Transazioni multi-documento

Dalla versione **4.0** MongoDB supporta le **transazioni multi-documento** all'interno di un **replica set**, e dalla versione **4.2** anche su **cluster sharded** (transazioni distribuite). Offrono le stesse garanzie ACID dei sistemi relazionali:

```js
const session = db.getMongo().startSession();
session.startTransaction();
try {
    conti.updateOne({ _id: "A" }, { $inc: { saldo: -1200 } }, { session });
    conti.updateOne({ _id: "B" }, { $inc: { saldo: +1200 } }, { session });
    session.commitTransaction();
} catch (e) {
    session.abortTransaction();
}
```

Vanno però usate con parsimonia: hanno un **costo prestazionale significativo**, sono soggette a un limite di durata (60 secondi per default) e il loro uso frequente è considerato il sintomo di un modello dei dati progettato "alla relazionale", che non sfrutta l'incapsulamento. La raccomandazione è **progettare i documenti in modo da non averne bisogno**.

### Write concern

Il **write concern** specifica il livello di **conferma** che MongoDB deve fornire per considerare conclusa un'operazione di scrittura, cioè **quanti nodi** del replica set devono averla registrata. È il parametro che governa il compromesso fra **durabilità** e **latenza**.

| Valore | Significato | Durabilità | Latenza |
|---|---|---|---|
| `w: 0` | *unacknowledged*: il client non attende alcuna conferma | nessuna garanzia: la scrittura può andare perduta senza che il client lo sappia | minima |
| `w: 1` (default) | conferma dal solo nodo **primario** | la scrittura è persa se il primario cade prima di replicarla e viene eletto un altro primario (*rollback*) | bassa |
| `w: "majority"` | conferma dalla **maggioranza** dei nodi votanti | ⭐ la scrittura **sopravvive** all'elezione di un nuovo primario: è l'unica impostazione che garantisce vera durabilità | più alta |
| `w: <n>` | conferma da `n` nodi | intermedia | intermedia |
| `j: true` | in aggiunta, la scrittura deve essere registrata sul **journal** su disco | protegge anche dal crash del singolo nodo | più alta |

Si può associare un `wtimeout` per evitare che la scrittura resti bloccata indefinitamente se troppi nodi sono irraggiungibili.

### Read concern

Il **read concern** specifica quali dati una lettura può restituire, in termini di **garanzia di consistenza**:

| Valore | Garanzia |
|---|---|
| `"local"` (default) | restituisce i dati più recenti del nodo interrogato, **senza garantire** che siano stati replicati sulla maggioranza: potrebbero essere annullati da un rollback |
| `"available"` | come `local` ma senza attese in contesto sharded: la più veloce, la meno consistente |
| `"majority"` | restituisce solo dati confermati dalla **maggioranza** dei nodi: garantisce che non verranno mai annullati (*read your writes* durevoli) |
| `"linearizable"` | garantisce di leggere l'effetto di tutte le scritture completate prima dell'inizio della lettura; la più forte e la più costosa |
| `"snapshot"` | usato nelle transazioni: legge da uno snapshot coerente della base di dati |

### Read preference e il compromesso fra consistenza, disponibilità e prestazioni

La **read preference** indica a quale membro del replica set indirizzare le **letture**:

| Valore | Comportamento | Conseguenza |
|---|---|---|
| `primary` (default) | tutte le letture vanno al **primario** | **massima consistenza**: si legge sempre lo stato più aggiornato. Ma il primario diventa un collo di bottiglia, e durante un'elezione le letture **falliscono** |
| `primaryPreferred` | il primario se disponibile, altrimenti un secondario | mantiene la disponibilità durante le elezioni, al prezzo di possibili letture stantie in quei momenti |
| `secondary` | solo i **secondari** | distribuisce il carico e migliora il throughput in lettura, ma si possono leggere dati **non aggiornati** (*eventual consistency*), per via del **replication lag** dovuto alla replicazione **asincrona** |
| `secondaryPreferred` | i secondari se disponibili, altrimenti il primario | come sopra, con fallback |
| `nearest` | il nodo con **latenza di rete minore**, indipendentemente dal ruolo | minima latenza (utile con nodi geograficamente distribuiti), nessuna garanzia sull'aggiornamento |

**Il compromesso.** La radice del problema è che la replicazione è **asincrona**: il primario conferma la scrittura senza attendere i secondari. Ne segue che:

- leggere dal **primario** dà consistenza forte ma non scala e non è disponibile durante le elezioni;
- leggere dai **secondari** scala e resta disponibile, ma espone a letture di dati arretrati.

È la manifestazione concreta del **teorema CAP**: in presenza di partizionamento della rete (`P`, che in un sistema distribuito non è opzionale) occorre scegliere fra consistenza (`C`) e disponibilità (`A`). MongoDB non impone una scelta rigida ma la rende **configurabile per operazione**, combinando write concern e read concern:

- `w: "majority"` + `readConcern: "majority"` + `readPreference: primary` → comportamento sostanzialmente **CP**, con garanzie vicine a quelle di un DBMS relazionale;
- `w: 1` + `readConcern: "local"` + `readPreference: nearest` → comportamento **AP**, massime prestazioni e disponibilità, consistenza solo eventuale.

---

## d) Gestore dell'affidabilità — ripresa a freddo **(4)**

Il guasto è **di dispositivo**: si è persa la **memoria secondaria**, cioè la base di dati su disco è distrutta o corrotta. Si applica la **ripresa a freddo** (*cold restart*), eseguita dal **gestore dell'affidabilità**.

### Numerazione del log

| # | record | | # | record |
|---|---|---|---|---|
| 1 | **`DUMP`** | | 10 | `U(T2,O4,B4,A4)` |
| 2 | `B(T1)` | | 11 | `C(T2)` |
| 3 | `B(T2)` | | 12 | `B(T4)` |
| 4 | `U(T1,O1,B1,A1)` | | 13 | `U(T4,O5,B5,A5)` |
| 5 | `I(T2,O2,A2)` | | 14 | `U(T3,O1,B6,A6)` |
| 6 | `C(T1)` | | 15 | `C(T3)` |
| 7 | `B(T3)` | | 16 | `B(T5)` |
| 8 | `U(T3,O3,B3,A3)` | | 17 | `I(T5,O6,A7)` |
| 9 | **`CK(T2,T3)`** | | — | **guasto di dispositivo** |

### Fase 1 — Ripristino dal dump

Si individua sul log l'ultimo record di **`DUMP`** (posizione 1), che segnala il momento in cui è stata effettuata la copia di backup della base di dati su **memoria stabile**. Si **ricarica** la base di dati (o la sola porzione danneggiata) a partire da quella copia.

Al termine di questa fase la base di dati si trova nello stato in cui era **all'istante del dump**, cioè prima dell'inizio di `T1`.

### Fase 2 — Riapplicazione di tutte le azioni dal dump in poi

Si percorre il log **in avanti** a partire dal record di `DUMP`, **riapplicando nell'ordine tutte le azioni** registrate — di **tutte** le transazioni, senza distinguere fra quelle committate e quelle non committate, e senza costruire alcun insieme UNDO/REDO:

| # | record | azione riapplicata |
|---|---|---|
| 4 | `U(T1,O1,B1,A1)` | `O1 = A1` |
| 5 | `I(T2,O2,A2)` | **inserisce** `O2` con valore `A2` |
| 8 | `U(T3,O3,B3,A3)` | `O3 = A3` |
| 10 | `U(T2,O4,B4,A4)` | `O4 = A4` |
| 13 | `U(T4,O5,B5,A5)` | `O5 = A5` |
| 14 | `U(T3,O1,B6,A6)` | `O1 = A6` |
| 17 | `I(T5,O6,A7)` | **inserisce** `O6` con valore `A7` |

Al termine di questa fase la base di dati si trova **esattamente nello stato che aveva nell'istante del guasto** — comprese quindi le modifiche delle transazioni rimaste incomplete. Il problema è ora ricondotto a quello di un guasto di sistema.

### Fase 3 — Ripresa a caldo

**Ultimo checkpoint:** `CK(T2,T3)` alla posizione **9**.
Inizializzazione: `UNDO = {T2, T3}`, `REDO = { }`. Percorrendo il log in avanti dalla posizione 10:

| # | record | azione | UNDO | REDO |
|---|---|---|---|---|
| — | — | inizializzazione | `{T2,T3}` | `{ }` |
| 11 | `C(T2)` | `T2` da UNDO a REDO | `{T3}` | `{T2}` |
| 12 | `B(T4)` | aggiungi `T4` | `{T3,T4}` | `{T2}` |
| 15 | `C(T3)` | `T3` da UNDO a REDO | `{T4}` | `{T2,T3}` |
| 16 | `B(T5)` | aggiungi `T5` | `{T4,T5}` | `{T2,T3}` |

```
UNDO = { T4, T5 }
REDO = { T2, T3 }
```

**Ripercorrimento all'indietro (UNDO).** La transazione più vecchia di `UNDO ∪ REDO = {T2,T3,T4,T5}` è `T2`, il cui `begin` è alla posizione **3**: ci si spinge all'indietro fino alla posizione 3. Disfacendo, in ordine inverso, le azioni delle transazioni in UNDO:

| # | record | azione di UNDO |
|---|---|---|
| 17 | `I(T5,O6,A7)` | **cancella** `O6` |
| 13 | `U(T4,O5,B5,A5)` | `O5 = B5` |

**Ripercorrimento in avanti (REDO).** Dalla posizione 3, rifacendo le azioni delle transazioni in REDO:

| # | record | azione di REDO |
|---|---|---|
| 5 | `I(T2,O2,A2)` | **inserisce** `O2` con valore `A2` |
| 8 | `U(T3,O3,B3,A3)` | `O3 = A3` |
| 10 | `U(T2,O4,B4,A4)` | `O4 = A4` |
| 14 | `U(T3,O1,B6,A6)` | `O1 = A6` |

### Stato finale della base di dati

```
O1 = A6      (scritto da T3, committata)
O2 = A2      (inserito da T2, committata)
O3 = A3      (scritto da T3, committata)
O4 = A4      (scritto da T2, committata)
O5 = B5      (ripristinato: T4 non aveva committato)
O6           CANCELLATO  (T5 non aveva committato)
```

### Osservazioni da riportare all'esame

1. **`T1` non compare né in UNDO né in REDO.** Ha committato alla posizione 6, **prima** del checkpoint della posizione 9: il checkpoint garantisce che le sue pagine siano già state forzate su disco. La sua azione `U(T1,O1,B1,A1)@4` viene però **riapplicata nella fase 2** (che riapplica *tutto* dal dump), e viene poi correttamente sovrascritta dal REDO di `U(T3,O1,B6,A6)@14`, che è cronologicamente successivo.
2. **La fase 2 riapplica anche le azioni di `T4` e `T5`, che poi la fase 3 disfa.** Sembra uno spreco, ed effettivamente lo è, ma è necessario: solo riportando la base di dati allo stato esatto del guasto la procedura di ripresa a caldo — che assume di operare su quello stato — produce il risultato corretto.
3. **Differenza chiave rispetto alla ripresa a caldo.** In un guasto di **sistema** la memoria secondaria è intatta, quindi le fasi 1 e 2 non servono e si parte direttamente dal checkpoint. Nella ripresa a **freddo** occorre ricostruire da zero il contenuto del disco, e per questo si parte dal record di **`DUMP`**, non dal checkpoint.
4. **La ripresa a freddo può richiedere molto tempo** (ore, se il dump è vecchio e il log è lungo). Per questo i dump vengono effettuati con regolarità: più recente è il dump, più corta è la fase 2.

---

## e) Esecuzione concorrente **(6)**

```
S: r1(x), r2(z), w1(x), r1(y), w1(y), w2(z), r2(y), r3(t), w2(y), w3(t), r3(x), w3(z)
     1       2       3       4       5       6       7       8       9      10      11      12
```

Operazioni per transazione:

```
T1:  r1(x)@1   w1(x)@3   r1(y)@4   w1(y)@5
T2:  r2(z)@2   w2(z)@6   r2(y)@7   w2(y)@9
T3:  r3(t)@8   w3(t)@10  r3(x)@11  w3(z)@12
```

### Conflict-serializzabilità (CSR)

| Oggetto | Operazioni | Conflitti (arco `Ti → Tj`) |
|---|---|---|
| `x` | `r1@1, w1@3, r3@11` | `w1@3 – r3@11` → **T1→T3** |
| `y` | `r1@4, w1@5, r2@7, w2@9` | `w1@5 – r2@7` → **T1→T2**; `r1@4 – w2@9` → **T1→T2**; `w1@5 – w2@9` → **T1→T2** |
| `z` | `r2@2, w2@6, w3@12` | `r2@2 – w3@12` → **T2→T3**; `w2@6 – w3@12` → **T2→T3** |
| `t` | `r3@8, w3@10` | nessuno (stessa transazione) |

**Grafo dei conflitti:**

```
              ┌──────────────────────────┐
              │                          ▼
            (T1) ─────────► (T2) ─────► (T3)
```

Archi: `T1→T2`, `T1→T3`, `T2→T3`.

Il grafo è **aciclico**: `T1` è una sorgente, `T3` è un pozzo, e l'unico arco fra `T1` e `T2` va da `T1` a `T2`. L'ordinamento topologico è unico: **`T1, T2, T3`**.

> ### ✅ **S è CSR**, conflict-equivalente allo schedule seriale `T1 T2 T3`.

### View-serializzabilità (VSR)

Poiché **CSR ⊂ VSR**, ogni schedule conflict-serializzabile è anche view-serializzabile.

> ### ✅ **S è VSR**, view-equivalente allo schedule seriale `T1 T2 T3`.

*Verifica diretta (facoltativa).*
- **LEGGE-DA(S):** `r2(y)@7` legge da `w1(y)@5` → `(T2, y, T1)`; `r3(x)@11` legge da `w1(x)@3` → `(T3, x, T1)`. Le letture `r1(x)@1`, `r2(z)@2`, `r1(y)@4` e `r3(t)@8` leggono il valore iniziale.
- **Scritture finali:** `x → w1@3` (T1), `y → w2@9` (T2), `z → w3@12` (T3), `t → w3@10` (T3).

Lo schedule seriale `T1 T2 T3` produce le stesse letture-da e le stesse scritture finali.

### Locking a due fasi (2PL) — con piano di locking

Occorre esibire un'assegnazione di lock tale che, **per ogni transazione**, tutte le acquisizioni precedano tutti i rilasci, e che rispetti la compatibilità (un lock esclusivo esclude ogni altro lock sullo stesso oggetto).

Si osservi che ogni transazione, sugli oggetti che poi scriverà, può acquisire direttamente un lock **esclusivo** già alla prima lettura, evitando il costo di un successivo *upgrade*.

**Piano di locking proposto** (i tempi frazionari indicano istanti fra due operazioni consecutive):

| Transazione | Acquisizioni | Ultima acquisizione | Rilasci | Primo rilascio |
|---|---|---|---|---|
| `T1` | `XL(x)` a **1** (per `r1(x)@1`, `w1(x)@3`) · `XL(y)` a **4** (per `r1(y)@4`, `w1(y)@5`) | **4** | `y` a **6** · `x` a **10** | **6** |
| `T2` | `XL(z)` a **2** (per `r2(z)@2`, `w2(z)@6`) · `XL(y)` a **7** (per `r2(y)@7`, `w2(y)@9`) | **7** | `z` a **11** · `y` a fine transazione | **11** |
| `T3` | `XL(t)` a **8** · `XL(x)` a **11** · `XL(z)` a **12** | **12** | tutti a fine transazione (dopo 12) | **> 12** |

**Verifica della regola delle due fasi:**

```
T1:   ultima acquisizione = 4     <  primo rilascio = 6      ✓
T2:   ultima acquisizione = 7     <  primo rilascio = 11     ✓
T3:   ultima acquisizione = 12    <  primo rilascio > 12     ✓
```

**Verifica della compatibilità dei lock:**

| Istante | Richiesta | L'oggetto è libero? |
|---|---|---|
| 7 | `T2` chiede `XL(y)` | `T1` detiene `y` da 4 e lo rilascia a **6** → libero a 7 ✓ (e il rilascio a 6 è lecito perché l'ultima acquisizione di `T1` è a 4) |
| 11 | `T3` chiede `XL(x)` | `T1` detiene `x` da 1 e lo rilascia a **10** → libero a 11 ✓ |
| 12 | `T3` chiede `XL(z)` | `T2` detiene `z` da 2 e lo rilascia a **11** → libero a 12 ✓ (lecito: l'ultima acquisizione di `T2` è a 7) |
| 8 | `T3` chiede `XL(t)` | nessun'altra transazione tocca `t` ✓ |

Tutte le richieste sono soddisfatte senza attese, e nessuna transazione acquisisce un lock dopo averne rilasciato uno.

> ### ✅ **S è 2PL.**

**Riepilogo:** `S` è VSR ✅, è CSR ✅, è 2PL ✅.
Coerentemente con l'inclusione **2PL ⊂ CSR ⊂ VSR**, uno schedule 2PL è necessariamente anche CSR e VSR: una volta verificato che `S` è 2PL, le altre due risposte seguono automaticamente. All'esame conviene comunque **disegnare il grafo dei conflitti**, sia perché è richiesto esplicitamente, sia perché è il modo più rapido per accorgersi se lo schedule **non** è CSR (e quindi nemmeno 2PL, risparmiando la costruzione del piano di locking).

---

## f) Ottimizzazione **(5)**

### Parte 1 — Costo senza indice

**Dati:** `NP(SOCIO) = 150`, `NR(SOCIO) = 12000`, `NP(INGRESSO) = 2000`, `NR(INGRESSO) = 240000`, `VAL(Citta, SOCIO) = 25`, `VAL(Socio, INGRESSO) = 12000`.

**Passo 1 — selezione su `SOCIO` (scansione, risultato nel buffer)**

```
costo = NP(SOCIO) = 150 accessi
```
Cardinalità del risultato:
```
NR(SOCIO con Citta='Verona') = NR(SOCIO) / VAL(Citta, SOCIO) = 12000 / 25 = 480 tuple
```
Il risultato resta **nel buffer** → nessun costo di scrittura né di rilettura.

**Passo 2 — selezione su `INGRESSO` (scansione, risultato salvato su disco)**

```
lettura   = NP(INGRESSO) = 2000 accessi
scrittura =                 640 accessi   (le 640 pagine indicate dal testo)
────────────────────────────────────────
subtotale =                2640 accessi
```
Cardinalità del risultato: 76800 righe in 640 pagine (dato dal testo).

**Passo 3 — Nested Loop Join `SOCIO ⋈ INGRESSO`**

```
costo(NLJ) = NP(esterna) + NR(esterna) × NP(interna)
```
L'operando **esterno** è `SOCIO` selezionato, che si trova **già nel buffer** → `NP(esterna) = 0`.
L'operando **interno** è `INGRESSO` selezionato, materializzato su **640 pagine** di disco, da rileggere per ogni tupla esterna.

```
costo(NLJ) = 0 + 480 × 640 = 307.200 accessi
```

**Costo totale**

```
      150          (scansione SOCIO)
+   2.640          (scansione INGRESSO + scrittura del risultato)
+ 307.200          (Nested Loop Join)
─────────────
= 309.990 accessi a memoria secondaria
```

### Parte 2 — Costo con indice B+-tree di profondità 3 su `INGRESSO.Socio`

Con l'indice **non serve più** né scandire né materializzare `INGRESSO`: per ogni socio selezionato si accede direttamente ai suoi ingressi.

Numero di ingressi per socio:
```
NR(INGRESSO) / VAL(Socio, INGRESSO) = 240000 / 12000 = 20 ingressi per socio
```

Costo per ogni tupla esterna: `3` accessi per attraversare il B+-tree fino alla foglia, più `20` accessi per leggere le tuple corrispondenti (indice **secondario**: ogni tupla può stare in un blocco diverso):

```
costo per socio = 3 + 20 = 23 accessi
```

```
      150              (scansione SOCIO)
+ 480 × 23 = 11.040    (accesso indicizzato a INGRESSO)
─────────────
=  11.190 accessi a memoria secondaria
```

Il predicato `I.Data > '01/09/2025'` viene valutato **al volo** sulle tuple recuperate tramite indice, senza costo aggiuntivo.

> **Confronto:** `309.990 → 11.190`, un miglioramento di circa **28 volte**.
>
> **Osservazione avanzata.** Un indice B+-tree **composito** su `(Socio, Data)` sarebbe ancora migliore: consentirebbe di applicare **entrambi** i predicati durante l'attraversamento dell'indice, recuperando solo le tuple che soddisfano anche la condizione sulla data invece di tutte e 20 quelle del socio.

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

Le 5 foglie richiedono 5 puntatori dalla radice, con 4 chiavi separatrici pari alla **prima chiave** di ciascuna foglia successiva alla prima: `F`, `K`, `P`, `T`.

```
                        ┌───┬───┬───┬───┐
                        │ F │ K │ P │ T │        radice: 4 chiavi, 5 puntatori (al massimo)
                        └─┬─┴─┬─┴─┬─┴─┬─┘
            ┌─────────────┘   │   │   └─────────────┐
            │           ┌─────┘   └─────┐           │
            ▼           ▼               ▼           ▼           ▼
       (A,B,D) ──── (F,G) ──── (K,L,M,N) ──── (P,R,S) ──── (T,W,Z)
```

### b) Inserimento della chiave `O`

**Ricerca della foglia:** `K ≤ O < P` → terzo puntatore → foglia `(K,L,M,N)`.

**Inserimento:** `(K,L,M,N,O)` = **5 chiavi > 4** → **split della foglia**.
Le 5 chiavi si ripartiscono in `⌈5/2⌉ = 3` a sinistra e `2` a destra; la prima chiave del nodo destro (`N`) viene **copiata** nel padre:

```
(K,L,M)   (N,O)              nuova chiave separatrice da inserire nella radice: N
```

**Propagazione nella radice:** `[F | K | N | P | T]` = **5 chiavi, 6 puntatori > 5** → **split del nodo interno**.
La chiave **mediana** (la 3ª di 5, cioè `N`) viene **spostata** (non copiata) al livello superiore, creando una nuova radice:

```
                              ┌───┐
                              │ N │                  nuova radice: 1 chiave, 2 puntatori ✓
                              └─┬─┘
                  ┌─────────────┴─────────────┐
            ┌───┬───┐                   ┌───┬───┐
            │ F │ K │                   │ P │ T │    3 puntatori ciascuno ✓
            └─┬─┴─┬─┘                   └─┬─┴─┬─┘
        ┌─────┘   │   └───┐          ┌─────┘   │   └───┐
        ▼         ▼       ▼          ▼         ▼       ▼
    (A,B,D)    (F,G)   (K,L,M)    (N,O)    (P,R,S)  (T,W,Z)
```

L'**altezza è cresciuta** da 2 a 3 livelli.

### c) Rimozione della chiave `G`

**Ricerca della foglia:** `F ≤ G < K` → foglia `(F,G)`.

**Rimozione:** `(F)` = **1 chiave < 2** → **underflow della foglia**.

**Tentativo di prestito da un fratello adiacente** (con lo stesso padre `[F | K]`):
- fratello **sinistro** `(A,B,D)`: ha **3 chiavi > 2** → **può prestare**;
- fratello **destro** `(K,L,M)`: ha anch'esso 3 chiavi, andrebbe bene, ma per convenzione si tenta prima il fratello sinistro.

**Prestito dal fratello sinistro:** poiché il fratello che presta sta **a sinistra**, la chiave che si sposta è la sua **più grande** (`D`), che diventa la **più piccola** della foglia in underflow:

```
(A,B,D)  →  (A,B)          ✓ 2 chiavi
(F)  +  D   →  (D,F)       ✓ 2 chiavi
```

**Aggiornamento del separatore nel padre:** la chiave che separava le due foglie era `F`; ora la prima chiave della foglia destra è `D`, quindi il separatore diventa `D`.

```
                              ┌───┐
                              │ N │
                              └─┬─┘
                  ┌─────────────┴─────────────┐
            ┌───┬───┐                   ┌───┬───┐
            │ D │ K │                   │ P │ T │
            └─┬─┴─┬─┘                   └─┬─┴─┬─┘
              │                     ← separatore aggiornato da F a D
        ┌─────┘   │   └───┐          ┌─────┘   │   └───┐
        ▼         ▼       ▼          ▼         ▼       ▼
     (A,B)     (D,F)   (K,L,M)    (N,O)    (P,R,S)  (T,W,Z)
```

Nessuna propagazione ulteriore: il padre non ha perso chiavi (una è stata solo **sostituita**), quindi non va in underflow. Tutti i vincoli di riempimento sono rispettati.

> **Prestito da sinistra o da destra?** La regola è simmetrica ma il **verso** cambia:
> - prestito dal fratello **sinistro** → si sposta la sua chiave **più grande**, che entra come **prima** chiave della foglia in underflow; il separatore diventa la **nuova prima chiave** della foglia destra;
> - prestito dal fratello **destro** → si sposta la sua chiave **più piccola**, che entra come **ultima** chiave della foglia in underflow; il separatore diventa la **nuova prima chiave** del fratello destro.
>
> In entrambi i casi il padre **non perde** chiavi: una viene semplicemente aggiornata. È questa la differenza rispetto alla **fusione**, che invece elimina una chiave dal padre e può propagare l'underflow verso l'alto.

---

# PARTE B — LABORATORIO

## h) Dichiarazione PostgreSQL con vincoli **(3)**

```sql
CREATE TABLE Corso (
  cod_corso        CHAR(8)      PRIMARY KEY,                        -- (i)
  nome_corso       VARCHAR(48)  NOT NULL,                           -- (iv)
  istruttore       CHAR(10)     NOT NULL                            -- (iv)
                   REFERENCES Istruttore(cod_istruttore),
  sala             VARCHAR(24),
  giorno_settimana VARCHAR(12)
                   CHECK (giorno_settimana IN
                          ('lunedi','martedi','mercoledi','giovedi',
                           'venerdi','sabato','domenica')),         -- (v)
  ora_inizio       TIME,
  durata           INTEGER      DEFAULT 60                          -- (vii)
                   CHECK (durata BETWEEN 30 AND 120),               -- (vi)
  max_posti        INTEGER      NOT NULL                            -- (iv)
                   CHECK (max_posti > 0),                           -- (vi)

  CONSTRAINT sk_sala_orario UNIQUE (sala, giorno_settimana, ora_inizio)   -- (iii)
);

CREATE TABLE Partecipazione (
  socio     CHAR(10)  REFERENCES Socio(cod_socio),                  -- (ii)
  corso     CHAR(8)   REFERENCES Corso(cod_corso)
                      ON DELETE CASCADE,                            -- (ii)
  data      DATE,
  presente  BOOLEAN   DEFAULT FALSE,                                -- (vii)

  CONSTRAINT pk_partecipazione PRIMARY KEY (socio, corso, data)     -- (i)
);
```

**Note sui punti critici:**

- **(i)** la chiave primaria **composta** si dichiara obbligatoriamente come **vincolo di tabella**: `PRIMARY KEY (socio, corso, data)`. Non è esprimibile in linea sulle singole colonne. Come effetto collaterale rende i tre attributi automaticamente `NOT NULL`.
- **(ii)** *"la cancellazione di un corso comporti la cancellazione delle relative partecipazioni"* → `ON DELETE CASCADE` sulla sola chiave esterna verso `Corso`. Sulla chiave esterna verso `Socio` non è richiesto nulla, quindi vale il default `NO ACTION`. Attenzione a non applicare il `CASCADE` a entrambe: il testo lo chiede solo per il corso.
- **(iii)** la superchiave su **tre** attributi richiede un `UNIQUE` di tabella. Il vincolo esprime il fatto che in una data sala, in un dato giorno e a una data ora si può tenere un solo corso.
- **(vi)** `BETWEEN 30 AND 120` è inclusivo su entrambi gli estremi, coerentemente con *"compresa fra 30 e 120"*.
- **(vii)** `DEFAULT FALSE` su un `BOOLEAN` e `DEFAULT 60` su `durata`: il default **non** implica `NOT NULL`, i due vincoli sono indipendenti.

## i) Query SQL

### i. [5] Soci con più ingressi nel fine settimana che nei giorni feriali

```sql
SELECT s.cod_socio, s.nome, s.cognome
FROM   socio s
WHERE  ( SELECT COUNT(*)
         FROM   ingresso i
         WHERE  i.socio = s.cod_socio
           AND  EXTRACT(DOW FROM i.data) IN (0, 6) )        -- 0 = domenica, 6 = sabato
     > ( SELECT COUNT(*)
         FROM   ingresso i
         WHERE  i.socio = s.cod_socio
           AND  EXTRACT(DOW FROM i.data) BETWEEN 1 AND 5 ); -- da lunedì a venerdì
```

> In PostgreSQL `EXTRACT(DOW FROM data)` restituisce il giorno della settimana con **0 = domenica** … **6 = sabato**. (`ISODOW` usa invece 1 = lunedì … 7 = domenica: con quella funzione il fine settimana sarebbe `IN (6, 7)`.)
>
> Come nel pattern *"più X che Y"*, le due sottoquery sono **correlate** con la riga esterna. La forma con sottoquery correlate include correttamente anche i soci con **zero** ingressi feriali, che un join interno escluderebbe.
>
> *Formulazione alternativa con conteggi condizionati:*
> ```sql
> SELECT s.cod_socio, s.nome, s.cognome
> FROM   socio s JOIN ingresso i ON s.cod_socio = i.socio
> GROUP BY s.cod_socio, s.nome, s.cognome
> HAVING COUNT(*) FILTER (WHERE EXTRACT(DOW FROM i.data) IN (0,6))
>      > COUNT(*) FILTER (WHERE EXTRACT(DOW FROM i.data) BETWEEN 1 AND 5);
> ```

### ii. [4] Per ogni istruttore, corsi tenuti e media dei presenti (min. 3 corsi)

> *Interpretazione:* per ciascun corso si conta il numero di partecipazioni con `presente = TRUE`; si calcola poi, per ogni istruttore, la media di tale conteggio sui suoi corsi.

```sql
WITH presenze_per_corso AS (
    SELECT c.cod_corso,
           c.istruttore,
           COUNT(*) FILTER (WHERE p.presente) AS num_presenti
    FROM   corso c LEFT JOIN partecipazione p ON c.cod_corso = p.corso
    GROUP BY c.cod_corso, c.istruttore
)
SELECT i.cod_istruttore,
       i.nome,
       i.cognome,
       COUNT(*)                    AS num_corsi,
       AVG(pc.num_presenti)        AS media_presenti
FROM   istruttore i JOIN presenze_per_corso pc
       ON i.cod_istruttore = pc.istruttore
GROUP BY i.cod_istruttore, i.nome, i.cognome
HAVING COUNT(*) >= 3;
```

> Tre punti da giustificare all'esame:
> - **doppia aggregazione**: non si può calcolare la media dei presenti per corso con un solo `GROUP BY`; serve prima aggregare per corso, poi aggregare quel risultato per istruttore. Da qui la vista/CTE intermedia.
> - **`LEFT JOIN`** nella CTE: un corso senza alcuna partecipazione registrata deve contare come **0 presenti**, non essere escluso. Con `COUNT(*) FILTER (WHERE p.presente)` la riga generata dal left join (con `p.presente` a `NULL`) viene esclusa dal conteggio, che risulta correttamente 0.
> - `COUNT(*) FILTER (WHERE …)` è sintassi PostgreSQL; la forma portabile equivalente è `SUM(CASE WHEN p.presente THEN 1 ELSE 0 END)`.

### iii. [5] Soci di Verona con ingressi 2025 sopra la media dei soci di Padova

```sql
CREATE VIEW ingressi_2025 AS
SELECT s.cod_socio,
       s.citta,
       COUNT(i.cod_ingresso) AS num_ingressi
FROM   socio s LEFT JOIN ingresso i
       ON  s.cod_socio = i.socio
       AND i.data >= DATE '2025-01-01'
       AND i.data <  DATE '2026-01-01'
GROUP BY s.cod_socio, s.citta;

SELECT COUNT(*)
FROM   ingressi_2025 v
WHERE  v.citta = 'Verona'
  AND  v.num_ingressi > ( SELECT AVG(v1.num_ingressi)
                          FROM   ingressi_2025 v1
                          WHERE  v1.citta = 'Padova' );
```

> Due dettagli che fanno la differenza:
> - le condizioni sulla **data** stanno nella clausola `ON` del `LEFT JOIN`, **non** nel `WHERE`. Se stessero nel `WHERE`, le righe con `i.data` a `NULL` (soci senza ingressi nel 2025) verrebbero eliminate e quei soci scomparirebbero dal conteggio, mentre devono contare con **0 ingressi** — sia per il confronto di Verona sia, soprattutto, per la **media** di Padova.
> - `COUNT(i.cod_ingresso)` e non `COUNT(*)`: con il left join, un socio senza ingressi produce comunque una riga, e `COUNT(*)` restituirebbe erroneamente 1. `COUNT(colonna)` ignora i valori nulli e restituisce correttamente 0.

### iv. [3] Ingressi del tornello 'T1' in una data, e indici utili

```sql
SELECT *
FROM   ingresso
WHERE  tornello = 'T1'
  AND  data = DATE '2026-03-10';
```

**Indici possibili e loro valutazione:**

| Indice | Valutazione |
|---|---|
| `CREATE INDEX ON ingresso(tornello, data);` — **B+-tree composito** | ⭐ la soluzione migliore. **Entrambi** i predicati sono di uguaglianza, quindi l'indice composito li applica **entrambi** durante l'attraversamento e individua direttamente l'insieme esatto delle tuple. La selettività combinata è molto alta (pochi tornelli × pochi ingressi al giorno per tornello), quindi si recuperano poche tuple |
| `CREATE INDEX ON ingresso(data, tornello);` — **composito, ordine invertito** | equivalente per **questa** query, dato che entrambi i predicati sono di uguaglianza. La scelta dell'ordine conta per **altre** query: il primo attributo dell'indice è l'unico utilizzabile da solo, quindi si mette per primo quello più spesso presente nelle interrogazioni. Poiché `data` è tipicamente usata anche da sola (e su **intervallo**: "ingressi del mese di marzo"), l'ordine `(data, tornello)` è in pratica preferibile |
| `CREATE INDEX ON ingresso(tornello);` — **su una sola colonna** | utile ma inferiore: individua tutti gli ingressi di quel tornello (potenzialmente decine di migliaia, accumulati negli anni) e poi il predicato sulla data va verificato tupla per tupla |
| `CREATE INDEX ON ingresso(data);` — **su una sola colonna** | ragionevole: la selettività della data è buona (una giornata su diversi anni di storico), e il filtro sul tornello si applica poi al volo |
| Indici **hash** su `tornello` e su `data` | ammissibili singolarmente, perché i predicati sono di uguaglianza, ma **due indici hash separati non si combinano bene** e nessuno dei due esclude da solo abbastanza tuple. Inoltre l'hash non servirebbe per le interrogazioni su intervallo di date, che sono frequentissime su una tabella di questo tipo |

**Osservazione sulla selettività.** `tornello` da solo ha selettività **pessima** (`VAL(tornello, INGRESSO)` è dell'ordine di poche unità: un impianto ha 2–5 tornelli), quindi un indice sul solo tornello selezionerebbe circa un quinto della tabella e l'ottimizzatore lo scarterebbe a favore della scansione sequenziale. È la **combinazione** con la data a rendere il predicato selettivo: da qui la preferenza per l'indice composito.

## j) Query MongoDB **(3)**

**i.** Corsi del lunedì in Sala A di durata non superiore a 60 minuti:

```js
db.corsi.find(
  {
    giornoSettimana: "lunedi",
    sala:            "Sala A",
    durata:          { $lte: 60 }
  },
  { _id: 0, nome: 1, oraInizio: 1, "istruttore.cognome": 1 }
)
```

> L'accesso al campo di un sottodocumento nella proiezione usa la **dot notation** fra virgolette: `"istruttore.cognome": 1`.

**ii.** Per specialità di istruttore, iscritti totali e media delle presenze:

```js
db.corsi.aggregate([
  { $unwind: "$iscritti" },
  { $group: {
      _id:           "$istruttore.specialita",
      numIscritti:   { $sum: 1 },
      mediaPresenze: { $avg: "$iscritti.presenze" },
      numCorsi:      { $addToSet: "$_id" }
  }},
  { $project: {
      _id: 1, numIscritti: 1, mediaPresenze: 1,
      numCorsi: { $size: "$numCorsi" }
  }},
  { $sort: { numIscritti: -1 } }
])
```

> `$unwind` produce un documento per ogni elemento dell'array `iscritti`, quindi `$sum: 1` conta correttamente gli **iscritti** e `$avg` calcola la media delle presenze **per iscritto**. Se si volesse anche il numero di **corsi**, non lo si può contare con `$sum: 1` (ogni corso comparirebbe tante volte quanti sono i suoi iscritti): serve `$addToSet` sull'`_id` del corso seguito da `$size`, come mostrato.

## k) Transazioni: aggiornamento fantasma e lettura sporca **(6)**

### Aggiornamento fantasma (*ghost update*)

**Definizione.** Una transazione legge **due dati diversi** che sono legati da un **vincolo di integrità**, e li legge in due momenti fra i quali un'altra transazione ha modificato **entrambi** rispettando il vincolo. La transazione lettrice osserva così uno stato che **non rispetta il vincolo** e che non è mai esistito nella base di dati.

La particolarità è che le due transazioni, prese singolarmente, sono corrette: nessun valore letto è "sporco", ogni valore letto è stato committato o è comunque coerente. È la **combinazione** delle letture a essere incoerente.

```
   Vincolo di integrità:   x + y + z = 1000

   t1: bot  r1(x)          r1(y)          r1(z)   s = x+y+z   commit  eot
   t2: bot        r2(y) r2(z) y=y-100 z=z+100 w2(y) w2(z)  commit  eot
```

```
        t1                       t2                x     y     z
        bot                                       100   500   400
        r1(x) → 100                               100   500   400
                                 bot              100   500   400
                                 r2(y) → 500      100   500   400
                                 r2(z) → 400      100   500   400
                                 w2(y) → 400      100   400   400
                                 w2(z) → 500      100   400   500
                                 commit           100   400   500
        r1(y) → 400                               100   400   500
        r1(z) → 500                               100   400   500
        somma = 100 + 400 + 500 = 1000   ← in questo caso corretto
```

Perché l'anomalia si manifesti basta invertire l'ordine delle letture di `t1`:

```
        t1                       t2                x     y     z
        bot                                       100   500   400
        r1(x) → 100                               100   500   400
        r1(y) → 500                               100   500   400
                                 bot
                                 w2(y) → 400      100   400   400
                                 w2(z) → 500      100   400   500
                                 commit           100   400   500
        r1(z) → 500                               100   400   500
        somma = 100 + 500 + 500 = 1100   ← VINCOLO VIOLATO: stato mai esistito
```

`t1` ha letto `y` **prima** dell'aggiornamento e `z` **dopo**: la somma che ottiene non corrisponde ad alcuno stato reale della base di dati.

**Esempio SQL concreto** (trasferimento fra due conti):

```sql
-- T1 (rendiconto)                              -- T2 (bonifico interno)
BEGIN;
SELECT saldo FROM conto WHERE numero = 15;
-- legge 1000
                                                BEGIN;
                                                UPDATE conto SET saldo = saldo - 300
                                                  WHERE numero = 15;
                                                UPDATE conto SET saldo = saldo + 300
                                                  WHERE numero = 205;
                                                COMMIT;
SELECT saldo FROM conto WHERE numero = 205;
-- legge 700 (già incrementato)
COMMIT;
-- totale calcolato: 1000 + 700 = 1700, mentre il totale reale è 1400
```

**Livello di isolamento minimo per evitarlo: `REPEATABLE READ`.** Mantenendo i lock condivisi su tutti i dati letti fino alla fine della transazione, `t2` non può ottenere il lock esclusivo per modificarli mentre `t1` è in corso.

### Lettura sporca (*dirty read*)

**Definizione.** Una transazione legge un valore scritto da un'altra transazione **non ancora committata**; se quest'ultima esegue successivamente un `rollback`, il valore letto **non è mai esistito** nella base di dati e ogni decisione presa su di esso è priva di fondamento.

```
   t1: bot  r1(x)  x=x+1  w1(x)  ...  rollback  eot
   t2: bot                       r2(x)  ...  commit  eot
```

```
        t1                       t2                valore di x
        bot                                            [2]
        r1(x) → 2                                      [2]
        w1(x) → 3                                      [3]
                                 bot                   [3]
                                 r2(x) → legge 3       [3]   ← lettura SPORCA
                                 commit                [3]
        rollback                                       [2]   ← x torna a 2
```

**Esempio SQL concreto:**

```sql
-- T1                                            -- T2
BEGIN;
UPDATE conto SET saldo = saldo + 5000
  WHERE numero = 15;
                                                 BEGIN;
                                                 SELECT saldo FROM conto WHERE numero = 15;
                                                 -- legge il saldo GONFIATO, non committato
                                                 INSERT INTO bonifico …;  -- decisione errata
                                                 COMMIT;
ROLLBACK;   -- il versamento non è mai avvenuto
```

**Livello di isolamento minimo per evitarla: `READ COMMITTED`.** È il primo livello che impedisce di leggere dati non committati; solo `READ UNCOMMITTED` la consente.

### Quale delle due può manifestarsi anche in assenza di rollback

> **L'aggiornamento fantasma.**

La distinzione è concettualmente importante:

- la **lettura sporca** è un'anomalia **condizionata al fallimento**: finché `t1` procede fino al `commit`, il valore che `t2` ha letto in anticipo si rivela alla fine corretto e nessun danno si produce. L'anomalia si concretizza **solo se** `t1` esegue un `rollback`, rendendo retroattivamente falso il dato già usato da `t2`. È quindi legata a un **fallimento** di transazione;
- l'**aggiornamento fantasma** si manifesta invece con **entrambe le transazioni che committano regolarmente**. Nessun valore letto da `t1` è "sporco": ciascuno è stato scritto e committato correttamente da `t2`. Il problema è che `t1` ne ha letti alcuni **prima** e altri **dopo** l'aggiornamento di `t2`, componendo una vista che non corrisponde ad alcuno stato consistente della base di dati. L'anomalia dipende soltanto dall'**interleaving** delle operazioni, non da alcun fallimento.

La stessa proprietà vale per la **perdita di aggiornamento** e per la **lettura inconsistente**, che pure si manifestano con tutte le transazioni committate. La lettura sporca è l'unica delle cinque anomalie a richiedere un rollback per produrre danno — ed è anche per questo la più facile da eliminare, con il livello di isolamento più basso fra quelli utili.

### Confronto riassuntivo

| | Aggiornamento fantasma | Lettura sporca |
|---|---|---|
| Operazioni coinvolte | lettura – scrittura su **oggetti diversi** legati da un vincolo | scrittura – lettura sullo **stesso** oggetto |
| Serve un `rollback`? | **No** | **Sì** |
| Che cosa osserva la vittima | uno stato che viola un vincolo di integrità | un valore mai esistito |
| Livello di isolamento minimo | `REPEATABLE READ` | `READ COMMITTED` |

**Tabella dei livelli di isolamento SQL** (✗ = anomalia possibile, ✓ = impedita):

| Livello | Lettura sporca | Lettura inconsistente / Perdita di aggiornamento / Aggiornamento fantasma | Inserimento fantasma |
|---|---|---|---|
| `READ UNCOMMITTED` | ✗ | ✗ | ✗ |
| `READ COMMITTED` | ✓ | ✗ | ✗ |
| `REPEATABLE READ` | ✓ | ✓ | ✗ |
| `SERIALIZABLE` | ✓ | ✓ | ✓ |

## l) Programma Python **(4)**

```python
import psycopg2
from datetime import datetime

DSN = "dbname=palestra user=studente password=segreta host=localhost port=5432"

QUERY = """
    SELECT s.cod_socio, s.cognome, i.ora_entrata
    FROM   socio s JOIN ingresso i ON s.cod_socio = i.socio
    WHERE  i.data = %s
      AND  i.ora_uscita IS NULL
    ORDER BY i.ora_entrata ASC
"""


def leggi_data():
    while True:
        testo = input("Data (formato AAAA-MM-GG): ").strip()
        try:
            return datetime.strptime(testo, "%Y-%m-%d").date()
        except ValueError:
            print("Formato non valido. Esempio: 2026-03-10")


def main():
    giorno = leggi_data()

    conn = None
    try:
        conn = psycopg2.connect(DSN)
        with conn.cursor() as cur:
            cur.execute(QUERY, (giorno,))
            righe = cur.fetchall()

        if not righe:
            print(f"Nessuna uscita mancante in data {giorno}")
            return

        print(f"\nSoci senza ora di uscita registrata in data {giorno}:\n")
        print(f"{'CODICE':<12}{'COGNOME':<28}{'ORA ENTRATA':>12}")
        print("-" * 52)
        for cod, cognome, ora_entrata in righe:
            print(f"{cod:<12}{cognome:<28}{str(ora_entrata):>12}")
        print(f"\n{len(righe)} ingressi senza uscita.")

    except psycopg2.Error as e:
        print(f"Errore nell'accesso alla base di dati: {e}")
    finally:
        if conn is not None:
            conn.close()


if __name__ == "__main__":
    main()
```

**Punti che il docente valuta:**
- **parametri** `%s` invece della concatenazione di stringhe (protezione dalla *SQL injection*); si noti che si passa un oggetto `date` di Python, che `psycopg2` converte automaticamente nel tipo `DATE` di PostgreSQL;
- il predicato `ora_uscita IS NULL` — non `= NULL`, che in SQL è sempre `UNKNOWN` e non restituirebbe mai nulla: è l'errore più frequente in questo tipo di esercizio;
- il `JOIN` con `SOCIO` è necessario perché il testo chiede il **cognome**, che non è in `INGRESSO`;
- l'`ORDER BY` è **dentro la query**, non realizzato in Python;
- **validazione** dell'input dell'utente con un ciclo di reinserimento;
- gestione del **caso vuoto** con il messaggio richiesto dal testo;
- **chiusura** della connessione nel blocco `finally`.
