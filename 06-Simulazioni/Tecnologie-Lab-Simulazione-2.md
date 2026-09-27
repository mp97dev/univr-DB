# Basi di Dati — Prova di Tecnologie e Laboratorio

**Simulazione 2** · Matricola: ______________ · Cognome: ______________________ · Nome: ______________________

> *Avvertenze: è severamente vietato consultare libri e appunti.*
> **Parte A — Tecnologie: 2h15min** · **Parte B — Laboratorio: 1h30min**

---

# PARTE A — TECNOLOGIE

## DOMANDE DI TEORIA

**a) (4)** Illustrare le **proprietà delle transazioni**, soffermandosi in particolare su **atomicità** e **persistenza**: si spieghi che cosa comporta ciascuna delle due, quale modulo del DBMS le garantisce e quali meccanismi vengono impiegati. Si dia inoltre la definizione di *transazione ben formata*.

**b) (3)** Illustrare il **gestore del buffer**: come è organizzato il buffer, quali primitive mette a disposizione (`fix`, `unfix`, `setDirty`, `force`, `flush`), su quali principi si basano le politiche di gestione della memoria e in che cosa consistono le politiche *steal / no-steal* e *force / no-force*.

**c) (4)** Illustrare i **tipi di guasto** che possono colpire una base di dati e le corrispondenti procedure di ripristino. Si spieghi in particolare la differenza fra **ripresa a caldo** e **ripresa a freddo**, indicando quando ciascuna viene applicata, quali strutture vengono utilizzate e quale modulo del DBMS le esegue. Si enuncino inoltre la regola **WAL** e la regola di **Commit-Precedenza**, spiegando quale proprietà ACID ciascuna garantisce.

**d) (3)** Illustrare il funzionamento di un **replica set** in MongoDB: ruolo del nodo primario e dei nodi secondari, funzione dell'**oplog**, meccanismo di **heartbeat** e algoritmo di **elezione** del nuovo primario. Si spieghi inoltre a cosa serve un nodo **arbitro**.

## ESERCIZI

**e) (4) Gestore dell'affidabilità**

Si supponga che si verifichi un **guasto di sistema** con perdita del contenuto della memoria centrale. Al momento del guasto il contenuto del file di LOG è il seguente:

```
B(T1), B(T2), U(T1,O1,B1,A1), U(T2,O2,B2,A2), B(T3), I(T3,O3,A3), CK(T1,T2,T3),
C(T2), B(T4), U(T4,O4,B4,A4), U(T1,O5,B5,A5), B(T5), D(T5,O6,B6), C(T1),
U(T4,O2,B7,A7), B(T6), I(T6,O7,A8), A(T3), U(T6,O8,B9,A9), C(T4), guasto
```

Illustrare che cosa accade al riavvio del sistema nell'esecuzione della procedura di **ripresa a caldo**, indicando esplicitamente: gli insiemi UNDO e REDO, il punto del log fino al quale ci si deve spingere all'indietro, e la sequenza completa delle azioni di disfacimento e di rifacimento.

**f) Esecuzione concorrente**

Dato il seguente schedule `S`:

```
S: r1(x), r2(y), w2(x), r1(y), w1(x), r3(z), w2(y), w3(z), w4(x), r4(y), w4(t), r3(x)
```

- **(2)** Indicare se `S` è **view-serializzabile (VSR)** oppure no (giustificare la risposta indicando, se esiste, uno schedule seriale view-equivalente).
- **(2)** Indicare se `S` è **conflict-serializzabile (CSR)** oppure no (giustificare la risposta disegnando il grafo dei conflitti).
- **(2)** Indicare se `S` è **2PL** (vale a dire, se rispetta la regola di serializzabilità del locking a due fasi).

**g) Ottimizzazione**

Si consideri il seguente schema relazionale che descrive i prestiti di una biblioteca:

```
LETTORE(Tessera, Nome, Cognome, Email, Comune, Provincia)
PRESTITO(CodPrestito, Tessera, Copia, DataInizio, DataScadenza, DataRestituzione)
COPIA(CodCopia, ISBN, Collocazione, Stato)
```
Vincoli d'integrità referenziale: `PRESTITO.Tessera → LETTORE`, `PRESTITO.Copia → COPIA`

Data la seguente interrogazione, che trova i prestiti effettuati dai lettori della provincia di Verona:

```sql
SELECT L.Tessera, L.Cognome, P.Copia, P.DataInizio
FROM LETTORE L JOIN PRESTITO P ON (L.Tessera = P.Tessera)
WHERE L.Provincia = 'Verona'
```

- **(3)** Calcolare il costo dell'interrogazione in termini di **numero di accessi a memoria secondaria** sotto le seguenti ipotesi:
  - la selezione dei lettori con `Provincia = 'Verona'` richiede una scansione sequenziale della tabella `LETTORE` e il risultato viene **salvato in 25 pagine** della memoria secondaria: `NP(LETTORE con Provincia='Verona') = 25`;
  - l'ordine di esecuzione del join è `LETTORE ⋈ PRESTITO`;
  - le operazioni di join vengono eseguite con la tecnica **"Nested Loop Join"** con una pagina di buffer disponibile per ogni tabella;
  - `NP(COPIA) = 90`, `NP(PRESTITO) = 1800`, `NP(LETTORE) = 220`
  - `NR(COPIA) = 10800`, `NR(PRESTITO) = 264000`, `NR(LETTORE) = 26400`
  - `VAL(Provincia, LETTORE) = 12`, `VAL(Tessera, PRESTITO) = 26400`
- **(2)** Come cambia il costo della query considerando la presenza di un **indice B+-tree di profondità 2** sull'attributo `Tessera` della tabella `PRESTITO`?

**h) B+-tree (5)**

Data la seguente lista di possibili valori chiave `L = (A, B, C, D, E, F, G, H, I, L, M, N, O, P, Q, R, S, T, U, V, Z)`:

- **a) (1)** costruire un B+-tree con **fan-out = 4** che contenga i seguenti nodi foglia, indicando i vincoli di riempimento adottati:

```
(A, C)     (F, G, H)     (L, M)     (P, Q)
```

- **b) (2)** mostrare l'albero dopo l'**inserimento** del valore chiave `I`;
- **c) (2)** partendo dal risultato del punto precedente, mostrare l'albero dopo la **rimozione** del valore chiave `Q`.

---

# PARTE B — LABORATORIO

**i) (3)** Si consideri la seguente dichiarazione in PostgreSQL:

```sql
CREATE TABLE Copia (
  cod_copia     CHAR(12),
  isbn          CHAR(13),
  collocazione  VARCHAR(24),
  stato         VARCHAR(20)
);

CREATE TABLE Prestito (
  cod_prestito       CHAR(14),
  tessera            CHAR(10),
  copia              CHAR(12),
  data_inizio        DATE,
  data_scadenza      DATE,
  data_restituzione  DATE,
  rinnovi            INTEGER
);
```

Si completi la dichiarazione (anche direttamente sopra su questo foglio) in modo che permetta di rappresentare:

- **(i)** il vincolo di chiave primaria sull'attributo `cod_copia` di `Copia` e sull'attributo `cod_prestito` di `Prestito`;
- **(ii)** un vincolo di integrità referenziale da `Prestito.copia` a `Copia.cod_copia` e da `Prestito.tessera` a `Lettore.tessera`;
- **(iii)** una superchiave composta dagli attributi `isbn` e `collocazione` della tabella `Copia`;
- **(iv)** l'obbligatorietà degli attributi `isbn` e `stato` di `Copia`, e degli attributi `tessera`, `copia` e `data_inizio` di `Prestito`;
- **(v)** un vincolo di dominio per l'attributo `stato` di `Copia`, che può assumere solo i seguenti valori: `{'disponibile', 'in prestito', 'in restauro', 'smarrita'}`;
- **(vi)** un vincolo su `data_inizio < data_scadenza` e un vincolo che imponga, quando la restituzione è avvenuta, `data_restituzione >= data_inizio`;
- **(vii)** un valore di default per `rinnovi` pari a `0` e un vincolo che limiti i rinnovi a un massimo di 2;
- **(viii)** un vincolo che impedisca la cancellazione di una copia se esistono prestiti che la riguardano.

**j) Query SQL**

Dato il seguente schema relazionale:

```
LETTORE( tessera, nome, cognome, email, comune, provincia, data_iscrizione )
LIBRO( isbn, titolo, autore, editore, anno, genere )
COPIA( cod_copia, isbn, collocazione, stato )
PRESTITO( cod_prestito, tessera, copia, data_inizio, data_scadenza, data_restituzione, rinnovi )
```

Chiavi primarie sottolineate e vincoli di integrità:
`COPIA.isbn → LIBRO`, `PRESTITO.tessera → LETTORE`, `PRESTITO.copia → COPIA`

Formulare in SQL le seguenti interrogazioni:

- **i. [5]** Trovare i lettori che hanno preso in prestito più libri di genere `'Giallo'` che libri di genere `'Saggistica'`. Per ciascun lettore riportare la tessera, il nome e il cognome.
- **ii. [4]** Trovare, per ogni genere, il numero di prestiti effettuati nel 2025 e il numero di lettori distinti che li hanno effettuati, considerando soltanto i generi con almeno 100 prestiti nel 2025.
- **iii. [5]** Trovare i libri di cui la biblioteca possiede almeno 3 copie e che non sono mai stati restituiti in ritardo (cioè per i quali non esiste alcun prestito con `data_restituzione > data_scadenza`). Per ciascun libro riportare l'ISBN e il titolo.
- **iv. [3]** Trovare tutti i prestiti non ancora restituiti la cui data di scadenza è antecedente al 1 gennaio 2026. Indicare che tipo di indici è possibile costruire per ottimizzare l'interrogazione, giustificando la risposta.

**k) Query MongoDB [3]**

Si supponga che le informazioni relative ai libri siano memorizzate in una collezione `libri` di documenti JSON con la seguente struttura:

```json
{ "_id": "9788817034...", "titolo": "...", "autore": "...", "editore": "...",
  "anno": 0, "generi": ["...", "..."],
  "copie": [ { "codCopia": "...", "collocazione": "...", "stato": "..." } ] }
```

- **i.** Formulare una query per trovare tutti i libri pubblicati dopo il 2010 che appartengono al genere `'Giallo'` e che hanno almeno una copia nello stato `'disponibile'`, riportando soltanto il titolo e l'autore.
- **ii.** Formulare una query per calcolare, per ogni editore, il numero totale di copie possedute dalla biblioteca, ordinando il risultato per numero di copie decrescente e riportando solo i primi 10 editori.

**l) Transazioni [6]**

Descrivere la differenza fra l'anomalia di **lettura inconsistente** e l'anomalia di **inserimento fantasma**, anche attraverso l'utilizzo di esempi di transazioni SQL che possono produrre ciascuna anomalia. Indicare il livello di isolamento minimo che deve essere utilizzato per evitare ciascun tipo di anomalia e spiegare perché il solo locking sui record non è sufficiente per il secondo caso.

**m) Python [4]**

Si consideri una base di dati in PostgreSQL contenente la tabella

```
PRESTITO( cod_prestito, tessera, copia, data_inizio, data_scadenza, data_restituzione, rinnovi )
```

Scrivere il codice di un programma Python che richieda all'utente di inserire il numero di tessera di un lettore e restituisca l'elenco dei prestiti ancora aperti (cioè con `data_restituzione` non valorizzata) di quel lettore, ordinati per data di scadenza crescente, segnalando con la dicitura `"SCADUTO"` i prestiti la cui data di scadenza è già passata. Se il lettore non ha prestiti aperti, verrà riportato il messaggio `"Nessun prestito aperto per la tessera X"`, dove `X` va sostituito con la tessera inserita dall'utente.
