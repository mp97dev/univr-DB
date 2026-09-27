# Soluzioni — Prova di Tecnologie e Laboratorio, Simulazione 2

> Traccia: [`Tecnologie-Lab-Simulazione-2.md`](../Tecnologie-Lab-Simulazione-2.md)

---

# PARTE A — TECNOLOGIE

## a) Proprietà delle transazioni: atomicità e persistenza **(4)**

**Transazione.** Unità elementare di lavoro svolta da un'applicazione, delimitata da `begin transaction` … `end transaction`, che termina con `commit work` (successo) o `rollback work` (fallimento).

**Transazione ben formata.** Una transazione è *ben formata* se:
1. inizia con `begin transaction`;
2. termina con `end transaction`;
3. contiene **al più un** comando di `commit work` o di `rollback work`;
4. non esegue alcuna operazione sulla base di dati **dopo** tale comando.

```sql
begin transaction;
    update CONTO set saldo = saldo - 1200 where filiale = '005' and numero = 15;
    update CONTO set saldo = saldo + 1200 where filiale = '005' and numero = 205;
    commit work;
end transaction;
```

Le quattro proprietà sono **A**tomicità, **C**onsistenza, **I**solamento, **D**urabilità. Le prime due qui richieste in dettaglio:

### Atomicità

**Enunciato.** La transazione è un'unità **indivisibile** di esecuzione: o vengono resi definitivi **tutti** i suoi effetti sulla base di dati, o **nessuno** di essi. Non sono ammesse esecuzioni parziali. È il principio del *"tutto o niente"*.

**Che cosa comporta.** Il momento discriminante è l'esecuzione del `commit`, che rappresenta il **punto di non ritorno**:
- se la transazione fallisce (per rollback esplicito, per violazione di un vincolo, per guasto) **prima** del commit, tutte le modifiche già applicate alla base di dati devono essere **disfatte** (**UNDO**), riportando la base di dati esattamente allo stato precedente l'inizio della transazione;
- se il guasto avviene **dopo** il commit, le modifiche devono essere **rifatte** (**REDO**), perché la transazione risulta conclusa con successo.

Nell'esempio del bonifico, l'atomicità è ciò che impedisce che venga eseguito l'addebito senza l'accredito.

**Modulo che la garantisce: il gestore dell'affidabilità.**

**Meccanismi:**
- il **file di log** su **memoria stabile**, che per ogni azione registra un record `U(T, O, before, after)` con l'immagine *precedente* e quella *successiva* dell'oggetto;
- la regola **WAL** (*Write-Ahead Log*): la parte *before image* del record di log deve essere scritta sul log **prima** che la corrispondente modifica venga scritta sulla base di dati. Questa regola è ciò che rende **sempre possibile** l'UNDO, e quindi ciò che garantisce l'atomicità;
- la procedura di **UNDO**, che ripercorre il log all'indietro ripristinando le *before image*;
- il record di `A(T)` (abort) e le procedure di ripresa a caldo e a freddo.

### Persistenza (Durabilità)

**Enunciato.** Gli effetti di una transazione che ha eseguito con successo il `commit` sono **permanenti**: devono sopravvivere a qualunque guasto successivo al commit, incluso il guasto che distrugge il contenuto della memoria centrale o della memoria secondaria.

**Che cosa comporta.** Al momento del commit le modifiche possono essere ancora **solo nel buffer** in memoria centrale, non ancora scritte sulle pagine della base di dati (politica *no-force*, adottata per ragioni di efficienza). Se il sistema cade in quell'istante, le modifiche andrebbero perdute pur essendo state confermate all'utente. La persistenza impone quindi che, prima di comunicare all'applicazione l'esito positivo, l'informazione necessaria a **ricostruire** quelle modifiche sia già su memoria stabile.

**Modulo che la garantisce: il gestore dell'affidabilità** (lo stesso dell'atomicità, ma con meccanismi opposti).

**Meccanismi:**
- la **regola di Commit-Precedenza**: la parte *after image* di tutti i record di log della transazione deve essere scritta sul log **prima** del record di `C(T)` (commit). Questa regola è ciò che rende **sempre possibile** il REDO, e quindi ciò che garantisce la persistenza;
- la scrittura **sincrona e forzata** del record di commit sul log: è questa scrittura, e non quella sulle pagine dati, a rendere la transazione "committata";
- la procedura di **REDO**, che ripercorre il log in avanti riapplicando le *after image*;
- il **dump** periodico della base di dati, che consente il ripristino anche in caso di perdita della memoria secondaria.

> **Sintesi utile all'esame.** Atomicità e persistenza sono due facce della stessa medaglia, garantite dallo stesso modulo con meccanismi speculari:
>
> | | Atomicità | Persistenza |
> |---|---|---|
> | Serve a | disfare ciò che non è stato committato | rifare ciò che è stato committato |
> | Operazione | **UNDO** (all'indietro, *before image*) | **REDO** (in avanti, *after image*) |
> | Regola sul log | **WAL** | **Commit-Precedenza** |

Per completezza: la **consistenza** è garantita dal *gestore dell'integrità* (verifica dei vincoli, immediata o differita) e l'**isolamento** dal *gestore della concorrenza* (locking a due fasi, timestamp).

---

## b) Il gestore del buffer **(3)**

### Organizzazione del buffer

Il **buffer** è un'ampia area di memoria centrale, gestita direttamente dal DBMS e sottratta al sistema operativo, destinata a contenere copie di blocchi della memoria secondaria. È organizzato in **pagine** di dimensione pari (o multipla) a quella dei blocchi del disco, tipicamente da 2 a 100 KB. Il DBMS gestisce il buffer autonomamente perché conosce meglio del sistema operativo i propri pattern di accesso.

Per ogni pagina il gestore mantiene un **direttorio** con: l'identificatore del file e del blocco caricato, un **contatore di utilizzo** (numero di transazioni che stanno usando la pagina) e un **bit di stato "dirty"** che indica se la pagina è stata modificata rispetto alla copia su disco.

### Primitive

| Primitiva | Effetto |
|---|---|
| **`fix`** | richiede l'accesso a un blocco. Se il blocco è già nel buffer (*hit*) restituisce subito il riferimento alla pagina; altrimenti (*miss*) sceglie una pagina vittima, eventualmente la riscrive su disco se è *dirty*, carica il blocco richiesto e restituisce il riferimento. Incrementa il contatore di utilizzo, **impedendo** che la pagina venga rimossa mentre è in uso |
| **`unfix`** | segnala che la transazione ha terminato di usare la pagina; decrementa il contatore. La pagina diventa candidata al rimpiazzo quando il contatore torna a zero |
| **`setDirty`** | segnala che la pagina è stata modificata, così il gestore saprà che va riscritta su disco prima di essere rimpiazzata |
| **`force`** | trasferisce **sincronamente** una pagina dal buffer alla memoria secondaria: la transazione richiedente si sospende fino al completamento della scrittura. È la primitiva usata dal gestore dell'affidabilità per il log e per il checkpoint |
| **`flush`** | trasferisce **asincronamente** una pagina su disco, per iniziativa autonoma del gestore del buffer, tipicamente nei momenti di minor carico o per liberare pagine |

Le prime tre sono invocate dal **gestore dei metodi di accesso**; `force` è invocata dal **gestore dell'affidabilità**; `flush` è decisa dal gestore del buffer stesso.

### Principi su cui si basano le politiche di gestione

1. **Principio di località dei riferimenti** (*locality of reference*). I dati usati di recente hanno alta probabilità di essere riusati nell'immediato futuro (*località temporale*), e i dati vicini a quelli appena usati hanno alta probabilità di essere richiesti a breve (*località spaziale*). Conviene quindi tenere nel buffer le pagine appena usate.
2. **Legge empirica 80–20** (*legge di Pareto*). L'80 % degli accessi riguarda il 20 % dei dati: un buffer relativamente piccolo può servire la grande maggioranza delle richieste senza toccare il disco.

Su questi principi si basa la politica di rimpiazzo classica **LRU** (*Least Recently Used*): quando serve una pagina libera si sceglie come vittima quella non utilizzata da più tempo. Alcuni DBMS adottano varianti (LRU-K, clock, o addirittura **MRU** — *Most Recently Used* — per le scansioni sequenziali, in cui la località temporale non vale).

### Politiche steal / no-steal e force / no-force

Riguardano il rapporto fra buffer e gestore dell'affidabilità, cioè **quando** le pagine modificate finiscono su disco.

| Politica | Significato | Conseguenza |
|---|---|---|
| **steal** | il gestore del buffer **può** scegliere come vittima una pagina "sporca" appartenente a una transazione **ancora attiva**, riscrivendola su disco prima del commit | il disco può contenere modifiche non committate → in caso di guasto serve l'**UNDO** → è necessaria la regola **WAL** |
| **no-steal** | non si rimpiazzano pagine di transazioni attive: le modifiche raggiungono il disco solo dopo il commit | non serve UNDO, ma il buffer deve poter contenere tutte le pagine di tutte le transazioni attive: **irrealistico** |
| **force** | al momento del commit tutte le pagine modificate dalla transazione vengono **forzate** su disco | non serve REDO, ma il commit diventa lentissimo (molte scritture sincrone e sparse) |
| **no-force** | al commit le pagine restano nel buffer e saranno scritte più tardi | il commit è veloce (basta forzare il log, che è **sequenziale**), ma in caso di guasto serve il **REDO** → è necessaria la regola di **Commit-Precedenza** |

**I DBMS reali adottano `steal` + `no-force`**: è la combinazione più efficiente, ed è esattamente quella che rende necessari **entrambi** i meccanismi di UNDO e di REDO, e quindi entrambe le regole di scrittura sul log.

---

## c) Tipi di guasto, ripresa a caldo e a freddo, WAL e Commit-Precedenza **(4)**

### Tipi di guasto

| Tipo | Che cosa si perde | Frequenza | Procedura di ripristino |
|---|---|---|---|
| **Guasto di transazione** (*soft failure* di una singola transazione) | nulla di fisico: la transazione fallisce e viene abortita | frequentissimo (ogni pochi secondi) | **UNDO** delle sole azioni di quella transazione; la gestione è locale e immediata |
| **Guasto di sistema** (*system failure*, *soft crash*) | il contenuto della **memoria centrale** (buffer compreso). La memoria secondaria resta **intatta** | frequente (giorni/settimane) | **RIPRESA A CALDO** (*warm restart*) |
| **Guasto di dispositivo** (*device failure*, *hard crash*) | il contenuto della **memoria secondaria** (un disco si rompe) | raro (mesi/anni) | **RIPRESA A FREDDO** (*cold restart*) |

Entrambe le procedure sono eseguite dal **gestore dell'affidabilità**, che si serve del **file di log** e — per la ripresa a freddo — anche del **dump**.

Il **file di log** contiene:
- *record di transazione*: `B(T)` begin, `I(T,O,A)` insert, `D(T,O,B)` delete, `U(T,O,B,A)` update, `C(T)` commit, `A(T)` abort;
- *record di sistema*: `CK(T1,…,Tn)` checkpoint e `DUMP`.

### Ripresa a caldo (warm restart)

Si applica dopo un **guasto di sistema**. Obiettivo: ricostruire uno stato in cui tutte le transazioni committate abbiano i loro effetti sul disco, e nessuna transazione non committata ne abbia.

```
1. Si accede all'ULTIMO record di CHECKPOINT, risalendo il log all'indietro.

2. Si costruiscono gli insiemi UNDO e REDO:
      UNDO := { transazioni attive al checkpoint }        REDO := { }

3. Si percorre il log IN AVANTI dal checkpoint fino alla fine:
      per ogni B(Ti):  UNDO := UNDO ∪ {Ti}
      per ogni C(Ti):  UNDO := UNDO − {Ti} ;  REDO := REDO ∪ {Ti}
      (un record A(Ti) NON toglie Ti da UNDO)

4. Si percorre il log ALL'INDIETRO, fino al record di begin della transazione
   più vecchia appartenente a UNDO ∪ REDO, DISFACENDO le azioni delle
   transazioni in UNDO:
      U(T,O,B,A) → O = B          I(T,O,A) → cancella O
      D(T,O,B)   → reinserisci O con valore B

5. Si percorre il log IN AVANTI da quel punto, RIFACENDO le azioni delle
   transazioni in REDO:
      U(T,O,B,A) → O = A          I(T,O,A) → inserisci O con valore A
      D(T,O,B)   → cancella O
```

### Ripresa a freddo (cold restart)

Si applica dopo un **guasto di dispositivo**, quando la base di dati su disco è perduta o corrotta. Si articola in tre fasi:

```
1. RIPRISTINO: si ricarica la base di dati (o la sola porzione danneggiata)
   dall'ultima copia di backup, individuata dal record di DUMP sul log.

2. RIAPPLICAZIONE: si percorre il log IN AVANTI a partire dal record di DUMP,
   riapplicando NELL'ORDINE tutte le azioni registrate — di TUTTE le transazioni,
   sia quelle committate sia quelle non committate. Si riporta così la base di dati
   esattamente allo stato che aveva nell'istante del guasto.

3. RIPRESA A CALDO: si esegue la procedura di warm restart descritta sopra,
   che disfa le transazioni rimaste incomplete e rifà quelle committate.
```

**Differenze essenziali:**

| | Ripresa a caldo | Ripresa a freddo |
|---|---|---|
| Guasto | di sistema (persa la memoria **centrale**) | di dispositivo (persa la memoria **secondaria**) |
| Strutture usate | **solo il log** | **dump + log**, poi ripresa a caldo |
| Punto di partenza sul log | l'ultimo **checkpoint** | l'ultimo **record di DUMP** |
| Azioni riapplicate nella fase iniziale | nessuna: si costruiscono direttamente UNDO e REDO | **tutte** le azioni di **tutte** le transazioni |
| Durata | secondi/minuti | può richiedere ore |

### Regola WAL e regola di Commit-Precedenza

**Regola WAL** (*Write-Ahead Log*)
> La parte *before image* di un record di log deve essere scritta nel file di log (su memoria stabile) **prima** che la corrispondente modifica venga scritta nella base di dati su memoria secondaria.

Se il DBMS scrivesse su disco una pagina modificata **prima** di aver registrato il valore precedente, e poi la transazione fallisse, non esisterebbe più alcuna informazione per ripristinare il valore originale: l'UNDO diventerebbe impossibile.
→ **Garantisce l'ATOMICITÀ** (rende sempre possibile il disfacimento).

**Regola di Commit-Precedenza**
> La parte *after image* di **tutti** i record di log di una transazione deve essere scritta nel file di log (su memoria stabile) **prima** che venga scritto il record di `commit`.

Se si registrasse il commit senza aver prima registrato i nuovi valori, e poi il sistema cadesse con le pagine ancora solo nel buffer, la transazione risulterebbe committata ma i suoi effetti sarebbero irrecuperabili: il REDO diventerebbe impossibile.
→ **Garantisce la PERSISTENZA** (rende sempre possibile il rifacimento).

---

## d) Replica set in MongoDB **(3)**

### Struttura e ruoli

Un **replica set** è un gruppo di istanze `mongod` che mantengono **una copia dello stesso dataset**. Serve a garantire **ridondanza**, **alta disponibilità** e **tolleranza al guasto** di un singolo server, e a migliorare le prestazioni in lettura.

```
                         ┌──────────────┐
              ┌─────────►│   PRIMARY    │◄─────────┐
              │          └──────┬───────┘          │
        replicazione            │            replicazione
              │                 │                  │
       ┌──────▼──────┐   heartbeat   ┌─────────────▼─┐
       │  SECONDARY  │◄─────────────►│   SECONDARY   │
       └─────────────┘               └───────────────┘
```

- **Nodo primario.** È l'**unico** nodo che riceve le operazioni di **scrittura**. Ogni replica set ha **uno e un solo** primario. Registra tutte le modifiche nel proprio oplog.
- **Nodi secondari.** Mantengono una copia del dataset replicando le operazioni dell'oplog del primario. Per default servono solo la replicazione, ma possono essere configurati per servire anche letture. Sono i candidati a diventare primario in caso di guasto.

### Oplog

L'**oplog** (*operation log*) è una collezione speciale, di dimensione fissa (*capped collection*), in cui il primario registra in sequenza **tutte le operazioni che modificano** il dataset. I secondari copiano l'oplog del primario e ne **riapplicano** le operazioni sulla propria copia dei dati.

Due proprietà fondamentali:
- la replicazione è **asincrona**: il primario non attende che i secondari abbiano applicato l'operazione (salvo diversa indicazione tramite *write concern*). Ne consegue che i secondari possono essere temporaneamente **in ritardo** (*replication lag*);
- le operazioni contenute nell'oplog sono **idempotenti**: riapplicarle più volte produce lo stesso risultato. Ciò rende sicuro il recupero di un nodo che riparte dopo essere stato disconnesso, che riapplica semplicemente le operazioni mancanti.

I nodi si scambiano informazioni condividendo i rispettivi oplog, così ogni membro sa a che punto della replicazione si trovano gli altri.

### Heartbeat

Ogni membro del replica set invia periodicamente (per default ogni 2 secondi) un messaggio di **heartbeat** a tutti gli altri, per segnalare la propria presenza e verificare quella degli altri. Se un nodo non risponde entro un **timeout** prestabilito (per default **10 secondi**), viene considerato **non raggiungibile**. L'heartbeat è il meccanismo di **identificazione automatica della perdita del nodo primario**: appena i secondari smettono di ricevere risposta dal primario, avviano un'elezione.

### Algoritmo di elezione

L'elezione determina **quale membro assumerà il ruolo di primario** e si basa sull'algoritmo di consenso **Raft**. Viene attivata nei casi seguenti:
- **inizializzazione** del replica set;
- **aggiunta o rimozione** di un nodo;
- **perdita del primario**, rilevata quando esso non risponde all'heartbeat oltre il timeout;
- promozione manuale (`rs.stepDown()` sul primario).

Funzionamento essenziale:
1. un secondario che rileva l'assenza del primario si propone come candidato e chiede il voto agli altri membri;
2. per vincere il candidato deve ottenere il voto della **maggioranza** dei membri votanti del replica set. Il requisito della maggioranza è ciò che impedisce la *split-brain*, cioè la coesistenza di due primari in caso di partizionamento della rete: solo la partizione che contiene la maggioranza può eleggere un primario;
3. il vincitore diventa primario e comincia ad accettare scritture; il vecchio primario, se torna disponibile, si riunisce al replica set come **secondario** ed effettua eventualmente un *rollback* delle scritture che non erano state replicate;
4. mentre un'elezione è in corso il replica set **non accetta scritture** (il servizio di lettura può continuare sui secondari); finché un'elezione non si è conclusa con successo non ne può iniziare un'altra.

Per rendere l'elezione sempre possibile è raccomandato un **numero dispari** di membri votanti.

### L'arbitro

Un **arbitro** (*arbiter*) è un membro del replica set che **partecipa alle elezioni e vota**, ma:
- **non mantiene una copia del dataset**;
- **non può diventare primario**.

Serve a garantire la **maggioranza dispari** quando i nodi che contengono dati sono in numero **pari** — tipicamente in una configurazione minimale con un solo primario e un solo secondario. Senza arbitro, con due nodi, la perdita di uno impedirebbe di raggiungere la maggioranza (1 voto su 2 non è maggioranza) e il replica set resterebbe senza primario, cioè in sola lettura. Aggiungendo un arbitro si arriva a 3 votanti e la maggioranza (2) è raggiungibile anche con un nodo dati caduto. Poiché non memorizza dati, l'arbitro richiede risorse hardware trascurabili.

Altre configurazioni particolari: i **nodi nascosti** (invisibili alle applicazioni, votano, usati per backup e reporting) e i **nodi ritardati** (mantengono una copia volutamente arretrata nel tempo, utile per recuperare da errori applicativi).

---

## e) Gestore dell'affidabilità — ripresa a caldo **(4)**

### Numerazione del log

| # | record | | # | record |
|---|---|---|---|---|
| 1 | `B(T1)` | | 11 | `U(T1,O5,B5,A5)` |
| 2 | `B(T2)` | | 12 | `B(T5)` |
| 3 | `U(T1,O1,B1,A1)` | | 13 | `D(T5,O6,B6)` |
| 4 | `U(T2,O2,B2,A2)` | | 14 | `C(T1)` |
| 5 | `B(T3)` | | 15 | `U(T4,O2,B7,A7)` |
| 6 | `I(T3,O3,A3)` | | 16 | `B(T6)` |
| 7 | **`CK(T1,T2,T3)`** | | 17 | `I(T6,O7,A8)` |
| 8 | `C(T2)` | | 18 | `A(T3)` |
| 9 | `B(T4)` | | 19 | `U(T6,O8,B9,A9)` |
| 10 | `U(T4,O4,B4,A4)` | | 20 | `C(T4)` |
| | | | — | **guasto** |

### Passo 1 — Ultimo checkpoint

`CK(T1,T2,T3)` alla posizione **7**: al momento del checkpoint erano attive `T1`, `T2` e `T3`.

### Passo 2 — Costruzione di UNDO e REDO

Inizializzazione: `UNDO = {T1, T2, T3}`, `REDO = { }`.
Percorrendo il log **in avanti** dalla posizione 8:

| # | record | azione | UNDO | REDO |
|---|---|---|---|---|
| — | — | inizializzazione | `{T1,T2,T3}` | `{ }` |
| 8 | `C(T2)` | `T2` da UNDO a REDO | `{T1,T3}` | `{T2}` |
| 9 | `B(T4)` | aggiungi `T4` | `{T1,T3,T4}` | `{T2}` |
| 12 | `B(T5)` | aggiungi `T5` | `{T1,T3,T4,T5}` | `{T2}` |
| 14 | `C(T1)` | `T1` da UNDO a REDO | `{T3,T4,T5}` | `{T2,T1}` |
| 16 | `B(T6)` | aggiungi `T6` | `{T3,T4,T5,T6}` | `{T2,T1}` |
| 18 | `A(T3)` | `T3` **resta** in UNDO | `{T3,T4,T5,T6}` | `{T2,T1}` |
| 20 | `C(T4)` | `T4` da UNDO a REDO | `{T3,T5,T6}` | `{T2,T1,T4}` |

**Risultato:**

```
UNDO = { T3, T5, T6 }
REDO = { T1, T2, T4 }
```

### Passo 3 — Ripercorrimento all'indietro (UNDO)

La transazione più vecchia di `UNDO ∪ REDO = {T1,T2,T3,T4,T5,T6}` è `T1`, il cui `begin` è alla posizione **1**: ci si spinge all'indietro fino alla posizione 1.

Disfacendo, in ordine inverso, le azioni delle sole transazioni in UNDO (`T3`, `T5`, `T6`):

| # | record | azione di UNDO |
|---|---|---|
| 19 | `U(T6,O8,B9,A9)` | `O8 = B9` |
| 17 | `I(T6,O7,A8)` | **cancella** `O7` |
| 13 | `D(T5,O6,B6)` | **reinserisce** `O6` con valore `B6` |
| 6 | `I(T3,O3,A3)` | **cancella** `O3` |

### Passo 4 — Ripercorrimento in avanti (REDO)

Ripercorrendo il log in avanti dalla posizione 1, rifacendo le azioni delle sole transazioni in REDO (`T1`, `T2`, `T4`):

| # | record | azione di REDO |
|---|---|---|
| 3 | `U(T1,O1,B1,A1)` | `O1 = A1` |
| 4 | `U(T2,O2,B2,A2)` | `O2 = A2` |
| 10 | `U(T4,O4,B4,A4)` | `O4 = A4` |
| 11 | `U(T1,O5,B5,A5)` | `O5 = A5` |
| 15 | `U(T4,O2,B7,A7)` | `O2 = A7` |

**Valore finale di `O2`: `A7`.**

### Osservazioni da riportare all'esame

1. **Le azioni di `T1` e `T2` precedenti al checkpoint vengono rifatte.** `U(T1,O1,…)@3` e `U(T2,O2,…)@4` si trovano **prima** del checkpoint, eppure vanno redone: il checkpoint garantisce che siano su disco solo le pagine delle transazioni **già concluse** al momento del checkpoint, e `T1` e `T2` a quel momento erano ancora **attive** (compaiono infatti nella lista di `CK`). Committano solo dopo, alle posizioni 14 e 8.
   È questa la ragione per cui la fase di UNDO deve risalire fino al `begin` più vecchio di `UNDO ∪ REDO` e non fermarsi al checkpoint.
2. **`O2` viene scritto due volte in fase di REDO**, prima da `T2` (`A2`) e poi da `T4` (`A7`). Il REDO procede **in avanti**, quindi l'ordine cronologico è rispettato e prevale correttamente l'ultimo valore committato, `A7`. Invertire il verso della fase di REDO produrrebbe un risultato sbagliato.
3. **`A(T3)` non toglie `T3` da UNDO:** l'abort indica che la transazione ha deciso di terminare senza successo, ma le sue scritture possono essere già state trasferite su disco dalla politica *steal* e vanno comunque disfatte.
4. **`T5` non ha alcun record di commit né di abort:** era semplicemente ancora in corso al momento del guasto, e finisce in UNDO.

---

## f) Esecuzione concorrente **(6)**

```
S: r1(x), r2(y), w2(x), r1(y), w1(x), r3(z), w2(y), w3(z), w4(x), r4(y), w4(t), r3(x)
     1       2       3       4       5       6       7       8       9      10      11      12
```

Operazioni per transazione:

```
T1:  r1(x)@1   r1(y)@4   w1(x)@5
T2:  r2(y)@2   w2(x)@3   w2(y)@7
T3:  r3(z)@6   w3(z)@8   r3(x)@12
T4:  w4(x)@9   r4(y)@10  w4(t)@11
```

### Conflict-serializzabilità (CSR)

| Oggetto | Operazioni | Conflitti |
|---|---|---|
| `x` | `r1@1, w2@3, w1@5, w4@9, r3@12` | `r1@1–w2@3` → **T1→T2**; `w2@3–w1@5` → **T2→T1**; `r1@1–w4@9` → T1→T4; `w2@3–w4@9` → T2→T4; `w1@5–w4@9` → T1→T4; `w2@3–r3@12` → T2→T3; `w1@5–r3@12` → T1→T3; `w4@9–r3@12` → T4→T3 |
| `y` | `r2@2, r1@4, w2@7, r4@10` | `r1@4–w2@7` → **T1→T2**; `w2@7–r4@10` → T2→T4 |
| `z` | `r3@6, w3@8` | nessuno (stessa transazione) |
| `t` | `w4@11` | nessuno (unica operazione) |

**Grafo dei conflitti:**

```
              ┌─────────┐
              │         ▼
            (T1) ◄───► (T2)           ← CICLO
              │         │
              ▼         ▼
            (T4) ────► (T3)
              ▲         ▲
              └─────────┘  (da T1 e T2)
```

Il grafo contiene il **ciclo `T1 → T2 → T1`**, prodotto dalla coppia di conflitti:
- `r1(x)@1` precede `w2(x)@3` → `T1` deve precedere `T2`;
- `w2(x)@3` precede `w1(x)@5` → `T2` deve precedere `T1`.

> ### ❌ **S non è CSR.**

### View-serializzabilità (VSR)

Il fatto che `S` non sia CSR **non** implica che non sia VSR: la classe CSR è contenuta **strettamente** in VSR. Occorre applicare la definizione di view-equivalenza, che si basa su due insiemi.

**Relazione LEGGE-DA.** `ri(x)` *legge da* `wj(x)` se `wj(x)` precede `ri(x)`, `i ≠ j`, e fra le due non c'è alcuna altra scrittura su `x`.

| Lettura | Ultima scrittura precedente sull'oggetto | Legge da |
|---|---|---|
| `r1(x)@1` | nessuna | **valore iniziale** |
| `r2(y)@2` | nessuna | **valore iniziale** |
| `r1(y)@4` | nessuna (`w2(y)` è a @7) | **valore iniziale** |
| `r3(z)@6` | nessuna (`w3(z)` è a @8) | **valore iniziale** |
| `r4(y)@10` | `w2(y)@7` | **T2** |
| `r3(x)@12` | `w4(x)@9` | **T4** |

```
LEGGE-DA(S) = { (T4, y, T2), (T3, x, T4) }
```

**Scritture finali.**

```
x → w4(x)@9   (T4)          z → w3(z)@8   (T3)
y → w2(y)@7   (T2)          t → w4(t)@11  (T4)
```

**Ricerca di uno schedule seriale view-equivalente.** I vincoli da rispettare sono:

| Vincolo | Deriva da | Conseguenza sull'ordine |
|---|---|---|
| `r1(x)` legge il valore iniziale | in `S` nessuno scrive `x` prima | `T1` deve precedere **tutti** gli altri scrittori di `x`, cioè `T2` e `T4` |
| `r1(y)` legge il valore iniziale | idem su `y` | `T1` deve precedere `T2` (unico scrittore di `y`) |
| `r4(y)` legge da `T2` | — | `T2` prima di `T4`, senza altre scritture di `y` in mezzo (`T2` è l'unico scrittore di `y`: soddisfatto) |
| `r3(x)` legge da `T4` | — | `T4` prima di `T3`, senza altre scritture di `x` in mezzo |
| scrittura finale di `x` = `T4` | — | `T4` dopo `T1` e `T2` fra gli scrittori di `x` |
| `r3(z)` legge il valore iniziale | — | soddisfatto (`T3` è l'unico scrittore di `z`) |

L'ordine **`T1, T2, T4, T3`** soddisfa tutti i vincoli. Verifica completa:

```
   T1:  r1(x) → iniziale ✓    r1(y) → iniziale ✓    w1(x)
   T2:  r2(y) → iniziale ✓    w2(x)                 w2(y)
   T4:  w4(x)                 r4(y) → da T2 ✓       w4(t)
   T3:  r3(z) → iniziale ✓    w3(z)                 r3(x) → da T4 ✓

   Scritture finali:  x → T4 ✓    y → T2 ✓    z → T3 ✓    t → T4 ✓
```

LEGGE-DA e scritture finali coincidono con quelle di `S`.

> ### ✅ **S è VSR**, view-equivalente allo schedule seriale `T1 T2 T4 T3`.

### Locking a due fasi (2PL)

Poiché **2PL ⊂ CSR** e si è dimostrato che `S` **non** è CSR, si conclude immediatamente che `S` non può essere prodotto da uno scheduler 2PL.

> ### ❌ **S non è 2PL.**

**Riepilogo:** `S` è VSR ✅, **non** è CSR ❌, **non** è 2PL ❌.
`S` è l'esempio classico di schedule **view-serializzabile ma non conflict-serializzabile**: il ciclo nel grafo dei conflitti nasce da una **scrittura cieca** (*blind write*), cioè `w1(x)@5` eseguita da `T1` senza che `T1` abbia riletto `x` dopo la scrittura di `T2`. Poiché il valore scritto da `T2` viene comunque sovrascritto e nessuno lo legge mai, quel conflitto è irrilevante ai fini del risultato — cosa che la nozione di *view*-equivalenza riesce a cogliere e quella di *conflict*-equivalenza no.

---

## g) Ottimizzazione **(5)**

### Parte 1 — Costo senza indice

**Dati:** `NP(LETTORE) = 220`, `NR(LETTORE) = 26400`, `NP(PRESTITO) = 1800`, `NR(PRESTITO) = 264000`, `VAL(Provincia, LETTORE) = 12`, `VAL(Tessera, PRESTITO) = 26400`, `NP(LETTORE con Provincia='Verona') = 25`.

**Passo 1 — selezione su `LETTORE` (scansione + materializzazione su disco)**

```
lettura   = NP(LETTORE) = 220 accessi
scrittura =                25 accessi   (le 25 pagine indicate dal testo)
─────────────────────────────────────
subtotale =               245 accessi
```

Cardinalità del risultato:
```
NR(LETTORE con Provincia='Verona') = NR(LETTORE) / VAL(Provincia, LETTORE)
                                   = 26400 / 12 = 2200 tuple
```

**Passo 2 — Nested Loop Join `LETTORE ⋈ PRESTITO`**

```
costo(NLJ) = NP(esterna) + NR(esterna) × NP(interna)
```

Qui, a differenza del caso in cui il risultato resta nel buffer, l'operando esterno è **su disco** e va letto una volta: `NP(esterna) = 25`. L'operando interno è la tabella `PRESTITO` **intera** (la query non applica alcuna selezione sui prestiti): `NP(interna) = NP(PRESTITO) = 1800`.

```
costo(NLJ) = 25 + 2200 × 1800
           = 25 + 3.960.000
           = 3.960.025 accessi
```

**Costo totale**

```
       245          (scansione LETTORE + scrittura del risultato)
+ 3.960.025         (Nested Loop Join)
─────────────
= 3.960.270 accessi a memoria secondaria
```

### Parte 2 — Costo con indice B+-tree di profondità 2 su `PRESTITO.Tessera`

Con l'indice, per ogni lettore selezionato si accede direttamente ai suoi prestiti, senza rileggere l'intera tabella `PRESTITO`.

Numero di prestiti per lettore:
```
NR(PRESTITO) / VAL(Tessera, PRESTITO) = 264000 / 26400 = 10 prestiti per lettore
```

Costo per ogni tupla esterna: `2` accessi per attraversare il B+-tree (profondità 2) più `10` accessi per leggere le tuple corrispondenti:

```
costo per lettore = 2 + 10 = 12 accessi
```

```
       220              (scansione LETTORE)
+       25              (scrittura del risultato della selezione)
+       25              (rilettura dell'operando esterno)
+ 2200 × 12 = 26.400    (accesso indicizzato a PRESTITO)
─────────────
=   26.670 accessi a memoria secondaria
```

> **Confronto:** `3.960.270 → 26.670`, un miglioramento di circa **148 volte**. Si noti che, se il risultato della selezione fosse stato mantenuto nel **buffer** anziché scritto su disco, si sarebbero risparmiati i 50 accessi di scrittura e rilettura — un contributo trascurabile rispetto al costo del join, ma che nella parte 1 sarebbe stato altrettanto marginale: il fattore dominante è sempre il termine `NR(esterna) × NP(interna)`.

---

## h) B+-tree, fan-out = 4 **(5)**

**Vincoli di riempimento con fan-out `n = 4`:**

```
NODO FOGLIA:   ⌈(n-1)/2⌉ ≤ #chiavi ≤ n-1        →   2 ≤ #chiavi ≤ 3
NODO INTERNO:  ⌈n/2⌉ ≤ #puntatori ≤ n           →   2 ≤ #puntatori ≤ 4
                                                →   1 ≤ #chiavi ≤ 3
NODO RADICE:   almeno 2 puntatori (se non è anche foglia)
```

### a) Costruzione dell'albero

Le 4 foglie richiedono 4 puntatori dalla radice, con 3 chiavi separatrici pari alla **prima chiave** di ciascuna foglia successiva alla prima: `F`, `L`, `P`.

```
                     ┌───┬───┬───┐
                     │ F │ L │ P │              radice: 3 chiavi, 4 puntatori (al massimo)
                     └─┬─┴─┬─┴─┬─┘
            ┌──────────┘   │   └──────────┐
            │        ┌─────┘              │
            ▼        ▼                    ▼          ▼
        (A,C) ─── (F,G,H) ─────────── (L,M) ─── (P,Q)
```

### b) Inserimento della chiave `I`

**Ricerca della foglia:** `F ≤ I < L` → foglia `(F,G,H)`.

**Inserimento:** `(F,G,H,I)` = **4 chiavi > 3** → **split della foglia**.
Le 4 chiavi si ripartiscono in `⌈4/2⌉ = 2` a sinistra e `2` a destra; la prima chiave del nodo destro (`H`) viene **copiata** nel padre:

```
(F,G)   (H,I)              nuova chiave separatrice da inserire nella radice: H
```

**Propagazione nella radice:** `[F | H | L | P]` = **4 chiavi, 5 puntatori > 4** → **split del nodo interno**.
La chiave **mediana** viene **spostata** (non copiata) al livello superiore. Con 4 chiavi si promuove la seconda, `H`:

```
                              ┌───┐
                              │ H │                nuova radice: 1 chiave, 2 puntatori ✓
                              └─┬─┘
                  ┌─────────────┴─────────────┐
                ┌───┐                   ┌───┬───┐
                │ F │                   │ L │ P │
                └─┬─┘                   └─┬─┴─┬─┘
            ┌─────┴─────┐          ┌──────┘   │   └──────┐
            ▼           ▼          ▼          ▼          ▼
        (A,C)        (F,G)      (H,I)      (L,M)      (P,Q)
```

Verifica dei vincoli: nodo interno sinistro 2 puntatori ≥ 2 ✓ · nodo interno destro 3 puntatori ✓ · radice 2 puntatori ✓ · tutte le foglie 2 chiavi ≥ 2 ✓. L'**altezza è cresciuta** da 2 a 3 livelli.

### c) Rimozione della chiave `Q`

**Ricerca della foglia:** `Q ≥ P` → foglia `(P,Q)`.

**Rimozione:** `(P)` = **1 chiave < 2** → **underflow della foglia**.

**Tentativo di prestito da un fratello adiacente** (con lo stesso padre `[L | P]`):
- fratello **sinistro** `(L,M)`: ha 2 chiavi = il **minimo**, **non può prestare**;
- fratello **destro**: non esiste, `(P)` è la foglia più a destra dell'albero.

Poiché nessun fratello può prestare, si procede alla **fusione (*merge*)** con il fratello sinistro:

```
(L,M)  ∪  (P)   →   (L,M,P)          3 chiavi ≤ 3 ✓
```

**Aggiornamento del padre:** la fusione elimina una foglia, quindi il padre perde un puntatore e la chiave separatrice corrispondente (`P`):

```
[L | P]  con 3 puntatori   →   [L]  con 2 puntatori     ✓ ≥ 2, nessun underflow
```

```
                              ┌───┐
                              │ H │
                              └─┬─┘
                  ┌─────────────┴─────────────┐
                ┌───┐                       ┌───┐
                │ F │                       │ L │        ← la chiave P è stata rimossa
                └─┬─┘                       └─┬─┘
            ┌─────┴─────┐               ┌─────┴─────┐
            ▼           ▼               ▼           ▼
        (A,C)        (F,G)           (H,I)       (L,M,P)
```

Il padre conserva 2 puntatori, il minimo consentito: **non** va in underflow e la propagazione si arresta. Se invece fosse sceso sotto il minimo, si sarebbe dovuto ripetere ricorsivamente il procedimento (prestito o fusione) al livello superiore, con la possibilità di ridurre l'altezza dell'albero.

> **Regola generale in caso di underflow:** si tenta **prima** il prestito (*borrow*) da un fratello adiacente che abbia più del minimo di chiavi; solo se **nessun** fratello può prestare si procede alla **fusione** (*merge*), che rimuove una chiave dal padre e può propagare l'underflow verso l'alto fino, eventualmente, alla radice.

---

# PARTE B — LABORATORIO

## i) Dichiarazione PostgreSQL con vincoli **(3)**

```sql
CREATE TABLE Copia (
  cod_copia     CHAR(12)     PRIMARY KEY,                          -- (i)
  isbn          CHAR(13)     NOT NULL                              -- (iv)
                REFERENCES Libro(isbn),
  collocazione  VARCHAR(24),
  stato         VARCHAR(20)  NOT NULL                              -- (iv)
                CHECK (stato IN ('disponibile','in prestito',
                                 'in restauro','smarrita')),       -- (v)

  CONSTRAINT sk_isbn_collocazione UNIQUE (isbn, collocazione)      -- (iii)
);

CREATE TABLE Prestito (
  cod_prestito       CHAR(14)  PRIMARY KEY,                        -- (i)
  tessera            CHAR(10)  NOT NULL                            -- (iv)
                     REFERENCES Lettore(tessera),                  -- (ii)
  copia              CHAR(12)  NOT NULL                            -- (iv)
                     REFERENCES Copia(cod_copia)
                     ON DELETE NO ACTION,                          -- (ii) (viii)
  data_inizio        DATE      NOT NULL,                           -- (iv)
  data_scadenza      DATE,
  data_restituzione  DATE,
  rinnovi            INTEGER   DEFAULT 0                           -- (vii)
                     CHECK (rinnovi BETWEEN 0 AND 2),              -- (vii)

  CONSTRAINT ck_scadenza     CHECK (data_inizio < data_scadenza),  -- (vi)
  CONSTRAINT ck_restituzione CHECK (data_restituzione IS NULL
                                    OR data_restituzione >= data_inizio)  -- (vi)
);
```

**Note sui punti critici:**

- **(vi)** *"quando la restituzione è avvenuta"* → il `CHECK` deve **tollerare il valore nullo** su `data_restituzione` (prestito ancora aperto). Si noti però che in SQL un `CHECK` è soddisfatto anche quando il predicato vale `UNKNOWN`: `CHECK (data_restituzione >= data_inizio)` da solo funzionerebbe comunque. La forma esplicita con `IS NULL OR …` è preferibile perché rende evidente l'intenzione.
- **(vii)** il vincolo sui rinnovi è un **vincolo di dominio**; `DEFAULT 0` e `CHECK` sono indipendenti fra loro.
- **(viii)** *"impedire la cancellazione di una copia se esistono prestiti"* → `ON DELETE NO ACTION` (o `RESTRICT`), che è anche il comportamento di default. **Sbagliato** `CASCADE` (cancellerebbe la storia dei prestiti) e **sbagliato** `SET NULL` (incompatibile con il `NOT NULL`).
- **(iii)** la superchiave **composta** richiede un **vincolo di tabella** `UNIQUE (isbn, collocazione)`, non due `UNIQUE` separati su ciascuna colonna.

## j) Query SQL

### i. [5] Lettori con più prestiti di genere 'Giallo' che di genere 'Saggistica'

```sql
SELECT l.tessera, l.nome, l.cognome
FROM   lettore l
WHERE  ( SELECT COUNT(*)
         FROM   prestito p JOIN copia c  ON p.copia = c.cod_copia
                           JOIN libro li ON c.isbn  = li.isbn
         WHERE  p.tessera = l.tessera
           AND  li.genere = 'Giallo' )
     > ( SELECT COUNT(*)
         FROM   prestito p JOIN copia c  ON p.copia = c.cod_copia
                           JOIN libro li ON c.isbn  = li.isbn
         WHERE  p.tessera = l.tessera
           AND  li.genere = 'Saggistica' );
```

> È il pattern **"più X che Y"**: due sottoquery aggregate **correlate** con la riga esterna (`p.tessera = l.tessera`), confrontate fra loro. Il vantaggio rispetto a un `GROUP BY` con due `COUNT` condizionati è che vengono inclusi anche i lettori con **zero** prestiti di saggistica, che un join interno escluderebbe.
>
> *Formulazione alternativa con conteggi condizionati:*
> ```sql
> SELECT l.tessera, l.nome, l.cognome
> FROM   lettore l
>        JOIN prestito p ON l.tessera = p.tessera
>        JOIN copia    c ON p.copia   = c.cod_copia
>        JOIN libro   li ON c.isbn    = li.isbn
> GROUP BY l.tessera, l.nome, l.cognome
> HAVING COUNT(*) FILTER (WHERE li.genere = 'Giallo')
>      > COUNT(*) FILTER (WHERE li.genere = 'Saggistica');
> ```

### ii. [4] Per ogni genere, prestiti 2025 e lettori distinti (min. 100 prestiti)

```sql
SELECT li.genere,
       COUNT(*)                    AS num_prestiti,
       COUNT(DISTINCT p.tessera)   AS num_lettori
FROM   prestito p JOIN copia c  ON p.copia = c.cod_copia
                  JOIN libro li ON c.isbn  = li.isbn
WHERE  p.data_inizio >= DATE '2025-01-01'
  AND  p.data_inizio <  DATE '2026-01-01'
GROUP BY li.genere
HAVING COUNT(*) >= 100;
```

> Due aggregati diversi sullo stesso gruppo: `COUNT(*)` conta le righe (i prestiti), `COUNT(DISTINCT p.tessera)` conta i valori distinti (i lettori). Dimenticare il `DISTINCT` è l'errore tipico.

### iii. [5] Libri con almeno 3 copie mai restituiti in ritardo

```sql
SELECT li.isbn, li.titolo
FROM   libro li
WHERE  ( SELECT COUNT(*) FROM copia c WHERE c.isbn = li.isbn ) >= 3
  AND  NOT EXISTS (
         SELECT *
         FROM   prestito p JOIN copia c ON p.copia = c.cod_copia
         WHERE  c.isbn = li.isbn
           AND  p.data_restituzione > p.data_scadenza
       );
```

> Due condizioni indipendenti sullo stesso libro: una sottoquery scalare per il conteggio delle copie e un `NOT EXISTS` correlato per la condizione di negazione. Si noti che `p.data_restituzione > p.data_scadenza` è `UNKNOWN` quando la restituzione non è avvenuta, quindi i prestiti **ancora aperti** non contano come ritardi — coerentemente con il testo, che parla di libri *"mai restituiti in ritardo"*.

### iv. [3] Prestiti aperti scaduti prima del 2026, e indici utili

```sql
SELECT *
FROM   prestito
WHERE  data_restituzione IS NULL
  AND  data_scadenza < DATE '2026-01-01';
```

**Indici possibili e loro valutazione:**

| Indice | Valutazione |
|---|---|
| `CREATE INDEX ON prestito(data_scadenza);` — **B+-tree** | il predicato su `data_scadenza` è di **intervallo** (`<`), quindi **serve necessariamente un B+-tree**: un indice hash sarebbe del tutto inutile perché non conserva l'ordine delle chiavi. Il B+-tree individua la prima foglia utile e poi scorre le foglie concatenate all'indietro |
| `CREATE INDEX ON prestito(data_scadenza) WHERE data_restituzione IS NULL;` — **indice parziale** | ⭐ la soluzione migliore. I prestiti ancora aperti sono tipicamente una **piccola frazione** dello storico (qualche migliaio su centinaia di migliaia): l'indice parziale contiene solo quelle righe, risulta di dimensioni ridottissime, resta caldo nel buffer e non richiede di verificare `data_restituzione IS NULL` sulle tuple recuperate |
| `CREATE INDEX ON prestito(data_restituzione, data_scadenza);` — **composito** | poco efficace: la prima colonna dell'indice è usata con un predicato `IS NULL`, che ha selettività bassa se l'attributo è nullo di frequente, e in diversi sistemi i valori nulli non sono indicizzati affatto |
| Indice **hash** su `data_scadenza` | ❌ **inutilizzabile**: l'hash supporta solo predicati di uguaglianza |

**Osservazione sulla selettività.** Se la data indicata è recente e quasi tutti i prestiti risultano scaduti, l'ottimizzatore preferirà comunque una **scansione sequenziale**: l'accesso via indice secondario a una frazione elevata di tuple costa più della scansione, perché ogni tupla richiede un accesso a una pagina potenzialmente diversa. L'indice paga solo quando la selettività del predicato è buona (indicativamente sotto il 10–15 % delle righe).

## k) Query MongoDB **(3)**

**i.** Libri gialli dopo il 2010 con almeno una copia disponibile:

```js
db.libri.find(
  {
    anno:   { $gt: 2010 },
    generi: "Giallo",
    copie:  { $elemMatch: { stato: "disponibile" } }
  },
  { _id: 0, titolo: 1, autore: 1 }
)
```

> - `generi: "Giallo"` su un **array** è vero se **almeno un elemento** vale `"Giallo"`: non serve alcun operatore aggiuntivo.
> - Con una **sola** condizione sull'elemento, `copie: { $elemMatch: { stato: "disponibile" } }` è equivalente alla forma più semplice `"copie.stato": "disponibile"`. `$elemMatch` diventa **indispensabile** solo quando le condizioni sull'elemento sono **due o più** e devono valere per lo **stesso** elemento.

**ii.** Numero totale di copie per editore, primi 10:

```js
db.libri.aggregate([
  { $group: {
      _id:      "$editore",
      numCopie: { $sum: { $size: "$copie" } },
      numTitoli:{ $sum: 1 }
  }},
  { $sort:  { numCopie: -1 } },
  { $limit: 10 }
])
```

> `$size` restituisce la lunghezza dell'array in ciascun documento; sommandola sui documenti dello stesso editore si ottiene il totale delle copie. In alternativa si poteva usare `$unwind` seguito da `$sum: 1`, ma `$size` è più efficiente perché evita di moltiplicare i documenti nella pipeline.
> L'ordine `$sort` → `$limit` è essenziale: invertirli prenderebbe 10 documenti a caso e poi li ordinerebbe.

## l) Transazioni: lettura inconsistente e inserimento fantasma **(6)**

### Lettura inconsistente (*non-repeatable read*)

**Definizione.** Una transazione legge **due volte lo stesso dato** nel corso della propria esecuzione e ottiene **valori diversi**, perché nel frattempo un'altra transazione lo ha modificato e ha committato. La transazione lavora quindi su una visione **non stabile** della base di dati.

```
   t1: bot  r1(x)   ...   r1(x)   commit  eot
   t2: bot        w2(x)  commit  eot
```

```
        t1                          t2               valore di x
        bot                                              [2]
        r1(x) → legge 2                                  [2]
                                    bot                  [2]
                                    w2(x)                [4]
                                    commit               [4]
        r1(x) → legge 4  ← DIVERSO                       [4]
        commit
```

**Esempio SQL:**

```sql
-- T1                                            -- T2
BEGIN;
SELECT saldo FROM conto WHERE numero = 15;
-- legge 1000
                                                 BEGIN;
                                                 UPDATE conto SET saldo = 500
                                                   WHERE numero = 15;
                                                 COMMIT;
SELECT saldo FROM conto WHERE numero = 15;
-- legge 500  →  la stessa query dà due risultati diversi
COMMIT;
```

**Livello di isolamento minimo per evitarla: `REPEATABLE READ`.** Il lock condiviso acquisito dalla prima lettura viene mantenuto fino alla fine della transazione, impedendo a `t2` di ottenere il lock esclusivo necessario alla scrittura. `READ COMMITTED` **non basta**, perché rilascia il lock di lettura subito dopo la `SELECT`.

### Inserimento fantasma (*phantom insert*)

**Definizione.** Una transazione esegue due volte la **stessa interrogazione su un insieme di righe** (una query con un predicato di selezione) e la seconda volta ottiene **righe in più** — i *fantasmi* — perché un'altra transazione ha nel frattempo **inserito** (o modificato in modo da farle rientrare nel predicato) delle tuple che soddisfano quel predicato, e ha committato.

La differenza cruciale rispetto alla lettura inconsistente è che **le righe nuove non esistevano** al momento della prima lettura: non c'era alcun dato da bloccare.

```
   t1: bot  "SELECT AVG(voto) FROM esame WHERE corso='BD'"  →  media su 10 esami
   t2: bot  "INSERT INTO esame VALUES (…, 'BD', 30)"  commit  eot
   t1:      "SELECT AVG(voto) FROM esame WHERE corso='BD'"  →  media su 11 esami
```

**Esempio SQL:**

```sql
-- T1                                            -- T2
BEGIN;
SELECT COUNT(*) FROM prestito
  WHERE tessera = 'L0042'
    AND data_restituzione IS NULL;
-- risultato: 3 prestiti aperti (limite = 5, si può prestare)
                                                 BEGIN;
                                                 INSERT INTO prestito
                                                   VALUES ('P991','L0042','C7',
                                                           CURRENT_DATE, …, NULL, 0);
                                                 COMMIT;
SELECT COUNT(*) FROM prestito
  WHERE tessera = 'L0042'
    AND data_restituzione IS NULL;
-- risultato: 4  →  è comparsa una riga FANTASMA
COMMIT;
```

**Livello di isolamento minimo per evitarlo: `SERIALIZABLE`.** È l'unico livello che lo impedisce: `REPEATABLE READ`, nella definizione dello standard SQL, ammette ancora i fantasmi.

### Perché il locking sui record non basta per l'inserimento fantasma

Il meccanismo di locking tradizionale opera su **oggetti esistenti**: la transazione richiede un lock su ogni tupla (o pagina) che legge o scrive. Questo è sufficiente per la lettura inconsistente, perché la tupla `x` **esiste già** quando `t1` la legge e può quindi essere bloccata, impedendo a `t2` di modificarla.

Nel caso dell'inserimento fantasma il problema è diverso: la tupla che causa l'anomalia **non esiste** al momento della prima lettura di `t1`. Non c'è alcun oggetto su cui `t1` possa acquisire un lock; `t2` inserisce una tupla completamente nuova, sulla quale nessun lock precedente può insistere. Bloccare tutte le tuple lette non serve a nulla contro una tupla che non era fra quelle lette.

La soluzione richiede di bloccare non gli oggetti ma il **predicato**, cioè l'insieme (potenzialmente infinito) delle tuple che lo soddisferebbero:

- **Predicate locking**: si acquisisce un lock logico sulla condizione `corso = 'BD'`; ogni inserimento che soddisfi il predicato viene bloccato. È corretto ma costosissimo da verificare in generale, quindi poco usato in pratica.
- **Index-range locking** (o *next-key locking*): la soluzione realmente adottata dai DBMS. Si bloccano gli **intervalli di chiave dell'indice** corrispondenti al predicato, non le sole tuple. Un inserimento che cadrebbe in quell'intervallo dell'indice trova il lock e viene sospeso. È la tecnica con cui, ad esempio, MySQL/InnoDB implementa `REPEATABLE READ` in modo da evitare anche i fantasmi.
- **Serializable Snapshot Isolation (SSI)**: la strada seguita da PostgreSQL a livello `SERIALIZABLE`, che non blocca ma rileva a posteriori i cicli di dipendenza fra transazioni e aborta una delle transazioni coinvolte.

### Confronto riassuntivo

| | Lettura inconsistente | Inserimento fantasma |
|---|---|---|
| Che cosa cambia fra le due letture | il **valore** di una tupla esistente | l'**insieme** delle tuple che soddisfano un predicato |
| Operazione dell'altra transazione | `UPDATE` | `INSERT` (o `UPDATE` che fa rientrare la tupla nel predicato) |
| L'oggetto esiste alla prima lettura? | **sì** | **no** |
| Si evita bloccando le tuple lette? | **sì** | **no** |
| Livello di isolamento minimo | `REPEATABLE READ` | `SERIALIZABLE` |

## m) Programma Python **(4)**

```python
import psycopg2
from datetime import date

DSN = "dbname=biblioteca user=studente password=segreta host=localhost port=5432"

QUERY = """
    SELECT cod_prestito, copia, data_inizio, data_scadenza, rinnovi
    FROM   prestito
    WHERE  tessera = %s
      AND  data_restituzione IS NULL
    ORDER BY data_scadenza ASC
"""


def main():
    tessera = input("Numero di tessera del lettore: ").strip()
    if not tessera:
        print("Tessera non valida.")
        return

    conn = None
    try:
        conn = psycopg2.connect(DSN)
        with conn.cursor() as cur:
            cur.execute(QUERY, (tessera,))
            righe = cur.fetchall()

        if not righe:
            print(f"Nessun prestito aperto per la tessera {tessera}")
            return

        oggi = date.today()
        print(f"\nPrestiti aperti per la tessera {tessera}:\n")
        print(f"{'PRESTITO':<16}{'COPIA':<14}{'INIZIO':<12}{'SCADENZA':<12}"
              f"{'RINNOVI':>8}  STATO")
        print("-" * 76)

        scaduti = 0
        for cod, copia, inizio, scadenza, rinnovi in righe:
            if scadenza is not None and scadenza < oggi:
                stato = "SCADUTO"
                scaduti += 1
            else:
                stato = ""
            print(f"{cod:<16}{copia:<14}{str(inizio):<12}{str(scadenza):<12}"
                  f"{rinnovi:>8}  {stato}")

        print(f"\n{len(righe)} prestiti aperti, di cui {scaduti} scaduti.")

    except psycopg2.Error as e:
        print(f"Errore nell'accesso alla base di dati: {e}")
    finally:
        if conn is not None:
            conn.close()


if __name__ == "__main__":
    main()
```

**Punti che il docente valuta:**
- **parametri** `%s` invece della concatenazione di stringhe (protezione dalla *SQL injection*);
- il filtro `data_restituzione IS NULL` e l'`ORDER BY` sono **dentro la query** e non realizzati in Python;
- il confronto con la data odierna per la dicitura `"SCADUTO"` è fatto **in Python** perché riguarda la sola presentazione — in alternativa si poteva calcolarlo nel `SELECT` con `data_scadenza < CURRENT_DATE AS scaduto`, soluzione altrettanto valida e anzi preferibile se il dato servisse per filtrare;
- gestione del **caso vuoto** con il messaggio richiesto dal testo;
- gestione del valore **`NULL`** su `data_scadenza` (il confronto `scadenza < oggi` andrebbe in errore su `None`);
- **chiusura** della connessione nel blocco `finally`.
