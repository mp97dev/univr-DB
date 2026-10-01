# Basi di Dati — Indice del materiale

Università di Verona — A.A. 2025/2026
Moduli: **Teoria** · **Tecnologie** (Dr. Sara Migliorini) · **Laboratorio** (Dr. Beatrice Amico)

> Per sapere **cosa studiare** e in che ordine → [GUIDA-ESAME.md](GUIDA-ESAME.md)

## Struttura

```
01-Teoria/             lucidi + esercizi del modulo di teoria (ER, relazionale, document, algebra, calcolo)
02-Tecnologie/         lucidi + esercizi risolti del modulo di tecnologie (interni del DBMS)
03-Laboratorio/        8 lezioni di laboratorio (PostgreSQL, SQL, indici, concorrenza, Python, MongoDB)
04-Esami/              temi d'esame degli anni precedenti, divisi per prova
05-Appunti-Riassunto/  appunti riassuntivi in PDF + sorgente LaTeX + dataset SQL d'esempio
06-Simulazioni/        6 temi d'esame inediti (3 per prova) con soluzioni ragionate
07-Esercizi-SQL-Personali/  2 mini-DB (Docker + PostgreSQL) per esercitarsi con query via CLI
_Fuori-corso/          file trovati nella cartella ma non pertinenti a Basi di Dati
```

---

## 01-Teoria

### 00-Introduzione
| File | Contenuto |
|---|---|
| `Introduzione2025-IIIanno.pdf` | Sistema informativo, base di dati, DBMS, modello dei dati, architettura a 3 livelli |
| `EsempioIndipendenzaFisicaLogica.pdf` | Esempio di indipendenza fisica e logica dei dati |

### 01-Modello-ER
| File | Contenuto |
|---|---|
| `ER1.pdf` | Entità, istanze, relazioni, relazioni ricorsive |
| `ER2.pdf` | Attributi (semplici, composti, opzionali, multivalore), identificatori interni ed esterni |
| `ER3.pdf` | Cardinalità di relazione e di attributo, vincoli |
| `ER4.pdf` | Generalizzazioni (totali/parziali, esclusive/sovrapposte), sottoinsiemi, relazioni ternarie |
| `StrategieProgetto.pdf` | Strategie top-down / bottom-up / inside-out / mista, qualità dello schema |

### 02-Modello-Relazionale
| File | Contenuto |
|---|---|
| `ModelloRelazionale.pdf` | Domini, relazione matematica e su attributi, ennupla, schema vs istanza |
| `ProgettazioneNelModelloRelazionale.pdf` | Relazione unica, anomalie, decomposizione |
| `ValoriNulliVincoli.pdf` | Valori nulli, vincoli di dominio/tupla/chiave, superchiave, integrità referenziale |

### 03-Progettazione-Logica-Relazionale
| File | Contenuto |
|---|---|
| `ProgettazioneLogica-primaParte.pdf` | Ristrutturazione dello schema ER (ridondanze, generalizzazioni, partizionamenti/accorpamenti) |
| `ProgettazioneLogica-secondaParte.pdf` | Regole di traduzione ER → schema relazionale (1:1, 1:N, N:N, ternarie, identificatori esterni) |

### 04-Document-DB-e-JSON
| File | Contenuto |
|---|---|
| `DocumentDB-progettazioneLogica.pdf` | Modello a documenti, JSON, collezioni, embedding vs riferimenti, etichettatura ER → collezioni |
| `DocumentDBLinguaggioInterrogazione.pdf` | Linguaggio di interrogazione MongoDB: find, operatori, aggregation pipeline |

### 05-Algebra-Relazionale
| File | Contenuto |
|---|---|
| `AR1.pdf` – `AR4.pdf` | Operatori insiemistici, selezione, proiezione, ridenominazione, join (naturale/theta/esterni), divisione, algebra con valori nulli |
| `EsempioOttimizzazione.png` | Esempio di ottimizzazione algebrica |
| `Q1_soluzione.png` – `Q7_soluzione.png` | Soluzioni degli esercizi di algebra relazionale |
| `Esercizi-svolti-AR-Garza-2006.pdf` | Esercizi svolti di algebra relazionale **e SQL** (P. Garza, schema riviste/articoli) |

### 06-Calcolo-Relazionale
| File | Contenuto |
|---|---|
| `Calcolo1.pdf` | Calcolo relazionale sulle tuple con dichiarazioni di range: sintassi e semantica |
| `Calcolo2.pdf` | Quantificatori, operatori insiemistici, corrispondenza con SQL, limiti espressivi |
| `Esercitazione-calcolo-relazionale-testo.pdf` / `-soluzioni.pdf` | Esercitazione in preparazione della II prova (schema aule/insegnamenti/docenti/lezioni) con soluzioni |

### 07-Esercizi-Progettazione-Concettuale
`EserciziSullaProgettazioneConcettualeinER.pdf` (testi) · `RelazioniTernarieEserciziTesto.pdf` · `Esempio ER1..ER4-soluzione*.pdf` (soluzioni in ER)

### 08-Esercizi-Progettazione-Logica-Relazionale
`Esempio ER1..ER4-soluzione-conSchemaLogico.pdf` — gli stessi 4 esercizi tradotti in schema relazionale

### 09-Esercizi-Progettazione-Logica-Document
`Esempio ER1..ER4-soluzione-mappingDocument*.pdf` — gli stessi 4 esercizi tradotti in collezioni di documenti

> I gruppi 07/08/09 sono la **stessa serie di 4 esercizi** portata avanti nei tre modelli: usali in sequenza sullo stesso testo.

---

## 02-Tecnologie

### 01-Transazioni-e-Affidabilita
| File | Contenuto |
|---|---|
| `lesson_01_transazioni.pdf` | Transazione, transazione ben formata, **proprietà ACID**, moduli del DBMS che le garantiscono |
| `lesson_02_esercizio_ripresa_a_caldo_01.pdf` | Esercizio svolto di ripresa a caldo (warm restart) |
| `lesson_02_esercizio_ripresa_a_caldo_02.pdf` | Secondo esercizio svolto di ripresa a caldo |

### 02-Strutture-Fisiche-e-Accesso
| File | Contenuto |
|---|---|
| `lesson_02_strutture_accesso_ai_dati_01.pdf` | Memoria secondaria, blocchi/pagine, **gestore del buffer** e sue politiche |
| `lesson_03_strutture_accesso_ai_dati_02.pdf` | Gestore dei metodi di accesso, organizzazione della pagina, dizionario, TOAST |
| `lesson_04_strutture_accesso_ai_dati_03.pdf` | **B+-tree**: struttura, fan-out, vincoli di riempimento, ricerca/inserimento/split |
| `lesson_04_esercizio_b+tree.pdf` | Esercizio svolto: costruzione di un B+-tree con fan-out 5 |

### 03-Concorrenza
| File | Contenuto |
|---|---|
| `lesson_05_concorrenza_01.pdf` | Anomalie: perdita di aggiornamento, lettura sporca/inconsistente, aggiornamento e inserimento fantasma |
| `lesson_06_concorrenza_02.pdf` | Schedule, serialità, **view-equivalenza (VSR)**, relazione LEGGE-DA e scritture finali |
| `lesson_07_concorrenza_03.pptx` | **CSR**, grafo dei conflitti, locking, **2PL**, timestamp, deadlock |
| `lesson_06_01_esercizi_test_VSR.pdf` | Esercizi sul test VSR |
| `lesson_06_02_esercizi_test_CSR.pdf` | Esercizi sul test CSR |
| `lesson_06_03_esercizi_test_VSR_CSR_soluzioni.pdf` | Soluzioni dei due gruppi di esercizi |

### 04-Ottimizzazione
| File | Contenuto |
|---|---|
| `lesson_08_ottimizzazione_01.pdf` | Compilazione di una query, ottimizzazione algebrica, profili, scansione, ordinamento |
| `lesson_09_ottimizzazione_02.pdf` | **Algoritmi di join**: nested loop (con/senza indice), merge-scan, hash — e loro costo |
| `lesson_09_esercizio_ottimizzazione_stima_costo.pdf` | Esercizio svolto di stima del costo |
| `lesson_12_03_esercitazione_ottimizzazione_soluzioni.pdf` | Esercitazione di ottimizzazione con soluzioni |

### 05-SQL
`02_sql.pdf` (lucidi SQL aggiornati) · `02_sql_esercizi.pdf` · `02_sql_esercizi_in_aula.pdf`

### 06-MongoDB-Architettura
`architettura_mongodb.pdf` — **replica set** (oplog, heartbeat, elezione Raft, arbitro, nodi nascosti, write concern, read preference), **sharding** (shard key, chunk, mongos, config server), proprietà ACID in MongoDB

### 07-Esercitazioni-Riepilogative
| File | Contenuto |
|---|---|
| `lesson_12_03_esercitazione_in_preparazione_terza_prova.pdf` | Simulazione completa della III prova |
| `lesson_12_03_esercitazione_in_preparazione_terza_prova_soluzioni.pdf` | Soluzioni della simulazione |
| `esercitazione_lab_20-09-2024.pdf` | Esercitazione di laboratorio su testo d'esame del 20/09/2024 (DDL PostgreSQL + query) |

---

## 03-Laboratorio

Ogni cartella contiene i lucidi (`lesson_*.pdf`), il testo dell'esercitazione (`esercitazione*.pdf`) e, dove disponibile, la soluzione (`*.sql`).

| Lezione | Argomento |
|---|---|
| `Lezione-01-PostgreSQL-e-SQL-base` | Presentazione del corso, PostgreSQL, SQL di base (+ 2 file `.sql`) |
| `Lezione-02-Interrogazioni-SQL` | Interrogazioni SQL |
| `Lezione-03-Interrogazioni-SQL-UNIVR` | Interrogazioni sulla base di dati UNIVR |
| `Lezione-04-Query-Nidificate-e-Insiemistiche` | Interrogazioni nidificate e operatori insiemistici |
| `Lezione-05-Indici-e-Prestazioni` | Indici e analisi delle prestazioni delle query |
| `Lezione-06-Controllo-di-Concorrenza-SQL` | Controllo di concorrenza in SQL, livelli di isolamento |
| `Lezione-07-Python-per-DB` | Python (differenze rispetto a Java), accesso al DB da Python |
| `Lezione-08-MongoDB` | MongoDB: insert e query (`01_museo_insert.txt`, `02_*_insert.txt`, `03_query.txt`) |

---

## 04-Esami

### 01-Teoria-e-Progettazione
44 temi del **modulo di teoria** (dal 2004 al 2024), divisi per tipo di prova. Il suffisso `-conSoluzioni` / `-soluzioni` indica le **soluzioni ufficiali** del docente.

#### 01-I-Prova-Progettazione — ER, traduzione relazionale, documenti
| File | Contenuto |
|---|---|
| `BD-I-ProvaIntermediaA-9gennaio2017.pdf` | Testo (aeroporto di Verona) |
| `BD-I-ProvaIntermediaA-9gennaio2017-conSoluzioni.pdf` | Stesso tema **con soluzioni** (domande a/b/c + schema ER + logico) |
| `BD-ProvaIntermediaA-8gennaio2018.pdf` | Testo (gestione corsi) — svolto a mano in `04-Svolti-con-Soluzioni/1-18_A` |
| `BD-IProvaIntermedia-2dicembre2022-A/B/C.pdf` | Tre varianti: catena di alberghi / ristoranti / officine |
| `BD_IProvaIntermediaB-1dicembre2023-conSoluzioni.pdf` | Variante B (catena di supermercati) **con soluzioni** — la variante A è svolta in `04-Svolti-con-Soluzioni/` |
| `EsercitazioneInPreparazioneProvaIntermedia-2017-soluzioni.pdf` | Tema della prova 2015/16 (progetti) **con soluzioni** |

#### 02-II-Prova-Algebra-Calcolo — algebra, calcolo relazionale, ottimizzazione algebrica
| File | Contenuto |
|---|---|
| `BD-II-ProvaIntermediaA-24febbraio2017.pdf` | Testo |
| `EsercitazioneInPreparazioneSecondaProvaIntermedia-2019-20-*` | Tema del 28/02/2017: `-testo`, `-testo-corretto`, `-calcoloRel-soluzioni`, `-calcoloRel-conSoluzioni` (versione con refusi corretti) |
| `SecondaProvaIntermediaA-28gennaio2020.pdf` | Testo |
| `SecondaProvaIntermediaA-28gennaio2020-testo-CalcoloRel.pdf` / `-conSol-calcoloRel.pdf` | Variante con domanda di calcolo + **soluzioni** |
| `BD-ProvaIntermedia-3marzo2022-esercitazione.pdf` | Prova "progettazione e algebra" del 3/3/2022 (versione esercitazione) |
| `EsercitazioneAlgebraCalcolo_BDProvaIntermediaA-3marzo2022.pdf` / `-conSoluzioniCalcolo.pdf` | Stessa prova, parte algebra/calcolo + **soluzioni** |
| `BD-IIProvaIntermedia-28febbraio2023-scansione.pdf` | Foto del compito (risposte oscurate) |
| `BDSecondaProvaIntermediaA-28febbraio2023-soluzioni-corretta.pdf` | Stesso tema **con soluzioni** (parco divertimenti: turisti, attrazioni, accessi) |
| `BD-IIProvaIntermediaA-29febbraio2024.pdf` / `-esercitazione-soluzioni.pdf` | Concessionarie auto + **soluzioni** — svolto a mano anche in `04-Svolti-con-Soluzioni/29-02-24` |

#### 03-Appelli-Completi — appelli con l'intero programma (progettazione + algebra/SQL)
`BDweb-giu04a/b/c`, `BDweb-giu05a`, `BDweb-set06bis`, `BDwebMM-giu07A`, `BDwebMM-set07`, `BDWebMM8febbraio2011`, `BDwebMMGiugno2011`, `BDwebMMLuglio2011`, `BD-Esercitazione-IProvaIntermedia-2013-14` (elezioni studentesche), `BDTeoria26Feb2014`, `BD-ProvaIntermediaA-26febbraio2014` (corsi e-learning), `BD-25giugno2014`, `BDTeoria16lug14`, `BD13luglio2016`, `BD11luglio2017`, `BDTeoria19Giu2020`.

### 02-Tecnologie-III-Prova
9 testi della **III prova in itinere**: `2015_06` (+ `_soluzioni`), `2016_06_07_soluzioni`, `2022_04_21_A/B`, `2022_06_10`, `2023_06_08_A/B`, `2024_06_12_A`, `2024_06_23`.
Il più completo e recente: `2024_06_23_III_prova_intermedia.pdf`. Con **soluzioni ufficiali**: `2015_06_terza_prova_soluzioni.pdf`, `2016_06_07_III_prova_intermedia_soluzioni.pdf` (il testo 2016 è `02-Tecnologie/07-…/lesson_12_03_esercitazione_in_preparazione_terza_prova.pdf`).

### 03-Laboratorio
9 appelli di laboratorio (durata 1h30), tutti con la stessa struttura: DDL con vincoli, domande brevi su PostgreSQL, query SQL, transazioni/isolamento, programma Python/Java.
| File | Note |
|---|---|
| `2022_06_17_I_appello_laboratorio.pdf` · `2022_07_01_II_…` · `2022_09_28_III_…` | Formato 2022: domande brevi su `NUMERIC(p,s)`, logica a 3 valori con `NULL`, scelta di indici, lettura di un piano `EXPLAIN` (il 28/09 è una scansione) |
| `2023_06_21_I_…` · `2023_06_23_I_…` · `2023_07_12_II_…` · `2023_09_13_III_…` · `2024_02_28_IV_…` | Formato 2023-24: DDL + 4 query SQL (con domanda sugli indici) + transazioni + Python/Java |
| `2025_09_16_III_appello_laboratorio_con_soluzioni.pdf` | **Unico con soluzioni complete** |

### 04-Svolti-con-Soluzioni
Temi d'esame con **svolgimento a mano** (coppie `.pdf` + `.xopp`, si aprono con [Xournal++](https://xournalpp.github.io/)):
`09-01-17`, `1-18_A`, `16-06-14`, `24-02-25`, `29-02-24`, `28-01-20`, `BD_IProvaIntermedia-01dicembre2023`, `BD_IProvaIntermediaA-29novembre2024`, `BD_IProvaIntermediaB-29novembre2024`, `12-12-2025` (solo annotazioni, senza PDF di base).

---

## 05-Appunti-Riassunto

Appunti di Fabio Irimie (UniVR, Dipartimento di Informatica) che coprono l'intero corso, un volume per semestre.

| File | Contenuto |
|---|---|
| `AppuntiBasiDati-1-Teoria.pdf` | **Riassunto del 1° semestre / modulo di Teoria** (~100 pagine): introduzione, progettazione concettuale, progettazione logica, sistemi document-based, algebra e calcolo relazionale, MongoDB |
| `AppuntiBasiDati-2-Tecnologie.pdf` | **Riassunto del 2° semestre / moduli Tecnologie e Laboratorio** (~110 pagine): tecnologia dei DBMS e transazioni, SQL e PostgreSQL, strutture fisiche e di accesso (buffer, gestore dell'affidabilità, indici, B+-tree, hash, **collisioni**), transazioni concorrenti (VSR, CSR, 2PL, deadlock), ottimizzazione con esercizi svolti, MongoDB (replicazione, sharding, ACID) |
| `Esercizi-Svolti/` | Esercizi svolti a mano su algebra relazionale, progettazione concettuale e logica (`.pdf` + `.xopp`) |
| `sorgente-latex/` | Sorgente LaTeX del primo volume (`BasiDati.tex`, `title.tex`, `figures/`) |
| `pokedata-esempio-SQL/` | Dataset Pokémon in CSV + script SQL (`tables.sql`, `views.sql`, `es.sql`) per esercitarsi con query reali |

---

## 06-Simulazioni

Sei temi d'esame **inediti** costruiti sul formato dei temi reali, con soluzioni ragionate. Dettagli e tabella degli argomenti coperti in [`06-Simulazioni/README.md`](06-Simulazioni/README.md).

| File | Contenuto |
|---|---|
| `Teoria-Simulazione-1/2/3.md` | Tre prove di teoria complete (comprensorio sciistico · rete di ricarica elettrica · festival musicale) |
| `Tecnologie-Lab-Simulazione-1/2/3.md` | Tre prove di tecnologie e laboratorio complete (e-commerce · biblioteca · palestra) |
| `Soluzioni/` | Una soluzione commentata per ciascuna delle sei tracce, con motivazioni ed errori tipici |

---

## 07-Esercizi-SQL-Personali

Due mini-database indipendenti, ciascuno con schema + dati di esempio + script per lanciarli in un
container PostgreSQL via Docker, pensati per esercitarsi a scrivere query SQL (in particolare query
annidate con più filtri/sottoquery, come richiesto agli esami).

| Cartella | Schema | Contenuto |
|---|---|---|
| `scuola/` | `insegnante`, `classe`, `studente`, `esame` | `query.sql` con una query corretta + 23 esercizi (solo enunciati, difficoltà crescente: SELECT/WHERE → JOIN → GROUP BY/HAVING → subquery scalari → EXISTS/NOT EXISTS → ALL/ANY → subquery annidate per gruppo → insiemistica/divisione relazionale) |
| `turismo/` | `turista`, `attrazione`, `prenotazione` | `query.sql` con due query risolte e commentate (conteggio turisti con più attrazioni distinte nel 2026 vs 2025; attrazioni con prenotazioni 2025 superiori a ogni anno precedente) |

Ogni cartella è autonoma: `./run.sh` avvia un container Postgres dedicato (porte diverse: 5433 per
`scuola`, 5434 per `turismo`), carica schema e dati da `init/`, poi esegue `query.sql`.
`./run.sh reset` ricrea il database da zero, `./run.sh psql` apre una shell interattiva.

---

## Note sulla riorganizzazione

- Rimosse le due cartelle duplicate `... - Copia` in `Teoria/` (contenuto verificato byte-identico all'originale).
- Rimosso il suffisso `-20260823` (data di download) dai nomi delle cartelle; lezioni di laboratorio rinominate con il loro argomento.
- Appiattita la sottocartella `Temi desame precedenti/TE/` nei temi d'esame di teoria.
- Rimossi i file intermedi di compilazione LaTeX (`.aux`, `.log`, `.out`, `.toc`, `.auxlock`) e la cartella `.git` del dataset `pokedata` (ri-clonabile dal remoto).
- `linguaggi_non_cf.pdf` / `.xopp` (pumping lemma, linguaggi non context-free) spostati in `_Fuori-corso/`: non appartengono a Basi di Dati.
- Nessun file di contenuto è stato eliminato.
- Integrata la raccolta `Esami_BD/` (cartelle Belussi / Migliorini / mix): 26 file erano copie byte-identiche di temi già presenti, 8 erano doppioni interni tra `Belussi/` e `mix/`, `TE.zip` conteneva solo gli 8 temi `BDweb*` già presenti. I 35 file nuovi sono stati rinominati con data e tipo di prova (es. `1-17_A.pdf` → `BD-I-ProvaIntermediaA-9gennaio2017-conSoluzioni.pdf`, `Esame_lab_17-06-2022.pdf` → `2022_06_17_I_appello_laboratorio.pdf`) e distribuiti in `04-Esami/`, `01-Teoria/05-…` e `01-Teoria/06-…`.
- `04-Esami/01-Teoria-e-Progettazione/` diviso in tre sottocartelle: I prova, II prova, appelli completi.
