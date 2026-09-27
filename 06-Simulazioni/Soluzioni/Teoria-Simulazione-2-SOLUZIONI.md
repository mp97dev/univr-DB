# Soluzioni — Prova di Teoria, Simulazione 2

> Traccia: [`Teoria-Simulazione-2.md`](../Teoria-Simulazione-2.md)

---

## a) Il costrutto di generalizzazione **(3)**

**Definizione.** Una *generalizzazione* è un legame logico fra un'entità `E`, detta **padre** (o entità generica), e una o più entità `E1, …, En`, dette **figlie** (o entità specifiche), tale che `E` è più generale delle figlie, nel senso che le comprende come casi particolari.

**Proprietà delle istanze.** Ogni istanza di un'entità figlia è **anche** un'istanza dell'entità padre. Ne discende l'**ereditarietà**: ogni proprietà del padre (attributi, identificatori, relazioni a cui partecipa) vale automaticamente anche per le figlie e non va ripetuta su di esse. Le figlie possiedono in aggiunta i propri attributi specifici e possono partecipare a proprie relazioni. L'identificatore è **unico** e appartiene al padre: le figlie non hanno un identificatore proprio.

**Rappresentazione grafica.** Una freccia (o un triangolo) che va dalle entità figlie verso l'entità padre.

```
                    ┌──────────────┐
                    │   PERSONA    │      ●CodiceFiscale, Nome, Cognome
                    └──────┬───────┘
                        ───┴───   (t, e)
                       ╱       ╲
              ┌────────┐       ┌────────┐
              │ UOMO   │       │ DONNA  │
              └────────┘       └────────┘
```

**Classificazione.** Si basa su due dimensioni indipendenti, che danno quattro combinazioni:

| | **Esclusiva (e)** — le figlie sono a due a due disgiunte | **Sovrapposta (s)** — un'istanza può appartenere a più figlie |
|---|---|---|
| **Totale (t)** — ogni istanza del padre appartiene ad almeno una figlia | `(t,e)` **PERSONA** → `UOMO`, `DONNA`: ogni persona è l'uno o l'altra, mai entrambi | `(t,s)` **PERSONA** → `STUDENTE`, `LAVORATORE` in un contesto in cui tutti studiano o lavorano: uno studente lavoratore appartiene a entrambe |
| **Parziale (p)** — possono esistere istanze del padre che non appartengono a nessuna figlia | `(p,e)` **VEICOLO** → `AUTO`, `MOTO`: esistono anche camion e rimorchi, non classificati, ma un veicolo non è mai auto e moto insieme | `(p,s)` **DIPENDENTE** → `PROGETTISTA`, `COLLAUDATORE`: esistono dipendenti con altri ruoli, e alcuni svolgono entrambe le mansioni |

Un caso particolare è il **sottoinsieme**: una generalizzazione con una sola entità figlia, necessariamente parziale (es. `STUDENTE` → `STUDENTE_LAVORATORE`).

---

## b) Traduzione dello schema ER nel modello relazionale **(3)**

```
E( e1, e2 )
   PK: e1

F( f1, f2 )
   PK: (f1, f2)

G( g1, E, F1, F2 )
   PK: g1
   G.E        → E(e1)          NOT NULL
   G.(F1, F2) → F(f1, f2)      NOT NULL

H( h1, h2*, Padre*, E, v1 )
   PK: h1
   H.Padre → H(h1)             può essere NULL
   H.E     → E(e1)             NOT NULL
```

**Motivazioni:**

| Costrutto | Regola applicata |
|---|---|
| Relazione **ternaria** `T` fra `E` (0,N), `F` (0,N), `G` (1,1) | poiché `G` partecipa con cardinalità **(1,1)**, ogni istanza di `G` è associata a **esattamente una** coppia (`E`, `F`): la relazione ternaria **non genera una tabella propria** ma viene **accorpata in `G`**, che riceve le chiavi di `E` e di `F` come attributi obbligatori. La chiave di `G` resta `g1`, perché `g1` da solo determina la coppia associata |
| `F` con identificatore **composto** | la chiave primaria di `F` è `(f1, f2)`; ogni riferimento a `F` deve quindi propagare **entrambi** gli attributi (in `G`: `F1`, `F2`) |
| Relazione `V` fra `E` (1,N) e `H` (1,1) con attributo `v1` | relazione **uno a molti**: la chiave dell'entità sul lato "uno" (`E`) migra come chiave esterna nell'entità sul lato "molti" (`H`); poiché `H` partecipa con cardinalità minima 1, l'attributo è `NOT NULL`. L'attributo `v1` della relazione **migra insieme alla chiave esterna** dentro `H` |
| Relazione **ricorsiva** `W` su `H`, ruoli `padre` (0,N) / `figlio` (0,1) | ogni istanza di `H`, nel ruolo di *figlio*, ha **al più un** padre (cardinalità massima 1): la relazione si traduce con una chiave esterna `Padre` dentro `H` stessa, che riferisce la chiave primaria di `H`. La chiave esterna **ammette valore nullo** perché la cardinalità minima nel ruolo di figlio è 0 (le istanze radice non hanno padre) |
| `h2` opzionale | attributo con cardinalità (0,1) → ammette valore nullo |

> ⚠️ Se `G` avesse partecipato alla ternaria con cardinalità `(0,N)` anziché `(1,1)`, la relazione `T` avrebbe generato una tabella a sé: `T(E, F1, F2, G)` con chiave l'unione delle tre chiavi.

---

## c) Struttura di un documento JSON e differenza fra collezione e tabella **(3)**

### Struttura di un documento JSON

Un **documento** è un insieme non ordinato di coppie *chiave : valore* delimitato da parentesi graffe. La chiave è sempre una stringa; il valore può essere:

| Tipo di valore | Esempio |
|---|---|
| stringa | `"comune": "Verona"` |
| numero (intero o reale) | `"potenzaMax": 22.5` |
| booleano | `"coperta": true` |
| valore nullo | `"dataFine": null` |
| **array** (sequenza ordinata di valori, anche eterogenei) | `"connettori": ["Type2", "CCS"]` |
| **documento annidato** (sottodocumento) | `"indirizzo": { "via": "Via Roma 3", "cap": "37100" }` |

Array e sottodocumenti possono essere **annidati arbitrariamente** (un array di documenti, un documento contenente array di documenti, …): è questa la caratteristica che consente di rappresentare in un solo documento un'informazione che nel modello relazionale richiederebbe più tabelle e dei join.

**Il campo `_id`.** Ogni documento di una collezione possiede obbligatoriamente un campo `_id`, che ne costituisce l'**identificatore univoco all'interno della collezione** — è l'equivalente della chiave primaria. Se non viene fornito dall'applicazione, MongoDB lo genera automaticamente come valore di tipo `ObjectId` (12 byte, contenenti fra l'altro un timestamp). Su `_id` esiste sempre un indice, creato automaticamente e non eliminabile. Il valore di `_id` è immutabile dopo l'inserimento.

MongoDB memorizza fisicamente i documenti in **BSON** (*Binary JSON*), una codifica binaria di JSON che aggiunge tipi non previsti da JSON (date, dati binari, `ObjectId`, interi a 32/64 bit) e rende più efficienti attraversamento e confronto.

### Collezione vs tabella

| | **Tabella** (modello relazionale) | **Collezione** (document store) |
|---|---|---|
| **Schema** | *schema-on-write*: lo schema è definito a priori con `CREATE TABLE` ed è **rigido**; il DBMS rifiuta ogni tupla che non lo rispetti | *schema-less* o *schema-on-read*: non esiste uno schema dichiarato obbligatorio; la struttura è implicita nei documenti e può essere validata solo facoltativamente (JSON Schema validator) |
| **Omogeneità delle istanze** | tutte le tuple hanno **esattamente gli stessi attributi**, nello stesso ordine e con lo stesso dominio | i documenti possono essere **eterogenei**: campi presenti in alcuni e assenti in altri, con tipi diversi per lo stesso campo |
| **Valori mancanti** | l'attributo esiste comunque e assume il valore `NULL` | il campo può essere semplicemente **assente** dal documento: assenza e valore nullo sono situazioni distinte |
| **Struttura dei valori** | i domini sono **atomici** (prima forma normale): niente array né strutture annidate | i valori possono essere **array e documenti annidati**: l'informazione strutturata sta dentro un solo documento |
| **Evoluzione** | modificare lo schema richiede `ALTER TABLE` su tutta la tabella | si aggiunge semplicemente un campo nuovo ai documenti nuovi; i vecchi restano validi |
| **Associazioni** | espresse con chiavi esterne e ricomposte con **join** | espresse con incapsulamento oppure con riferimenti, ricomposte dall'applicazione o con `$lookup` |

**Conseguenza progettuale.** Nel modello relazionale la progettazione logica è guidata dai dati e mira a eliminare la ridondanza; in un sistema document-based è guidata dalle **interrogazioni** e la ridondanza controllata è spesso una scelta deliberata per evitare i join.

---

## Esercizio 1 — Progettazione **(12)**

### 1.1 Schema concettuale ER

```
STAZIONE( ●CodStazione, Indirizzo, Comune, Provincia,
          Coordinate{Latitudine, Longitudine}, DataAttivazione, Coperta )
      Coordinate è un attributo COMPOSTO

COLONNINA( ●Numero, PotenzaMax, Connettore, Stato )
      identificatore ESTERNO: STAZIONE + Numero

UTENTE( ●CodFiscale, Nome, Cognome, DataNascita, Email, Telefono[1,N] )
      Telefono è un attributo MULTIVALORE
      generalizzazione PARZIALE ed ESCLUSIVA (p,e) in:
        UTENTE_PRIVATO( DataIscrizione )
        UTENTE_AZIENDALE( RagioneSociale, PartitaIVA )

VEICOLO( ●Targa, Costruttore, Modello, CapacitaBatteria, Connettore )

TARIFFA( ●CodTariffa, NomeTar, PrezzoKWh, ○QuotaFissa, DataInizioVal, DataFineVal )

SESSIONE( DataOraInizio, ○DataOraFine, EnergiaKWh, Importo )
      identificatore ESTERNO: VEICOLO + COLONNINA + DataOraInizio

MANUTENZIONE( DataOra, TipoIntervento, Ditta, Tecnico[1,N] )
      identificatore ESTERNO: COLONNINA + DataOra
      Tecnico è un attributo MULTIVALORE (codici fiscali)

RIEPILOGO_MENSILE( Anno, Mese, EnergiaTotale, NumSessioni )
      identificatore ESTERNO: STAZIONE + Anno + Mese
```

**Relazioni:**

| Relazione | Entità e cardinalità |
|---|---|
| `DISPONE` | `STAZIONE` (1,N) — `COLONNINA` (1,1) |
| `POSSIEDE` | `UTENTE` (0,N) — `VEICOLO` (1,1) |
| `SESS_VEICOLO` | `VEICOLO` (0,N) — `SESSIONE` (1,1) |
| `SESS_COLONNINA` | `COLONNINA` (0,N) — `SESSIONE` (1,1) |
| `APPLICA` | `TARIFFA` (0,N) — `SESSIONE` (1,1) |
| `SUBISCE` | `COLONNINA` (0,N) — `MANUTENZIONE` (1,1) |
| `RIEPILOGA` | `STAZIONE` (0,N) — `RIEPILOGO_MENSILE` (1,1) |

**Scelte di progetto da motivare:**

1. **`COLONNINA` ha identificatore esterno.** Il testo dice che *"il numero da solo non è univoco: è la coppia stazione–numero a identificare una colonnina"*. La condizione di correttezza è rispettata: `COLONNINA` partecipa a `DISPONE` con cardinalità (1,1) e `STAZIONE` è identificata internamente.
2. **`SESSIONE` è un'entità con identificatore esterno**, non una relazione, perché *"uno stesso veicolo può eseguire più sessioni sulla stessa colonnina […] anche nello stesso giorno, purché con ora di inizio diversa"*: una relazione ER non potrebbe contenere due istanze con la stessa coppia (veicolo, colonnina). Stesso ragionamento per `MANUTENZIONE`.
3. **La generalizzazione è PARZIALE** — e non totale — perché il testo precisa che un utente *"non può appartenere a nessuna delle due se è un utente non ancora verificato"*. È **esclusiva** perché *"un utente appartiene a una sola delle due categorie"*.
4. **`DataOraFine` è opzionale** perché una sessione in corso non ha ancora una fine registrata.
5. **`RIEPILOGO_MENSILE` contiene due ridondanze** (`EnergiaTotale` e `NumSessioni` sono derivabili da `SESSIONE`). Si sceglie di mantenerle: sono calcolate una sola volta al mese e vengono lette molto più spesso di quanto vengano scritte, mentre il loro ricalcolo richiederebbe l'aggregazione di una tabella con milioni di righe.

### 1.2 Schema logico relazionale

```
STAZIONE( CodStazione, Indirizzo, Comune, Provincia, Latitudine, Longitudine,
          DataAttivazione, Coperta )
   PK: CodStazione

COLONNINA( Stazione, Numero, PotenzaMax, Connettore, Stato )
   PK: (Stazione, Numero)
   COLONNINA.Stazione → STAZIONE(CodStazione)

UTENTE( CodFiscale, Nome, Cognome, DataNascita, Email,
        Categoria*, DataIscrizione*, RagioneSociale*, PartitaIVA* )
   PK: CodFiscale
   CHECK: Categoria IS NULL OR Categoria ∈ {'privato','aziendale'}
   CHECK: (Categoria='privato'   AND DataIscrizione IS NOT NULL
                                 AND RagioneSociale IS NULL AND PartitaIVA IS NULL)
       OR (Categoria='aziendale' AND RagioneSociale IS NOT NULL AND PartitaIVA IS NOT NULL
                                 AND DataIscrizione IS NULL)
       OR (Categoria IS NULL     AND DataIscrizione IS NULL
                                 AND RagioneSociale IS NULL AND PartitaIVA IS NULL)

TELEFONO_UTENTE( Utente, Numero )
   PK: (Utente, Numero)
   TELEFONO_UTENTE.Utente → UTENTE(CodFiscale)

VEICOLO( Targa, Costruttore, Modello, CapacitaBatteria, Connettore, Utente )
   PK: Targa
   VEICOLO.Utente → UTENTE(CodFiscale)   NOT NULL

TARIFFA( CodTariffa, NomeTar, PrezzoKWh, QuotaFissa*, DataInizioVal, DataFineVal )
   PK: CodTariffa

SESSIONE( Veicolo, Stazione, Colonnina, DataOraInizio, DataOraFine*,
          EnergiaKWh, Importo, Tariffa )
   PK: (Veicolo, Stazione, Colonnina, DataOraInizio)
   SESSIONE.Veicolo              → VEICOLO(Targa)
   SESSIONE.(Stazione, Colonnina)→ COLONNINA(Stazione, Numero)
   SESSIONE.Tariffa              → TARIFFA(CodTariffa)   NOT NULL

MANUTENZIONE( Stazione, Colonnina, DataOra, TipoIntervento, Ditta )
   PK: (Stazione, Colonnina, DataOra)
   MANUTENZIONE.(Stazione, Colonnina) → COLONNINA(Stazione, Numero)
   CHECK: TipoIntervento ∈ {'ordinaria','straordinaria','riparazione'}

TECNICO_MANUTENZIONE( Stazione, Colonnina, DataOra, CodFiscaleTecnico )
   PK: (Stazione, Colonnina, DataOra, CodFiscaleTecnico)
   TECNICO_MANUTENZIONE.(Stazione, Colonnina, DataOra) → MANUTENZIONE

RIEPILOGO_MENSILE( Stazione, Anno, Mese, EnergiaTotale, NumSessioni )
   PK: (Stazione, Anno, Mese)
   RIEPILOGO_MENSILE.Stazione → STAZIONE(CodStazione)
```

**Motivazione della strategia per la generalizzazione — accorpamento nell'entità padre.**
La generalizzazione è **parziale**: esistono istanze di `UTENTE` che non appartengono a nessuna figlia (gli utenti non verificati). L'accorpamento nelle figlie **non è quindi applicabile**, perché quelle istanze non avrebbero alcuna tabella in cui essere memorizzate. Si accorpa allora tutto nel padre, con un attributo discriminante `Categoria` che può valere `NULL` proprio per gli utenti non verificati, e con gli attributi specifici resi opzionali. Il prezzo da pagare è la presenza di valori nulli e la necessità di vincoli di tupla (`CHECK`) per garantire la coerenza fra discriminante e attributi specifici.

> *Alternativa:* sostituire la generalizzazione con due relazioni uno-a-uno fra `UTENTE` e due tabelle separate `PRIVATO(CodFiscale, DataIscrizione)` e `AZIENDALE(CodFiscale, RagioneSociale, PartitaIVA)`. Elimina i valori nulli ma introduce due join per l'accesso ai dati completi.

**Attributi composti e multivalore.** L'attributo composto `Coordinate` è stato tradotto sostituendolo con i suoi componenti atomici (`Latitudine`, `Longitudine`). Gli attributi multivalore `Telefono` e `Tecnico` hanno invece richiesto **una tabella a sé**, perché il modello relazionale ammette solo domini atomici (prima forma normale).

---

## Esercizio 2 — Progettazione verso un sistema document-based **(6)**

### 2.1 Etichettatura dello schema

```
      ┌───────────────┐                            ┌──────────────┐
      │   STAZIONE    │ ★ principale               │   VEICOLO    │ ★ principale
      └───────┬───────┘                            └──────┬───────┘
              │ (1,N)                                     │ (0,N)
          ╱───┴────╲                                      │
          │ DISPONE│  ══► incapsulamento                  │
          ╲───┬────╱                                      │
              │ (1,1)                                     │
      ┌───────┴───────┐                                   │
      │   COLONNINA   │                                   │
      └───────┬───────┘                                   │
              │ (0,N)                                     │
              └──────────►  riferimento  ◄────────────────┘
                                 │
                         ┌───────┴────────┐
                         │   SESSIONE     │ ★ principale
                         └────────────────┘
```

**Entità principali:** `STAZIONE`, `VEICOLO`, `SESSIONE` → tre collezioni: `stazioni`, `veicoli`, `sessioni`.
`COLONNINA` **non** è entità principale: è incapsulata dentro la stazione.

### 2.2 Collezioni e documenti JSON

```json
// collezione: stazioni
{
  "_id": "ST-0142",
  "indirizzo": "Via Cà di Cozzi 12",
  "comune": "Verona",
  "provincia": "VR",
  "coordinate": { "latitudine": 45.4642, "longitudine": 10.9902 },
  "dataAttivazione": "2024-05-09",
  "coperta": true,
  "colonnine": [
    { "numero": 1, "potenzaMax": 22,  "connettore": "Type2", "stato": "libera"   },
    { "numero": 2, "potenzaMax": 150, "connettore": "CCS",   "stato": "guasta"   },
    { "numero": 3, "potenzaMax": 50,  "connettore": "CHAdeMO", "stato": "occupata" }
  ]
}
```

```json
// collezione: veicoli
{
  "_id": "FA123BC",
  "costruttore": "Tesla",
  "modello": "Model 3 Long Range",
  "capacitaBatteria": 75,
  "connettore": "CCS",
  "utente": "RSSMRA85M01L781X"
}
```

```json
// collezione: sessioni
{
  "_id": { "veicolo": "FA123BC", "stazione": "ST-0142", "colonnina": 2,
           "dataOraInizio": "2026-03-10T08:14:00" },
  "dataOraFine": "2026-03-10T09:02:00",
  "energiaKWh": 41.6,
  "importo": 18.72,
  "tariffa": { "codice": "TF-STD", "nomeTar": "Standard", "prezzoKWh": 0.45 }
}
```

### 2.3 Discussione della scelta fra `COLONNINA` e `SESSIONE`

**`STAZIONE` — `COLONNINA`: incapsulamento.** L'associazione è 1:N con `COLONNINA` sul lato (1,1); una colonnina **non ha vita propria** al di fuori della sua stazione (è addirittura identificata esternamente da essa) e il numero di colonnine per stazione è piccolo e limitato (tipicamente 2–10). I dati di stazione e colonnine vengono quasi sempre letti insieme (la mappa delle stazioni con la disponibilità delle prese). L'incapsulamento è quindi la scelta corretta: una sola lettura restituisce tutto, e l'aggiornamento dello stato di una colonnina è **atomico** perché avviene all'interno di un unico documento.

**`COLONNINA` — `SESSIONE`: riferimento, obbligatoriamente.** Il testo dell'esercizio segnala che *una colonnina accumula decine di migliaia di sessioni all'anno*. Incapsulare le sessioni in un array dentro la stazione sarebbe **sbagliato** per tre ragioni:

1. **Limite di dimensione.** In MongoDB un documento non può superare i **16 MB**. Con ~30 000 sessioni all'anno per colonnina e ~150 byte per sessione si superano i 4 MB per colonnina all'anno: un documento stazione con più colonnine sfonderebbe il limite nel giro di pochi mesi. Il documento avrebbe una **crescita illimitata e non controllabile**, che è l'anti-pattern classico dell'*unbounded array*.
2. **Costo di scrittura e frammentazione.** Ogni nuova sessione comporterebbe la riscrittura (o la riallocazione) di un documento enorme, invece dell'inserimento di un documento piccolo.
3. **Granularità delle letture.** Le interrogazioni sulle sessioni (statistiche di consumo, fatturazione, storico di un veicolo) hanno criteri di selezione **diversi** da quelli sulle stazioni; caricare l'intera stazione per analizzare le sessioni sarebbe uno spreco.

La collezione `sessioni` porta quindi come `_id` composto il riferimento a veicolo, stazione, colonnina e istante di inizio — che è esattamente l'identificatore esterno individuato nello schema ER.

**La tariffa è incapsulata** nella sessione benché sia un'entità con vita propria: si tratta di una **denormalizzazione deliberata**, perché il prezzo applicato deve restare "congelato" al momento della ricarica anche se la tariffa viene in seguito modificata (è un dato storico, non un riferimento vivo).

---

## Esercizio 3 — Algebra relazionale **(9)**

### 3.a

```
π Veicolo, Colonnina, EnergiaKWh, Importo (

    π Veicolo, Stazione, Colonnina, EnergiaKWh, Importo (
        σ DataOraInizio ≥ '10/03/2026 00:00' ∧ DataOraInizio ≤ '10/03/2026 23:59' ( SESSIONE )
    )

  ⋈ Veicolo = Targa
    π Targa ( σ Costruttore = 'Tesla' ( VEICOLO ) )

  ⋈ Stazione = CodStazione
    π CodStazione ( σ Coperta = TRUE ∧ Comune = 'Verona' ( STAZIONE ) )
)
```

Tutte e tre le selezioni sono anticipate sulle rispettive tabelle di base; le proiezioni riducono ogni operando ai soli attributi necessari. Poiché in `SESSIONE` l'attributo `Veicolo` **è** la targa, non serve alcun ulteriore accesso a `VEICOLO` per il risultato.

### 3.b

```
SESS_TRENTO := π Veicolo (
        π Veicolo, Stazione ( SESSIONE )
      ⋈ Stazione = CodStazione
        π CodStazione ( σ Provincia = 'Trento' ( STAZIONE ) )
   )

UTENTI_TRENTO := ρ CodFiscale ← Utente (
        π Utente ( π Targa, Utente ( VEICOLO ) ⋈ Targa = Veicolo SESS_TRENTO )
   )

RISULTATO := π CodFiscale, Nome, Cognome (
        ( π CodFiscale ( UTENTE ) − UTENTI_TRENTO ) ⋈ UTENTE
   )
```

**Schema del ragionamento "non ha mai …":** si calcola l'insieme di *tutti* gli utenti, si calcola l'insieme di quelli che **hanno** eseguito almeno una sessione in provincia di Trento, e si fa la **differenza**. La ridenominazione `ρ CodFiscale ← Utente` è necessaria perché la differenza richiede operandi con lo stesso schema. Il join finale con `UTENTE` recupera nome e cognome, proiettati via nei passi intermedi.

### 3.c

```
S := π Veicolo, Stazione, Colonnina ( SESSIONE )

RISULTATO := π Veicolo (
        S
      ⋈ Veicolo = Veicolo2 ∧ Stazione = Stazione2 ∧ Colonnina ≠ Colonnina2
        ρ Veicolo2 ← Veicolo, Stazione2 ← Stazione, Colonnina2 ← Colonnina ( S )
   )
```

Il theta-join accoppia due sessioni **dello stesso veicolo** presso la **stessa stazione** ma su **colonnine diverse**. La proiezione preliminare su `(Veicolo, Stazione, Colonnina)` elimina i duplicati dovuti a più sessioni sulla stessa colonnina, che non devono contribuire al risultato.

---

## Esercizio 4 — Document DB e calcolo relazionale **(5)**

### 4.a MongoDB

**i.** Stazioni coperte di Verona con almeno una colonnina CCS da oltre 100 kW:

```js
db.stazioni.find(
  {
    coperta: true,
    comune: "Verona",
    colonnine: { $elemMatch: { connettore: "CCS", potenzaMax: { $gt: 100 } } }
  },
  { _id: 0, indirizzo: 1, colonnine: 1 }
)
```

> ⚠️ **Errore tipico:** scrivere `{ "colonnine.connettore": "CCS", "colonnine.potenzaMax": { $gt: 100 } }`. Questa forma è **sbagliata**, perché le due condizioni verrebbero soddisfatte anche da elementi **diversi** dell'array (una colonnina CCS da 22 kW più una Type2 da 150 kW). `$elemMatch` impone che sia **lo stesso elemento** a soddisfarle entrambe.

**ii.** Per ogni provincia, numero di colonnine guaste e potenza massima presente:

```js
db.stazioni.aggregate([
  { $unwind: "$colonnine" },
  { $group: {
      _id: "$provincia",
      colonnineGuaste: {
        $sum: { $cond: [ { $eq: ["$colonnine.stato", "guasta"] }, 1, 0 ] }
      },
      potenzaMassima: { $max: "$colonnine.potenzaMax" }
  }},
  { $sort: { colonnineGuaste: -1 } }
])
```

`$unwind` "srotola" l'array producendo un documento per ogni colonnina; il conteggio condizionato si ottiene con `$sum` di un `$cond`, che vale 1 quando lo stato è `"guasta"` e 0 altrimenti.

### 4.b Calcolo relazionale sulle tuple con dichiarazioni di range — interrogazione 3.b

```
{ u.CodFiscale, u.Nome, u.Cognome  |
     u(UTENTE)  |
     ¬ ∃ v(VEICOLO) ( ∃ s(SESSIONE) ( ∃ t(STAZIONE) (
            v.Utente    = u.CodFiscale   ∧
            s.Veicolo   = v.Targa        ∧
            s.Stazione  = t.CodStazione  ∧
            t.Provincia = 'Trento'
     ) ) )
}
```

Le interrogazioni con negazione (*"non ha mai …"*) si esprimono nel calcolo con un **quantificatore esistenziale negato**, equivalente a un quantificatore universale sulla condizione negata:

```
∀ v(VEICOLO) ( ∀ s(SESSIONE) ( ∀ t(STAZIONE) (
     ¬( v.Utente = u.CodFiscale ∧ s.Veicolo = v.Targa ∧
        s.Stazione = t.CodStazione ∧ t.Provincia = 'Trento' ) ) ) )
```

È la controparte del `NOT EXISTS` di SQL e dell'operatore di **differenza** dell'algebra relazionale.
