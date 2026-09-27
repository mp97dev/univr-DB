# Basi di Dati — Prova di Teoria

**Simulazione 1** · Matricola: ______________ · Cognome: ______________________ · Nome: ______________________

> *Avvertenze: è severamente vietato consultare libri e appunti.* **Durata: 2h15min**
> Punteggi: (a, b, c) 3 — (1) 12 — (2) 6 — (3.a, 3.b, 3.c) 3 — (4.a) 3 — (4.b) 2

---

## DOMANDE PRELIMINARI

> *È necessario rispondere in modo sufficiente alle seguenti tre domande per poter superare la prova con esito positivo; in caso di mancata o errata risposta a queste domande il resto del compito non verrà corretto.*

**a) (3)** Si illustri il costrutto di **identificatore** del modello Entità-Relazione, distinguendo tra identificatore **interno** ed **esterno**. Si indichino le condizioni di correttezza che un identificatore esterno deve rispettare e si fornisca un esempio grafico di ciascuno dei due tipi.

**b) (3)** Dato il seguente schema concettuale nel modello ER, si produca la sua traduzione nel modello relazionale, indicando esplicitamente per ogni relazione: la chiave primaria, gli attributi che possono assumere valore nullo e i vincoli di integrità referenziale.

```
                    (1,N)              (1,N)
        ┌───┐                ╱────╲                ┌───┐
        │ A │────────────────│  R  │───────────────│ B │
        └───┘                ╲────╱                └───┘
       a1  a2                   │                 b1  b2  b3
        │                       r1
        │ (0,N)                                      │ (0,1)
      ╱─┴──╲                                       ╱─┴──╲
      │  S  │                                      │  Q  │
      ╲─┬──╱                                       ╲─┬──╱
        │ (1,1)                                      │ (1,1)
      ┌─┴─┐                                        ┌─┴─┐
      │ C │                                        │ D │
      └───┘                                        └───┘
     c1   c2                                      d1   d2
```

Specifiche dello schema:

| Costrutto | Dettaglio |
|---|---|
| Entità `A` | attributi `a1`, `a2` — identificatore interno: `a1` |
| Entità `B` | attributi `b1`, `b2`, `b3` — identificatore interno: `b1`; `b3` è **opzionale** |
| Entità `C` | attributi `c1`, `c2` — **identificatore esterno**: `c1` + la relazione `S` con `A` |
| Entità `D` | attributi `d1`, `d2` — identificatore interno: `d1` |
| Relazione `R` | fra `A` (1,N) e `B` (1,N), con attributo `r1` |
| Relazione `S` | fra `A` (0,N) e `C` (1,1) |
| Relazione `Q` | fra `B` (0,1) e `D` (1,1) |

**c) (3)** Nella progettazione logica verso un sistema **document-based** si deve decidere, per ogni associazione dello schema concettuale, se **incapsulare** (*embedding*) il documento associato oppure se rappresentarlo tramite **riferimento** (*referencing*). Si illustrino le due tecniche, si indichino i criteri che guidano la scelta fra l'una e l'altra, e si fornisca per ciascuna un esempio di documento JSON che rappresenti l'associazione fra un'entità `Ordine` e un'entità `Cliente`.

---

## ESERCIZI

### 1. Progettazione di una base di dati **(12)**

Si vuole progettare il sistema informativo del comprensorio sciistico **Monte Baldo Ski**.

Il comprensorio è costituito da un insieme di **impianti di risalita**. Per ciascun impianto si registra: un codice univoco, il nome, la tipologia (seggiovia, cabinovia, skilift), la quota di partenza, la quota di arrivo, la portata oraria (numero di persone trasportabili in un'ora) e l'anno di costruzione.

Il comprensorio comprende inoltre un insieme di **piste**. Per ogni pista si registra: il numero, il versante di appartenenza (il numero è univoco solo all'interno di un versante: è la coppia numero–versante a identificare la pista), il nome, la lunghezza in metri, il dislivello e la difficoltà (blu, rossa, nera). Ogni pista parte dalla stazione di arrivo di esattamente un impianto di risalita; un impianto può servire più piste oppure nessuna.

Del **personale** si registra: la matricola univoca, il nome, il cognome, la data di nascita e il codice fiscale. Il personale si distingue in *maestri di sci*, per i quali si registra in aggiunta il livello di abilitazione e le lingue parlate (una o più), e *addetti agli impianti*, per i quali si registra la data di conseguimento dell'abilitazione tecnica. Ogni membro del personale è o un maestro o un addetto, e non può essere entrambe le cose.

Ogni giorno di apertura ciascun impianto viene affidato a uno o più addetti. Per ogni **turno** si registra: l'impianto, l'addetto, la data, l'ora di inizio e l'ora di fine. Uno stesso addetto può svolgere più turni sullo stesso impianto nella stessa giornata, purché con ora di inizio diversa.

Gli sciatori acquistano uno **skipass**, di cui si registra: il numero seriale univoco della tessera, il tipo (giornaliero, plurigiornaliero, stagionale), la data di emissione, la data di scadenza e il prezzo pagato. Di ogni skipass si registrano i dati dell'intestatario: nome, cognome e data di nascita; solo per gli skipass di tipo stagionale si registrano inoltre il codice fiscale e l'indirizzo di residenza dell'intestatario.

Ogni volta che uno skipass viene presentato al tornello di un impianto il sistema registra un **passaggio**: lo skipass, l'impianto, la data e l'ora. Uno stesso skipass può passare più volte allo stesso impianto nella stessa giornata, ma non nello stesso istante.

Il comprensorio organizza **corsi di sci**. Di ciascun corso si registra: un codice univoco, il livello (principiante, intermedio, avanzato), la data di inizio, la data di fine e il numero massimo di partecipanti. Ogni corso è tenuto da un solo maestro di sci; un maestro può tenere più corsi oppure nessuno. A ogni corso si iscrivono uno o più skipass (gli allievi sono identificati dal loro skipass); per ogni iscrizione si registra la data di iscrizione e l'eventuale voto finale.

Al termine di ogni giornata di apertura si registra, per ogni impianto, il numero totale di passaggi della giornata e il tempo di fermo impianto espresso in minuti.

> **1.1** Progettare lo **schema concettuale** della base di dati utilizzando il modello Entità-Relazione. Non aggiungere attributi non esplicitamente indicati nel testo. **ATTENZIONE**: specificare sempre i vincoli di cardinalità, gli identificatori (interni ed esterni) e le generalizzazioni con la loro classificazione.
>
> **1.2** Tradurre lo schema concettuale nello **schema logico relazionale**, indicando esplicitamente per ogni relazione: la chiave primaria (sottolineata), gli attributi che possono contenere valori nulli (contrassegnati con `*`) e i vincoli di integrità referenziale. Motivare la strategia adottata per la traduzione della generalizzazione.

### 2. Progettazione logica verso un sistema document-based **(6)**

Si consideri la porzione dello schema concettuale dell'esercizio 1 costituita dalle entità **CORSO**, **SKIPASS** e **MAESTRO** e dalle relazioni **ISCRIZIONE** (fra `SKIPASS` e `CORSO`) e **TIENE** (fra `MAESTRO` e `CORSO`).

Si progetti la corrispondente rappresentazione in un sistema **document-based**:

> **2.1** Etichettare lo schema ER indicando l'entità principale e le frecce di incapsulamento.
> **2.2** Indicare quali **collezioni** vengono create e, per ciascuna, riportare un documento **JSON** di esempio completo.
> **2.3** Motivare per ogni associazione la scelta fra incapsulamento e riferimento.

### 3. Algebra relazionale **(9)**

Dato il seguente schema relazionale (chiavi primarie sottolineate, `*` indica attributi che possono essere nulli):

```
IMPIANTO(Codice, NomeImp, Tipologia, Versante, PortataOraria)
SKIPASS(NumeroSeriale, TipoPass, DataEmissione, Prezzo, Cognome, Comune, Provincia)
PASSAGGIO(Skipass, Impianto, Data, Ora)
MAESTRO(Matricola, Nome, Cognome, LivelloAbil)
CORSO(CodCorso, Livello, DataInizio, Maestro)
ISCRIZIONE(Skipass, Corso, DataIscrizione, Voto*)
```

Vincoli d'integrità referenziale:
`PASSAGGIO.Skipass → SKIPASS`, `PASSAGGIO.Impianto → IMPIANTO`,
`CORSO.Maestro → MAESTRO`, `ISCRIZIONE.Skipass → SKIPASS`, `ISCRIZIONE.Corso → CORSO`

Formulare in **algebra relazionale ottimizzata** le seguenti interrogazioni:

**3.a (3)** Trovare gli skipass di tipo `'stagionale'` intestati a persone residenti in provincia di `'Trento'` che il giorno `15/01/2026` sono passati alla cabinovia di nome `'Pra Alpesina'`, riportando il numero seriale, il cognome dell'intestatario e l'ora del passaggio.

**3.b (3)** Trovare gli impianti del versante `'Nord'` ai quali nel mese di febbraio 2026 non è mai passato nessuno skipass di tipo `'giornaliero'`, riportando il codice e il nome dell'impianto.

**3.c (3)** Trovare il cognome degli intestatari degli skipass che si sono iscritti ad **almeno due corsi diversi** di livello `'avanzato'`.

### 4. Interrogazioni su sistemi document-based e calcolo relazionale **(5)**

**4.a (3)** Si supponga che le informazioni sui corsi siano memorizzate in una collezione `corsi` di documenti con la seguente struttura:

```json
{
  "_id": "C104",
  "livello": "avanzato",
  "dataInizio": "2026-01-12",
  "maestro": { "matricola": "M77", "nome": "Elena", "cognome": "Rossi" },
  "iscritti": [ { "skipass": "SP00912", "voto": 28 }, { "skipass": "SP01455", "voto": null } ]
}
```

Formulare in **MongoDB** le seguenti interrogazioni:
- **i.** trovare i corsi di livello `'avanzato'` iniziati dopo il `2026-01-01` che hanno almeno 8 iscritti, riportando soltanto il livello, la data di inizio e il cognome del maestro;
- **ii.** calcolare, per ogni maestro, il numero di corsi tenuti e il voto medio assegnato agli iscritti, ordinando il risultato per voto medio decrescente.

**4.b (2)** Esprimere in **calcolo relazionale sulle tuple con dichiarazioni di range** l'interrogazione 3.a.
