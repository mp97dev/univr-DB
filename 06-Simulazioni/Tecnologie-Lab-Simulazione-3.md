# Basi di Dati — Prova di Tecnologie e Laboratorio

**Simulazione 3** · Matricola: ______________ · Cognome: ______________________ · Nome: ______________________

> *Avvertenze: è severamente vietato consultare libri e appunti.*
> **Parte A — Tecnologie: 2h15min** · **Parte B — Laboratorio: 1h30min**

---

# PARTE A — TECNOLOGIE

## DOMANDE DI TEORIA

**a) (4)** Illustrare le **proprietà delle transazioni**; si indichi quali moduli di un DBMS garantiscono ciascuna di tali proprietà. Si spieghi inoltre che cosa si intende per verifica **immediata** e verifica **differita** dei vincoli di integrità e a quale proprietà tale distinzione si riferisce.

**b) (4)** Illustrare la struttura di accesso ai dati denominata **indice secondario**. Si descrivano in particolare: (i) le caratteristiche della struttura, (ii) l'algoritmo di ricerca di una tupla con chiave `K`, (iii) la differenza rispetto a un **indice primario (clustered)** in termini di costo di accesso, e (iv) in quali casi l'ottimizzatore preferisce una scansione sequenziale all'uso dell'indice.

**c) (4)** Illustrare come MongoDB garantisce (o non garantisce) le **proprietà ACID**. Si discuta in particolare: l'atomicità a livello di singolo documento, le transazioni multi-documento, il ruolo del **write concern** e del **read concern**, e il compromesso fra consistenza, disponibilità e prestazioni introdotto dalla **read preference**.

## ESERCIZI

**d) (4) Gestore dell'affidabilità**

Si supponga che si verifichi un **guasto di dispositivo** con perdita del contenuto della memoria secondaria. Al momento del guasto il contenuto del file di LOG è il seguente:

```
DUMP, B(T1), B(T2), U(T1,O1,B1,A1), I(T2,O2,A2), C(T1), B(T3), U(T3,O3,B3,A3),
CK(T2,T3), U(T2,O4,B4,A4), C(T2), B(T4), U(T4,O5,B5,A5), U(T3,O1,B6,A6), C(T3),
B(T5), I(T5,O6,A7), guasto
```

Illustrare che cosa accade nell'esecuzione della procedura di **ripresa a freddo**, descrivendo in ordine tutte le fasi della procedura e indicando esplicitamente, per la fase finale di ripresa a caldo: gli insiemi UNDO e REDO, il punto del log fino al quale ci si deve spingere all'indietro, e la sequenza completa delle azioni di disfacimento e di rifacimento.

**e) Esecuzione concorrente**

Dato il seguente schedule `S`:

```
S: r1(x), r2(z), w1(x), r1(y), w1(y), w2(z), r2(y), r3(t), w2(y), w3(t), r3(x), w3(z)
```

- **(2)** Indicare se `S` è **view-serializzabile (VSR)** oppure no (giustificare la risposta).
- **(2)** Indicare se `S` è **conflict-serializzabile (CSR)** oppure no (giustificare la risposta disegnando il grafo dei conflitti e indicando lo schedule seriale equivalente).
- **(2)** Indicare se `S` è **2PL** (vale a dire, se rispetta la regola di serializzabilità del locking a due fasi). In caso affermativo, esibire un piano di locking valido.

**f) Ottimizzazione**

Si consideri il seguente schema relazionale che descrive gli accessi a una palestra:

```
SOCIO(CodSocio, Nome, Cognome, DataNascita, Citta, Provincia, Abbonamento)
INGRESSO(CodIngresso, Socio, Data, OraEntrata, OraUscita, Tornello)
CORSO(CodCorso, NomeCorso, Istruttore, Sala)
```
Vincoli d'integrità referenziale: `INGRESSO.Socio → SOCIO`

Data la seguente interrogazione:

```sql
SELECT S.CodSocio, S.Cognome, I.Data, I.OraEntrata
FROM SOCIO S JOIN INGRESSO I ON (S.CodSocio = I.Socio)
WHERE S.Citta = 'Verona' AND I.Data > '01/09/2025'
```

- **(3)** Calcolare il costo dell'interrogazione in termini di **numero di accessi a memoria secondaria** sotto le seguenti ipotesi:
  - la selezione dei soci viene eseguita attraverso una scansione della tabella `SOCIO`; il risultato della selezione viene mantenuto nel buffer;
  - la selezione degli ingressi viene eseguita con una scansione sequenziale della tabella `INGRESSO`; il risultato viene salvato in **640 pagine** della memoria secondaria (76800 righe);
  - l'ordine di esecuzione del join è `SOCIO ⋈ INGRESSO` e le operazioni di join vengono eseguite con la tecnica **"Nested Loop Join"** con una pagina di buffer disponibile per ogni tabella;
  - `NP(CORSO) = 5`, `NP(INGRESSO) = 2000`, `NP(SOCIO) = 150`
  - `NR(CORSO) = 400`, `NR(INGRESSO) = 240000`, `NR(SOCIO) = 12000`
  - `VAL(Citta, SOCIO) = 25`, `VAL(Socio, INGRESSO) = 12000`
- **(2)** Come cambia il costo della query considerando la presenza di un **indice B+-tree di profondità 3** sull'attributo `Socio` della tabella `INGRESSO`?

**g) B+-tree (5)**

Data la seguente lista di possibili valori chiave `L = (A, B, C, D, E, F, G, H, I, L, M, N, O, P, Q, R, S, T, U, V, W, Z)`:

- **a) (1)** costruire un B+-tree con **fan-out = 5** che contenga i seguenti nodi foglia, indicando i vincoli di riempimento adottati:

```
(A, B, D)     (F, G)     (K, L, M, N)     (P, R, S)     (T, W, Z)
```

> *Nota: per questo esercizio si consideri l'alfabeto esteso con la lettera K fra I e L.*

- **b) (2)** mostrare l'albero dopo l'**inserimento** del valore chiave `O`;
- **c) (2)** partendo dal risultato del punto precedente, mostrare l'albero dopo la **rimozione** del valore chiave `G`.

---

# PARTE B — LABORATORIO

**h) (3)** Si consideri la seguente dichiarazione in PostgreSQL:

```sql
CREATE TABLE Corso (
  cod_corso        CHAR(8),
  nome_corso       VARCHAR(48),
  istruttore       CHAR(10),
  sala             VARCHAR(24),
  giorno_settimana VARCHAR(12),
  ora_inizio       TIME,
  durata           INTEGER,
  max_posti        INTEGER
);

CREATE TABLE Partecipazione (
  socio     CHAR(10),
  corso     CHAR(8),
  data      DATE,
  presente  BOOLEAN
);
```

Si completi la dichiarazione (anche direttamente sopra su questo foglio) in modo che permetta di rappresentare:

- **(i)** il vincolo di chiave primaria sull'attributo `cod_corso` di `Corso` e la chiave primaria **composta** dagli attributi `socio`, `corso` e `data` di `Partecipazione`;
- **(ii)** un vincolo di integrità referenziale da `Partecipazione.socio` a `Socio.cod_socio` e da `Partecipazione.corso` a `Corso.cod_corso`, tale che la cancellazione di un corso comporti la cancellazione delle relative partecipazioni;
- **(iii)** una superchiave composta dagli attributi `sala`, `giorno_settimana` e `ora_inizio` della tabella `Corso`;
- **(iv)** l'obbligatorietà degli attributi `nome_corso`, `istruttore` e `max_posti` di `Corso`;
- **(v)** un vincolo di dominio per l'attributo `giorno_settimana`, che può assumere solo i valori `{'lunedi', 'martedi', 'mercoledi', 'giovedi', 'venerdi', 'sabato', 'domenica'}`;
- **(vi)** un vincolo su `durata` compresa fra 30 e 120 minuti e un vincolo su `max_posti > 0`;
- **(vii)** un valore di default per `presente` pari a `FALSE` e per `durata` pari a `60`.

**i) Query SQL**

Dato il seguente schema relazionale:

```
SOCIO( cod_socio, nome, cognome, data_nascita, citta, provincia, data_iscrizione, abbonamento )
INGRESSO( cod_ingresso, socio, data, ora_entrata, ora_uscita, tornello )
ISTRUTTORE( cod_istruttore, nome, cognome, specialita )
CORSO( cod_corso, nome_corso, istruttore, sala, giorno_settimana, ora_inizio, durata, max_posti )
PARTECIPAZIONE( socio, corso, data, presente )
```

Chiavi primarie sottolineate e vincoli di integrità:
`INGRESSO.socio → SOCIO`, `CORSO.istruttore → ISTRUTTORE`,
`PARTECIPAZIONE.socio → SOCIO`, `PARTECIPAZIONE.corso → CORSO`

Formulare in SQL le seguenti interrogazioni:

- **i. [5]** Trovare i soci che hanno effettuato più ingressi nel fine settimana (sabato e domenica) che nei giorni feriali. Per ciascun socio riportare il codice, il nome e il cognome.
- **ii. [4]** Trovare, per ogni istruttore, il numero di corsi tenuti e il numero medio di partecipanti effettivamente presenti per corso, considerando soltanto gli istruttori che tengono almeno 3 corsi.
- **iii. [5]** Trovare quanti soci della città di `'Verona'` hanno effettuato nel 2025 un numero di ingressi superiore al numero medio di ingressi del 2025 dei soci della città di `'Padova'`.
- **iv. [3]** Trovare tutti gli ingressi registrati dal tornello `'T1'` in data `'2026-03-10'`. Indicare che tipo di indici è possibile costruire per ottimizzare l'interrogazione, giustificando la risposta.

**j) Query MongoDB [3]**

Si supponga che le informazioni relative ai corsi siano memorizzate in una collezione `corsi` di documenti JSON con la seguente struttura:

```json
{ "_id": "CR-014", "nome": "...", "sala": "...", "giornoSettimana": "...",
  "oraInizio": "...", "durata": 0, "maxPosti": 0,
  "istruttore": { "codice": "...", "nome": "...", "cognome": "...", "specialita": "..." },
  "iscritti": [ { "socio": "...", "dataIscrizione": "...", "presenze": 0 } ] }
```

- **i.** Formulare una query per trovare tutti i corsi che si svolgono il `'lunedi'` nella sala `'Sala A'` con durata non superiore a 60 minuti, riportando soltanto il nome del corso, l'ora di inizio e il cognome dell'istruttore.
- **ii.** Formulare una query per calcolare, per ogni specialità di istruttore, il numero totale di iscritti e il numero medio di presenze per iscritto, ordinando il risultato per numero di iscritti decrescente.

**k) Transazioni [6]**

Descrivere la differenza fra l'anomalia di **aggiornamento fantasma** e l'anomalia di **lettura sporca**, anche attraverso l'utilizzo di esempi di transazioni SQL che possono produrre ciascuna anomalia. Indicare il livello di isolamento minimo che deve essere utilizzato per evitare ciascun tipo di anomalia e spiegare quale delle due può manifestarsi anche in assenza di rollback.

**l) Python [4]**

Si consideri una base di dati in PostgreSQL contenente le tabelle

```
SOCIO( cod_socio, nome, cognome, data_nascita, citta, provincia, data_iscrizione, abbonamento )
INGRESSO( cod_ingresso, socio, data, ora_entrata, ora_uscita, tornello )
```

Scrivere il codice di un programma Python che richieda all'utente di inserire una data e restituisca l'elenco dei soci che sono entrati in palestra in quella data ma per i quali non risulta registrata l'ora di uscita, riportando per ciascuno il codice, il cognome e l'ora di entrata, ordinati per ora di entrata crescente. Se non esistono soci in questa situazione, verrà riportato il messaggio `"Nessuna uscita mancante in data X"`, dove `X` va sostituito con la data inserita dall'utente.
