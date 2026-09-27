
-- Esercizio 1
--
-- Trovare identificatore, cognome e nome dei docenti che, nell’anno accademico 2010/2011, hanno tenuto un 
-- insegnamento (l’attributo da confrontare è nomeins) che non hanno tenuto nell’anno accademico precedente. 
-- Ordinare la soluzione per identificatore.
-- La soluzione ha 1031 righe. 
--
SELECT DISTINCT P1.id, P1.nome, P1.cognome
FROM Persona AS P1
  JOIN Docenza as D1 ON (P1.id = D1.id_persona)
  JOIN InsErogato AS IE1 ON (IE1.id = D1.id_inserogato)
  JOIN Insegn AS I1 ON (I1.id = IE1.id_insegn)
WHERE IE1.annoaccademico = '2010/2011' 
  AND D1.id_persona NOT IN
    ( SELECT D2.id_persona
      FROM Docenza AS D2 
        JOIN InsErogato AS IE2 ON (IE2.id = D2.id_inserogato) 
        JOIN Insegn AS I2 ON (I2.id = IE2.id_insegn)
      WHERE IE2.annoaccademico = '2009/2010'  
        AND I2.nomeins = I1.nomeins )
ORDER BY P1.id;        

-- Esercizio 2
--
-- Trovare i corsi di studio che non sono gestiti dalla facoltà di "Medicina e Chirurgia" 
-- e che hanno insegnamenti erogati con moduli nel 2010/2011. Si visualizzi il 
-- nome del corso e il numero di insegnamenti erogati con moduli nel 2010/2011.
--
-- Soluzione: ci sono 33 righe.
--
SELECT CS.nome, COUNT(IE.id) as num_ins
FROM CorsoStudi AS CS
  JOIN InsErogato AS IE ON (IE.id_corsostudi = CS.id)
WHERE CS.id NOT IN 
  ( SELECT CS1.id 
    FROM CorsoStudi AS CS1 
      JOIN CorsoInFacolta AS CIF ON (CS1.id = CIF.id_corsostudi)
      JOIN Facolta AS F ON (F.id = CIF.id_facolta)
    WHERE F.nome = 'Medicina e Chirurgia'
  )
  AND IE.annoaccademico = '2010/2011'
  AND IE.hamoduli <> '0'
GROUP BY CS.nome
ORDER BY CS.nome;


-- Esercizio 3
--
-- Trovare gli insegnamenti del corso di studi con id=4 che non sono mai stati 
-- offerti al secondo quadrimestre.
-- Per selezionare il secondo quadrimestre usare la condizione 
-- "abbreviazione LIKE '2%'".
--
-- La soluzione ha 14 righe.
--
SELECT DISTINCT nomeins
FROM Insegn AS I1
  JOIN InsErogato AS IE1 ON (IE1.id_insegn = I1.id)
  JOIN CorsoStudi AS CS1 ON (IE1.id_corsostudi = CS1.id)
WHERE CS1.id = 4 AND I1.id NOT IN
( SELECT I2.id
  FROM Insegn AS I2
    JOIN InsErogato AS IE2 ON (IE2.id_insegn = I2.id)
    JOIN CorsoStudi AS CS2 ON (IE2.id_corsostudi = CS2.id)
    JOIN InsInPeriodo AS IIP2 ON (IIP2.id_inserogato = IE2.id)
    JOIN PeriodoLez AS PL2 ON (IIP2.id_periodolez = PL2.id)
  WHERE CS2.id = 4 AND
    PL2.abbreviazione LIKE '2%'
);

-- Esercizio 4
-- 
-- Trovare il nome dei corsi di studio che non hanno mai erogato insegnamenti 
-- che contengono nel nome la stringa 'matematica' (usare ILIKE invece di LIKE 
-- per rendere il test non sensibile alle maiuscole/minuscole (case-insensitive)).
--
-- La soluzione ha 572 righe.
--
SELECT CS1.nome
FROM CorsoStudi as CS1 
WHERE CS1.id NOT IN
  ( SELECT CS2.id
    FROM Insegn AS I2
      JOIN InsErogato AS IE2 ON (IE2.id_insegn = I2.id)
      JOIN CorsoStudi as CS2 ON (IE2.id_corsostudi = CS2.id)
    WHERE I2.nomeins ILIKE '%matematica%')

-- Soluzione alternativa
SELECT CS1.nome
FROM CorsoStudi as CS1 
WHERE NOT EXISTS
  ( SELECT 1
    FROM Insegn AS I2
      JOIN InsErogato AS IE2 ON (IE2.id_insegn = I2.id)
      JOIN CorsoStudi as CS2 ON (IE2.id_corsostudi = CS2.id)
    WHERE CS1.id = CS2.id 
      AND I2.nomeins ILIKE '%matematica%' 
  );

-- Esercizio 5
-- Trovare nome, cognome e telefono dei docenti che hanno tenuto nel 
-- 2009/2010 un’occorrenza di insegnamento che non sia un'unità 
-- logistica del corso di studi con id=4 ma che non hanno mai tenuto 
-- un modulo dell'insegnamento di 'Programmazione' del medesimo corso di studi.
--
-- La soluzione ha 5 righe.
--
SELECT P.id, P.nome, P.cognome, P.telefono
FROM Docenza D
  JOIN InsErogato IE ON D. id_inserogato = IE.id
  JOIN Persona P ON D. id_persona = P.id
WHERE IE.id_corsostudi = 4 AND IE.annoaccademico = '2009/2010'
  AND IE. modulo >= 0
EXCEPT
SELECT P.id , P.nome, P.cognome, P.telefono
FROM Docenza D
  JOIN InsErogato IE ON D. id_inserogato = IE.id
  JOIN Persona P ON D. id_persona = P.id
  JOIN Insegn I ON IE. id_insegn = I.id
WHERE I. nomeins = 'Programmazione' AND IE.modulo > 0

-- Alternativa

SELECT DISTINCT P.id , P.nome , P.cognome, P.telefono
FROM persona P 
  JOIN Docenza D ON P.id = D. id_persona
  JOIN inserogato IE ON D.id_inserogato = IE.id
WHERE IE. annoaccademico ='2009/2010'
  AND IE. id_corsostudi = 4
  AND IE.modulo >= 0
  AND D.id_persona NOT IN (
    SELECT D.id_persona
    FROM Inserogato IE 
      JOIN Insegn I ON IE.id_insegn = I.id 
      JOIN Docenza D ON D.id_inserogato = IE.id
    WHERE IE. id_corsostudi = 4
    AND I.nomeins = 'Programmazione'
    AND IE.modulo > 0
);

-- Esercizio 6
-- Trovare, per ogni facoltà, il numero di unità logistiche erogate 
-- (modulo < 0) e il numero corrispondente di crediti totali erogati 
-- nel 2010/2011, riportando il nome della facoltà e i conteggi richiesti. 
-- Usare pure la relazione diretta tra InsErogato e Facolta.
--
-- La soluzione ha 8 righe. La riga relativa a 'Medicina e Chirurgia' 
-- ha valori 253 e 979,50.
--
SELECT F.nome , COUNT (nomeunita) AS numUnita, SUM(crediti) AS sommaCrediti
FROM InsErogato IE JOIN Facolta F ON IE. id_facolta = F.id
WHERE IE. annoaccademico = '2010/2011' AND IE. modulo < 0
GROUP BY F.nome;


-- Esercizio 7
-- Trovare, per ogni facoltà, il docente che ha tenuto il numero massimo
-- di ore di lezione nel 2009/2010, riportando il cognome e il nome del
-- docente e la facoltà. Per la relazione tra InsErogato e Facolta
-- usare la relazione diretta.
--
-- La soluzione ha 10 righe.
--
CREATE TEMP VIEW OreDocente( docente, oreTot, facolta ) AS (
  SELECT D.id_persona, SUM( D.orelez ), F.nome
  FROM Docenza D
    JOIN InsErogato IE ON D.id_inserogato = IE.id
    JOIN Facolta F ON IE.id_facolta = F.id
  WHERE IE.annoaccademico = '2009/2010'
  GROUP BY D.id_persona, F.nome
);

SELECT DISTINCT P.id , P.cognome, P.nome, OD.facolta, OD.oreTot
FROM Persona P JOIN OreDocente OD ON P.id = OD.docente
WHERE ROW( OD.oreTot, OD.facolta ) IN (
  SELECT MAX (oreTot) AS maxOre, facolta
  FROM OreDocente
  GROUP BY facolta
)
ORDER BY cognome;


-- Alternativa
--
SELECT P.id, P.cognome, P.nome, OD.facolta , OD.oreTot
FROM Persona P JOIN OreDocente OD ON P.id = OD.docente JOIN (
  SELECT MAX ( oreTot ) AS maxOre, facolta
  FROM OreDocente
  GROUP BY facolta
) AS M ON M.facolta = OD.facolta AND OD.oreTot = M.maxOre
ORDER BY cognome;

--
-- Esercizio 8
-- Trovare gli insegnamenti (esclusi i moduli e le unità logistiche)
-- del corso di studi con id=240 erogati nel 2009/2010 e nel 2010/2011
-- che hanno avuto almeno un docente ma che non hanno avuto docenti di
-- nome 'Roberto', 'Alberto', 'Massimo' o 'Luca' in entrambi gli anni
-- accademici, riportando il nome, il discriminante dell'insegnamento,
-- ordinati per nome insegnamento.
--
-- La soluzione ha 22 righe.
-- "Non hanno avuto" = "non hanno avuto in quei due anni accademici".
--
SELECT I.nomeins , D.nome AS discriminante
FROM Insegn I
  JOIN InsErogato IE ON I.id = IE.id_insegn
  JOIN Discriminante D ON D.id = IE.id_discriminante
  JOIN Docenza DOC ON IE.id = DOC.id_inserogato
  JOIN Persona P ON DOC.id_persona = P.id
WHERE IE.id_corsostudi = 240
  AND IE.annoaccademico = '2009/2010'
  AND IE.modulo = 0
  AND P.nome NOT IN('Roberto', 'Alberto', 'Massimo', 'Luca')
INTERSECT
SELECT I.nomeins , d.nome AS discriminante
FROM Insegn I
  JOIN InsErogato IE ON I.id = IE.id_insegn
  JOIN Discriminante D ON D.id = IE.id_discriminante
  JOIN Docenza DOC ON IE.id = DOC.id_inserogato
  JOIN Persona P ON DOC.id_persona = P.id
WHERE IE.id_corsostudi = 240
AND IE.annoaccademico = '2010/2011'
AND IE.modulo = 0
AND P.nome NOT IN('Roberto', 'Alberto', 'Massimo', 'Luca')
ORDER BY nomeins;

--
-- Esercizio 9
-- Trovare le unità logistiche del corso di studi con id=420
-- erogati nel 2010/2011 e che hanno lezione o il
-- lunedì (Lezione.giorno=2) o il martedì (Lezione.giorno=3), ma non in
-- entrambi i giorni, riportando il nome dell'insegnamento e il nome
-- dell'unità ordinate per nome insegnamento.
--
-- La soluzione ha 8 righe.
--
-- L'unita logistica Sistemi operativi-Laboratorio ha una omonima
-- unità con lezioni in entrambi i giorni.
-- Quindi la soluzione corretta è la seguente.
SELECT DISTINCT I.nomeins, IE.nomeunita
FROM Insegn I JOIN InsErogato IE ON I.id = IE.id_insegn
WHERE IE.id IN (
  SELECT IE.id
  FROM InsErogato IE JOIN Lezione L ON IE.id = L.id_inserogato
  WHERE IE.id_corsostudi = 420
    AND IE.annoaccademico = '2010/2011'
    AND IE.modulo < 0
    AND (L.giorno = 2 OR L.giorno = 3)
  EXCEPT
  SELECT ie.id
  FROM InsErogato IE JOIN Lezione L1 ON IE.id = L1.id_inserogato
    JOIN Lezione L2 ON IE.id = L2.id_inserogato
  WHERE IE.id_corsostudi = 420
    AND IE.annoaccademico = '2010/2011'
    AND IE.modulo < 0
    AND (L1.giorno = 2 AND L2.giorno = 3)
)
ORDER BY nomeins;


-- Esercizio 10
-- Trovare gli insegnamenti in ordine alfabetico (esclusi moduli e
-- unità logistiche) dei corsi di studi della facoltà di
-- 'Scienze Matematiche Fisiche e Naturali' che sono stati tenuti
-- dallo stesso docente per due anni accademici consecutivi riportando
-- id, nome dell'insegnamento e id, nome, cognome del docente.
-- Per la relazione tra InsErogato e Facolta non usare la relazione diretta.
-- Circa la condizione sull'anno accademico, dopo aver estratto una sua
-- opportuna parte, si può trasformare questa in un intero e, quindi,
-- usarlo per gli opportuni controlli. Oppure si può usarla direttamente
-- confrontandola con un’opportuna parte dell’altro anno accademico.
--
-- La soluzione ha 544 righe
--
CREATE TEMP VIEW InsDocAnnoAtScienze( id_insegn , id_docente, aa ) AS
  SELECT DISTINCT IE.id_insegn, D.id_persona , IE.annoaccademico
  FROM Docenza D JOIN InsErogato IE ON D.id_inserogato = IE.id
    JOIN CorsoInFacolta CF ON IE.id_corsostudi = CF.id_corsostudi
    JOIN Facolta F ON CF.id_facolta = F.id
  WHERE F.nome = 'Scienze matematiche fisiche e naturali'
    AND IE.modulo = 0;
-- sono 2598 righe

SELECT DISTINCT I.id, I.nomeins, P.id, P.nome, P.cognome
FROM InsDocAnnoAtScienze I1
JOIN InsDocAnnoAtScienze I2 ON I1.id_insegn = I2.id_insegn
JOIN Insegn I ON I1.id_insegn = I.id
JOIN Persona P ON I1.id_docente = P.id
WHERE I1.id_docente = I2.id_docente
  AND RIGHT(I1.aa, 4) = LEFT(I2.aa, 4)
ORDER BY I.nomeins, P.id, P.nome, P.cognome;

-- LEFT(stringa, n) prende i primi n caratteri, RIGHT(stringa, n) prende gli ultimi n caratteri
-- aa = '2014/2015': LEFT(aa, 4) ->2014,  RIGHT(aa, 4) ->2015

-- Esercizio 11
-- Trovare per ogni docente il numero di insegnamenti o moduli o unità
-- logistiche a lui assegnate come docente nell'anno accademico
-- 2005/2006, riportare anche coloro che non hanno assegnato alcun
-- insegnamento. Nel risultato si mostri identificatore, nome e cognome
-- del docente insieme al conteggio richiesto (0 per il caso nessun
-- insegnamento/modulo/unità insegnati).
--
-- La soluzione ha 3315 righe.
--
SELECT P.id, P.nome, P.cognome, COUNT(IE.id) AS insDocente
FROM Persona P
  JOIN Docenza D ON P.id = D.id_persona
  JOIN Inserogato IE ON D.id_inserogato = IE.id
  WHERE annoaccademico = '2005/2006'
GROUP BY P.id , P.nome, P.cognome
UNION
SELECT P.id, P.nome, P.cognome, 0 AS insDocente
FROM Persona P
  JOIN Docenza D ON P.id = D.id_persona
WHERE P.id NOT IN (
  SELECT D2.id_persona
  FROM Docenza D2 JOIN Inserogato IE2 ON D2.id_inserogato = IE2.id
  WHERE annoaccademico = '2005/2006');


-- Soluzione ottimizzata
--
SELECT P.id, P.nome, P.cognome, COUNT(IE.id) AS insDocente
FROM Persona P JOIN Docenza D ON P.id = D.id_persona
LEFT JOIN (
  SELECT *
  FROM InsErogato
  WHERE annoaccademico = '2005/2006'
) AS IE ON D.id_inserogato = IE.id
GROUP BY P.id, P.nome, P.cognome ;
