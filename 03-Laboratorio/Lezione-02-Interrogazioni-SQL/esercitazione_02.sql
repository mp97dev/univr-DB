--Esercizio 1
--Visualizzare tutti i musei della città di Verona con il loro giorno di chiusura.
SELECT nome, città, giornochiusura
FROM museo
WHERE LOWER(città) = LOWER('Verona')

--Esercizio 2
--Visualizzare per ogni mostra che inizia con la lettera 'M', una stringa composta dal titolo e dalla città in cui si svolge.
SELECT titolo || ' ' || città as titolo_citta
FROM mostra
WHERE titolo LIKE 'R%';

-- Esercizio 3
-- Visualizzare il titolo di ogni mostra ancora in corso e quanti giorni rimane ancora aperta a partire dalla data corrente. 
-- Usare la costante CURRENT_DATE per avere la data corrente.
SELECT titolo, fine - CURRENT_DATE
FROM mostra
WHERE fine > CURRENT_DATE;

--Esercizio 4
--Visualizzare per ogni museo l’orario di apertura e chiusura il martedì. Se per un museo il martedì è giorno di chiusura, non mostrare nulla.
SELECT m.nome, m.città, o.orarioapertura, o.orariochiusura
FROM museo as m, orario as o
WHERE m.nome = o.museo AND m.città = o.città AND o.giorno = 'MAR' AND 
m.giornochiusura <> 'MAR'

--Esercizio 5
--Assicurarsi che almeno una mostra abbia il prezzo ridotto non valorizzato (NULL) usando eventualmente il comando UPDATE per modificare almeno una riga.
--Visualizzare tutte le mostre che hanno prezzo ridotto non valorizzato usando prima l’espressione ERRATA 'prezzoRidotto = NULL' e poi l’espressione corretta prezzoRidotto IS NULL.
SELECT *
FROM mostra
WHERE prezzoRidotto IS NULL;

--Esercizio 6
--Visualizzare tutte le mostre non terminate in ordine di data inizio e, in caso di pari data inizio, data fine.
SELECT *
FROM mostra
WHERE fine > CURRENT_DATE\
ORDER BY inizio, fine;

--Esercizio 7
--Visualizzare il numero totale di giorni di apertura del museo 'Arena di Verona'.
SELECT count(distinct giorno)
FROM museo as m, orario as o
WHERE m.nome = o.museo AND m.città = o.città AND m.nome = 'Arena di Verona';

--Esercizio 8
--Visualizzare le ore medie di apertura del museo 'Arena di Verona'. Suggerimento: convertire orarioapertura e orariochiusura usando '::time'.
SELECT AVG( o.orariochiusura::time - o.orarioapertura::time )
FROM museo as m, orario as o
WHERE m.nome = o.museo AND m.città = o.città;

--Esercizio 9
--Indicare il numero di autori distinti presenti in tutti i musei.
SELECT distinct( nomeAutore )
FROM museo as m, opera as o
WHERE m.nome = o.museo AND m.città = o.città;