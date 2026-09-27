# Soluzioni — Prova di Teoria, Simulazione 1

> Traccia: [`Teoria-Simulazione-1.md`](../Teoria-Simulazione-1.md)

---

## a) Il costrutto di identificatore **(3)**

**Definizione.** Un *identificatore* di un'entità `E` è un insieme minimale di elementi (attributi di `E` e/o entità collegate a `E` tramite relazioni) i cui valori individuano univocamente ogni istanza di `E`. È il costrutto ER che corrisponde alla nozione di chiave del modello relazionale. Ogni entità deve possedere almeno un identificatore; se ne possiede più di uno, in fase di progettazione logica se ne sceglie uno come *identificatore primario*.

**Identificatore interno.** È costituito **solo da attributi dell'entità stessa**. Può essere:
- *semplice*, se formato da un unico attributo (es. `Matricola` di `STUDENTE`);
- *composto*, se formato da due o più attributi (es. `Numero` + `Versante` di `PISTA`).

Gli attributi che compongono un identificatore interno devono essere obbligatori (cardinalità minima 1) e monovalore (cardinalità massima 1).

```
      ┌──────────────┐                       ┌──────────────┐
      │   STUDENTE   │                       │    PISTA     │
      └──────────────┘                       └──────────────┘
        ●Matricola                             ●Numero
         Nome                                  ●Versante        ← identificatore composto
         Cognome                                Nome

   (● = attributo che partecipa all'identificatore)
```

**Identificatore esterno.** Si usa quando gli attributi dell'entità **non bastano** a identificarne le istanze: l'identificazione richiede di "appoggiarsi" a un'altra entità raggiunta attraverso una relazione. È formato da zero o più attributi dell'entità più una o più entità esterne.

```
      ┌───────────┐   (1,1)    ╱────────╲   (0,N)   ┌────────────┐
      │  STUDENTE │────────────│ ISCRITTO│──────────│ UNIVERSITA │
      └───────────┘            ╲────────╱           └────────────┘
        ●Matricola                                     ●Nome
         Nome

   Matricola è univoca solo all'interno di una università:
   l'identificatore di STUDENTE è { Matricola, UNIVERSITA }.
```

**Condizioni di correttezza di un identificatore esterno:**
1. l'entità identificata deve partecipare alla relazione di identificazione con cardinalità **(1,1)**: ogni sua istanza deve essere associata a **esattamente una** istanza dell'entità identificante;
2. l'entità identificante deve essere a sua volta **identificata** (direttamente o indirettamente): non sono ammessi cicli di identificazione esterna;
3. un'entità identificata esternamente non può essere identificata attraverso una relazione a cui partecipa con cardinalità massima maggiore di 1.

**Traduzione nel modello relazionale.** L'identificatore interno diventa la chiave primaria della tabella; l'identificatore esterno produce una chiave primaria composta che include la chiave dell'entità identificante, la quale è al tempo stesso vincolo di integrità referenziale.

---

## b) Traduzione dello schema ER nel modello relazionale **(3)**

```
A( a1, a2 )
   PK: a1

B( b1, b2, b3* )
   PK: b1
   b3 può assumere valore nullo (attributo opzionale)

R( a1, b1, r1 )
   PK: (a1, b1)
   R.a1 → A(a1)      R.b1 → B(b1)

C( a1, c1, c2 )
   PK: (a1, c1)
   C.a1 → A(a1)

D( d1, d2, b1 )
   PK: d1
   D.b1 → B(b1),  b1 NOT NULL,  UNIQUE(b1)
```

**Motivazioni:**

| Costrutto | Regola applicata |
|---|---|
| `R` fra `A` (1,N) e `B` (1,N) | relazione **molti a molti**: diventa una tabella a sé; la chiave è l'unione delle chiavi delle due entità; l'attributo `r1` della relazione diventa attributo della tabella |
| `S` fra `A` (0,N) e `C` (1,1) con identificatore esterno | `C` è identificata esternamente da `c1` + `A`: la chiave di `A` **entra nella chiave primaria** di `C` ed è al tempo stesso vincolo di integrità referenziale. La relazione `S` **non genera una tabella propria** |
| `Q` fra `B` (0,1) e `D` (1,1) | relazione **uno a uno** con cardinalità minime diverse: la chiave esterna si colloca nell'entità con partecipazione **obbligatoria** (`D`), così da **evitare valori nulli**. `b1` è `NOT NULL` (partecipazione (1,1) di `D`) e `UNIQUE` (cardinalità massima 1 dal lato di `B`) |
| `b3` opzionale | attributo con cardinalità (0,1) → attributo che ammette valore nullo, contrassegnato con `*` |

> ⚠️ Errore tipico: mettere la chiave esterna di `Q` in `B` invece che in `D`. Poiché `B` partecipa con cardinalità minima 0, ne risulterebbero valori nulli su tutte le istanze di `B` non associate ad alcun `D`.

---

## c) Incapsulamento e riferimento nella progettazione document-based **(3)**

Nei sistemi document-based non esiste l'operatore di join come operazione primitiva ed efficiente: la struttura dei documenti deve essere progettata a partire dalle **interrogazioni** che si prevede di eseguire. Per ogni associazione dello schema concettuale si sceglie fra due tecniche.

### Incapsulamento (embedding)

Il documento associato viene **annidato dentro** il documento principale come sottodocumento o come elemento di un array.

```json
{
  "_id": "ORD-2026-0451",
  "data": "2026-03-14",
  "importo": 249.90,
  "cliente": {
    "codCliente": "CL-0087",
    "nome": "Marco",
    "cognome": "Bianchi",
    "email": "marco.bianchi@example.it"
  },
  "righe": [
    { "prodotto": "P0031", "quantita": 2, "prezzoUnitario": 99.95 },
    { "prodotto": "P0114", "quantita": 1, "prezzoUnitario": 50.00 }
  ]
}
```

**Vantaggi:** una sola lettura recupera tutte le informazioni necessarie (nessun join applicativo); atomicità garantita, perché in MongoDB la scrittura di un singolo documento è atomica; ottime prestazioni in lettura.

**Svantaggi:** **duplicazione** del dato incapsulato in tutti i documenti che lo contengono, con conseguente costo e rischio di incoerenza in aggiornamento; crescita illimitata del documento se l'array è di cardinalità elevata (in MongoDB il limite di un documento è 16 MB).

### Riferimento (referencing)

Il documento associato risiede in una **collezione separata** e viene richiamato tramite il suo identificatore.

```json
// collezione "ordini"
{
  "_id": "ORD-2026-0451",
  "data": "2026-03-14",
  "importo": 249.90,
  "cliente": "CL-0087"          // riferimento
}

// collezione "clienti"
{
  "_id": "CL-0087",
  "nome": "Marco",
  "cognome": "Bianchi",
  "email": "marco.bianchi@example.it"
}
```

**Vantaggi:** nessuna duplicazione, quindi aggiornamento in un solo punto; documenti di dimensione contenuta e stabile; adatto ad associazioni molti a molti e ad associazioni di cardinalità elevata.

**Svantaggi:** ricomporre l'informazione richiede una seconda interrogazione oppure una fase `$lookup` nella aggregation pipeline, con costo maggiore in lettura; non c'è garanzia di integrità referenziale, che va gestita dall'applicazione.

### Criteri di scelta

| Si preferisce **incapsulare** quando… | Si preferisce il **riferimento** quando… |
|---|---|
| l'associazione è 1:1 o 1:N con N contenuto e limitato | l'associazione è N:N, oppure 1:N con N grande o illimitato |
| i dati associati vengono quasi sempre letti insieme | i dati associati vengono letti indipendentemente |
| i dati associati cambiano raramente | i dati associati cambiano di frequente |
| l'entità associata non ha vita propria (esiste solo nel contesto del padre) | l'entità associata ha vita propria ed è referenziata da più collezioni |
| serve atomicità nell'aggiornamento congiunto | il documento rischierebbe di superare i 16 MB |

---

## Esercizio 1 — Progettazione **(12)**

### 1.1 Schema concettuale ER

**Entità e attributi** (● = attributo dell'identificatore, ○ = attributo opzionale):

```
IMPIANTO( ●Codice, Nome, Tipologia, QuotaPartenza, QuotaArrivo, PortataOraria, AnnoCostruzione )

PISTA( ●Numero, ●Versante, Nome, Lunghezza, Dislivello, Difficolta )
      identificatore interno COMPOSTO: (Numero, Versante)

PERSONALE( ●Matricola, Nome, Cognome, DataNascita, CodiceFiscale )
      generalizzazione TOTALE ed ESCLUSIVA (t,e) in:
        MAESTRO( LivelloAbilitazione, Lingua[1,N] )     ← attributo MULTIVALORE
        ADDETTO( DataAbilitazione )

SKIPASS( ●NumeroSeriale, TipoPass, DataEmissione, DataScadenza, Prezzo,
         Intestatario{ Nome, Cognome, DataNascita, ○CodiceFiscale, ○Indirizzo } )
      Intestatario è un attributo COMPOSTO;
      CodiceFiscale e Indirizzo sono opzionali (presenti solo per gli skipass stagionali)

CORSO( ●CodCorso, Livello, DataInizio, DataFine, MaxPartecipanti )

PASSAGGIO( Data, Ora )
      identificatore ESTERNO: SKIPASS + IMPIANTO + Data + Ora

TURNO( Data, OraInizio, OraFine )
      identificatore ESTERNO: IMPIANTO + ADDETTO + Data + OraInizio

RIEPILOGO_GIORNALIERO( Data, NumPassaggi, MinutiFermo )
      identificatore ESTERNO: IMPIANTO + Data
```

**Relazioni:**

| Relazione | Entità e cardinalità | Attributi |
|---|---|---|
| `PARTE_DA` | `PISTA` (1,1) — `IMPIANTO` (0,N) | — |
| `TIENE` | `CORSO` (1,1) — `MAESTRO` (0,N) | — |
| `ISCRIZIONE` | `SKIPASS` (0,N) — `CORSO` (1,N) | `DataIscrizione`, `Voto`○ |
| `PASS_SKIPASS` | `PASSAGGIO` (1,1) — `SKIPASS` (0,N) | — |
| `PASS_IMPIANTO` | `PASSAGGIO` (1,1) — `IMPIANTO` (0,N) | — |
| `TURNO_IMPIANTO` | `TURNO` (1,1) — `IMPIANTO` (0,N) | — |
| `TURNO_ADDETTO` | `TURNO` (1,1) — `ADDETTO` (0,N) | — |
| `RIEPILOGO_IMP` | `RIEPILOGO_GIORNALIERO` (1,1) — `IMPIANTO` (0,N) | — |

**Scelte di progetto da motivare all'esame:**

1. **`PASSAGGIO` è un'entità, non una relazione.** Il testo dice esplicitamente che *"uno stesso skipass può passare più volte allo stesso impianto nella stessa giornata"*. Una relazione ER è un sottoinsieme del prodotto cartesiano delle entità coinvolte, quindi **non può contenere due istanze con la stessa coppia (skipass, impianto)**: modellare `PASSAGGIO` come relazione impedirebbe di registrare i passaggi ripetuti. Si introduce quindi un'entità con **identificatore esterno** che include anche `Data` e `Ora`. Lo stesso ragionamento vale per `TURNO`.
2. **`ISCRIZIONE` resta una relazione**, perché uno skipass si iscrive a un corso al più una volta: la coppia (skipass, corso) è sufficiente a identificare l'iscrizione.
3. **L'intestatario è un attributo composto, non un'entità.** Il testo non fornisce un identificatore per la persona in generale (il codice fiscale è disponibile solo per gli stagionali) e non associa la persona ad altro se non allo skipass.
4. **La generalizzazione è totale ed esclusiva**: *"ogni membro del personale è o un maestro o un addetto, e non può essere entrambe le cose"*.
5. **`RIEPILOGO_GIORNALIERO.NumPassaggi` è una ridondanza**: è derivabile contando le istanze di `PASSAGGIO` per impianto e data. In fase di *ristrutturazione dello schema* va analizzata: si sceglie di **mantenerla** perché il dato viene consultato molto più spesso di quanto venga aggiornato (una volta al giorno) e il suo ricalcolo richiederebbe la scansione di una tabella molto grande. `MinutiFermo` non è invece derivabile e va comunque memorizzato.

### 1.2 Schema logico relazionale

```
IMPIANTO( Codice, Nome, Tipologia, QuotaPartenza, QuotaArrivo, PortataOraria, AnnoCostruzione )
   PK: Codice

PISTA( Numero, Versante, Nome, Lunghezza, Dislivello, Difficolta, Impianto )
   PK: (Numero, Versante)
   PISTA.Impianto → IMPIANTO(Codice)      NOT NULL

PERSONALE( Matricola, Nome, Cognome, DataNascita, CodiceFiscale, Ruolo,
           LivelloAbilitazione*, DataAbilitazione* )
   PK: Matricola          UNIQUE: CodiceFiscale
   CHECK: Ruolo ∈ {'maestro','addetto'}
   CHECK: (Ruolo='maestro' AND LivelloAbilitazione IS NOT NULL AND DataAbilitazione IS NULL)
       OR (Ruolo='addetto' AND DataAbilitazione IS NOT NULL AND LivelloAbilitazione IS NULL)

LINGUA_PARLATA( Personale, Lingua )
   PK: (Personale, Lingua)
   LINGUA_PARLATA.Personale → PERSONALE(Matricola)

SKIPASS( NumeroSeriale, TipoPass, DataEmissione, DataScadenza, Prezzo,
         NomeInt, CognomeInt, DataNascitaInt, CodiceFiscaleInt*, IndirizzoInt* )
   PK: NumeroSeriale
   CHECK: TipoPass = 'stagionale' OR (CodiceFiscaleInt IS NULL AND IndirizzoInt IS NULL)

PASSAGGIO( Skipass, Impianto, Data, Ora )
   PK: (Skipass, Impianto, Data, Ora)
   PASSAGGIO.Skipass  → SKIPASS(NumeroSeriale)
   PASSAGGIO.Impianto → IMPIANTO(Codice)

TURNO( Impianto, Addetto, Data, OraInizio, OraFine )
   PK: (Impianto, Addetto, Data, OraInizio)
   TURNO.Impianto → IMPIANTO(Codice)
   TURNO.Addetto  → PERSONALE(Matricola)        [con Ruolo = 'addetto']

CORSO( CodCorso, Livello, DataInizio, DataFine, MaxPartecipanti, Maestro )
   PK: CodCorso
   CORSO.Maestro → PERSONALE(Matricola)  NOT NULL   [con Ruolo = 'maestro']

ISCRIZIONE( Skipass, Corso, DataIscrizione, Voto* )
   PK: (Skipass, Corso)
   ISCRIZIONE.Skipass → SKIPASS(NumeroSeriale)
   ISCRIZIONE.Corso   → CORSO(CodCorso)

RIEPILOGO_GIORNALIERO( Impianto, Data, NumPassaggi, MinutiFermo )
   PK: (Impianto, Data)
   RIEPILOGO_GIORNALIERO.Impianto → IMPIANTO(Codice)
```

**Motivazione della strategia per la generalizzazione — accorpamento nell'entità padre.**
Si è scelto di accorpare `MAESTRO` e `ADDETTO` in un'unica tabella `PERSONALE` con un attributo discriminante `Ruolo` e gli attributi specifici resi opzionali. Le ragioni:
- gli attributi specifici delle figlie sono **pochi** (uno per `MAESTRO`, uno per `ADDETTO`), quindi il numero di valori nulli introdotti è contenuto;
- la `Matricola` deve essere **univoca su tutto il personale**: mantenendo un'unica tabella il vincolo è garantito dalla chiave primaria, mentre con l'accorpamento nelle figlie andrebbe imposto con un vincolo aggiuntivo fra due tabelle;
- le interrogazioni che riguardano il personale nel suo complesso (elenco anagrafico) non richiedono unioni.

*Alternativa accettabile:* **accorpamento nelle entità figlie**, legittimo perché la generalizzazione è **totale** (nessuna istanza resterebbe scoperta) ed **esclusiva** (nessuna duplicazione), e perché nessuna relazione insiste sull'entità padre. Produrrebbe:
`MAESTRO(Matricola, Nome, Cognome, DataNascita, CodiceFiscale, LivelloAbilitazione)` e `ADDETTO(Matricola, Nome, Cognome, DataNascita, CodiceFiscale, DataAbilitazione)`, con lo svantaggio di dover garantire l'unicità di `Matricola` fra le due tabelle.

---

## Esercizio 2 — Progettazione verso un sistema document-based **(6)**

### 2.1 Etichettatura dello schema

```
                    ┌──────────┐
                    │ MAESTRO  │
                    └────┬─────┘
                         │ (0,N)
                      ╱──┴───╲
                      │ TIENE │        ══► incapsulamento in CORSO
                      ╲──┬───╱
                         │ (1,1)
                  ┌──────┴──────┐
                  │    CORSO    │   ★ ENTITÀ PRINCIPALE
                  └──────┬──────┘
                         │ (1,N)
                   ╱─────┴──────╲
                   │ ISCRIZIONE │      ══► incapsulamento dell'associazione,
                   ╲─────┬──────╱          RIFERIMENTO allo skipass
                         │ (0,N)
                  ┌──────┴──────┐
                  │   SKIPASS   │   ★ ENTITÀ PRINCIPALE (collezione propria)
                  └─────────────┘
```

**Entità principali:** `CORSO` e `SKIPASS` → due collezioni: `corsi` e `skipass`.

### 2.2 Collezioni e documenti JSON

```json
// collezione: corsi
{
  "_id": "C104",
  "livello": "avanzato",
  "dataInizio": "2026-01-12",
  "dataFine": "2026-01-17",
  "maxPartecipanti": 10,
  "maestro": {
    "matricola": "M77",
    "nome": "Elena",
    "cognome": "Rossi",
    "livelloAbilitazione": "nazionale",
    "lingue": ["italiano", "tedesco", "inglese"]
  },
  "iscritti": [
    { "skipass": "SP00912", "dataIscrizione": "2026-01-03", "voto": 28 },
    { "skipass": "SP01455", "dataIscrizione": "2026-01-05", "voto": null }
  ]
}
```

```json
// collezione: skipass
{
  "_id": "SP00912",
  "tipoPass": "stagionale",
  "dataEmissione": "2025-11-28",
  "dataScadenza": "2026-04-30",
  "prezzo": 720.00,
  "intestatario": {
    "nome": "Luca",
    "cognome": "Ferrari",
    "dataNascita": "1998-06-04",
    "codiceFiscale": "FRRLCU98H04L781K",
    "indirizzo": "Via Mazzini 14, Trento"
  }
}
```

### 2.3 Motivazione delle scelte

| Associazione | Scelta | Motivazione |
|---|---|---|
| `TIENE` (`MAESTRO` — `CORSO`, 1:N con `CORSO` sul lato (1,1)) | **incapsulamento** del maestro dentro il corso | ogni corso ha esattamente un maestro e i dati del maestro vengono letti praticamente sempre insieme al corso. I dati anagrafici di un maestro cambiano raramente, quindi il costo della duplicazione è basso. Il numero di corsi per maestro è limitato, quindi la duplicazione è contenuta |
| `ISCRIZIONE` (`SKIPASS` — `CORSO`, N:N con attributi) | **incapsulamento dell'associazione** dentro il corso, con **riferimento** allo skipass | l'associazione ha attributi propri (`dataIscrizione`, `voto`) che vanno collocati da qualche parte: l'array `iscritti` dentro il corso è il posto naturale, perché il numero di iscritti a un corso è limitato dal `maxPartecipanti`. Lo **skipass** però è un'entità con vita propria, referenziata anche dai passaggi e dai riepiloghi: incapsularlo per intero significherebbe duplicarne i dati e doverli aggiornare in ogni corso. Si usa quindi un riferimento |
| `SKIPASS` | **collezione propria** | è un'entità principale: viene interrogata direttamente (validità, intestatario, passaggi) e non esiste solo nel contesto di un corso |

> **Osservazione.** Se l'applicazione dovesse mostrare frequentemente "tutti i corsi a cui è iscritto uno skipass", si potrebbe aggiungere dentro il documento `skipass` un array `corsi: ["C104", "C231"]` di riferimenti. È una **denormalizzazione bidirezionale**: velocizza la navigazione inversa al prezzo di dover mantenere allineate due copie dell'associazione.

---

## Esercizio 3 — Algebra relazionale **(9)**

### 3.a

```
π NumeroSeriale, Cognome, Ora (

    π NumeroSeriale, Cognome ( σ TipoPass='stagionale' ∧ Provincia='Trento' ( SKIPASS ) )

  ⋈ NumeroSeriale = Skipass

    π Skipass, Ora (
        π Skipass, Impianto, Ora ( σ Data='15/01/2026' ( PASSAGGIO ) )
      ⋈ Impianto = Codice
        π Codice ( σ Tipologia='cabinovia' ∧ NomeImp='Pra Alpesina' ( IMPIANTO ) )
    )
)
```

**Ottimizzazione applicata:** tutte le selezioni sono state **anticipate** (*selection push*) direttamente sulle tabelle di base, prima dei join; le proiezioni sono state anticipate (*projection push*) mantenendo in ciascun ramo solo gli attributi necessari al join e al risultato finale. Il join più selettivo (`PASSAGGIO ⋈ IMPIANTO`, che riduce a un solo impianto) viene eseguito per primo.

### 3.b

```
IMP_NORD  :=  π Codice ( σ Versante='Nord' ( IMPIANTO ) )

IMP_CON_GIORNALIERI  :=  ρ Codice ← Impianto (
      π Impianto (
          π Skipass, Impianto ( σ Data ≥ '01/02/2026' ∧ Data ≤ '28/02/2026' ( PASSAGGIO ) )
        ⋈ Skipass = NumeroSeriale
          π NumeroSeriale ( σ TipoPass='giornaliero' ( SKIPASS ) )
      )
   )

RISULTATO  :=  π Codice, NomeImp ( ( IMP_NORD − IMP_CON_GIORNALIERI ) ⋈ IMPIANTO )
```

**Nota.** La differenza richiede che i due operandi abbiano lo **stesso schema**: da qui la ridenominazione `ρ Codice ← Impianto`. Il join finale con `IMPIANTO` serve solo a recuperare l'attributo `NomeImp`, che è stato proiettato via nei passi intermedi.

### 3.c

```
ISCR_AVANZATE  :=  π Skipass, Corso (
        ISCRIZIONE ⋈ Corso = CodCorso π CodCorso ( σ Livello='avanzato' ( CORSO ) )
   )

ALMENO_DUE  :=  π Skipass (
        ISCR_AVANZATE
      ⋈ Skipass = Skipass2 ∧ Corso ≠ Corso2
        ρ Skipass2 ← Skipass, Corso2 ← Corso ( ISCR_AVANZATE )
   )

RISULTATO  :=  π Cognome ( ALMENO_DUE ⋈ Skipass = NumeroSeriale SKIPASS )
```

**Schema del ragionamento "almeno due":** si costruisce l'insieme delle iscrizioni ai corsi avanzati, se ne fa una **copia ridenominata** e si esegue un theta-join che accoppia due iscrizioni **dello stesso skipass** ma su **corsi diversi**. La proiezione finale elimina i duplicati.

---

## Esercizio 4 — Document DB e calcolo relazionale **(5)**

### 4.a MongoDB

**i.** Corsi avanzati iniziati dopo il 2026-01-01 con almeno 8 iscritti:

```js
db.corsi.find(
  {
    livello: "avanzato",
    dataInizio: { $gt: "2026-01-01" },
    $expr: { $gte: [ { $size: "$iscritti" }, 8 ] }
  },
  { _id: 0, livello: 1, dataInizio: 1, "maestro.cognome": 1 }
)
```

*Variante equivalente e più efficiente* (sfrutta l'indice sull'array, senza valutare `$size` su ogni documento): la condizione "almeno 8 elementi" si può esprimere verificando l'esistenza dell'ottavo elemento, di indice 7:

```js
db.corsi.find(
  { livello: "avanzato", dataInizio: { $gt: "2026-01-01" }, "iscritti.7": { $exists: true } },
  { _id: 0, livello: 1, dataInizio: 1, "maestro.cognome": 1 }
)
```

**ii.** Per ogni maestro, numero di corsi tenuti e voto medio assegnato:

```js
db.corsi.aggregate([
  { $unwind: "$iscritti" },
  { $group: {
      _id:       "$maestro.matricola",
      cognome:   { $first: "$maestro.cognome" },
      corsi:     { $addToSet: "$_id" },
      votoMedio: { $avg: "$iscritti.voto" }
  }},
  { $project: {
      _id: 1, cognome: 1,
      numCorsi: { $size: "$corsi" },
      votoMedio: 1
  }},
  { $sort: { votoMedio: -1 } }
])
```

> **Attenzione a due punti spesso sbagliati:** (1) dopo `$unwind` ogni corso compare tante volte quanti sono i suoi iscritti, quindi il numero di corsi **non** si può contare con `$sum: 1` — serve `$addToSet` sull'`_id` seguito da `$size`; (2) `$avg` **ignora automaticamente i valori `null`**, quindi gli iscritti senza voto non falsano la media.

### 4.b Calcolo relazionale sulle tuple con dichiarazioni di range — interrogazione 3.a

```
{ s.NumeroSeriale, s.Cognome, p.Ora  |
     s(SKIPASS), p(PASSAGGIO), i(IMPIANTO)  |
     s.TipoPass  = 'stagionale'  ∧
     s.Provincia = 'Trento'      ∧
     p.Skipass   = s.NumeroSeriale ∧
     p.Data      = '15/01/2026'  ∧
     p.Impianto  = i.Codice      ∧
     i.Tipologia = 'cabinovia'   ∧
     i.NomeImp   = 'Pra Alpesina'
}
```

La lista target indica gli attributi in uscita, la dichiarazione di range associa a ogni variabile la relazione su cui varia, la formula esprime sia le condizioni di selezione sia le condizioni di join (uguaglianze fra attributi di variabili diverse).
