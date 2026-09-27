# Basi di Dati — Prova di Teoria

**Simulazione 2** · Matricola: ______________ · Cognome: ______________________ · Nome: ______________________

> *Avvertenze: è severamente vietato consultare libri e appunti.* **Durata: 2h15min**
> Punteggi: (a, b, c) 3 — (1) 12 — (2) 6 — (3.a, 3.b, 3.c) 3 — (4.a) 3 — (4.b) 2

---

## DOMANDE PRELIMINARI

> *È necessario rispondere in modo sufficiente alle seguenti tre domande per poter superare la prova con esito positivo; in caso di mancata o errata risposta a queste domande il resto del compito non verrà corretto.*

**a) (3)** Si illustri il costrutto di **generalizzazione** del modello Entità-Relazione: definizione, proprietà delle istanze, rappresentazione grafica e classificazione (totale/parziale, esclusiva/sovrapposta). Si fornisca un esempio per ciascuna delle quattro combinazioni della classificazione.

**b) (3)** Dato il seguente schema concettuale nel modello ER, si produca la sua traduzione nel modello relazionale, indicando esplicitamente per ogni relazione: la chiave primaria, gli attributi che possono assumere valore nullo e i vincoli di integrità referenziale.

```
        ┌───┐                                        ┌───┐
        │ E │                                        │ F │
        └───┘                                        └───┘
       e1  e2                                       f1  f2
         │  (0,N)                            (0,N)   │
         └──────────────┐              ┌─────────────┘
                        │              │
                      ╱─┴──────────────┴─╲
                      │        T          │        (relazione ternaria)
                      ╲────────┬──────────╱
                               │ (1,1)
                             ┌─┴─┐
                             │ G │
                             └───┘
                               g1

                                              "padre" (0,N)
        ┌───┐        (1,N)   ╱────╲   (1,1)   ┌───┐──────────┐
        │ E │────────────────│  V  │──────────│ H │        ╱─┴──╲
        └───┘                ╲────╱           └───┘        │  W  │  (ricorsiva)
                                │            h1  h2        ╲─┬──╱
                                v1                           │
                                              "figlio" (0,1) └┘
```

Specifiche dello schema:

| Costrutto | Dettaglio |
|---|---|
| Entità `E` | attributi `e1`, `e2` — identificatore interno: `e1` |
| Entità `F` | attributi `f1`, `f2` — identificatore interno **composto**: (`f1`, `f2`) |
| Entità `G` | attributo `g1` — identificatore interno: `g1` |
| Entità `H` | attributi `h1`, `h2` — identificatore interno: `h1`; `h2` è **opzionale** |
| Relazione `T` | **ternaria** fra `E` (0,N), `F` (0,N) e `G` (1,1) |
| Relazione `V` | fra `E` (1,N) e `H` (1,1), con attributo `v1` |
| Relazione `W` | **ricorsiva** su `H`, ruoli `padre` (0,N) e `figlio` (0,1) |

**c) (3)** Si illustri la struttura di un **documento JSON**: tipi di valore ammessi, array, documenti annidati, ruolo del campo `_id`. Si spieghi inoltre in che cosa una **collezione** di un sistema document-based differisce da una **tabella** del modello relazionale, con particolare riferimento allo schema dei dati e all'omogeneità delle istanze.

---

## ESERCIZI

### 1. Progettazione di una base di dati **(12)**

Si vuole progettare il sistema informativo della società **VoltaVerde**, che gestisce una rete di stazioni di ricarica per veicoli elettrici.

La società gestisce un insieme di **stazioni di ricarica**. Per ogni stazione si registra: un codice univoco, l'indirizzo, il comune, la provincia, le coordinate geografiche (latitudine e longitudine), la data di attivazione e se la stazione è coperta oppure no.

Ogni stazione dispone di una o più **colonnine**. Per ogni colonnina si registra: il numero progressivo all'interno della stazione (il numero da solo non è univoco: è la coppia stazione–numero a identificare una colonnina), la potenza massima erogabile in kW, il tipo di connettore (Type2, CCS, CHAdeMO) e lo stato attuale (libera, occupata, guasta).

Gli utenti del servizio si registrano al portale. Per ogni **utente** si memorizza: il codice fiscale, il nome, il cognome, la data di nascita, l'indirizzo email e uno o più numeri di telefono. Gli utenti si distinguono in *utenti privati*, per i quali si registra la data di iscrizione, e *utenti aziendali*, per i quali si registra la ragione sociale e la partita IVA dell'azienda. Un utente appartiene a una sola delle due categorie e non può appartenere a nessuna delle due se è un utente non ancora verificato.

Ogni utente può registrare uno o più **veicoli**. Per ogni veicolo si registra: la targa (univoca), il costruttore, il modello, la capacità della batteria in kWh e il tipo di connettore supportato. Un veicolo appartiene a un solo utente.

Quando un veicolo si collega a una colonnina inizia una **sessione di ricarica**. Per ogni sessione si registra: il veicolo, la colonnina, la data e l'ora di inizio, la data e l'ora di fine, l'energia erogata in kWh e l'importo addebitato. Uno stesso veicolo può eseguire più sessioni sulla stessa colonnina in giorni diversi e anche nello stesso giorno, purché con ora di inizio diversa.

Ogni sessione viene addebitata secondo una **tariffa**. Di ogni tariffa si registra: un codice univoco, il nome commerciale, il prezzo al kWh, l'eventuale quota fissa di attivazione e il periodo di validità (data di inizio e data di fine). Una sessione è associata a esattamente una tariffa; una tariffa può essere applicata a molte sessioni.

La società registra inoltre gli **interventi di manutenzione** sulle colonnine, indicando: la data e l'ora dell'intervento, la colonnina interessata, il tipo di intervento (ordinaria, straordinaria, riparazione), la ditta che lo ha eseguito e i codici fiscali dei tecnici che vi hanno partecipato (uno o più).

Al termine di ogni mese si registra, per ogni stazione, l'energia totale erogata nel mese e il numero complessivo di sessioni.

> **1.1** Progettare lo **schema concettuale** della base di dati utilizzando il modello Entità-Relazione. Non aggiungere attributi non esplicitamente indicati nel testo. **ATTENZIONE**: specificare sempre i vincoli di cardinalità, gli identificatori (interni ed esterni) e le generalizzazioni con la loro classificazione.
>
> **1.2** Tradurre lo schema concettuale nello **schema logico relazionale**, indicando esplicitamente per ogni relazione: la chiave primaria (sottolineata), gli attributi che possono contenere valori nulli (contrassegnati con `*`) e i vincoli di integrità referenziale. Motivare la strategia adottata per la traduzione della generalizzazione.

### 2. Progettazione logica verso un sistema document-based **(6)**

Si consideri la porzione dello schema concettuale dell'esercizio 1 costituita dalle entità **STAZIONE**, **COLONNINA**, **SESSIONE** e **VEICOLO** e dalle relazioni che le collegano.

> **2.1** Etichettare lo schema ER indicando l'entità principale e le frecce di incapsulamento.
> **2.2** Indicare quali **collezioni** vengono create e, per ciascuna, riportare un documento **JSON** di esempio completo.
> **2.3** Discutere in particolare la scelta relativa all'associazione fra `COLONNINA` e `SESSIONE`: si valuti l'impatto sul documento del fatto che una colonnina accumula decine di migliaia di sessioni all'anno.

### 3. Algebra relazionale **(9)**

Dato il seguente schema relazionale (chiavi primarie sottolineate, `*` indica attributi che possono essere nulli):

```
STAZIONE(CodStazione, Indirizzo, Comune, Provincia, Coperta)
COLONNINA(Stazione, Numero, PotenzaMax, Connettore, Stato)
UTENTE(CodFiscale, Nome, Cognome, Email, Categoria)
VEICOLO(Targa, Utente, Costruttore, Modello, CapacitaBatteria, Connettore)
TARIFFA(CodTariffa, NomeTar, PrezzoKWh, QuotaFissa*)
SESSIONE(Veicolo, Stazione, Colonnina, DataOraInizio, DataOraFine*, EnergiaKWh, Importo, Tariffa)
```

Vincoli d'integrità referenziale:
`COLONNINA.Stazione → STAZIONE`, `VEICOLO.Utente → UTENTE`,
`SESSIONE.Veicolo → VEICOLO`, `SESSIONE.(Stazione, Colonnina) → COLONNINA`, `SESSIONE.Tariffa → TARIFFA`

Formulare in **algebra relazionale ottimizzata** le seguenti interrogazioni:

**3.a (3)** Trovare le sessioni di ricarica eseguite il giorno `10/03/2026` presso stazioni coperte del comune di `'Verona'` da veicoli di costruttore `'Tesla'`, riportando la targa del veicolo, il numero della colonnina, l'energia erogata e l'importo.

**3.b (3)** Trovare gli utenti che non hanno mai eseguito una sessione di ricarica presso una stazione della provincia di `'Trento'`, riportando il codice fiscale, il nome e il cognome.

**3.c (3)** Trovare le targhe dei veicoli che hanno eseguito **almeno due sessioni distinte** su **colonnine diverse** della **stessa** stazione.

### 4. Interrogazioni su sistemi document-based e calcolo relazionale **(5)**

**4.a (3)** Si supponga che le informazioni sulle stazioni siano memorizzate in una collezione `stazioni` di documenti con la seguente struttura:

```json
{
  "_id": "ST-0142",
  "indirizzo": "Via Cà di Cozzi 12",
  "comune": "Verona",
  "provincia": "VR",
  "coperta": true,
  "colonnine": [
    { "numero": 1, "potenzaMax": 22,  "connettore": "Type2", "stato": "libera" },
    { "numero": 2, "potenzaMax": 150, "connettore": "CCS",   "stato": "guasta" }
  ]
}
```

Formulare in **MongoDB** le seguenti interrogazioni:
- **i.** trovare le stazioni coperte del comune di `'Verona'` che possiedono almeno una colonnina con connettore `'CCS'` e potenza massima superiore a 100 kW, riportando soltanto l'indirizzo e l'array delle colonnine;
- **ii.** calcolare, per ogni provincia, il numero totale di colonnine guaste e la potenza massima presente in provincia, ordinando per numero di colonnine guaste decrescente.

**4.b (2)** Esprimere in **calcolo relazionale sulle tuple con dichiarazioni di range** l'interrogazione 3.b.
