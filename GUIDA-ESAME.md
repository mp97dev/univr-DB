# Guida allo studio — Esame di Basi di Dati

Cosa studiare, su quali file, in che ordine.
Indice completo dei file → [INDEX.md](INDEX.md)

---

## Come è fatto l'esame

L'esame è diviso in **due prove distinte**, che corrispondono ai due semestri del corso.

| | Prova 1 — **Teoria** | Prova 2 — **Tecnologie + Laboratorio** |
|---|---|---|
| Argomenti | Progettazione: ER, modello relazionale, document/JSON, algebra e calcolo relazionale | Interni del DBMS: transazioni, affidabilità, strutture di accesso, concorrenza, ottimizzazione, MongoDB, SQL su PostgreSQL |
| Formato | Domande aperte brevi su costrutti ER, collezioni e JSON + esercizio di progettazione + query in algebra/calcolo | Domande di teoria (**una è sempre sulle proprietà ACID**, una su guasti/collisioni) + esercizi + query da scrivere |
| Materiale | `01-Teoria/`, `05-Appunti-Riassunto/` | `02-Tecnologie/`, `03-Laboratorio/` |
| Temi svolti | `04-Esami/01-Teoria-e-Progettazione/`, `04-Esami/04-Svolti-con-Soluzioni/` | `04-Esami/02-Tecnologie-III-Prova/`, `04-Esami/03-Laboratorio/` |

> **Attenzione alle domande di sbarramento.** Nei temi di teoria le prime domande (a, b, c) sono dichiarate obbligatorie: *"in caso di mancata o errata risposta a queste domande il resto del compito non verrà corretto"*. Vedi `04-Esami/01-Teoria-e-Progettazione/03-Appelli-Completi/BDTeoria19Giu2020.pdf`.

> **Temi con soluzioni ufficiali** (usali per verificare il tuo svolgimento, non solo per leggerli):
> - I prova: `01-I-Prova-Progettazione/BD-I-ProvaIntermediaA-9gennaio2017-conSoluzioni.pdf`, `BD_IProvaIntermediaB-1dicembre2023-conSoluzioni.pdf`, `EsercitazioneInPreparazioneProvaIntermedia-2017-soluzioni.pdf`
> - II prova: in `02-II-Prova-Algebra-Calcolo/` tutti i file `*soluzioni*` / `*conSol*` (28/02/2017, 28/01/2020, 3/03/2022, 28/02/2023, 29/02/2024)
> - Tecnologie: `2015_06_terza_prova_soluzioni.pdf`, `2016_06_07_III_prova_intermedia_soluzioni.pdf`, più `02-Tecnologie/07-Esercitazioni-Riepilogative/`
> - Laboratorio: `2025_09_16_III_appello_laboratorio_con_soluzioni.pdf`

---

# PARTE 1 — TEORIA

## Struttura tipica del compito

Ricostruita dai temi in `04-Esami/01-Teoria-e-Progettazione/`, divisi in `01-I-Prova-Progettazione/` (punti 1-2), `02-II-Prova-Algebra-Calcolo/` (punto 3 + domande su join/proiezione) e `03-Appelli-Completi/` (tutto insieme):

1. **Domande preliminari (sbarramento)**
   - a) *"Si illustri il costrutto di … del modello Entità-Relazione"* — definizione + sintassi grafica + esempio.
   - b) *Dato uno schema concettuale ER, produrne la traduzione nel modello relazionale.*
   - c) Domanda su superchiave / chiave / vincoli di integrità referenziale **oppure** una o due espressioni di algebra relazionale su schemi astratti `R1(A,B,C*,D)`, `R2(D,E,F,G)`.
2. **Esercizio grande di progettazione** — un testo lungo (aeroporto, prenotazioni lezioni, ospedale…) da cui produrre:
   - lo **schema concettuale ER** (con tutti i vincoli e le cardinalità, senza aggiungere attributi non richiesti dal testo);
   - lo **schema logico relazionale** (con chiavi primarie sottolineate e vincoli di integrità referenziale);
   - lo **schema a documenti** (collezioni JSON) per la parte non relazionale.
3. **Interrogazioni** in algebra relazionale ottimizzata, calcolo relazionale sulle tuple, e/o linguaggio MongoDB.

## Cosa studiare

### 1. Fondamenti — `01-Teoria/00-Introduzione/`
- Sistema informativo, informatico, base di dati, DBMS.
- Modello dei dati; schema vs istanza.
- **Architettura a tre livelli**: schema esterno / logico / interno.
- **Indipendenza fisica e indipendenza logica** dei dati (`EsempioIndipendenzaFisicaLogica.pdf`).
- Fasi della progettazione: concettuale → logica → fisica.

### 2. Modello ER — `01-Teoria/01-Modello-ER/` ⭐ *fonte delle domande a)*
Per ogni costrutto devi saper dare: **definizione formale + notazione grafica + esempio d'uso**. È esattamente ciò che chiede la domanda a).
- **Entità** e istanza di entità.
- **Relazione** (associazione): definizione come sottoinsieme del prodotto cartesiano, istanza, relazione **ricorsiva** (con ruoli), relazione **ternaria** e n-aria.
- **Attributo**: semplice, **composto**, **opzionale**, **multivalore**; attributo di entità e attributo di relazione.
- **Identificatore**: interno, esterno, composto; regole di correttezza.
- **Cardinalità** di relazione `(MIN, MAX)` e cardinalità di attributo; valori ammessi per MIN e MAX e loro significato.
- **Generalizzazione**: totale/parziale, esclusiva/sovrapposta; ereditarietà delle proprietà; sottoinsieme.
- **Strategie di progetto** (`StrategieProgetto.pdf`): top-down, bottom-up, inside-out, mista; qualità dello schema (correttezza, completezza, leggibilità, minimalità).

> ✅ *Check*: sai spiegare a voce, con un disegno, **relazione**, **cardinalità**, **identificatore esterno** e **generalizzazione**? Sono i quattro costrutti che ricorrono di più nella domanda a).

### 3. Modello relazionale — `01-Teoria/02-Modello-Relazionale/`
- Dominio, relazione matematica vs **relazione su attributi**, ennupla, grado e cardinalità.
- Accesso ai valori di una ennupla (`t[A]`).
- **Valori nulli**: significati (sconosciuto, inesistente, senza informazione) e problemi.
- **Vincoli di integrità**: di dominio, di tupla, intrarelazionali (**chiave**, **superchiave**, NOT NULL), interrelazionali (**integrità referenziale / foreign key**).
- **Superchiave e chiave**: definizione formale (una superchiave è un insieme di attributi che identifica univocamente ogni ennupla; una chiave è una superchiave **minimale**), chiave primaria, notazione con `*` per gli attributi opzionali.
- Relazione unica, **anomalie** (inserimento, cancellazione, aggiornamento, ridondanza) e **decomposizione**.

> ✅ *Check*: la domanda c) chiede spesso *"si illustri il concetto di superchiave (definizione formale) e si indichino due superchiavi non minimali"* e *"si specifichi un vincolo di integrità referenziale sull'attributo B di R1"*. Impara la definizione a memoria.

### 4. Progettazione logica relazionale — `01-Teoria/03-Progettazione-Logica-Relazionale/` ⭐ *fonte della domanda b)*
**Fase 1 — Ristrutturazione dello schema ER:**
- analisi delle **ridondanze**;
- eliminazione delle **generalizzazioni** (tre alternative: accorpamento nel padre, accorpamento nei figli, sostituzione con relazioni) e criteri di scelta;
- **partizionamento/accorpamento** di entità e relazioni;
- eliminazione di attributi **multivalore** e **composti**;
- scelta degli **identificatori primari**.

**Fase 2 — Traduzione nel modello logico.** Devi conoscere a memoria la regola per ciascun caso:
| Costrutto ER | Traduzione |
|---|---|
| Entità | Tabella con gli attributi; identificatore → chiave primaria |
| Relazione **N:N** | Tabella a sé, chiave = unione delle chiavi delle entità coinvolte; eventuali attributi di relazione |
| Relazione **N:N con attributi** | Idem, gli attributi di relazione diventano attributi della nuova tabella |
| Relazione **1:N** | Chiave esterna nell'entità lato "N" (lato con MAX = 1 riceve… attenzione al verso) |
| Relazione **1:N con attributi** | Gli attributi di relazione migrano insieme alla chiave esterna |
| Relazione **1:1** | Chiave esterna in una delle due; la scelta dipende dalle **cardinalità minime** (0,1 / 1,1) |
| Relazione **1:1 con MIN = 0** su un lato | Chiave esterna nell'entità con partecipazione obbligatoria, per evitare NULL |
| **Identificatore esterno** | La chiave dell'entità identificante entra nella chiave primaria dell'entità identificata |
| Relazione **ternaria** | Tabella a sé con le chiavi delle tre entità; se una cardinalità è (1,1) la chiave si riduce |

Riferimento visivo utile: `05-Appunti-Riassunto/sorgente-latex/figures/regola_traduzione_*.png` — c'è una figura per ogni regola.

> ✅ *Check*: prendi uno schema ER a caso da un tema d'esame, coprine la soluzione e traducilo in 10 minuti.

### 5. Sistemi document-based, collezioni e JSON — `01-Teoria/04-Document-DB-e-JSON/` ⭐
Il testo dell'esercizio chiede la progettazione **anche** verso un sistema a documenti; nelle domande brevi compaiono *collezioni* e *JSON*.
- Motivazioni NoSQL; classificazione dei sistemi NoSQL; **document store**.
- Struttura di un **documento JSON**: coppie chiave/valore, valori scalari, **array**, **documenti annidati**; BSON e `_id`.
- **Collezione**: insieme di documenti eterogenei, assenza di schema fisso.
- **Embedding (incapsulamento) vs referencing (riferimenti)**: quando conviene l'uno e quando l'altro; documenti normalizzati vs denormalizzati; costi di lettura/scrittura e duplicazione.
- **Etichettatura dello schema ER** per la traduzione in collezioni: individuazione dell'**entità principale**, freccia di incapsulamento, regole di traduzione ER → collezioni.
- Casi: 1:1, 1:N, N:N, generalizzazioni, relazioni ricorsive.

Figure di supporto: `05-Appunti-Riassunto/sorgente-latex/figures/esempio_incapsulamento_*.png`, `esempio_documenti_con_riferimenti*.png`, `esempio_etichettatura*.png`, `struttura_documento_json.png`.

### 6. Algebra relazionale — `01-Teoria/05-Algebra-Relazionale/` ⭐
- Operatori **insiemistici**: unione, differenza, intersezione (e requisito di compatibilità degli schemi).
- **Ridenominazione** ρ.
- **Selezione** σ e **proiezione** π (con eliminazione dei duplicati).
- **Join**: prodotto cartesiano, **join naturale**, **theta-join**, **equi-join**, **join esterni** (left, right, full).
- **Divisione**.
- Algebra con **valori nulli** (logica a tre valori, `IS NULL` / `IS NOT NULL`).
- **Ottimizzazione algebrica**: anticipo delle selezioni (*selection push*), anticipo delle proiezioni (*projection push*), trasformazioni di equivalenza. Le tracce chiedono spesso *"un'espressione **ottimizzata**"*.

Pattern d'esame ricorrenti da saper scrivere al volo:
- combinazioni **distinte** di due attributi → proiezione;
- valori di R1 **non presenti** in R2 → differenza (attenzione: spesso è vietato usare join);
- *"esiste una tupla t′ di R2 tale che t[G] > t′[B]"* → **theta-join** + proiezione, con vincoli sul numero di operatori ammessi;
- *"non … né … né …"* → differenza;
- *"almeno due …"* → self-join con ridenominazione e disuguaglianza;
- *"il più giovane / il massimo"* → differenza tra tutti e quelli superati da qualcun altro.

Esercizi con soluzione: `Q1_soluzione.png` … `Q7_soluzione.png`, `Esercizi-svolti-AR-Garza-2006.pdf` (algebra + SQL sulla stessa query, utile anche per il laboratorio), più `05-Appunti-Riassunto/Esercizi-Svolti/algebra_relazionale.pdf`.

> 📌 La domanda a) della II prova è sempre *"Si illustri l'operatore di … dell'algebra relazionale (sintassi, semantica, esempio d'uso)"*: **join naturale** (2020, 2023, 2024) o **proiezione** (2017). La b) usa schemi astratti (es. `R1(A,B,C*,D)`, `R2(D,E,F,G*)` nel 2023) con vincoli sugli operatori ammessi (*"solo un theta join, una selezione e una proiezione"*).

### 7. Calcolo relazionale — `01-Teoria/06-Calcolo-Relazionale/`
- Calcolo relazionale **sulle tuple con dichiarazioni di range**: sintassi (lista target, range, formula) e semantica.
- **Quantificatori** esistenziale e universale, variabili libere e vincolate.
- Operatori insiemistici nel calcolo.
- Corrispondenza con SQL e con l'algebra; **limiti espressivi** (es. chiusura transitiva).
- **Esercitati** su: `Esercitazione-calcolo-relazionale-testo.pdf` → `-soluzioni.pdf`, poi le domande di calcolo dei temi `*calcoloRel*` / `*Calcolo*` in `04-Esami/01-…/02-II-Prova-Algebra-Calcolo/`.

### 8. Interrogazioni su document DB — `01-Teoria/04-Document-DB-e-JSON/DocumentDBLinguaggioInterrogazione.pdf`
- `find()` con filtro e proiezione; operatori `$eq $ne $gt $lt $in $nin $and $or $not $exists $regex`.
- Query su **documenti annidati** (dot notation) e su **array** (`$elemMatch`, `$all`, `$size`).
- **Aggregation pipeline**: `$match`, `$project`, `$group` (+ `$sum $avg $max $min $count`), `$unwind`, `$sort`, `$limit`, `$lookup` (il "join" di MongoDB).

---

# PARTE 2 — TECNOLOGIE E LABORATORIO

## Struttura tipica del compito

Ricostruita da `04-Esami/02-Tecnologie-III-Prova/2024_06_23_III_prova_intermedia.pdf` (durata 2h15):

**DOMANDE DI TEORIA (~13 punti)**
- a) **Proprietà delle transazioni (ACID)** + *quali moduli del DBMS garantiscono ciascuna proprietà* → **c'è praticamente sempre**.
- b) Una struttura di accesso: hash vs B+-tree, gestore del buffer, organizzazione della pagina.
- c) Una domanda su **MongoDB**: sharding, replica set, elezione del primario, ACID in MongoDB.

**ESERCIZI (~19 punti)**
- d) **Gestore dell'affidabilità** — dato un file di LOG e un guasto, illustrare la **ripresa a caldo** (o a freddo).
- e) **Esecuzione concorrente** — dato uno schedule: è **VSR**? è **CSR**? rispetta **2PL**? (con giustificazione).
- f) **Ottimizzazione** — calcolare il **costo in numero di accessi a memoria secondaria** di una query, e come cambia con un indice B+-tree.
- g) **B+-tree** — costruzione/inserimento.

**LABORATORIO** (`04-Esami/03-Laboratorio/`, durata 1h30). Ricostruita dai 9 appelli 2022–2025, la struttura è stabile:
- a) Completare una dichiarazione `CREATE TABLE` PostgreSQL con tutti i **vincoli** richiesti (chiave primaria, superchiave, FK, CHECK…).
- b) **Query SQL** su uno schema relazionale dato: di solito 4 query a difficoltà crescente (aggregati, `NOT EXISTS`, confronto con una media calcolata in sottoquery), l'ultima chiede anche **quali indici** creare e perché.
- *(solo formato 2022)* c)–e) Domande brevi: cosa succede assegnando un valore a `NUMERIC(p,s)`; valutazione di un'espressione con `NULL` (**logica a tre valori**); quali indici servono per `LIKE 'VR0%' OR voto = 30`; lettura di un piano `EXPLAIN` e indici da aggiungere.
- g) **Transazioni** ⭐ *c'è sempre*: descrivere un'anomalia (es. aggiornamento fantasma), scrivere **due transazioni SQL** che la producono e indicare il **livello di isolamento minimo** che la evita.
- h) **Python/Java** ⭐ *c'è sempre*: un programma che chiede input all'utente, esegue una query parametrica su PostgreSQL e gestisce il caso "nessun risultato".
- MongoDB compare solo nell'appello 2025.

## Cosa studiare

### 1. Transazioni e proprietà ACID — `02-Tecnologie/01-Transazioni-e-Affidabilita/lesson_01_transazioni.pdf` ⭐⭐ *domanda garantita*

Da sapere alla perfezione, perché è la domanda che c'è sempre:

| Proprietà | Significato | Modulo del DBMS che la garantisce |
|---|---|---|
| **A**tomicity (atomicità) | La transazione è indivisibile: o si esegue tutta o niente; nessuna esecuzione parziale | **Gestore dell'affidabilità** (log, UNDO/REDO) |
| **C**onsistency (consistenza) | La transazione porta la base di dati da uno stato consistente a un altro, rispettando i vincoli di integrità | **Gestore dell'integrità** (verifica immediata o differita dei vincoli) |
| **I**solation (isolamento) | L'esecuzione di una transazione è indipendente da quella delle altre concorrenti | **Gestore della concorrenza** (locking / 2PL / timestamp) |
| **D**urability (persistenza) | Gli effetti di una transazione andata a buon fine sono permanenti, anche in caso di guasto | **Gestore dell'affidabilità** |

Da sapere anche:
- definizione di transazione e di **transazione ben formata** (`begin transaction … end transaction`, con `commit work` / `rollback work`);
- `commit` come "punto di non ritorno";
- verifica **immediata** vs **differita** dei vincoli;
- architettura di riferimento del DBMS e collocazione dei vari gestori.

### 2. Gestore dell'affidabilità: guasti e ripresa — `02-Tecnologie/01-Transazioni-e-Affidabilita/` ⭐⭐ *esercizio garantito*
- **Memoria stabile**, gerarchia delle memorie.
- **File di LOG**: record di transazione `B(T)` begin, `I(T,O,A)` insert, `D(T,O,B)` delete, `U(T,O,B,A)` update, `C(T)` commit, `A(T)` abort; record di sistema `CK(...)` checkpoint e `DUMP`.
- Regole fondamentali: **WAL** (Write-Ahead Log) e **regola di Commit-Precedenza**.
- Tipi di guasto: **di sistema** (perdita della memoria centrale → ripresa a caldo) e **di dispositivo** (perdita della memoria secondaria → ripresa a freddo).
- **Ripresa a caldo (warm restart)** — i 4 passi:
  1. si legge il log **all'indietro** fino all'ultimo record di **checkpoint**;
  2. si costruiscono gli insiemi **UNDO** (transazioni iniziate ma non terminate con commit) e **REDO** (transazioni con commit dopo il checkpoint);
  3. si ripercorre il log **all'indietro** fino al `B()` della più vecchia transazione in UNDO, **disfacendo** le azioni delle transazioni in UNDO;
  4. si ripercorre il log **in avanti**, **rifacendo** le azioni delle transazioni in REDO.
- **Ripresa a freddo (cold restart)**: ripristino dal **dump**, riapplicazione del log dal dump in poi, poi ripresa a caldo.
- **Esercitati** su: `lesson_02_esercizio_ripresa_a_caldo_01.pdf` e `_02.pdf`, poi sulla traccia d) di ogni tema in `04-Esami/02-Tecnologie-III-Prova/`.

### 3. Strutture fisiche e strutture di accesso — `02-Tecnologie/02-Strutture-Fisiche-e-Accesso/`
- Memoria secondaria, **blocchi** e **pagine**; perché il costo si misura in accessi a memoria secondaria.
- **Gestore del buffer**: organizzazione in pagine, primitive `fix` / `unfix` / `setDirty` / `force` / `flush`, principio di **località dei riferimenti** e legge 80-20, politiche di rimpiazzo (LRU), politiche **steal/no-steal** e **force/no-force**.
- **Gestore dei metodi di accesso**; metodi disponibili: scansione sequenziale, accesso via indice, ordinamento, varie implementazioni del join.
- **Organizzazione della pagina**: dizionario, offset delle tuple, parte utile, TOAST (*Oversized-Attribute Storage Technique*).
- Organizzazioni primarie: **sequenziale** (entry-sequenced, ad array, ordinata), **ad accesso calcolato (hash)**, **ad albero**.
- **Hash**: funzione di hash, bucket, **collisioni** e gestione dell'overflow (catena di overflow); vantaggi rispetto al B+-tree (accesso puntuale su uguaglianza, costo ~1 accesso) e svantaggi (nessun supporto alle query di **range** e all'ordinamento).
- **B+-tree** ⭐: struttura dei nodi interni e foglia, **fan-out** `n`, **vincoli di riempimento** (nodo foglia: `⌈(n−1)/2⌉ ≤ #chiavi ≤ n−1`), concatenazione delle foglie, albero **bilanciato**, ricerca puntuale e di range, **inserimento con split**, cancellazione con merge, indice **primario/clustered** vs **secondario/unclustered**, profondità dell'albero e costo in accessi.
- **Esercitati** su: `lesson_04_esercizio_b+tree.pdf`.

> ⚠️ La domanda b) del tema 2024_06_23 è esattamente: *"Illustrare la struttura ad accesso calcolato (hash), in particolare il funzionamento dell'inserimento e della ricerca di una tupla di chiave K, ed evidenziare i casi in cui è più vantaggiosa di un B+-tree."* Il confronto **hash vs B+-tree** e la gestione delle **collisioni** sono argomenti caldi.

### 4. Controllo di concorrenza — `02-Tecnologie/03-Concorrenza/` ⭐⭐ *esercizio garantito*
- **Anomalie**: perdita di aggiornamento, lettura sporca (*dirty read*), lettura inconsistente, aggiornamento fantasma, inserimento fantasma. Sapere costruire l'esempio di schedule per ciascuna.
- Notazione `r_i(x)`, `w_i(x)`, **schedule**, schedule **seriale**, schedule **serializzabile**.
- Ipotesi di **commit-proiezione**.
- **View-serializzabilità (VSR)**: relazione **LEGGE-DA** e insieme delle **SCRITTURE FINALI**; due schedule sono view-equivalenti se hanno le stesse letture-da e le stesse scritture finali. Il test è di complessità esponenziale.
- **Conflict-serializzabilità (CSR)**: definizione di conflitto (r-w, w-r, w-w sullo stesso oggetto da transazioni diverse), **grafo dei conflitti**, test = assenza di cicli. Test polinomiale.
- Relazione tra le classi: **CSR ⊂ VSR ⊂ Serializzabili**. Ogni schedule CSR è VSR, non viceversa.
- **Locking**: lock condiviso (`r_lock`) ed esclusivo (`w_lock`), tabella di compatibilità, lock manager.
- **2PL (two-phase locking)**: fase crescente e fase calante; **2PL stretto** e sua relazione con l'atomicità; **2PL ⊂ CSR**.
- **Timestamp** (concorrenza ottimistica), **deadlock** e sua gestione.
- **Livelli di isolamento SQL**: `READ UNCOMMITTED`, `READ COMMITTED`, `REPEATABLE READ`, `SERIALIZABLE`, e quali anomalie ciascuno ammette (vedi anche `03-Laboratorio/Lezione-06-...`).
- **Esercitati** su: `lesson_06_01_esercizi_test_VSR.pdf` + `lesson_06_02_esercizi_test_CSR.pdf` → soluzioni in `lesson_06_03_...`.

> 📌 Metodo per l'esercizio e): (1) disegna il **grafo dei conflitti** — se è aciclico lo schedule è CSR, e quindi anche VSR, e hai finito con due risposte su tre; (2) se è ciclico, verifica VSR con legge-da + scritture finali; (3) per 2PL, prova a costruire un piano di lock a due fasi, oppure mostra la violazione.

### 5. Ottimizzazione delle interrogazioni — `02-Tecnologie/04-Ottimizzazione/` ⭐⭐ *esercizio garantito*
- Fasi di **compilazione** di una query: analisi lessicale/sintattica/semantica → ottimizzazione algebrica → ottimizzazione basata sui costi → generazione del codice.
- **Ottimizzazione algebrica**: anticipo delle selezioni, anticipo delle proiezioni, riordinamento dei join.
- **Profili delle relazioni**: `NP(R)` numero di pagine, `NR(R)` numero di tuple (righe), `VAL(A,R)` numero di valori distinti dell'attributo A, `MIN`/`MAX`.
- **Fattore di selettività** e stima della cardinalità del risultato: per una selezione di uguaglianza su A, `NR ≈ NR(R)/VAL(A,R)`.
- Costi dei metodi di accesso: **scansione** = `NP(R)`; **ordinamento**; **accesso via indice** (costo = profondità del B+-tree + accessi ai dati).
- **Algoritmi di join** e relativo costo:
  - **Nested Loop Join**: `NP(R) + NR(R) × NP(S)` (con una pagina di buffer per tabella) — R è l'operando **esterno**, S l'**interno**;
  - **Nested Loop Join con indice** su S: `NP(R) + NR(R) × (profondità indice + tuple corrispondenti)`;
  - **Merge Scan Join** (richiede operandi ordinati);
  - **Hash Join**.
- **Esercitati** su: `lesson_09_esercizio_ottimizzazione_stima_costo.pdf` e `lesson_12_03_esercitazione_ottimizzazione_soluzioni.pdf`.

> 📌 Nell'esercizio f) leggi con attenzione le **ipotesi** date dal testo (dove viene salvato il risultato intermedio, quale tabella è l'operando esterno, quante pagine di buffer): il numero cambia completamente a seconda di quelle.

### 6. Architettura di MongoDB — `02-Tecnologie/06-MongoDB-Architettura/architettura_mongodb.pdf` ⭐
- **Replicazione — replica set**: nodo **primario** e **secondari**, ridondanza, alta disponibilità, tolleranza ai guasti.
  - **oplog** (operation log): replica asincrona, operazioni **idempotenti**.
  - **heartbeat** tra i nodi e timeout (default 10 s).
  - **Algoritmo di elezione** basato sul consenso **Raft**: quando si attiva (aggiunta/rimozione di un nodo, inizializzazione, primario irraggiungibile oltre il timeout), maggioranza dei voti.
  - **Arbitro**: vota ma non mantiene copia dei dati e non può diventare primario; serve quando i nodi dati sono in numero pari.
  - **Nodi nascosti** e **ritardati**: partecipano al voto, non ricevono traffico dai client, usati per backup e reporting.
  - **Write concern** (`0`, `1`, `majority`, `<number>`) e **read preference / read concern**: trade-off tra consistenza, prestazioni e disponibilità.
- **Sharding (frammentazione)**: partizionamento orizzontale di una collezione su più istanze.
  - Componenti: **shard**, **mongos** (router), **config server** (metadati).
  - **Shard key** e **chunk**; sharding **ranged** vs **hashed**; **balancer**; micro-sharding.
  - Vantaggi (scalabilità orizzontale, throughput) e svantaggi.
- **Proprietà ACID in MongoDB**: atomicità garantita a livello di **singolo documento**; transazioni multi-documento (dalla 4.0) e distribuite (4.2); confronto con i DBMS relazionali.

### 7. SQL — `02-Tecnologie/05-SQL/` + `03-Laboratorio/`
- **DDL**: `CREATE TABLE`, tipi PostgreSQL (`CHAR(n)`, `VARCHAR(n)`, `INTEGER`, `DATE`, `TIMESTAMP`, `BOOLEAN`).
- **Vincoli** — è la domanda a) tipica del compito di laboratorio; sapere esprimere:
  | Richiesta | Vincolo |
  |---|---|
  | chiave primaria | `PRIMARY KEY` (di colonna o di tabella) |
  | superchiave / unicità | `UNIQUE` |
  | obbligatorietà | `NOT NULL` |
  | integrità referenziale | `FOREIGN KEY (…) REFERENCES T(…)` (+ `ON DELETE`/`ON UPDATE`) |
  | dominio ristretto a un insieme di valori | `CHECK (attr IN ('a','b','c'))` |
  | vincolo di tupla tra due attributi | `CHECK (data_inizio < data_fine)` |
  | valore di default | `DEFAULT FALSE` |
  > ⚠️ Una superchiave **composta** si esprime con `UNIQUE (a, b, c)` a livello di tabella, non ripetendo `UNIQUE` su ogni colonna.
- **Tipi e `NULL`** (domande brevi degli appelli 2022): `NUMERIC(p,s)` = p cifre totali di cui s decimali (valore arrotondato se ha troppi decimali, errore se sfora le cifre intere); confronti con `NULL` danno `UNKNOWN` e `WHERE` scarta le tuple non `TRUE`.
- **DML / query**: `SELECT`, join espliciti, `WHERE`, `GROUP BY` / `HAVING`, funzioni aggregate, `ORDER BY`, `DISTINCT`.
- **Query nidificate**: `IN`, `NOT IN`, `EXISTS`, `NOT EXISTS`, `ALL`, `ANY`; sottoquery correlate.
- **Operatori insiemistici**: `UNION`, `INTERSECT`, `EXCEPT`.
- **Viste**, `CREATE INDEX`, `EXPLAIN` / `EXPLAIN ANALYZE`.
- Pattern ricorrenti d'esame: *"trovare i X in cui A è più di B"* → due sottoquery aggregate messe a confronto; *"trovare gli X che non hanno mai …"* → `NOT EXISTS`; *"il massimo/minimo"* → `ALL` o `ORDER BY … LIMIT 1`.

### 8. Laboratorio — `03-Laboratorio/`
Ripercorri le 8 lezioni; per ciascuna il testo dell'esercitazione e (dove c'è) la soluzione `.sql`.
Rifai in particolare le lezioni **02, 03, 04** (query SQL), **05** (indici e prestazioni, `EXPLAIN`), **06** (concorrenza in SQL: anomalie + livelli di isolamento → domanda g), **07** (Python + `psycopg2`: query parametriche → domanda h) e **08** (MongoDB).

> 📌 Domanda h): prepara uno scheletro da riscrivere a memoria — connessione, `input()`, `cur.execute("… WHERE stelle >= %s AND regione = %s", (x, y))` con **parametri** (mai concatenare stringhe), ciclo sui risultati, messaggio se la lista è vuota, chiusura della connessione.
Per esercitarti su dati reali usa `05-Appunti-Riassunto/pokedata-esempio-SQL/` (`tables.sql` per creare lo schema, poi i CSV).

---

## Piano di studio consigliato

### Prova 1 — Teoria
| # | Cosa | File |
|---|---|---|
| 1 | Fondamenti e architettura a 3 livelli | `01-Teoria/00-Introduzione/` |
| 2 | Modello ER, tutti i costrutti | `01-Teoria/01-Modello-ER/` |
| 3 | Modello relazionale e vincoli | `01-Teoria/02-Modello-Relazionale/` |
| 4 | Regole di traduzione ER → relazionale | `01-Teoria/03-Progettazione-Logica-Relazionale/` |
| 5 | **Esercizio 1**: ER1 → schema ER → schema logico | `01-Teoria/07-…/Esempio ER1` poi `08-…/ER1` |
| 6 | Document DB, JSON, collezioni, etichettatura | `01-Teoria/04-Document-DB-e-JSON/` |
| 7 | **Esercizio 2**: ER1 → collezioni | `01-Teoria/09-…/Esempio ER1` |
| 8 | Algebra relazionale + ottimizzazione | `01-Teoria/05-Algebra-Relazionale/` |
| 9 | Calcolo relazionale | `01-Teoria/06-Calcolo-Relazionale/` |
| 10 | Query MongoDB | `01-Teoria/04-…/DocumentDBLinguaggioInterrogazione.pdf` |
| 11 | Ripeti 5-7 con ER2, ER3, ER4 | `01-Teoria/07/08/09` |
| 12 | **Simulazioni a tempo** (2h15) con soluzioni commentate | `06-Simulazioni/Teoria-Simulazione-1/2/3.md` |
| 13 | **Temi reali a tempo**, dai più recenti: prima quelli **con soluzioni ufficiali** (vedi elenco in cima) | `04-Esami/01-Teoria-e-Progettazione/01-I-Prova-…` (2022-23: alberghi, ristoranti, officine, supermercati) e `02-II-Prova-…` (2023-24), confronto con `04-Esami/04-Svolti-con-Soluzioni/` |
| 14 | Temi più vecchi per allenare la progettazione | `04-Esami/01-Teoria-e-Progettazione/03-Appelli-Completi/` |

Ripasso rapido finale: `05-Appunti-Riassunto/AppuntiBasiDati-1-Teoria.pdf`.

### Prova 2 — Tecnologie e Laboratorio
| # | Cosa | File |
|---|---|---|
| 1 | Transazioni e **ACID** (impara la tabella a memoria) | `02-Tecnologie/01-…/lesson_01_transazioni.pdf` |
| 2 | Log, WAL, ripresa a caldo e a freddo | `02-Tecnologie/01-…/lesson_02_esercizio_ripresa_a_caldo_01/02` |
| 3 | Buffer, pagine, organizzazioni fisiche, **hash e collisioni** | `02-Tecnologie/02-…/lesson_02`, `lesson_03` |
| 4 | **B+-tree** + esercizio di costruzione | `02-Tecnologie/02-…/lesson_04*` |
| 5 | Anomalie di concorrenza | `02-Tecnologie/03-…/lesson_05_concorrenza_01.pdf` |
| 6 | VSR, CSR, grafo dei conflitti, 2PL | `lesson_06_concorrenza_02.pdf`, `lesson_07_concorrenza_03.pptx` |
| 7 | **Esercizi VSR/CSR** finché non escono automatici | `lesson_06_01`, `lesson_06_02` → soluzioni `lesson_06_03` |
| 8 | Ottimizzazione algebrica e stima dei costi | `02-Tecnologie/04-…/lesson_08`, `lesson_09` |
| 9 | **Esercizi di costo** con e senza indice | `lesson_09_esercizio_…`, `lesson_12_03_…soluzioni.pdf` |
| 10 | Architettura MongoDB: replica set + sharding + ACID | `02-Tecnologie/06-MongoDB-Architettura/` |
| 11 | SQL: DDL con vincoli e query | `02-Tecnologie/05-SQL/`, `03-Laboratorio/Lezione-01..04` |
| 12 | Laboratorio: indici, concorrenza, **Python**, MongoDB | `03-Laboratorio/Lezione-05, 06, 07, 08` |
| 13 | **Simulazione completa** | `02-Tecnologie/07-Esercitazioni-Riepilogative/` (con soluzioni) |
| 14 | **Simulazioni a tempo** con soluzioni commentate | `06-Simulazioni/Tecnologie-Lab-Simulazione-1/2/3.md` |
| 15 | **Temi reali a tempo** (2h15) | `04-Esami/02-Tecnologie-III-Prova/` (soluzioni ufficiali per 2015 e 2016) |
| 16 | **Appelli di laboratorio a tempo** (1h30) — 9 temi, stessa struttura | `04-Esami/03-Laboratorio/` (soluzioni solo per il 2025: per gli altri prova le query su PostgreSQL) |

Ripasso rapido finale: `05-Appunti-Riassunto/AppuntiBasiDati-2-Tecnologie.pdf`.

---

## Checklist finale — le cose che *devono* essere automatiche

**Teoria**
- [ ] Definire + disegnare + esemplificare: entità, relazione, attributo, identificatore interno/esterno, cardinalità, generalizzazione
- [ ] Tradurre a vista uno schema ER in schema relazionale, con tutti i vincoli
- [ ] Definizione formale di superchiave, chiave, chiave primaria, vincolo di integrità referenziale
- [ ] Etichettare uno schema ER e produrre le collezioni di documenti JSON corrispondenti
- [ ] Sapere quando conviene incapsulare (embedding) e quando usare riferimenti
- [ ] Scrivere un'espressione di algebra **ottimizzata** rispettando i vincoli del testo (numero di operatori ammessi)
- [ ] Tradurre una query dall'algebra al calcolo relazionale e viceversa

**Tecnologie e Laboratorio**
- [ ] **ACID**: le quattro proprietà + il modulo del DBMS che garantisce ciascuna
- [ ] Ripresa a caldo: i 4 passi, costruzione degli insiemi UNDO e REDO da un file di LOG
- [ ] Differenza tra ripresa a caldo e a freddo, WAL e Commit-Precedenza
- [ ] Hash vs B+-tree: struttura, inserimento, ricerca, **collisioni**, quando conviene ciascuno
- [ ] Costruire un B+-tree con split dato un fan-out
- [ ] Le 5 anomalie di concorrenza con un esempio di schedule per ciascuna
- [ ] Grafo dei conflitti → CSR; legge-da + scritture finali → VSR; verifica 2PL
- [ ] Calcolare il costo di una query in accessi a memoria secondaria, con Nested Loop Join, con e senza indice
- [ ] MongoDB: replica set, oplog, elezione Raft, arbitro, write concern, sharding, shard key, mongos, config server
- [ ] `CREATE TABLE` PostgreSQL con PRIMARY KEY, UNIQUE (anche composta), NOT NULL, FOREIGN KEY, CHECK, DEFAULT
- [ ] Query SQL con GROUP BY/HAVING, sottoquery correlate, NOT EXISTS, operatori insiemistici
- [ ] Query MongoDB con `find` e con aggregation pipeline (`$match`, `$group`, `$unwind`, `$lookup`)
- [ ] Per ogni anomalia: due transazioni SQL che la producono + livello di isolamento minimo che la evita
- [ ] Programma Python (o Java) con input utente, query parametrica e gestione del risultato vuoto
