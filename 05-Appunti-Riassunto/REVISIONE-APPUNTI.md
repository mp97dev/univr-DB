# Revisione degli appunti riassuntivi — Basi di Dati (UniVR, III anno)

> ## ✅ STATO: correzioni applicate
>
> Questo documento è il **referto dell'analisi**. Le correzioni sono già state applicate
> e i PDF rigenerati:
>
> | Cosa | Dove |
> |---|---|
> | Teoria, corretto e integrato (70 pp., era 67) | `AppuntiBasiDati-1-Teoria-corretto.pdf` |
> | Tecnologie, corretto e integrato (90 pp., era 108) | `AppuntiBasiDati-2-Tecnologie-corretto.pdf` |
> | Sorgenti | `sorgente-latex/BasiDati.tex` (Teoria), `sorgente-latex/tecnologie/BasiDati.tex`, `sorgente-latex/preamble.sty` |
>
> Entrambi i documenti sono **corretti alla fonte**: le correzioni sono integrate nel
> testo, non in schede o appendici separate. Il preambolo è quello **originale** degli
> appunti, recuperato da `Uni-main/preamble.sty`.
>
> Margini impostati per stampa **fronte/retro con rilegatura**: lato dorso 2,3 cm
> (alternato fra pagine pari e dispari), lato esterno 1,4 cm.
>
> **Applicato in `BasiDati.tex`** (parte di Teoria): §1.3 query MongoDB, §1.6 didascalia,
> §2.1 aggregation pipeline, §2.2 ulteriori trasformazioni di equivalenza, §2.3 esempi
> con ∀ e ¬∃, §2.4 attributi multivalore e composti, §2.5 testo delle regole di traduzione.
>
> **Applicato in `sorgente-latex/tecnologie/BasiDati.tex`**: §1.1 CSR/VSR (Esempi 4.7 e
> 4.8 riscritti, più un riquadro sul metodo per l'esercizio d'esame), §1.2 descrizione
> dei moduli e didascalia della Figura 7, §1.4 sintassi SQL, §1.5 notazione dei costi.
>
> Integrazioni inserite nelle sezioni pertinenti, non in appendice:
>
> | Argomento | Collocazione |
> |---|---|
> | Confronto hash vs B+-tree | fine del capitolo sulle strutture ad accesso calcolato |
> | `ON DELETE` / `ON UPDATE` | dentro «Vincoli interrelazionali» |
> | steal/no-steal e force/no-force | dopo le primitive del gestore del buffer |
> | TOAST | dentro «Organizzazione di una pagina» |
> | Teorema 2PL ⊂ CSR con controesempio | fine di «Locking a due fasi» |
> | Indici, `CREATE INDEX`, `EXPLAIN` (lab 05) | fine del capitolo SQL |
> | `SET TRANSACTION ISOLATION LEVEL`, lock espliciti, tabella delle anomalie (lab 06) | dentro «Gestione della concorrenza in SQL» |
>
> I PDF originali **non sono stati sovrascritti**: restano come
> `AppuntiBasiDati-1-Teoria.pdf` e `AppuntiBasiDati-2-Tecnologie.pdf`.
>
> Resta valida la **sezione 3**: gli argomenti che la GUIDA elenca ma che il corso non chiede.

Controllo di `AppuntiBasiDati-1-Teoria` (sorgente `sorgente-latex/BasiDati.tex`) e
`AppuntiBasiDati-2-Tecnologie` confrontati con **le slide del corso** in `01-Teoria/`,
`02-Tecnologie/`, `03-Laboratorio/` e con la struttura d'esame descritta in `GUIDA-ESAME.md`.

> **Nota sul libro di testo.** `Basi di Dati - 4° Edizione.pdf` è una scansione senza livello
> testuale (0 byte estratti da `pdftotext`), quindi non è stato possibile leggerlo.
> Il confronto è stato fatto contro le slide del corso, che sono comunque la fonte
> autoritativa per quello che viene chiesto all'esame.

**Giudizio generale: gli appunti sono buoni e seguono le slide da vicino.** La parte di
Tecnologie è particolarmente completa (log, ripresa a caldo, B+-tree, hash, VSR/CSR,
costi dei join con esercizi svolti). I problemi si dividono in tre categorie: **errori da
correggere**, **contenuti mancanti** e **cose che la GUIDA elenca ma che il corso non chiede**.

---

## 1. Errori da correggere (priorità massima)

### 1.1 ⚠️ Errore logico su CSR/VSR — Tecnologie §4.3.2, Esempi 4.7 e 4.8

Gli appunti scrivono:

> «Il grafo è ciclico, quindi S2 non è conflict-serializzabile **e di conseguenza** S2 non è
> view-serializzabile.»

Questo **contraddice il teorema enunciato due pagine prima** negli appunti stessi:

> «S è CSR ⟹ S è VSR. (Se S **non** è CSR, allora **non si può dire nulla** sulla VSR)»

Poiché CSR ⊂ VSR in senso stretto, un grafo ciclico dice solo che lo schedule **non è CSR**;
la VSR va verificata a parte con LEGGE-DA e SCRITTURE-FINALI. Nei due esempi la conclusione
è *per caso* corretta (verificata separatamente negli Esercizi 4.4 e 4.5), ma il
ragionamento scritto è sbagliato.

**Perché conta:** l'esercizio (e) della prova di Tecnologie chiede sempre «è VSR? è CSR?
rispetta 2PL?». Interiorizzare questo passaggio porta a sbagliare la domanda.

**Metodo corretto:**
1. Grafo dei conflitti aciclico → CSR → **quindi anche VSR**. Finito, due risposte su tre.
2. Grafo ciclico → **non** CSR. Sulla VSR non si conclude niente: bisogna verificarla
   con LEGGE-DA + SCRITTURE-FINALI (o scartando le permutazioni per contraddizione,
   come negli Esercizi 4.4 e 4.5).

---

### 1.2 Moduli del DBMS scambiati — Tecnologie §1.3.2

Nell'elenco dei moduli:

> «**Gestore dell'affidabilità**: Carica in memoria principale le pagine della memoria
> secondaria di cui si ha bisogno, e le mantiene in memoria finché non sono più necessarie.»
> *(seguita da Figura 7, didascalia: «Gestore del buffer»)*
> «**Gestore del buffer**» ← voce vuota

La descrizione è quella del **gestore del buffer**, non dell'affidabilità. Da correggere in:

- **Gestore del buffer**: carica in memoria centrale le pagine della memoria secondaria e
  le mantiene finché servono (primitive `fix`/`unfix`/`setDirty`/`flush`/`force`).
- **Gestore dell'affidabilità**: gestisce il file di LOG e i guasti, garantendo atomicità
  e persistenza (WAL, Commit-Precedenza, ripresa a caldo/freddo).

### 1.2-bis ✅ La tabella ACID → moduli negli appunti è CORRETTA (è la GUIDA a essere sbagliata)

Gli appunti riportano:

| Modulo | Proprietà garantita |
|---|---|
| Gestore dei metodi d'accesso | Consistenza |
| Gestore dell'esecuzione concorrente | Atomicità e Isolamento |
| Gestore dell'affidabilità | Atomicità e Persistenza |

Questo **coincide esattamente** con l'ultima slide di
`02-Tecnologie/01-Transazioni-e-Affidabilita/lesson_01_transazioni.pdf`
(«Moduli e proprietà delle transazioni»).

`GUIDA-ESAME.md` riporta invece una tabella diversa (Consistency → «Gestore dell'integrità»,
Isolation → solo «Gestore della concorrenza»), che è la versione del libro di Atzeni ma
**non** quella della prof.ssa Migliorini. All'esame — che è la domanda (a) praticamente
garantita — **rispondere secondo la slide**, cioè secondo gli appunti.

---

### 1.3 Errori nel codice MongoDB — Teoria §«Interrogazioni nei sistemi document based»

| Riga negli appunti | Problema | Corretto |
|---|---|---|
| `db.studenti.find({ Esami.voto: 30 })` | chiave con punto non quotata → errore di sintassi | `db.studenti.find({ "esami.voto": 30 })` |
| `db.studenti.find({ Esami.voto: { $gt: 22 } })` | idem | `{ "esami.voto": { $gt: 22 } }` |
| `{ $and: [ { Cognome: "Rossi" }, { Nome "Verdi" } ] }` | manca i due punti dopo `Nome` | `{ Nome: "Verdi" }` |
| `{ Esami.voto: { $gte: 21 } }` | idem, va quotata | `{ "esami.voto": { $gte: 21 } }` |

**Incoerenza di maiuscole:** l'`insertMany` di esempio usa campi minuscoli
(`nome`, `cognome`, `esami`), mentre tutte le query successive usano `Nome`, `Cognome`,
`Esami`. MongoDB è case-sensitive: così come sono scritte, **quelle query non
restituirebbero nulla**. Le slide usano coerentemente il minuscolo — uniformare a minuscolo.

---

### 1.4 Errori SQL — Tecnologie §2.2.4 e §2.3

- `cognome VARCHAR(20) NOT NULL DEFAULT "VUOTO"` → in PostgreSQL i doppi apici delimitano
  **identificatori**, non stringhe. Corretto: `DEFAULT 'VUOTO'`.
  *(Rilevante: la domanda (a) del compito di laboratorio è una `CREATE TABLE`.)*
- `CHARCTER (6)` / `CHARCTER VARYING (20)` nell'Esempio 2.2 → `CHARACTER` (4 occorrenze).

---

### 1.5 Notazione sbagliata nel calcolo dei costi — Tecnologie Esercizio 5.2

> «Bisogna leggere tutta la tabella Composizione, quindi il costo è
> `NP(R) + NR(R) = 780 + 180 = 960`»

Il secondo addendo (180) è il **numero di pagine scritte** del risultato della selezione,
non `NR(R)` (che vale 19800). Stessa svista nel punto (b): `150 + 0`. Il risultato numerico
è giusto, la formula scritta no. Scrivere: `NP(lettura) + NP(scrittura)`.

---

### 1.6 Didascalia sbagliata — Teoria, ristrutturazione dello schema

La figura `esempio_accorpamento_entità_2` ha didascalia **«Eliminazione di attributi
multivalore»** ma illustra il *partizionamento/accorpamento di entità*. Vedi anche §2.4.

---

## 2. Contenuti mancanti richiesti dall'esame

### 2.1 🔴 MongoDB: aggregation pipeline — assente da entrambi i file

Questo è **il buco più grosso**.

- Gli appunti di **Teoria** si fermano a `find`, operatori di confronto/logici, dot notation,
  proiezione, `$lookup` ed `$elemMatch`. ✅ **Questo copre correttamente e per intero** le
  slide di teoria (`DocumentDBLinguaggioInterrogazione.pdf`), che non vanno oltre.
- Gli appunti di **Tecnologie** trattano MongoDB solo come **architettura** (replica set,
  sharding, ACID). Zero query.
- Ma `03-Laboratorio/Lezione-08-MongoDB/lesson_08.pdf` usa:
  **`$match`, `$group`, `$sum`, `$avg`, `$sort`, `$project`, `$limit`, `$lookup`, `$regex`** —
  e `GUIDA-ESAME.md` indica «c) Query MongoDB» come punto fisso del compito di laboratorio.

**Da aggiungere** (fonte: `lesson_08.pdf` + `03-Laboratorio/Lezione-08-MongoDB/03_query.txt`):
struttura di `db.coll.aggregate([...])`, gli stage sopra, `$unwind`, e gli accumulatori
in `$group` (`$sum`, `$avg`, `$max`, `$min`, `$push`).

### 2.2 🔴 Algebra relazionale: «Ulteriori trasformazioni di equivalenza» — assenti

Gli appunti coprono solo: atomizzazione delle selezioni, idempotenza delle proiezioni,
anticipazione di selezione e proiezione rispetto al join. Mancano **tre lucidi interi**
di `01-Teoria/05-Algebra-Relazionale/AR4.pdf`:

1. **Inglobamento della selezione nel prodotto cartesiano**
   `σ_F(E₁ × E₂) ≡ E₁ ⋈_F E₂` con `X₁ ∩ X₂ = ∅`
   ⚠️ applicabile *solo dopo* aver verificato che non si possa anticipare la selezione
   rispetto al join.
2. **Commutativa e associativa** di unione, prodotto cartesiano, intersezione.
3. **Distributiva:**
   - `σ_F(E₁ ∪ E₂) ≡ σ_F(E₁) ∪ σ_F(E₂)`
   - `σ_F(E₁ − E₂) ≡ σ_F(E₁) − σ_F(E₂)`
   - `π_Y(E₁ ∪ E₂) ≡ π_Y(E₁) ∪ π_Y(E₂)`
   - `E₁ ⋈ (E₂ ∪ E₃) ≡ (E₁ ⋈ E₂) ∪ (E₁ ⋈ E₃)`
4. **Selezioni composte in operatori insiemistici:**
   - `σ_{F₁ ∧ F₂}(E) ≡ σ_{F₁}(E) ∩ σ_{F₂}(E)`
   - `σ_{F₁ ∨ F₂}(E) ≡ σ_{F₁}(E) ∪ σ_{F₂}(E)`
   - `σ_{F₁ ∧ ¬F₂}(E) ≡ σ_{F₁}(E) − σ_{F₂}(E)`
5. L'**esempio di ottimizzazione svolto** con le cardinalità (treni non regionali che
   fermano a «Peschiera»), che mostra *come si sceglie* fra due espressioni equivalenti.

**Perché conta:** le tracce chiedono esplicitamente «un'espressione **ottimizzata**»,
spesso con un tetto al numero di operatori. Il punto 4 in particolare è la chiave dei
pattern «non… né… né…» e «almeno due…».

### 2.3 🟠 Calcolo relazionale: manca ogni esempio con il quantificatore universale

Gli appunti definiscono `∀` nella sintassi e nella semantica, ma **non c'è un solo esempio
svolto che lo usi**. C'è solo la frase «Il quantificatore esistenziale si può eliminare solo
quando non è negato» e l'esempio Q5 (∃ eliminabile).

Da `01-Teoria/06-Calcolo-Relazionale/Calcolo2.pdf` mancano tre pattern d'esame classici:

- **Q6 — «per ogni X l'ultimo/il massimo»**, con `¬∃`:
  `{Stazione,Numero: x.(Staz,Treno) | x(FERMATA) | ¬∃y(FERMATA)(x.Staz=y.Staz ∧ y.Orario > x.Orario)}`
  e soprattutto **perché il quantificatore NON si può eliminare** (il tentativo con
  `y.Orario < x.Orario` nella range list dà le fermate che ne hanno una precedente, non l'ultima).
- **Q7 — quantificatore universale con implicazione** (`A ⟹ B ≡ ¬A ∨ B`):
  «tutte le stazioni dove fermano *tutti* i treni per Venezia SL»
  `{Stazione: x.(Staz) | x(FERMATA) | ∀y(TRENO)(y.Dest='Venezia SL' ⟹ ∃z(FERMATA)(z.Treno=y.Num ∧ x.Staz=z.Staz))}`
  — **non eliminabile in nessun modo**.
- **Q8 — «l'immediatamente successivo»**: doppia quantificazione con `¬∃` intermedio.

### 2.4 🟠 Ristrutturazione dello schema ER: manca un passo

I passi elencati sono: analisi delle ridondanze, eliminazione delle generalizzazioni,
accorpamento/partizionamento di entità e relazioni, scelta degli identificatori principali.

Manca **l'eliminazione degli attributi multivalore e composti**, che
`GUIDA-ESAME.md` elenca e che è un passo standard della fase 1. (Vedi anche §1.6: la
didascalia sbagliata suggerisce che la figura ci fosse ma il testo sia andato perso.)

### 2.5 🟠 Regole di traduzione ER → relazionale: solo figure, nessun testo

Le 12 regole (`regola_traduzione_*.png`) sono riportate **esclusivamente come immagini**,
senza una riga di testo che le enunci. La domanda (b) è di **sbarramento** e garantita.
Conviene affiancare a ogni figura una riga, tipo:

- Entità → tabella, identificatore → chiave primaria
- Relazione 1:N → chiave esterna nell'entità con MAX = N (quella lato «molti»)
- Relazione N:N → tabella a sé, chiave = unione delle chiavi delle entità
- Relazione 1:1 → chiave esterna in una delle due, scelta in base alle **cardinalità minime**
  (se una sola ha MIN = 1, la FK va lì per evitare NULL)
- Identificatore esterno → la chiave dell'identificante entra nella chiave primaria dell'identificata
- Ternaria → tabella a sé con le tre chiavi; se una cardinalità è (1,1) la chiave si riduce

### 2.6 🟠 Laboratorio: due lezioni non coperte

Nessuno dei due file di appunti tratta:

- **Lezione 05 — Indici e prestazioni**: `CREATE INDEX`, `EXPLAIN` / `EXPLAIN ANALYZE`,
  lettura del piano (`Seq Scan` vs `Index Scan` vs `Bitmap Heap/Index Scan`), tipi di
  indice PostgreSQL (btree, hash, GiST, GIN), `ANALYZE`.
- **Lezione 06 — sintassi SQL della concorrenza**: `SET TRANSACTION ISOLATION LEVEL …`,
  `SELECT … FOR UPDATE`. (I *livelli* di isolamento sono trattati bene in §4.3.5 degli
  appunti di Tecnologie, ma solo a livello concettuale.)

⚠️ Inoltre la **Tabella 2 «Anomalie tollerate in SQL»** negli appunti è un'immagine: assicurati
di saper riprodurre a memoria quale livello ammette quale anomalia.

### 2.7 🟡 Hash vs B+-tree: manca il confronto esplicito

Gli appunti descrivono bene le due strutture **separatamente**. Ma la domanda (b) del tema
`2024_06_23_III_prova_intermedia.pdf` è letteralmente: *«…evidenziare i casi in cui [l'hash]
è più vantaggiosa di un B+-tree»*. Vale la pena aggiungere 5 righe:

| | Hash | B+-tree |
|---|---|---|
| Ricerca puntuale `A = v` | ~1 accesso (ottimo) | profondità dell'albero |
| Range query `v₁ ≤ A ≤ v₂` | **non supportata** (chiavi vicine → bucket diversi) | ottima (foglie concatenate) |
| Scansione ordinata / `ORDER BY` / `GROUP BY` | non supportata | supportata |
| Degrado | catene di overflow al crescere del fattore di riempimento | nessuno: resta bilanciato |

### 2.8 🟡 Dettagli minori mancanti

- **`ON DELETE` / `ON UPDATE`** (`CASCADE`, `SET NULL`, `RESTRICT`, `NO ACTION`): zero
  occorrenze negli appunti; la GUIDA li elenca per la `CREATE TABLE` di laboratorio.
- **TOAST** (*The Oversized-Attribute Storage Technique*): gli appunti riportano «molti
  gestori non consentono la separazione di una tupla su più pagine» ma tagliano la frase
  successiva della slide, che cita TOAST come soluzione PostgreSQL. Una riga.
- **Politica force / no-force** del buffer: gli appunti coprono `steal`/`no-steal` ma non
  la coppia `force`/`no-force`.
- **Teorema 2PL ⊂ CSR**: gli appunti affermano l'inclusione senza dimostrazione né
  controesempio. In `lesson_07_concorrenza_03.pptx` c'è il controesempio utile
  `s: r₁(x) w₁(x) r₂(x) w₂(x) r₃(y) w₁(y)` — **CSR ma non 2PL** (t₁ rilascia il lock su x
  e poi ne acquisisce uno su y). Serve per giustificare la risposta su 2PL nell'esercizio (e).
- **Esempio 4.9** (perdita di aggiornamento con 2PL): la slide conclude con **BLOCCO CRITICO**
  (entrambe le transazioni in attesa), gli appunti argomentano invece sulla fase calante.
  Entrambe le letture sono difendibili, ma all'esame conviene citare quella della slide.
- **Anomalie del modello relazionale**: gli appunti ne elencano 3 (aggiornamento,
  inserimento, cancellazione); la ridondanza è trattata a parte come problema. Va bene,
  basta saperlo.

---

## 3. Cose che la GUIDA elenca ma che il corso NON chiede

Verificate direttamente sulle slide — **non perderci tempo**:

| Argomento nella GUIDA | Realtà |
|---|---|
| **Divisione** (algebra relazionale) | 0 occorrenze in `AR1`–`AR4`. Non fa parte del corso. |
| **Join esterni** | Gli appunti scrivono correttamente «non sono ammessi in questo corso». Confermato. |
| **Strategia «mista»** di progetto | `StrategieProgetto.pdf` ha solo top-down, bottom-up, inside-out. Gli appunti sono corretti così. |
| **Relazione ricorsiva «con ruoli»** | «ruolo» compare 0 volte in `ER1`–`ER4`. |
| **Timestamp come tecnica di concorrenza ottimistica** | Nelle slide i timestamp compaiono **solo** come tecnica di *prevenzione del deadlock*, esattamente come negli appunti. |
| **Tabella ACID → moduli** | La versione della GUIDA contraddice la slide. Vedi §1.2-bis: seguire gli appunti. |

---

## 4. Ordine di lavoro suggerito

1. **Correggere §1.1** (CSR/VSR) — è l'unico errore che può costare direttamente punti in
   un esercizio garantito.
2. **Aggiungere §2.1** (aggregation pipeline MongoDB) — l'unico argomento d'esame
   completamente assente.
3. **Aggiungere §2.2** (ulteriori trasformazioni di equivalenza) — serve a ogni query
   «ottimizzata» della prova di Teoria.
4. **Aggiungere §2.3** (esempi con ∀ e con ¬∃ nel calcolo).
5. Correggere §1.2, §1.3, §1.4 (errori di trascrizione, veloci).
6. Coprire §2.5, §2.6, §2.7 (testo delle regole di traduzione, laboratorio 05/06,
   tabella hash vs B+-tree).
7. Il resto di §2.8 come rifinitura.
