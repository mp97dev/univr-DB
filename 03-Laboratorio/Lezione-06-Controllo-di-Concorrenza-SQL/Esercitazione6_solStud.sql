---Esercizio 1

--T1 

BEGIN;

INSERT INTO museo(nome, citta, indirizzo, numeroTelefono, giornoChiusura, prezzo)
VALUES ('Museo Egizio', 'Torino', 'Via Roma 1', '+39011111111', 'LUN ', 15.00);

COMMIT;

--T2

BEGIN;

INSERT INTO museo(nome, citta, indirizzo, numeroTelefono, giornoChiusura, prezzo)
VALUES ('Museo Egizio', 'Torino', 'Via Roma 1', '+39011111111', 'LUN ', 15.00);

COMMIT;

--Se due istruzioni INSERT dello stesso museo sono date “contemporaneamente”, in realtà una delle due viene 
--eseguita prima dell’altra. Di conseguenza, la seconda INSERT fallirebbe perché il valore della chiave è duplicato:
-- ERROR: duplicate key value violates unique constraint museo_pkey.
--Livello: Read Committed (sufficiente, la correttezza è garantita dal vincolo).
--Qui la correttezza è garantita dal vincolo di chiave primaria, non dal livello di isolamento.


--Esercizio 2

--T1
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT * FROM Museo
WHERE prezzo <> ceil ( prezzo ) AND citta ILIKE 'Verona';
UPDATE Museo SET prezzo = round( prezzo * 1.10, 2 )
WHERE prezzo <> ceil ( prezzo ) AND citta ILIKE 'Verona' ;
COMMIT;

--T2
BEGIN;
UPDATE Museo SET prezzo = round ( prezzo * 1.10, 2)
WHERE citta ILIKE 'Verona';
COMMIT;

--Con READ COMMITTED, la prima transazione potrebbe aggiornare righe diverse da quelle selezionate, 
--perché la seconda transazione può modificare i prezzi e fare COMMIT tra SELECT e UPDATE.
--Per evitare questa anomalia, la prima transazione deve essere eseguita in REPEATABLE READ. 
--In questo modo, se una transazione concorrente modifica le stesse righe e fa COMMIT, la prima 
--transazione fallisce all’UPDATE con errore di serializzazione dovuto ad aggiornamento concorrente.


--Esercizio 3
--T1:
BEGIN;
INSERT INTO mostra(titolo, inizio, fine, museo, citta, prezzoIntero, prezzoRidotto)
VALUES ('Mostra Primavera', '2026-04-16', '2026-06-30',
        'Castelvecchio', 'Verona', 40.00, 20.00);
COMMIT;

--T2:
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT avg(prezzoIntero) FROM mostra WHERE citta = 'Verona';
SELECT avg(prezzoRidotto) FROM mostra WHERE citta = 'Verona';
COMMIT;

--In Repeatable Read, tutte le SELECT della stessa transazione leggono la stessa snapshot del database, 
--quindi non possono restituire insiemi diversi di tuple.

--READ COMMITTED
--“Ogni SELECT vede lo stato più aggiornato del database”
--Prima SELECT → vede senza la nuova mostra
--T1 fa COMMIT
--Seconda SELECT → vede con la nuova mostra
--Risultato due insiemi diversi 

--Il livello REPEATABLE READ è necessario per evitare i Phantom Reads. Senza di esso, 
--se T1 committasse tra la prima e la seconda SELECT di T2, la seconda media includerebbe 
--la nuova mostra mentre la prima no, rendendo il report di T2 inconsistente
--(la somma delle parti non corrisponderebbe al totale).

--Esercizio 4
-- Banalmente, si possono eseguire i due update senza bisogno di transazioni particolare. 
-- L’esito dei due update è indipendende dall’ordine con cui vengono eseguiti.
UPDATE Mostra SET prezzoIntero = round ( prezzoIntero * 1.10 , 2) WHERE citta ILIKE 'Verona';
UPDATE Mostra SET prezzoRidotto = round ( prezzoRidotto * 0.95 , 2) WHERE citta ILIKE 'Verona';

BEGIN;
UPDATE Mostra
SET prezzoIntero = round(prezzoIntero * 1.10, 2)
WHERE citta ILIKE 'Verona';
COMMIT;

BEGIN;
UPDATE Mostra
SET prezzoRidotto = round(prezzoRidotto * 0.95, 2)
WHERE citta ILIKE 'Verona';
COMMIT;

--Le due transazioni possono essere eseguite con il livello di isolamento di default (READ COMMITTED), 
--poiché aggiornano attributi diversi delle stesse tuple e non dipendono da letture precedenti. 
--L’esito è indipendente dall’ordine di esecuzione e PostgreSQL garantisce la correttezza tramite 
--il meccanismo di gestione degli aggiornamenti concorrenti.

--Esercizio 5

--T1: calcola la media dei prezzi dei musei di Vicenza; inserisce un nuovo museo a Verona con quel prezzo.
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;

INSERT INTO museo(nome, "città", indirizzo, numeroTelefono, giornoChiusura, prezzo)
SELECT 'Museo moderno',
       'Verona',
       'Indirizzo da definire',
       NULL,
       'LUN ',
       avg(prezzo)
FROM museo
WHERE citta = 'Vicenza';

COMMIT;
--T2:calcola la media dei prezzi dei musei di Verona; inserisce un nuovo museo a Vicenza con quel prezzo.
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;

INSERT INTO museo(nome, "città", indirizzo, numeroTelefono, giornoChiusura, prezzo)
SELECT 'Museo contemporaneo',
       'Vicenza',
       'Indirizzo da definire',
       NULL,
       'MAR ',
       avg(prezzo)
FROM museo
WHERE citta = 'Verona';

COMMIT;

--Livello di isolamento scelto: Serializable.
--Questo è il caso classico in cui due transazioni leggono un insieme di righe;
--sulla base di quella lettura inseriscono nuove righe che influenzano il risultato dell’altra.

--Se eseguite in parallelo, entrambe calcolano la media sui dati “vecchi” e poi inseriscono.
-- Il risultato finale può non corrispondere a nessun ordine seriale delle due transazioni.

--Quindi:
--Read Committed non basta;
--Repeatable Read non basta;
--serve Serializable.
--È esattamente un caso da “mancata serializzazione”.

