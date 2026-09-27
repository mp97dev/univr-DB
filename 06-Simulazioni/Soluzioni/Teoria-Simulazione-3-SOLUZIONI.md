# Soluzioni — Prova di Teoria, Simulazione 3

> Traccia: [`Teoria-Simulazione-3.md`](../Teoria-Simulazione-3.md)

---

## a) Il costrutto di cardinalità **(3)**

**Definizione.** La *cardinalità* è un vincolo che limita il numero di volte in cui un'istanza può partecipare a un costrutto. Si esprime sempre come una coppia `(MIN, MAX)`.

### Cardinalità di relazione

Si specifica **per ogni entità che partecipa a una relazione** e indica il numero minimo e massimo di istanze della relazione a cui una singola istanza di quell'entità può partecipare. Va indicata su **ogni ramo** della relazione.

```
                (MIN₁, MAX₁)          (MIN₂, MAX₂)
       ┌───┐                ╱────╲                ┌───┐
       │ A │────────────────│  R  │───────────────│ B │
       └───┘                ╲────╱                └───┘
```

**Valori ammessi per MIN** (*cardinalità minima*):

| Valore | Significato |
|---|---|
| `0` | partecipazione **opzionale**: un'istanza dell'entità può non partecipare ad alcuna istanza della relazione |
| `1` | partecipazione **obbligatoria**: ogni istanza deve partecipare ad almeno un'istanza della relazione |
| `n > 1` | ogni istanza deve partecipare ad almeno `n` istanze (raro, ma ammesso) |

**Valori ammessi per MAX** (*cardinalità massima*):

| Valore | Significato |
|---|---|
| `1` | ogni istanza partecipa **al più una volta** |
| `N` | ogni istanza può partecipare a un numero qualsiasi (illimitato) di istanze |
| `n > 1` | ogni istanza partecipa al più `n` volte |

Combinando le cardinalità massime dei due rami si classificano le relazioni binarie in **uno a uno** (1:1), **uno a molti** (1:N) e **molti a molti** (N:N).

### Cardinalità di attributo

Si specifica **per ogni attributo** di un'entità o di una relazione e indica quanti valori l'attributo può assumere per una singola istanza. Se omessa si sottintende `(1,1)`.

| Cardinalità | Nome | Traduzione |
|---|---|---|
| `(1,1)` | attributo obbligatorio e monovalore (caso di default) | colonna `NOT NULL` |
| `(0,1)` | attributo **opzionale** | colonna che ammette `NULL` |
| `(1,N)` o `(0,N)` | attributo **multivalore** | **tabella a sé**, perché il modello relazionale ammette solo domini atomici |

### Effetto della cardinalità massima sulla traduzione nel modello relazionale

```
(1)  A (0,N) ──── R ──── (0,N) B          molti a molti
     ⇒  A(a1, …)   B(b1, …)   R(a1, b1, …attributi di R…)   PK(R) = (a1, b1)
        La relazione genera una TABELLA A SÉ.

(2)  A (0,N) ──── R ──── (1,1) B          uno a molti
     ⇒  A(a1, …)   B(b1, …, a1)   con B.a1 → A(a1), NOT NULL
        La relazione si traduce con una CHIAVE ESTERNA nell'entità sul lato "molti".
        Gli eventuali attributi di R migrano insieme alla chiave esterna dentro B.

(3)  A (1,1) ──── R ──── (1,1) B          uno a uno, entrambe obbligatorie
     ⇒  chiave esterna in una delle due, a scelta, con vincolo UNIQUE e NOT NULL
        (oppure fusione delle due entità in un'unica tabella)

(4)  A (0,1) ──── R ──── (1,1) B          uno a uno, una sola obbligatoria
     ⇒  B(b1, …, a1)   con B.a1 → A(a1), NOT NULL, UNIQUE
        La chiave esterna va nell'entità con partecipazione OBBLIGATORIA,
        per evitare valori nulli.
```

Il passaggio dal caso (1) al caso (2) — cioè da `N` a `1` come cardinalità massima di un ramo — è ciò che elimina la tabella intermedia; il passaggio dal caso (3) al caso (4) — cioè il cambiamento della cardinalità *minima* — determina invece **da quale parte** collocare la chiave esterna.

---

## b) Traduzione dello schema ER nel modello relazionale **(3)**

**Strategia scelta: accorpamento nelle entità figlie.**

```
P1( p1, p2, pa )
   PK: p1

P2( p1, p2, pb, pc, Q )
   PK: p1
   P2.Q → Q(q1)      NOT NULL

M( m1, m2 )
   PK: m1

Q( q1 )
   PK: q1

N( p1, m1, n1 )
   PK: (p1, m1)
   N.p1 → P1(p1)      N.m1 → M(m1)
```

**Vincolo aggiuntivo:** `P1.p1` e `P2.p1` devono essere **globalmente disgiunti** — nessun valore di `p1` può comparire in entrambe le tabelle. Il vincolo non è esprimibile con una chiave primaria e va imposto con un `CHECK` fra tabelle o con un trigger.

**Motivazione della strategia.** L'accorpamento nelle figlie è applicabile perché:
- la generalizzazione è **totale**: ogni istanza di `P` appartiene a `P1` o a `P2`, quindi nessuna istanza resterebbe priva di una tabella in cui essere memorizzata;
- la generalizzazione è **esclusiva**: nessuna istanza apparterrebbe a entrambe le tabelle, quindi non si crea duplicazione;
- **nessuna relazione insiste sull'entità padre** `P`: tutte le relazioni (`N` e `O`) partono dalle figlie. Se esistesse una relazione su `P`, la sua chiave esterna non saprebbe quale delle due tabelle riferire, e l'accorpamento nelle figlie diventerebbe scomodo.

È inoltre la scelta **efficiente** in questo caso, perché le due figlie hanno attributi specifici diversi e partecipano a relazioni diverse: tenerle separate evita del tutto i valori nulli.

**Regole applicate alle relazioni:**

| Costrutto | Regola |
|---|---|
| `N` fra `P1` (0,N) e `M` (1,N) con attributo `n1` | relazione **molti a molti**: tabella a sé, chiave = unione delle chiavi di `P1` e `M`; l'attributo `n1` diventa attributo della tabella |
| `O` fra `P2` (1,1) e `Q` (0,N) | relazione **uno a molti** con `P2` sul lato (1,1): la chiave di `Q` migra in `P2` come chiave esterna `NOT NULL` (partecipazione obbligatoria di `P2`). La relazione non genera una tabella propria |

> *Alternativa: accorpamento nell'entità padre.*
> `P(p1, p2, Tipo, pa*, pb*, pc*, Q*)` con `Tipo ∈ {'P1','P2'}`, `N(p1, m1, n1)` e un `CHECK` che imponga che i `p1` presenti in `N` abbiano `Tipo = 'P1'` e che `Q` sia non nullo se e solo se `Tipo = 'P2'`. Vantaggio: unicità di `p1` garantita dalla chiave primaria e nessun join per l'accesso ai dati comuni. Svantaggio: molti valori nulli e vincoli di tupla complessi.

---

## c) Superchiave, chiave, integrità referenziale, attributi multivalore **(3)**

### Definizione formale

Sia `r` una relazione (istanza) su uno schema `R(X)`, e sia `K ⊆ X` un insieme di attributi.

- **`K` è superchiave di `r`** se `r` non contiene due ennuple distinte `t₁` e `t₂` tali che `t₁[K] = t₂[K]`.
  Cioè: i valori assunti su `K` individuano univocamente ogni ennupla della relazione.
- **`K` è chiave di `r`** se `K` è superchiave di `r` ed è **minimale**, ossia non esiste alcun sottoinsieme proprio `K′ ⊂ K` che sia a sua volta superchiave di `r`.

**Differenza.** Ogni chiave è una superchiave, ma non viceversa: una superchiave può contenere attributi "inutili" ai fini dell'identificazione. Aggiungendo un qualunque attributo a una chiave si ottiene ancora una superchiave, ma non più minimale. L'insieme `X` di tutti gli attributi è sempre una superchiave (in una relazione non esistono ennuple duplicate). Fra le chiavi di una relazione se ne elegge una a **chiave primaria**, sulla quale si impone il vincolo di non-nullità.

### c.1 Due superchiavi non minimali

Assumendo che `A` sia chiave di `R1(A, B, C*, D)` e che `D` sia chiave di `R2(D, E, F*, G)`:

- per `R1`: **`{A, B}`** — è superchiave perché contiene la chiave `A`, ma non è minimale perché `{A}` è già superchiave. (Vanno bene anche `{A, D}`, `{A, B, D}`, `{A, B, C, D}`.)
- per `R2`: **`{D, E}`** — stesso ragionamento rispetto alla chiave `D`. (Vanno bene anche `{D, G}`, `{D, E, F, G}`.)

> ⚠️ Non si possono indicare superchiavi che contengano attributi **opzionali** come unici componenti: `{C}` non può essere superchiave di `R1`, perché due ennuple con `C` nullo non sarebbero distinguibili.

### c.2 Vincolo di integrità referenziale da `R1.D` verso `R2`

```
Vincolo:  R1.D → R2(D)
```

Il vincolo impone che, per ogni ennupla `t` di `R1`, il valore `t[D]` compaia fra i valori dell'attributo `D` di `R2`. Perché il vincolo sia ben posto, `D` deve essere **chiave (o comunque superchiave) di `R2`** — condizione qui soddisfatta, essendo `D` chiave primaria di `R2`.

**Effetto dei valori nulli.** Gli attributi `C` di `R1` e `F` di `R2` sono opzionali, ma **non fanno parte del vincolo** e quindi non lo influenzano in alcun modo. Ciò che conta è:
- se `R1.D` potesse assumere valore nullo, per convenzione il vincolo di integrità referenziale **è considerato soddisfatto** (in SQL: `MATCH SIMPLE`, il comportamento di default): un riferimento nullo significa "nessun riferimento" e non viene verificato;
- `R2.D`, essendo chiave primaria, **non può** essere nullo, quindi il lato riferito è sempre ben definito.

### c.3 Traduzione di un attributo multivalore

Si consideri l'entità `ARTISTA(●CodArtista, NomeArte, Paese, Genere[1,N])`.

**(i) Nel modello relazionale.** Il modello relazionale richiede che tutti i domini siano **atomici** (prima forma normale): un attributo non può contenere un insieme di valori. L'attributo multivalore va quindi estratto in una **tabella a sé**, la cui chiave primaria è l'unione della chiave dell'entità e dell'attributo stesso:

```
ARTISTA( CodArtista, NomeArte, Paese )
GENERE_ARTISTA( Artista, Genere )
   PK: (Artista, Genere)
   GENERE_ARTISTA.Artista → ARTISTA(CodArtista)
```

Recuperare un artista con i suoi generi richiede quindi un **join**.

**(ii) In una collezione di documenti JSON.** Il modello a documenti ammette valori **non atomici**: l'attributo multivalore diventa semplicemente un **array** dentro il documento, senza alcuna collezione aggiuntiva.

```json
{
  "_id": "A-317",
  "nomeArte": "Northern Lights",
  "paese": "Regno Unito",
  "generi": ["rock", "post-punk", "shoegaze"]
}
```

**Differenza fra le due soluzioni:**

| | Modello relazionale | Documento JSON |
|---|---|---|
| Struttura | tabella aggiuntiva | array dentro il documento |
| Lettura di artista + generi | richiede un **join** | **una sola lettura**, nessun join |
| Aggiunta di un genere | `INSERT` in `GENERE_ARTISTA` | `$push` sull'array, operazione **atomica** sul documento |
| Interrogazione "artisti di genere rock" | `JOIN` + `WHERE Genere='rock'` | `db.artisti.find({ generi: "rock" })` — la corrispondenza su un array verifica automaticamente se **almeno un elemento** soddisfa la condizione, e l'array può essere indicizzato (*multikey index*) |
| Elenco di tutti i generi esistenti | `SELECT DISTINCT Genere FROM GENERE_ARTISTA` — immediato | richiede `$unwind` + `$group`: l'informazione non è disponibile in forma tabellare |
| Integrità | il dominio dei generi si può vincolare con una tabella di riferimento e una FK | nessun vincolo automatico: la coerenza dei valori è a carico dell'applicazione |

---

## Esercizio 1 — Progettazione **(12)**

### 1.1 Schema concettuale ER

```
EDIZIONE( ●Anno, Tema, DataInizio, DataFine, NumBigliettiInVendita )

PALCO( ●NomePalco, Capienza, Luogo, AlChiuso )
      identificatore ESTERNO: EDIZIONE + NomePalco

ARTISTA( ●CodArtista, NomeArte, Paese, Genere[1,N] )
      Genere è un attributo MULTIVALORE
      generalizzazione TOTALE ed ESCLUSIVA (t,e) in:
        SOLISTA( Nome, Cognome, DataNascita )
        GRUPPO( AnnoFormazione, NumComponenti )

CONCERTO( Data, OraInizio, DurataPrevista, Cachet )
      identificatore ESTERNO: PALCO + Data + OraInizio

BIGLIETTO( ●CodBiglietto, TipoBig, DataAcquisto, Prezzo, Canale,
           Acquirente{ Nome, Cognome, Email, ○Documento, ○Telefono } )
      Acquirente è un attributo COMPOSTO;
      Documento e Telefono sono opzionali (presenti solo per i biglietti VIP)

PERSONALE( ●Matricola, Nome, Cognome, Mansione )

ASSEGNAZIONE( Data, OraInizio, OraFine )
      identificatore ESTERNO: PALCO + PERSONALE + Data + OraInizio

RIEPILOGO_GIORNALIERO( Data, NumValidazioni, Incasso )
      identificatore ESTERNO: PALCO + Data
```

**Relazioni:**

| Relazione | Entità e cardinalità | Attributi |
|---|---|---|
| `SI_SVOLGE` | `EDIZIONE` (1,N) — `PALCO` (1,1) | — |
| `SU_PALCO` | `PALCO` (0,N) — `CONCERTO` (1,1) | — |
| `SI_ESIBISCE` | `ARTISTA` (0,N) — `CONCERTO` (1,1) | — |
| `VALIDAZIONE` | `BIGLIETTO` (0,N) — `CONCERTO` (0,N) | `DataOraValidazione` |
| `ASSEGN_PALCO` | `PALCO` (0,N) — `ASSEGNAZIONE` (1,1) | — |
| `ASSEGN_PERSONALE` | `PERSONALE` (0,N) — `ASSEGNAZIONE` (1,1) | — |
| `RIEPILOGA` | `PALCO` (0,N) — `RIEPILOGO_GIORNALIERO` (1,1) | — |

**Scelte di progetto da motivare:**

1. **`VALIDAZIONE` resta una relazione** e non diventa un'entità. È il punto in cui questo tema differisce dagli altri: il testo dice esplicitamente che *"lo stesso biglietto non può essere validato due volte per lo stesso concerto"*, quindi la coppia (biglietto, concerto) identifica univocamente la validazione e il costrutto di relazione ER è adeguato. `DataOraValidazione` è un semplice attributo della relazione.
2. **`CONCERTO` è invece un'entità con identificatore esterno**, perché *"lo stesso artista può tenere più concerti sullo stesso palco […] anche nello stesso giorno, purché con ora di inizio diversa"*: una relazione ER fra `ARTISTA` e `PALCO` non potrebbe contenere due istanze con la stessa coppia. L'identificatore è `PALCO + Data + OraInizio` (un palco può ospitare un solo concerto in un dato istante), e non include l'artista perché è determinato dagli altri tre. Analogo ragionamento per `ASSEGNAZIONE`.
3. **`PALCO` ha identificatore esterno**: *"il nome è univoco solo all'interno di una edizione"*.
4. **La generalizzazione degli artisti è totale ed esclusiva**: *"ogni artista è o un solista o un gruppo, e non può essere entrambi"*.
5. **`Acquirente` è un attributo composto, non un'entità**: il testo non fornisce un identificatore per l'acquirente né lo associa ad altro se non al biglietto.
6. **`RIEPILOGO_GIORNALIERO` contiene ridondanze** (`NumValidazioni` è derivabile contando le validazioni; `Incasso` è derivabile dai prezzi dei biglietti validati). Si mantengono per gli stessi motivi di prestazione visti in fase di analisi delle ridondanze: sono calcolate una sola volta a fine giornata e lette molte volte.

> **Osservazione da segnalare al docente.** Il testo non collega esplicitamente `BIGLIETTO` a `EDIZIONE`. L'edizione di appartenenza di un biglietto è **derivabile** attraverso `VALIDAZIONE → CONCERTO → PALCO → EDIZIONE`, ma solo per i biglietti effettivamente validati: un biglietto acquistato e mai utilizzato non sarebbe attribuibile ad alcuna edizione. Poiché la consegna vieta di aggiungere attributi non indicati nel testo, si è scelto di **non** aggiungere una relazione `BIGLIETTO — EDIZIONE`, segnalando però la lacuna come ambiguità dei requisiti.

### 1.2 Schema logico relazionale

```
EDIZIONE( Anno, Tema, DataInizio, DataFine, NumBigliettiInVendita )
   PK: Anno

PALCO( Anno, NomePalco, Capienza, Luogo, AlChiuso )
   PK: (Anno, NomePalco)
   PALCO.Anno → EDIZIONE(Anno)

ARTISTA( CodArtista, NomeArte, Paese, TipoArt,
         Nome*, Cognome*, DataNascita*, AnnoFormazione*, NumComponenti* )
   PK: CodArtista
   CHECK: TipoArt ∈ {'solista','gruppo'}
   CHECK: (TipoArt='solista' AND Nome IS NOT NULL AND Cognome IS NOT NULL
                             AND DataNascita IS NOT NULL
                             AND AnnoFormazione IS NULL AND NumComponenti IS NULL)
       OR (TipoArt='gruppo'  AND AnnoFormazione IS NOT NULL AND NumComponenti IS NOT NULL
                             AND Nome IS NULL AND Cognome IS NULL AND DataNascita IS NULL)

GENERE_ARTISTA( Artista, Genere )
   PK: (Artista, Genere)
   GENERE_ARTISTA.Artista → ARTISTA(CodArtista)

CONCERTO( Anno, Palco, Data, OraInizio, DurataPrevista, Cachet, Artista )
   PK: (Anno, Palco, Data, OraInizio)
   CONCERTO.(Anno, Palco) → PALCO(Anno, NomePalco)
   CONCERTO.Artista       → ARTISTA(CodArtista)     NOT NULL

BIGLIETTO( CodBiglietto, TipoBig, DataAcquisto, Prezzo, Canale,
           NomeAcq, CognomeAcq, EmailAcq, Documento*, Telefono* )
   PK: CodBiglietto
   CHECK: TipoBig ∈ {'giornaliero','abbonamento','VIP'}
   CHECK: Canale  ∈ {'online','botteghino','rivendita autorizzata'}
   CHECK: TipoBig = 'VIP' OR (Documento IS NULL AND Telefono IS NULL)

VALIDAZIONE( Biglietto, Anno, Palco, Data, OraInizio, DataOraValidazione )
   PK: (Biglietto, Anno, Palco, Data, OraInizio)
   VALIDAZIONE.Biglietto                 → BIGLIETTO(CodBiglietto)
   VALIDAZIONE.(Anno, Palco, Data, OraInizio) → CONCERTO(Anno, Palco, Data, OraInizio)

PERSONALE( Matricola, Nome, Cognome, Mansione )
   PK: Matricola

ASSEGNAZIONE( Anno, Palco, Personale, Data, OraInizio, OraFine )
   PK: (Anno, Palco, Personale, Data, OraInizio)
   ASSEGNAZIONE.(Anno, Palco) → PALCO(Anno, NomePalco)
   ASSEGNAZIONE.Personale     → PERSONALE(Matricola)

RIEPILOGO_GIORNALIERO( Anno, Palco, Data, NumValidazioni, Incasso )
   PK: (Anno, Palco, Data)
   RIEPILOGO_GIORNALIERO.(Anno, Palco) → PALCO(Anno, NomePalco)
```

**Strategia per la generalizzazione: accorpamento nell'entità padre.** A differenza dell'esercizio b), qui l'accorpamento nelle figlie sarebbe scomodo: `ARTISTA` **partecipa a una relazione** (`SI_ESIBISCE` con `CONCERTO`) in quanto entità padre, e la chiave esterna in `CONCERTO` non saprebbe quale delle due tabelle figlie riferire. Si accorpa quindi tutto in `ARTISTA`, con un discriminante `TipoArt` e gli attributi specifici opzionali.

---

## Esercizio 2 — Progettazione verso un sistema document-based **(6)**

### 2.1 Etichettatura dello schema

```
      ┌───────────────┐
      │   EDIZIONE    │ ★ principale
      └───────┬───────┘
              │ (1,N)
          ╱───┴──────╲
          │ SI_SVOLGE│  ══► incapsulamento (PALCO non ha vita propria)
          ╲───┬──────╱
              │ (1,1)
      ┌───────┴───────┐
      │     PALCO     │
      └───────┬───────┘
              │ (0,N)
              └────────► riferimento (cardinalità elevata)
                              │
      ┌───────────────┐   ┌───┴───────────┐
      │   ARTISTA     │◄──┤   CONCERTO    │ ★ principale
      │  (t,e)        │   └───────────────┘
      │ SOLISTA/GRUPPO│      riferimento + snapshot incapsulato
      └───────────────┘ ★ principale
```

**Entità principali:** `EDIZIONE`, `ARTISTA`, `CONCERTO` → tre collezioni: `edizioni`, `artisti`, `concerti`.
`PALCO` **non** è entità principale: è incapsulato dentro l'edizione.

### 2.2 Collezioni e documenti JSON

```json
// collezione: edizioni
{
  "_id": 2026,
  "tema": "Suoni del Nord",
  "dataInizio": "2026-07-14",
  "dataFine": "2026-07-21",
  "numBigliettiInVendita": 48000,
  "palchi": [
    { "nome": "Arena Grande", "capienza": 12000, "luogo": "Piazza Bra",        "alChiuso": false },
    { "nome": "Sala Verdi",   "capienza": 800,   "luogo": "Teatro Filarmonico","alChiuso": true  }
  ]
}
```

```json
// collezione: artisti  —  SOLISTA
{
  "_id": "A-092",
  "nomeArte": "Marta Cielo",
  "paese": "Italia",
  "tipo": "solista",
  "nome": "Marta",
  "cognome": "Cielo",
  "dataNascita": "1994-02-11",
  "generi": ["cantautorato", "folk"]
}

// collezione: artisti  —  GRUPPO
{
  "_id": "A-317",
  "nomeArte": "Northern Lights",
  "paese": "Regno Unito",
  "tipo": "gruppo",
  "annoFormazione": 2011,
  "numComponenti": 4,
  "generi": ["rock", "post-punk"]
}
```

```json
// collezione: concerti
{
  "_id": "CN-2026-088",
  "edizione": 2026,
  "palco": { "nome": "Arena Grande", "capienza": 12000, "alChiuso": false },
  "data": "2026-07-18",
  "oraInizio": "21:30",
  "durataPrevista": 95,
  "cachet": 75000,
  "artista": {
    "codice": "A-317",
    "nomeArte": "Northern Lights",
    "paese": "Regno Unito",
    "tipo": "gruppo",
    "generi": ["rock", "post-punk"]
  }
}
```

**Motivazione delle scelte:**

| Associazione | Scelta | Motivazione |
|---|---|---|
| `EDIZIONE` — `PALCO` | **incapsulamento** | 1:N con N piccolo (pochi palchi per edizione); il palco è identificato esternamente dall'edizione, quindi **non ha vita propria**; i due dati vengono sempre letti insieme |
| `PALCO` — `CONCERTO` | **riferimento** (con *snapshot* incapsulato) | ogni edizione ha centinaia di concerti: incapsularli dentro il documento edizione farebbe crescere il documento senza limiti. `CONCERTO` diventa collezione propria; per evitare una seconda lettura nelle interrogazioni più frequenti si incapsula una **copia dei soli campi del palco che servono** (nome, capienza, alChiuso) |
| `ARTISTA` — `CONCERTO` | **riferimento + snapshot incapsulato** | l'artista ha vita propria (esiste indipendentemente, si esibisce in più edizioni, ha una sua scheda), quindi ha collezione propria; ma i campi usati per filtrare e visualizzare i concerti vengono duplicati nel documento concerto per evitare il `$lookup` |

### 2.3 Trattamento della generalizzazione in un sistema document-based

Nel modello relazionale la generalizzazione ha richiesto una scelta fra tre strategie, tutte con un costo: accorpando nel padre si introducono **valori nulli** su tutti gli attributi specifici (un gruppo ha `Nome`, `Cognome`, `DataNascita` a `NULL`), accorpando nelle figlie si perde l'unicità globale della chiave e si complica il riferimento dai concerti.

In un sistema document-based il problema **non si pone**, perché una collezione è **schema-less**: documenti di forma diversa possono convivere nella stessa collezione. La generalizzazione si traduce quindi semplicemente in **un'unica collezione `artisti`** in cui:

- gli attributi comuni (`nomeArte`, `paese`, `generi`) sono presenti in tutti i documenti;
- gli attributi specifici sono presenti **solo nei documenti del sottotipo a cui appartengono**: in un solista compaiono `nome`, `cognome`, `dataNascita`; in un gruppo compaiono `annoFormazione`, `numComponenti`;
- si mantiene un campo **discriminante** `tipo` per poter interrogare i sottotipi (`db.artisti.find({ tipo: "gruppo" })`) e per rendere esplicita al lettore la struttura attesa.

**Differenza sostanziale rispetto al modello relazionale:**

| | Accorpamento nel padre (relazionale) | Collezione unica (document) |
|---|---|---|
| Attributi non applicabili | esistono come colonne e valgono `NULL` | sono **assenti** dal documento: non occupano spazio e non vanno interpretati |
| Distinzione "assente" / "sconosciuto" | impossibile: entrambi sono `NULL` | possibile: campo assente ≠ campo presente con valore `null` |
| Aggiunta di un nuovo sottotipo | `ALTER TABLE` su tutta la tabella | si inseriscono semplicemente documenti con i nuovi campi; i vecchi restano validi |
| Vincoli di coerenza fra discriminante e attributi specifici | espressi con `CHECK` | non automatici: vanno imposti con un *JSON Schema validator* o gestiti dall'applicazione |

Il campo discriminante `tipo` resta comunque utile: senza di esso, distinguere un gruppo da un solista richiederebbe di verificare la presenza dei campi (`{ annoFormazione: { $exists: true } }`), soluzione più fragile e meno indicizzabile.

---

## Esercizio 3 — Algebra relazionale **(9)**

> Nota: lo schema dell'esercizio 3 usa una chiave surrogata `CodConcerto`, diversa dall'identificatore esterno individuato nell'esercizio 1. Si lavora con lo schema dato dalla traccia.

### 3.a

```
PALCHI_APERTI := ρ Palco ← NomePalco (
        π Anno, NomePalco ( σ AlChiuso = FALSE ( PALCO ) )
   )

RISULTATO := π NomeArte, Palco, Data, OraInizio (

       π Anno, Palco, Artista, Data, OraInizio (
           σ Anno = 2026 ∧ Cachet > 50000 ( CONCERTO )
       )

     ⋈ PALCHI_APERTI                                    (join naturale su Anno, Palco)

     ⋈ Artista = CodArtista
       π CodArtista, NomeArte ( σ Paese = 'Regno Unito' ( ARTISTA ) )
   )
```

Entrambe le selezioni su `CONCERTO` (`Anno` e `Cachet`) e quelle su `PALCO` e `ARTISTA` sono anticipate sulle tabelle di base. La ridenominazione `ρ Palco ← NomePalco` consente di usare il **join naturale** sui due attributi `(Anno, Palco)` invece di un theta-join esplicito.

### 3.b

> Interpretazione adottata: *artisti che si sono esibiti nell'edizione 2026 ma mai su un palco al chiuso*.

```
ART_2026 := π Artista ( σ Anno = 2026 ( CONCERTO ) )

PALCHI_CHIUSI := ρ Palco ← NomePalco (
        π Anno, NomePalco ( σ AlChiuso = TRUE ( PALCO ) )
   )

ART_AL_CHIUSO := π Artista (
        π Anno, Palco, Artista ( σ Anno = 2026 ( CONCERTO ) )  ⋈  PALCHI_CHIUSI
   )

RISULTATO := π CodArtista, NomeArte (
        ρ CodArtista ← Artista ( ART_2026 − ART_AL_CHIUSO )  ⋈  ARTISTA
   )
```

Si costruisce l'insieme degli artisti presenti nell'edizione 2026 e gli si sottrae l'insieme di quelli che vi hanno tenuto **almeno un** concerto al chiuso. La ridenominazione prima del join finale allinea lo schema del risultato della differenza con la chiave di `ARTISTA`.

> *Interpretazione alternativa* — "tutti gli artisti dell'archivio che non hanno concerti al chiuso nel 2026", inclusi quelli che nel 2026 non si sono esibiti affatto: basta sostituire `ART_2026` con `π CodArtista (ARTISTA)`, ridenominato opportunamente. All'esame conviene **dichiarare esplicitamente** l'interpretazione scelta.

### 3.c

```
VC := π Biglietto, Concerto, Anno, Palco (
        π Biglietto, Concerto ( VALIDAZIONE )
      ⋈ Concerto = CodConcerto
        π CodConcerto, Anno, Palco ( CONCERTO )
   )

ALMENO_DUE := π Biglietto (
        VC
      ⋈ Biglietto = Biglietto2 ∧ Anno = Anno2 ∧ Palco = Palco2 ∧ Concerto ≠ Concerto2
        ρ Biglietto2←Biglietto, Concerto2←Concerto, Anno2←Anno, Palco2←Palco ( VC )
   )

RISULTATO := π Cognome, Email ( ALMENO_DUE ⋈ Biglietto = CodBiglietto BIGLIETTO )
```

Il theta-join accoppia due validazioni **dello stesso biglietto** su **concerti diversi** che si sono però svolti sullo **stesso palco** (stessa coppia `Anno`, `Palco`).

---

## Esercizio 4 — Document DB e calcolo relazionale **(5)**

### 4.a MongoDB

**i.** Concerti 2026 all'aperto di gruppi rock con cachet superiore a 50000:

```js
db.concerti.find(
  {
    edizione: 2026,
    "palco.alChiuso": false,
    "artista.tipo": "gruppo",
    "artista.generi": "rock",
    cachet: { $gt: 50000 }
  },
  { _id: 0, "artista.nomeArte": 1, "palco.nome": 1, data: 1 }
)
```

Due punti da notare: l'accesso ai campi dei sottodocumenti avviene con la **dot notation** (`"palco.alChiuso"`); la condizione `"artista.generi": "rock"` su un **array** è soddisfatta se **almeno un elemento** dell'array vale `"rock"` — non serve alcun operatore aggiuntivo.

**ii.** Per ogni paese, numero di concerti e cachet totale, solo paesi con almeno 5 concerti:

```js
db.concerti.aggregate([
  { $group: {
      _id:          "$artista.paese",
      numConcerti:  { $sum: 1 },
      cachetTotale: { $sum: "$cachet" }
  }},
  { $match: { numConcerti: { $gte: 5 } } },
  { $sort:  { cachetTotale: -1 } }
])
```

> **Punto chiave:** il `$match` posto **dopo** il `$group` svolge il ruolo dello `HAVING` di SQL (filtra i gruppi già aggregati). Un `$match` posto **prima** del `$group` svolgerebbe invece il ruolo del `WHERE` (filtra i documenti in ingresso). Invertire i due è l'errore più comune.

### 4.b Calcolo relazionale sulle tuple con dichiarazioni di range — interrogazione 3.a

```
{ a.NomeArte, c.Palco, c.Data, c.OraInizio  |
     c(CONCERTO), p(PALCO), a(ARTISTA)  |
     c.Anno        = 2026            ∧
     c.Cachet      > 50000           ∧
     p.Anno        = c.Anno          ∧
     p.NomePalco   = c.Palco         ∧
     p.AlChiuso    = FALSE           ∧
     a.CodArtista  = c.Artista       ∧
     a.Paese       = 'Regno Unito'
}
```

Si noti che il join fra `CONCERTO` e `PALCO` avviene su **due** attributi (`Anno` e `Palco`), perché `PALCO` ha chiave primaria composta: nel calcolo relazionale ciò si esprime semplicemente con due uguaglianze congiunte nella formula.
