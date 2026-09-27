# Basi di Dati — Prova di Teoria

**Simulazione 3** · Matricola: ______________ · Cognome: ______________________ · Nome: ______________________

> *Avvertenze: è severamente vietato consultare libri e appunti.* **Durata: 2h15min**
> Punteggi: (a, b, c) 3 — (1) 12 — (2) 6 — (3.a, 3.b, 3.c) 3 — (4.a) 3 — (4.b) 2

---

## DOMANDE PRELIMINARI

> *È necessario rispondere in modo sufficiente alle seguenti tre domande per poter superare la prova con esito positivo; in caso di mancata o errata risposta a queste domande il resto del compito non verrà corretto.*

**a) (3)** Si illustri il costrutto di **cardinalità** del modello Entità-Relazione. Si distingua fra cardinalità di **relazione** e cardinalità di **attributo**; si elenchino i valori ammessi per la cardinalità minima e per quella massima indicando per ciascuno il significato, e si mostri con un esempio grafico come cambia la traduzione nel modello relazionale al variare della cardinalità massima di una relazione binaria.

**b) (3)** Dato il seguente schema concettuale nel modello ER, si produca la sua traduzione nel modello relazionale, indicando esplicitamente per ogni relazione: la chiave primaria, gli attributi che possono assumere valore nullo e i vincoli di integrità referenziale. Motivare la strategia scelta per la traduzione della generalizzazione.

```
                             ┌───┐
                             │ P │
                             └───┘
                            p1   p2
                               │
                             ──┴──   (t, e)   generalizzazione totale ed esclusiva
                            ╱     ╲
                       ┌───┐       ┌───┐
                       │P1 │       │P2 │
                       └───┘       └───┘
                         pa         pb  pc
                         │             │
                   (0,N) │             │ (1,1)
                       ╱─┴──╲        ╱─┴──╲
                       │  N  │       │  O  │
                       ╲─┬──╱        ╲─┬──╱
                    n1   │ (1,N)       │ (0,N)
                       ┌─┴─┐         ┌─┴─┐
                       │ M │         │ Q │
                       └───┘         └───┘
                      m1   m2          q1
```

Specifiche dello schema:

| Costrutto | Dettaglio |
|---|---|
| Entità `P` | attributi `p1`, `p2` — identificatore interno: `p1` |
| Generalizzazione | `P` è generalizzazione **totale ed esclusiva** di `P1` e `P2` |
| Entità `P1` | attributo specifico `pa` |
| Entità `P2` | attributi specifici `pb`, `pc` |
| Entità `M` | attributi `m1`, `m2` — identificatore interno: `m1` |
| Entità `Q` | attributo `q1` — identificatore interno: `q1` |
| Relazione `N` | fra `P1` (0,N) e `M` (1,N), con attributo `n1` |
| Relazione `O` | fra `P2` (1,1) e `Q` (0,N) |

**c) (3)** Si dia la **definizione formale** di superchiave e di chiave di una relazione e se ne illustri la differenza. Dato lo schema `R1(A, B, C*, D)` e `R2(D, E, F*, G)`:
- **c.1** si indichino due superchiavi **non minimali**, una per `R1` e una per `R2`;
- **c.2** si specifichi un vincolo di **integrità referenziale** dall'attributo `D` di `R1` verso `R2`, discutendo se la presenza di valori nulli su `C` e `F` influisca sulla validità del vincolo;
- **c.3** si spieghi come viene tradotto un **attributo multivalore** di un'entità (i) nel modello relazionale e (ii) in una collezione di documenti JSON, evidenziando la differenza fra le due soluzioni.

---

## ESERCIZI

### 1. Progettazione di una base di dati **(12)**

Si vuole progettare il sistema informativo del festival musicale **Verona Sound Festival**.

Il festival si svolge ogni anno in più **edizioni**, una per anno. Per ogni edizione si registra: l'anno (univoco), il tema, la data di inizio, la data di fine e il numero complessivo di biglietti messi in vendita.

Ogni edizione si svolge su uno o più **palchi**. Per ogni palco si registra: il nome, l'edizione di appartenenza (il nome è univoco solo all'interno di una edizione: è la coppia edizione–nome a identificare il palco), la capienza massima, il luogo e se il palco è al chiuso oppure all'aperto.

Il festival ospita degli **artisti**. Per ogni artista si registra: un codice univoco, il nome d'arte, il paese di provenienza e i generi musicali praticati (uno o più). Gli artisti si dividono in *solisti*, per i quali si registrano nome, cognome e data di nascita, e *gruppi*, per i quali si registrano l'anno di formazione e il numero di componenti. Ogni artista è o un solista o un gruppo, e non può essere entrambi.

Ogni artista può esibirsi in uno o più **concerti**. Per ogni concerto si registra: il palco, la data, l'ora di inizio, la durata prevista in minuti e il cachet pattuito. Un concerto è tenuto da un solo artista; lo stesso artista può tenere più concerti sullo stesso palco in giorni diversi e anche nello stesso giorno, purché con ora di inizio diversa.

Il festival vende **biglietti**. Per ogni biglietto si registra: un codice univoco, il tipo (giornaliero, abbonamento, VIP), la data di acquisto, il prezzo pagato e il canale di vendita (online, botteghino, rivendita autorizzata). Di ogni biglietto si registrano nome, cognome ed email dell'acquirente; per i soli biglietti di tipo VIP si registra anche il documento di identità e il numero di telefono.

All'ingresso di ogni concerto il biglietto viene validato: il sistema registra una **validazione** indicando il biglietto, il concerto, la data e l'ora della validazione. Lo stesso biglietto non può essere validato due volte per lo stesso concerto.

Il festival impiega **personale di servizio**. Per ogni membro del personale si registra: la matricola univoca, il nome, il cognome e la mansione. Ogni palco, in ogni giornata del festival, è affidato a uno o più membri del personale; per ogni assegnazione si registra il palco, il membro del personale, la data, l'ora di inizio e l'ora di fine del servizio.

Al termine di ogni giornata si registra, per ogni palco, il numero totale di validazioni della giornata e l'incasso complessivo.

> **1.1** Progettare lo **schema concettuale** della base di dati utilizzando il modello Entità-Relazione. Non aggiungere attributi non esplicitamente indicati nel testo. **ATTENZIONE**: specificare sempre i vincoli di cardinalità, gli identificatori (interni ed esterni) e le generalizzazioni con la loro classificazione.
>
> **1.2** Tradurre lo schema concettuale nello **schema logico relazionale**, indicando esplicitamente per ogni relazione: la chiave primaria (sottolineata), gli attributi che possono contenere valori nulli (contrassegnati con `*`) e i vincoli di integrità referenziale.

### 2. Progettazione logica verso un sistema document-based **(6)**

Si consideri la porzione dello schema concettuale dell'esercizio 1 costituita dalle entità **EDIZIONE**, **PALCO**, **CONCERTO** e **ARTISTA** (con la relativa generalizzazione in *solista* e *gruppo*) e dalle relazioni che le collegano.

> **2.1** Etichettare lo schema ER indicando l'entità principale e le frecce di incapsulamento.
> **2.2** Indicare quali **collezioni** vengono create e, per ciascuna, riportare un documento **JSON** di esempio completo.
> **2.3** Illustrare come viene trattata la **generalizzazione** degli artisti in un sistema document-based e in che cosa la soluzione differisce da quella adottata nel modello relazionale.

### 3. Algebra relazionale **(9)**

Dato il seguente schema relazionale (chiavi primarie sottolineate, `*` indica attributi che possono essere nulli):

```
EDIZIONE(Anno, Tema, DataInizio, DataFine)
PALCO(Anno, NomePalco, Capienza, Luogo, AlChiuso)
ARTISTA(CodArtista, NomeArte, Paese, TipoArt)
CONCERTO(CodConcerto, Anno, Palco, Artista, Data, OraInizio, Durata, Cachet)
BIGLIETTO(CodBiglietto, TipoBig, DataAcquisto, Prezzo, Canale, Cognome, Email)
VALIDAZIONE(Biglietto, Concerto, DataOra)
```

Vincoli d'integrità referenziale:
`PALCO.Anno → EDIZIONE`, `CONCERTO.(Anno, Palco) → PALCO`, `CONCERTO.Artista → ARTISTA`,
`VALIDAZIONE.Biglietto → BIGLIETTO`, `VALIDAZIONE.Concerto → CONCERTO`

Formulare in **algebra relazionale ottimizzata** le seguenti interrogazioni:

**3.a (3)** Trovare i concerti dell'edizione `2026` tenuti su palchi all'aperto da artisti provenienti dal `'Regno Unito'` con un cachet superiore a 50000 euro, riportando il nome d'arte dell'artista, il nome del palco, la data e l'ora di inizio.

**3.b (3)** Trovare gli artisti che nell'edizione `2026` non si sono mai esibiti su palchi al chiuso, riportando il codice e il nome d'arte.

**3.c (3)** Trovare il cognome e l'email degli acquirenti dei biglietti che sono stati validati per **almeno due concerti diversi** tenuti sullo **stesso** palco.

### 4. Interrogazioni su sistemi document-based e calcolo relazionale **(5)**

**4.a (3)** Si supponga che le informazioni sui concerti siano memorizzate in una collezione `concerti` di documenti con la seguente struttura:

```json
{
  "_id": "CN-2026-088",
  "edizione": 2026,
  "palco": { "nome": "Arena Grande", "capienza": 12000, "alChiuso": false },
  "data": "2026-07-18",
  "oraInizio": "21:30",
  "durata": 95,
  "cachet": 75000,
  "artista": {
    "codice": "A-317", "nomeArte": "Northern Lights", "paese": "Regno Unito",
    "tipo": "gruppo", "annoFormazione": 2011, "numComponenti": 4,
    "generi": ["rock", "post-punk"]
  }
}
```

Formulare in **MongoDB** le seguenti interrogazioni:
- **i.** trovare i concerti dell'edizione 2026 tenuti all'aperto da gruppi che praticano il genere `'rock'` con cachet superiore a 50000, riportando soltanto il nome d'arte, il nome del palco e la data;
- **ii.** calcolare, per ogni paese di provenienza, il numero di concerti e il cachet totale, considerando soltanto i paesi con almeno 5 concerti e ordinando per cachet totale decrescente.

**4.b (2)** Esprimere in **calcolo relazionale sulle tuple con dichiarazioni di range** l'interrogazione 3.a.
