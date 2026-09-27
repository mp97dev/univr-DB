
-- Esercizio 1
-- Visualizzare il numero di corso studi presenti nella base di dati.
-- Soluzione: 635 righe
--
SELECT COUNT (*) FROM CorsoStudi;


-- Esercizio 2
-- Visualizzare il nome, il codice, l’indirizzo e l’identificatore del preside di tutte le facoltà.
-- Soluzione: ci sono 8 facoltà.
--
SELECT nome, codice, indirizzo, id_preside_persona
FROM Facolta;



-- Esercizio 3
-- Trovare per ogni corso di studi che ha erogato insegnamenti nel 2010/2011 il suo nome e il nome delle facoltà
-- che lo gestiscono (si noti che un corso può essere gestito da più facoltà). Non usare la relazione diretta tra
-- InsErogato e Facoltà. Porre i risultati in ordine di nome corso studi.
-- Soluzione: ci sono 211 righe. Le 5 righe dalla X posizione sono:
--
SELECT DISTINCT CS.nome, F.nome
FROM CorsoStudi AS CS 
JOIN InsErogato AS IE ON (CS.id = IE.id_corsostudi)
JOIN CorsoInFacolta AS CIF ON (CIF.id_corsostudi = CS.id)
JOIN Facolta AS F ON (CIF.id_facolta = F.id)
WHERE IE.annoaccademico = '2010/2011'
ORDER BY CS.nome;


-- Esercizio 4
-- Visualizzare il nome, il codice e l’abbreviazione di tutti i corsi di studio gestiti dalla facoltà di 
-- Medicina e Chirurgia.
-- Soluzione: ci sono 236 righe.
-- 
SELECT CS.nome, CS.codice, CS.abbreviazione
FROM CorsoStudi AS CS
JOIN CorsoInFacolta AS CIF ON (CS.id = CIF.id_corsostudi)
JOIN Facolta AS F ON (F.id = CIF.id_facolta)
WHERE F.nome = 'Medicina e Chirurgia';


-- Esercizio 5
-- Visualizzare il codice, il nome e l’abbreviazione di tutti corsi di studio che nel nome contengono 
-- la sottostringa 'lingue' (eseguire il confronto usando ILIKE invece di LIKE: in questo modo i 
-- caratteri maiuscolo e minuscolo non sono diversi).
-- Soluzione: ci sono 16 righe.
--
SELECT CS.codice, CS.nome, CS.abbreviazione
FROM CorsoStudi AS CS
--JOIN CorsoInFacolta AS CIF ON (CS.id = CIF.id_corsostudi)
--JOIN Facolta AS F ON (F.id = CIF.id_facolta)
WHERE CS.nome ILIKE '%lingue%';


-- Esercizio 6
-- Visualizzare le sedi dei corsi di studi in un elenco senza duplicati.
-- Soluzione: ci sono 48 righe.
--
SELECT DISTINCT sede
FROM CorsoStudi;


-- Esercizio 7
-- Visualizzare solo i moduli degli insegnamenti erogati nel 2010/2011 nei corsi di studi della facoltà 
-- di Economia. Si visualizzi il nome dell’insegnamento, il discriminante (attributo descrizione della tabella Discriminante), 
-- il nome del modulo e l’attributo modulo.
-- Soluzione: ci sono 27 righe.
SELECT I.nomeins, D.descrizione, IE.nomemodulo, IE.modulo
FROM InsErogato AS IE
JOIN Insegn as I ON (IE.id_insegn = I.id)
JOIN CorsoInFacolta AS CIF ON (CIF.id_corsostudi = IE.id_corsostudi)
JOIN Facolta AS F ON (F.id = CIF.id_facolta)
JOIN Discriminante AS D ON (IE.id_discriminante = D.id)
WHERE IE.annoaccademico = '2010/2011' AND
F.nome = 'Economia' AND 
IE.modulo > 0;


-- Esercizio 8
-- Visualizzare il nome e il discriminante (attributo descrizione della tabella Discriminante) degli insegnamenti erogati 
-- nel 2009/2010 che non sono moduli o unità logistiche e che hanno 3, 5 o 12 crediti. Si ordini il risultato per 
-- discriminante.
-- Soluzione: ci sono 724 righe distinte
SELECT DISTINCT I.nomeins, D.descrizione --, IE.nomemodulo, IE.modulo
FROM InsErogato AS IE
JOIN Insegn as I ON (IE.id_insegn = I.id)
JOIN Discriminante AS D ON (IE.id_discriminante = D.id)
WHERE IE.annoaccademico = '2009/2010' AND
IE.crediti IN (3,5,12) AND 
IE.modulo = 0
ORDER BY D.descrizione;


-- Esercizio 9
-- Visualizzare l’identificatore, il nome e il discriminante degli insegnamenti erogati nel 2008/2009 che non sono 
-- moduli o unità logistiche e con peso maggiore di 9 crediti. Ordinare per nome.
-- Soluzione: ci sono 1218 righe. 
--
SELECT I.id, I.nomeins, D.descrizione --, IE.nomemodulo, IE.modulo
FROM InsErogato AS IE
JOIN Insegn as I ON (IE.id_insegn = I.id)
JOIN Discriminante AS D ON (IE.id_discriminante = D.id)
WHERE IE.annoaccademico = '2008/2009' AND
IE.crediti > 9 AND
IE.modulo = 0
ORDER BY I.nomeins;


-- Esercizio 10
-- Visualizzare in ordine alfabetico di nome degli insegnamenti (esclusi i moduli e le unità logistiche) erogati 
--- nel 2010/2011 nel corso di studi in Informatica, riportando il nome, il discriminante, i crediti e gli anni 
-- di erogazione.
-- Soluzione: ci sono 26 righe.
--
SELECT I.id, I.nomeins, D.descrizione, IE.nomemodulo, IE.modulo
FROM InsErogato AS IE
JOIN Insegn as I ON (IE.id_insegn = I.id)
JOIN Discriminante AS D ON (IE.id_discriminante = D.id)
JOIN CorsoStudi AS CS ON (CS.id = IE.id_corsostudi)
WHERE IE.annoaccademico = '2010/2011' AND
CS.nome ILIKE 'Laurea in Informatica' AND
IE.modulo = 0
ORDER BY I.nomeins;

-- Esercizio 11
-- Trovare il massimo numero di crediti associato a un insegnamento fra quelli erogati nel 2010/2011.
-- Soluzione: 180
--
SELECT MAX(crediti)
FROM InsErogato AS IE
WHERE IE.annoaccademico = '2010/2011';


-- Esercizio 12
-- Trovare, per ogni anno accademico, il massimo e il minimo numero di crediti erogati tra gli insegnamenti
-- dell’anno.
-- Soluzione: ci sono 16 righe.
--
SELECT annoaccademico, MAX(crediti), MIN(crediti)
FROM InsErogato
GROUP BY annoaccademico
ORDER BY annoaccademico;


-- Esercizio 13
-- Trovare, per ogni anno accademico e per ogni corso di studi la somma dei crediti erogati (esclusi i moduli e le
-- unità logistiche: vedi nota sopra) e il massimo e minimo numero di crediti degli insegnamenti erogati sempre
-- escludendo i moduli e le unità logistiche.
-- Soluzione: ci sono 1587 righe. Le riga relativa alla "Scuola di Specializzazione in Urologia (Vecchio ordinamento)"
-- nell’anno 2011/2012 ha valori 52.00, 10.00 e 162.00.
--
SELECT IE.annoaccademico, CS.nome, SUM(crediti), MAX(crediti), MIN(crediti)
FROM InsErogato AS IE JOIN CorsoStudi AS CS ON (IE.id_corsostudi = CS.id )
WHERE IE.modulo = 0
GROUP BY IE.annoaccademico, CS.id, CS.nome;


-- Esercizio 14
-- Trovare per ogni corso di studi della facoltà di Scienze Matematiche Fisiche e Naturali il numero di insegnamenti
-- (esclusi i moduli e le unità logistiche) erogati nel 2009/2010.
-- Soluzione: ci sono 19 righe.

SELECT CS.nome, COUNT(*)
FROM InsErogato AS IE 
  JOIN CorsoStudi AS CS ON (IE.id_corsostudi = CS.id )
  JOIN CorsoInFacolta AS CIF ON (CIF.id_corsostudi = CS.id )
  JOIN Facolta AS F ON (CIF.id_facolta = F.id)
WHERE LOWER(F.nome) = 'scienze matematiche fisiche e naturali' AND
IE.modulo = 0 AND IE.annoaccademico = '2009/2010'
GROUP BY CS.nome;

--
-- Esercizio 15
-- Trovare i corsi di studi che nel 2010/2011 hanno erogato insegnamenti con un numero di crediti pari a 4 o 6 o
-- 8 o 10 o 12 o un numero di crediti di laboratorio tra 10 e 15 escluso, riportando il nome del corso di studi e la
-- sua durata. Si ricorda che i crediti di laboratorio sono rappresentati dall’attributo creditilab della tabella
-- InsErogato.
-- Soluzione: ci sono 197 righe. 
--
SELECT DISTINCT CS.nome, CS.durataAnni
FROM InsErogato AS IE 
  JOIN CorsoStudi AS CS ON (IE.id_corsostudi = CS.id )  
WHERE IE.annoaccademico = '2010/2011' AND
( IE.crediti IN (4,6,8,10,12) OR ( IE.creditilab >= 10 AND IE.creditilab <= 15 ) );


-- Esercizio 16
-- Trovare nome, cognome dei docenti che nell’anno accademico 2010/2011 erano docenti 
-- in almeno due corsi di studio (vale a dire erano docenti in almeno due insegnamenti 
-- o moduli A e B dove A è del corso C1 e B è del corso C2 con C1 <> C2).

SELECT DISTINCT P.id, P.nome, P.cognome
FROM InsErogato AS IE1 
  JOIN Docenza AS D1 ON( D1.id_inserogato = IE1.id )
  JOIN Persona AS P ON( D1.id_persona = P.id )  
  JOIN Docenza AS D2 ON ( D2.id_persona = P.id )
  JOIN InsErogato AS IE2 ON ( D2.id_inserogato = IE2.id )
WHERE IE1.annoaccademico = '2010/2011' 
  AND IE2.annoaccademico = '2010/2011' 
  AND IE1.id_corsostudi <> IE2.id_corsostudi
ORDER BY P.id;

-- Soluzione alternativa
SELECT P.id, P.nome, P.cognome
FROM InsErogato AS IE 
  JOIN Docenza AS D ON( D.id_inserogato = IE.id )
  JOIN Persona AS P ON( D.id_persona = P.id )    
WHERE IE.annoaccademico = '2010/2011' 
GROUP BY P.id, P.nome, P.cognome
HAVING COUNT(DISTINCT IE.id_corsostudi) > 1
ORDER BY P.id;


-- Esercizio 17
-- Trovare per ogni periodo di lezione del 2010/2011 la cui descrizione inizia con  'I semestre' o 'Primo semestre' 
-- il numero di occorrenze di insegnamento allocate in quel periodo. Si visualizzi quindi: l’abbreviazione, il discriminante, 
-- inizio, fine e il conteggio richiesto ordinati rispetto all’inizio e fine.
-- 
-- La soluzione ha 3 righe
--
SELECT PL.abbreviazione, PD.discriminante, PD.inizio, PD.fine, COUNT(IP.id_inserogato) as numins
FROM PeriodoLez AS PL
  JOIN PeriodoDid AS PD ON (PL.id = PD.id)  
  JOIN InsInPeriodo AS IP ON (PD.id = IP.id_periodolez)
WHERE PD.descrizione IN ('I semestre','Primo semestre') 
  AND PD.annoaccademico = '2010/2011'
GROUP BY PL.abbreviazione, PD.discriminante, PD.inizio, PD.fine 
ORDER BY PD.inizio, PD.fine;

-- Esercizio 18
--
-- Trovare per ogni segreteria che serve almeno un corso di studi il numero di 
-- corsi di studi serviti, riportando il nome della struttura, il suo numero di 
-- fax e il conteggio richiesto.
--
-- La soluzione ha 42 righe.
--
SELECT S.nomestruttura, S.fax, COUNT(CS.id) AS numcorsi
FROM StrutturaServizio AS S
  JOIN CorsoStudi AS CS ON (CS.id_segreteria = S.id)
GROUP BY S.nomestruttura, S.fax;


