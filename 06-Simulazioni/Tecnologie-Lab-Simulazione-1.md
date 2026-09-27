# Basi di Dati — Prova di Tecnologie e Laboratorio

**Simulazione 1** · Matricola: ______________ · Cognome: ______________________ · Nome: ______________________

> *Avvertenze: è severamente vietato consultare libri e appunti.*
> **Parte A — Tecnologie: 2h15min** · **Parte B — Laboratorio: 1h30min**

---

# PARTE A — TECNOLOGIE

## DOMANDE DI TEORIA

**a) (4)** Illustrare le **proprietà delle transazioni**; si indichi per ciascuna proprietà quale modulo di un DBMS ne garantisce il rispetto e attraverso quale meccanismo.

**b) (4)** Illustrare la **struttura ad accesso calcolato (hash)**: in particolare si descriva il funzionamento dell'operazione di inserimento e di ricerca di una tupla di chiave `K`, si spieghi che cosa sono le **collisioni** e come vengono gestite, e si evidenzino i casi in cui questa struttura è più vantaggiosa di un B+-tree e quelli in cui è invece inadeguata.

**c) (4)** Illustrare dettagliatamente il concetto di **sharding** in MongoDB: a cosa serve e perché si utilizza, come viene implementato, quali sono i componenti che lo gestiscono e quale ruolo svolge la **shard key** nella distribuzione dei dati.

## ESERCIZI

**d) (4) Gestore dell'affidabilità**

Si supponga che si verifichi un **guasto di sistema** con perdita del contenuto della memoria centrale. Al momento del guasto il contenuto del file di LOG è il seguente:

```
B(T1), B(T2), U(T1,O1,B1,A1), B(T3), I(T2,O2,A2), U(T3,O3,B3,A3), C(T1), CK(T2,T3),
B(T4), U(T4,O4,B4,A4), D(T2,O5,B5), C(T2), B(T5), U(T5,O6,B6,A6), U(T3,O1,B7,A7),
A(T4), I(T5,O7,A8), C(T3), U(T5,O8,B9,A9), guasto
```

Illustrare che cosa accade al riavvio del sistema nell'esecuzione della procedura di **ripresa a caldo**, indicando esplicitamente: gli insiemi UNDO e REDO, il punto del log fino al quale ci si deve spingere all'indietro, e la sequenza completa delle azioni di disfacimento e di rifacimento.

**e) Esecuzione concorrente**

Dato il seguente schedule `S`:

```
S: r3(y), r1(x), w1(x), r2(x), w3(y), w1(y), w2(z), r4(z), r4(y), w3(t), r1(t), w2(t)
```

- **(2)** Indicare se `S` è **view-serializzabile (VSR)** oppure no (giustificare la risposta).
- **(2)** Indicare se `S` è **conflict-serializzabile (CSR)** oppure no (giustificare la risposta disegnando il grafo dei conflitti).
- **(2)** Indicare se `S` è **2PL** (vale a dire, se rispetta la regola di serializzabilità del locking a due fasi).

**f) Ottimizzazione**

Si consideri il seguente schema relazionale che descrive gli ordini di un negozio online:

```
CLIENTE(CodCliente, Nome, Cognome, Email, Citta, Provincia, Regione)
ORDINE(CodOrdine, Cliente, Data, Importo, Stato, Corriere)
CORRIERE(CodCorriere, NomeCorr, Sede)
```
Vincoli d'integrità referenziale: `ORDINE.Cliente → CLIENTE`, `ORDINE.Corriere → CORRIERE`

Data la seguente interrogazione:

```sql
SELECT C.CodCliente, C.Cognome, C.Nome, O.CodOrdine, O.Data, O.Importo
FROM CLIENTE C JOIN ORDINE O ON (C.CodCliente = O.Cliente)
WHERE C.Regione = 'Veneto' AND O.Data > '01/01/2025'
```

- **(3)** Calcolare il costo dell'interrogazione in termini di **numero di accessi a memoria secondaria** sotto le seguenti ipotesi:
  - la selezione dei clienti viene eseguita attraverso una scansione della tabella `CLIENTE`; il risultato della selezione viene mantenuto nel buffer;
  - la selezione degli ordini viene eseguita con una scansione sequenziale della tabella `ORDINE`; il risultato viene salvato in **1200 pagine** della memoria secondaria (144000 righe);
  - l'ordine di esecuzione del join è `CLIENTE ⋈ ORDINE` e le operazioni di join vengono eseguite con la tecnica **"Nested Loop Join"** con una pagina di buffer disponibile per ogni tabella;
  - `NP(CORRIERE) = 8`, `NP(ORDINE) = 3600`, `NP(CLIENTE) = 400`
  - `NR(CORRIERE) = 950`, `NR(ORDINE) = 432000`, `NR(CLIENTE) = 24000`
  - `VAL(Regione, CLIENTE) = 20`, `VAL(Cliente, ORDINE) = 24000`
- **(2)** Come cambia il costo della query considerando la presenza di un **indice B+-tree di profondità 3** sull'attributo `Cliente` della tabella `ORDINE`?

**g) B+-tree (5)**

Data la seguente lista di possibili valori chiave `L = (A, B, C, D, E, F, G, H, I, L, M, N, O, P, Q, R, S, T, U, V, Z)`:

- **a) (1)** costruire un B+-tree con **fan-out = 5** che contenga i seguenti nodi foglia, indicando i vincoli di riempimento adottati:

```
(B, C, E)     (H, I)     (M, N, O, P)     (R, S)     (U, V, Z)
```

- **b) (2)** mostrare l'albero dopo l'**inserimento** del valore chiave `Q`;
- **c) (2)** partendo dal risultato del punto precedente, mostrare l'albero dopo la **rimozione** del valore chiave `S`.

---

# PARTE B — LABORATORIO

**h) (3)** Si consideri la seguente dichiarazione in PostgreSQL:

```sql
CREATE TABLE Prodotto (
  cod_prodotto  CHAR(10),
  nome_prod     VARCHAR(64),
  categoria     VARCHAR(32),
  prezzo        NUMERIC(8,2),
  giacenza      INTEGER
);

CREATE TABLE Ordine (
  cod_ordine    CHAR(12),
  cliente       CHAR(10),
  data_ordine   DATE,
  importo       NUMERIC(10,2),
  stato         VARCHAR(20),
  corriere      CHAR(6)
);
```

Si completi la dichiarazione (anche direttamente sopra su questo foglio) in modo che permetta di rappresentare:

- **(i)** il vincolo di chiave primaria sull'attributo `cod_prodotto` di `Prodotto` e sull'attributo `cod_ordine` di `Ordine`;
- **(ii)** un vincolo di integrità referenziale da `Ordine.cliente` a `Cliente.cod_cliente`, tale che la cancellazione di un cliente sia impedita se esistono suoi ordini;
- **(iii)** una superchiave composta dagli attributi `nome_prod` e `categoria` della tabella `Prodotto`;
- **(iv)** l'obbligatorietà degli attributi `nome_prod` e `prezzo` di `Prodotto`, e degli attributi `cliente`, `data_ordine` e `stato` di `Ordine`;
- **(v)** un vincolo di dominio per l'attributo `stato` di `Ordine`, che può assumere solo i seguenti valori: `{'in preparazione', 'spedito', 'consegnato', 'annullato'}`;
- **(vi)** un vincolo su `prezzo > 0` e un vincolo su `giacenza >= 0`;
- **(vii)** un valore di default per `stato` pari a `'in preparazione'` e per `giacenza` pari a `0`.

**i) Query SQL**

Dato il seguente schema relazionale:

```
CLIENTE( cod_cliente, nome, cognome, email, citta, provincia, regione )
ORDINE( cod_ordine, cliente, data_ordine, importo, stato, corriere )
RIGA( ordine, prodotto, quantita, prezzo_unitario )
PRODOTTO( cod_prodotto, nome_prod, categoria, prezzo, giacenza )
```

Chiavi primarie sottolineate e vincoli di integrità:
`ORDINE.cliente → CLIENTE`, `RIGA.ordine → ORDINE`, `RIGA.prodotto → PRODOTTO`

Formulare in SQL le seguenti interrogazioni:

- **i. [5]** Trovare i clienti che nel 2025 hanno speso complessivamente più di 1000 euro in prodotti della categoria `'Informatica'`. Per ciascun cliente riportare il cognome, il nome e l'email.
- **ii. [4]** Trovare, per ogni provincia, il numero di ordini nello stato `'consegnato'` e il loro importo medio, considerando soltanto le province con almeno 50 ordini consegnati.
- **iii. [5]** Trovare i prodotti che non sono mai stati ordinati da nessun cliente della regione `'Veneto'`. Per ciascun prodotto riportare il codice e il nome.
- **iv. [3]** Trovare tutti i clienti della città di `'Verona'` che hanno un indirizzo email registrato. Indicare che tipo di indici è possibile costruire per ottimizzare l'interrogazione, giustificando la risposta.

**j) Query MongoDB [3]**

Si supponga che le informazioni relative ai prodotti siano memorizzate in una collezione `prodotti` di documenti JSON con la seguente struttura:

```json
{ "_id": "P0031", "nome": "...", "categoria": "...", "prezzo": 0,
  "giacenza": 0, "recensioni": [ { "cliente": "...", "voto": 0, "testo": "..." } ] }
```

- **i.** Formulare una query per trovare tutti i prodotti della categoria `'Informatica'` con prezzo inferiore a 500 euro e giacenza maggiore di zero, riportando soltanto il nome e il prezzo.
- **ii.** Formulare una query per calcolare, per ogni categoria, il voto medio delle recensioni ricevute, ordinando il risultato per voto medio decrescente.

**k) Transazioni [6]**

Descrivere la differenza fra l'anomalia di **perdita di aggiornamento** e l'anomalia di **lettura sporca**, anche attraverso l'utilizzo di esempi di transazioni SQL che possono produrre ciascuna anomalia. Indicare il livello di isolamento minimo che deve essere utilizzato per evitare ciascun tipo di anomalia.

**l) Python [4]**

Si consideri una base di dati in PostgreSQL contenente le tabelle

```
PRODOTTO( cod_prodotto, nome_prod, categoria, prezzo, giacenza )
```

Scrivere il codice di un programma Python che richieda all'utente di inserire una categoria e un prezzo massimo, e restituisca l'elenco dei prodotti di quella categoria con prezzo inferiore o uguale a quello indicato e con giacenza maggiore di zero. L'elenco riporterà i prodotti ordinati per prezzo crescente. Se non esistono prodotti che soddisfano i criteri, verrà riportato il messaggio `"Nessun prodotto disponibile nella categoria X sotto i Y euro"`, dove `X` e `Y` vanno sostituiti con i valori inseriti dall'utente.
