--
-- Esercizio 1
-- Visualizzare in nomi dei corsi di studio che finiscono con la stringa ’informatica’ senza considerare maiuscole/minuscole.

EXPLAIN SELECT nome FROM corsostudi WHERE nome ILIKE '%informatica'; -- ilike è case - insesitive

-- QUERY PLAN
-- ------------------------------------------------------------
--Seq Scan on corsostudi  (cost=0.00..98.94 rows=6 width=86)
--Filter: ((nome)::text ~~* '%informatica'::text)"

-- Creando un indice su nome, il numero di accessi a disco non diminuisce perché il pattern di ricerca inizia con '%'.
-- Quindi nessun indice può migliorare la query.

CREATE INDEX ON corsostudi(nome); 
ANALYZE corsostudi;
EXPLAIN SELECT nome FROM corsostudi WHERE nome ILIKE '%informatica';

--Seq Scan on corsostudi  (cost=0.00..98.94 rows=6 width=86)
--Filter: ((nome)::text ~~* '%informatica'::text)
----------------------------------------------------------------------------------------

-- Esercizio 2
-- Visualizzare in nomi degli insegnamenti che iniziano per ’Teoria...’
-- Soluzione: da ~198 accessi si passa a 47. Gli indici creati sono: ....
--
EXPLAIN SELECT id , nomeins FROM Insegn WHERE nomeins LIKE 'Teoria%';

-- QUERY PLAN
-- ----------------------------------------------------------
-- Seq Scan ON insegn (cost=0.00..198.11 ROWS=55 width=39)
-- Filter:((nomeins)::TEXT~~*'teoria %'::TEXT)

-- Si crea un indice su nomeins.

CREATE INDEX nomeinsErrato_idx ON Insegn (nomeins); 
ANALYZE Insegn;
EXPLAIN SELECT id, nomeins FROM Insegn WHERE nomeins LIKE 'Teoria%';

-- QUERY PLAN
-- ----------------------------------------------------------
-- Seq Scan ON insegn(cost=0.00..198.11 ROWS=55 width=39)
-- Filter:((nomeins)::TEXT~~*'teoria %'::TEXT )

-- L’indice non è stato usato perché l’operatore LIKE può usare solo indici creati con l’opzione varchar_pattern_ops

CREATE INDEX nomeins_idx ON Insegn (nomeins varchar_pattern_ops);
ANALYZE Insegn;
EXPLAIN SELECT id , nomeins FROM Insegn WHERE nomeins LIKE 'Teoria%';

-- QUERY PLAN

 Bitmap Heap Scan on insegn  (cost=5.15..105.37 rows=86 width=43)
   Filter: ((nomeins)::text ~~ 'Teoria %'::text)
   ->  Bitmap Index Scan on nomeins_idx  (cost=0.00..5.13 rows=85 width=0)
         Index Cond: (((nomeins)::text ~>=~ 'Teoria '::text) AND ((nomeins)::text ~<~ 'Teoria!'::text))

----------------------------------------------------------------------------------------

-- Esercizio 3
-- Trovare, per ogni insegnamento erogato dell’a.a. 2013/2014, il suo nome e id della facoltà che lo 
-- gestisce usando la relazione assorbita con facoltà.
-- Soluzione: da ~6398 accessi si passa a ~3981 con la creazione di due indici di cui uno di tipo hash.
--

EXPLAIN SELECT DISTINCT i. nomeins, ie.id_facolta 
FROM insegn i JOIN inserogato ie ON i.id=ie.id_insegn
WHERE annoaccademico ='2013/2014';

-- QUERY PLAN
-- ------------------------------------------------------------------------------
"HashAggregate  (cost=6344.27..6396.14 rows=5187 width=43)"
"  Group Key: i.nomeins, ie.id_facolta"
"  ->  Hash Join  (cost=281.80..6318.34 rows=5187 width=43)"
"        Hash Cond: (ie.id_insegn = i.id)"
"        ->  Seq Scan on inserogato ie  (cost=0.00..5965.21 rows=5187 width=8)"
"              Filter: ((annoaccademico)::text = '2013/2014'::text)"
"        ->  Hash  (cost=179.69..179.69 rows=8169 width=43)"
"              ->  Seq Scan on insegn i  (cost=0.00..179.69 rows=8169 width=43)"

----------------------------------------------------------------------------------------

-- Creando un indice su annoaccademico, il numero di accessi a disco diminuisce:
CREATE INDEX ON inserogato(annoaccademico); 
ANALYZE inserogato ;
EXPLAIN SELECT DISTINCT i.nomeins, ie.id_facolta 
FROM insegn i JOIN inserogato ie ON i.id=ie.id_insegn
WHERE annoaccademico ='2013/2014';

-- QUERY PLAN
-- ----------------------------------------------------------------------------------------------------------
 HashAggregate  (cost=5789.63..5840.82 rows=5119 width=43)
   Group Key: i.nomeins, ie.id_facolta
   ->  Hash Join  (cost=341.77..5764.03 rows=5119 width=43)
         Hash Cond: (ie.id_insegn = i.id)
         ->  Bitmap Heap Scan on inserogato ie  (cost=59.96..5411.84 rows=5119 width=8)
               Recheck Cond: ((annoaccademico)::text = '2013/2014'::text)
               ->  Bitmap Index Scan on inserogato_annoaccademico_idx  (cost=0.00..58.68 rows=5119 width=0)
                     Index Cond: ((annoaccademico)::text = '2013/2014'::text)
         ->  Hash  (cost=179.69..179.69 rows=8169 width=43)
               ->  Seq Scan on insegn i  (cost=0.00..179.69 rows=8169 width=43)


-- Creando un indice di tipo hash su insegn.id, si può verificare se migliora anche la seconda foglia del hash join;
CREATE INDEX ON insegn USING hash(id); 
ANALYZE insegn;
EXPLAIN SELECT DISTINCT i.nomeins, ie.id_facolta  
FROM insegn i JOIN inserogato ie ON i.id=ie.id_insegn 
WHERE annoaccademico ='2013/2014';

-- 
-- Esercizio 4
-- Visualizzare il codice, il nome e l'abbreviazione di tutti corsi di studio che nel nome contengono la sottostringa
-- 'lingue' (eseguire un test case-insensitive: usare ILIKE invece di LIKE).
-- Soluzione: da ~96 accessi si passa a...

EXPLAIN SELECT cs.codice, cs.nome, cs. abbreviazione FROM corsostudi cs WHERE cs.nome ILIKE '%lingue%';

-- QUERY PLAN
-- --------------------------------------------------------------
 Seq Scan on corsostudi cs  (cost=0.00..98.94 rows=19 width=98)
   Filter: ((nome)::text ~~* '%lingue%'::text)
-- Il fatto che il pattern di ricerca abbia ’%’ all’inzio è sufficiente per dire che nessun indice può essere usato.

----------------------------------------------------------------------------------------

-- Esercizio 5
-- Visualizzare identificatori e numero modulo dei moduli reali (modulo>0) degli insegnamenti erogati nel
-- 2010/2011 associati alla facoltà con id=7 tramite la relazione diretta.
-- Soluzione: da ~6310 accessi si passa a ~1460 creando 3 indici.
--

EXPLAIN SELECT ie.id, ie.modulo 
FROM inserogato ie 
WHERE ie.annoaccademico ='2010/2011' AND ie.id_facolta=7 AND modulo > 0;

-- QUERY PLAN
-- ---------------------------------------------------------------------------------------------------------

"Seq Scan on inserogato ie  (cost=0.00..6305.30 rows=849 width=7)"
"  Filter: ((modulo > '0'::numeric) AND ((annoaccademico)::text = '2010/2011'::text) AND (id_facolta = 7))"

-- Creando indice su annoaccademico:

CREATE INDEX ON inserogato(annoaccademico); 
ANALYZE inserogato ;
EXPLAIN SELECT ie.id, ie.modulo  
FROM inserogato ie  
WHERE ie.annoaccademico='2010/2011' AND ie.id_facolta=7 AND modulo>0;

-- QUERY PLAN
-- --------------------------------------------------------------------------
"Bitmap Heap Scan on inserogato ie  (cost=80.85..5588.78 rows=855 width=7)"
"  Recheck Cond: ((annoaccademico)::text = '2010/2011'::text)"
"  Filter: ((modulo > '0'::numeric) AND (id_facolta = 7))"
"  ->  Bitmap Index Scan on inserogato_annoaccademico_idx  (cost=0.00..80.64 rows=6979 width=0)"
"        Index Cond: ((annoaccademico)::text = '2010/2011'::text)"

-- Creando indice su id_facolta:
CREATE INDEX ON inserogato(id_facolta); 
ANALYZE inserogato;
EXPLAIN SELECT ie.id , ie.modulo  
FROM inserogato ie  
WHERE ie.annoaccademico ='2010/2011' AND ie.id_facolta=7 AND modulo > 0;


-- QUERY PLAN
-- -----------------------------------------------------------------------------------

"Bitmap Heap Scan on inserogato ie  (cost=419.08..5143.93 rows=855 width=7)"
"  Recheck Cond: (((annoaccademico)::text = '2010/2011'::text) AND (id_facolta = 7))"
"  Filter: (modulo > '0'::numeric)"
"  ->  BitmapAnd  (cost=419.08..419.08 rows=3139 width=0)"
"        ->  Bitmap Index Scan on inserogato_annoaccademico_idx  (cost=0.00..80.64 rows=6979 width=0)"
"              Index Cond: ((annoaccademico)::text = '2010/2011'::text)"
"        ->  Bitmap Index Scan on inserogato_id_facolta_idx  (cost=0.00..337.76 rows=30596 width=0)"
"              Index Cond: (id_facolta = 7)"

-- Creando indice su modulo:

CREATE INDEX ON inserogato(modulo); 
ANALYZE inserogato;
EXPLAIN SELECT ie.id, ie.modulo 
FROM inserogato ie  
WHERE ie.annoaccademico ='2010/2011' AND ie.id_facolta=7 AND modulo > 0;

-- QUERY PLAN
-- --------------------------------------------------------------------------------------
"Bitmap Heap Scan on inserogato ie  (cost=766.75..3010.30 rows=855 width=7)"
"  Recheck Cond: (((annoaccademico)::text = '2010/2011'::text) AND (id_facolta = 7) AND (modulo > '0'::numeric))"
"  ->  BitmapAnd  (cost=766.75..766.75 rows=855 width=0)"
"        ->  Bitmap Index Scan on inserogato_annoaccademico_idx  (cost=0.00..80.64 rows=6979 width=0)"
"              Index Cond: ((annoaccademico)::text = '2010/2011'::text)"
"        ->  Bitmap Index Scan on inserogato_id_facolta_idx  (cost=0.00..337.76 rows=30596 width=0)"
"              Index Cond: (id_facolta = 7)"
"        ->  Bitmap Index Scan on inserogato_modulo_idx  (cost=0.00..347.21 rows=18522 width=0)"
"              Index Cond: (modulo > '0'::numeric)"

-- Si può anche costruire un unico indice a 3 attributi.

CREATE INDEX ON inserogato(annoaccademico, id_facolta, modulo); 
ANALYZE inserogato;
EXPLAIN SELECT ie.id, ie.modulo 
FROM inserogato ie  
WHERE ie.annoaccademico ='2010/2011' AND ie.id_facolta=7 AND modulo > 0;

-- QUERY PLAN
-- -----------------------------------------------------------------------------------------------------
"Bitmap Heap Scan on inserogato ie  (cost=31.43..2290.74 rows=864 width=7)"
"  Recheck Cond: (((annoaccademico)::text = '2010/2011'::text) AND (id_facolta = 7) AND (modulo > '0'::numeric))"
"  ->  Bitmap Index Scan on inserogato_annoaccademico_id_facolta_modulo_idx  (cost=0.00..31.22 rows=864 width=0)"
"        Index Cond: (((annoaccademico)::text = '2010/2011'::text) AND (id_facolta = 7) AND (modulo > '0'::numeric))"
----------------------------------------------------------------------------------------


-- Esercizio 6
-- Visualizzare il nome e il discriminante (attributo descrizione della tabella Discriminante) degli insegnamenti
-- erogati nel 2009/2010 che non sono moduli e che hanno 3, 5 o 12 crediti.
-- Soluzione: da ~6743 accessi si passa a 1192 creando un indice btree e un indice hash.
--

-EXPLAIN SELECT DISTINCT I.nomeins, D.descrizione FROM Insegn I JOIN InsErogato IE ON I.id = IE.id_insegn 
JOIN Discriminante D ON IE.id_discriminante = D.id
WHERE IE. annoaccademico = '2009/2010'
AND IE. modulo = 0
AND IE. crediti IN (3, 5, 12);

-- QUERY PLAN
-- ---------------------------------------------------------------------------------------------------------------------

"Unique  (cost=6746.69..6751.55 rows=648 width=60)"
"  ->  Sort  (cost=6746.69..6748.31 rows=648 width=60)"
"        Sort Key: i.nomeins, d.descrizione"
"        ->  Nested Loop  (cost=281.81..6716.43 rows=648 width=60)"
"              ->  Hash Join  (cost=281.80..6686.44 rows=1041 width=43)"
"                    Hash Cond: (ie.id_insegn = i.id)"
"                    ->  Seq Scan on inserogato ie  (cost=0.00..6390.32 rows=1041 width=8)"
"                          Filter: (((annoaccademico)::text = '2009/2010'::text) AND (modulo = '0'::numeric) AND (crediti = ANY ('{3,5,12}'::numeric[])))"
"                    ->  Hash  (cost=179.69..179.69 rows=8169 width=43)"
"                          ->  Seq Scan on insegn i  (cost=0.00..179.69 rows=8169 width=43)"
"              ->  Memoize  (cost=0.01..0.05 rows=1 width=25)"
"                    Cache Key: ie.id_discriminante"
"                    Cache Mode: logical"
"                    ->  Index Scan using idx_discriminante on discriminante d  (cost=0.00..0.04 rows=1 width=25)"
"                          Index Cond: (id = ie.id_discriminante)"

-- Creando un indice a tre attributi, si ottiene
CREATE INDEX ON inserogato( annoaccademico, crediti, modulo ); 
ANALYZE inserogato;

EXPLAIN SELECT DISTINCT I.nomeins, D.descrizione
FROM Insegn I JOIN InsErogato IE ON I.id = IE.id_insegn 
JOIN Discriminante D ON IE.id_discriminante = D.id
WHERE IE.annoaccademico = '2009/2010'
AND IE.modulo = 0
AND IE.crediti IN (3, 5, 12);

-- QUERY PLAN
-- --------------------------------------------------------------------------------------------------------------------

"Unique  (cost=3020.48..3025.51 rows=671 width=60)"
"  ->  Sort  (cost=3020.48..3022.15 rows=671 width=60)"
"        Sort Key: i.nomeins, d.descrizione"
"        ->  Hash Join  (cost=325.85..2988.97 rows=671 width=60)"
"              Hash Cond: (ie.id_insegn = i.id)"
"              ->  Hash Join  (cost=44.04..2697.94 rows=671 width=25)"
"                    Hash Cond: (ie.id_discriminante = d.id)"
"                    ->  Bitmap Heap Scan on inserogato ie  (cost=38.98..2682.14 rows=1077 width=8)"
"                          Recheck Cond: (((annoaccademico)::text = '2009/2010'::text) AND (crediti = ANY ('{3,5,12}'::numeric[])) AND (modulo = '0'::numeric))"
"                          ->  Bitmap Index Scan on inserogato_annoaccademico_crediti_modulo_idx  (cost=0.00..38.71 rows=1077 width=0)"
"                                Index Cond: (((annoaccademico)::text = '2009/2010'::text) AND (crediti = ANY ('{3,5,12}'::numeric[])) AND (modulo = '0'::numeric))"
"                    ->  Hash  (cost=3.36..3.36 rows=136 width=25)"
"                          ->  Seq Scan on discriminante d  (cost=0.00..3.36 rows=136 width=25)"
"              ->  Hash  (cost=179.69..179.69 rows=8169 width=43)"
"                    ->  Seq Scan on insegn i  (cost=0.00..179.69 rows=8169 width=43)"

-- Poi si crea indice hash su insegn.id.
CREATE INDEX ON insegn USING hash(id); 
ANALYZE insegn;
EXPLAIN SELECT DISTINCT I.nomeins, D.descrizione
FROM Insegn I JOIN InsErogato IE ON I.id = IE.id_insegn 
JOIN Discriminante D ON IE.id_discriminante = D.id
WHERE IE.annoaccademico = '2009/2010'
AND IE.modulo = 0
AND IE.crediti IN (3, 5, 12);

-- QUERY PLAN
-- --------------------------------------------------------------------------------------------------------------------

"Unique  (cost=2972.80..2977.68 rows=651 width=60)"
"  ->  Sort  (cost=2972.80..2974.43 rows=651 width=60)"
"        Sort Key: i.nomeins, d.descrizione"
"        ->  Hash Join  (cost=320.34..2942.38 rows=651 width=60)"
"              Hash Cond: (ie.id_insegn = i.id)"
"              ->  Nested Loop  (cost=38.54..2651.62 rows=651 width=25)"
"                    ->  Bitmap Heap Scan on inserogato ie  (cost=38.53..2621.57 rows=1042 width=8)"
"                          Recheck Cond: (((annoaccademico)::text = '2009/2010'::text) AND (crediti = ANY ('{3,5,12}'::numeric[])) AND (modulo = '0'::numeric))"
"                          ->  Bitmap Index Scan on inserogato_annoaccademico_crediti_modulo_idx  (cost=0.00..38.27 rows=1042 width=0)"
"                                Index Cond: (((annoaccademico)::text = '2009/2010'::text) AND (crediti = ANY ('{3,5,12}'::numeric[])) AND (modulo = '0'::numeric))"
"                    ->  Memoize  (cost=0.01..0.05 rows=1 width=25)"
"                          Cache Key: ie.id_discriminante"
"                          Cache Mode: logical"
"                          ->  Index Scan using idx_discriminante on discriminante d  (cost=0.00..0.04 rows=1 width=25)"
"                                Index Cond: (id = ie.id_discriminante)"
"              ->  Hash  (cost=179.69..179.69 rows=8169 width=43)"
"                    ->  Seq Scan on insegn i  (cost=0.00..179.69 rows=8169 width=43)"

-- Creando tre indici separati, non si ottengono le stesse prestazioni;

CREATE INDEX ON inserogato(modulo); 
CREATE INDEX ON inserogato(annoaccademico);
CREATE INDEX ON inserogato(crediti);

ANALYZE inserogato;
EXPLAIN SELECT DISTINCT I.nomeins, D.descrizione
FROM Insegn I JOIN InsErogato IE ON I.id=IE.id_insegn JOIN Discriminante D ON IE.id_discriminante=D.id
WHERE IE.annoaccademico = '2009/2010'
AND IE.modulo = 0
AND IE.crediti IN (3, 5, 12);

"Unique  (cost=4023.79..4028.72 rows=657 width=60)"
"  ->  Sort  (cost=4023.79..4025.43 rows=657 width=60)"
"        Sort Key: i.nomeins, d.descrizione"
"        ->  Hash Join  (cost=624.99..3993.04 rows=657 width=60)"
"              Hash Cond: (ie.id_insegn = i.id)"
"              ->  Hash Join  (cost=343.18..3702.21 rows=657 width=25)"
"                    Hash Cond: (ie.id_discriminante = d.id)"
"                    ->  Bitmap Heap Scan on inserogato ie  (cost=338.12..3686.63 rows=1053 width=8)"
"                          Recheck Cond: (((annoaccademico)::text = '2009/2010'::text) AND (crediti = ANY ('{3,5,12}'::numeric[])))"
"                          Filter: (modulo = '0'::numeric)"
"                          ->  BitmapAnd  (cost=338.12..338.12 rows=1555 width=0)"
"                                ->  Bitmap Index Scan on inserogato_annoaccademico_idx  (cost=0.00..90.84 rows=7806 width=0)"
"                                      Index Cond: ((annoaccademico)::text = '2009/2010'::text)"
"                                ->  Bitmap Index Scan on inserogato_crediti_idx  (cost=0.00..246.51 rows=13551 width=0)"
"                                      Index Cond: (crediti = ANY ('{3,5,12}'::numeric[]))"
"                    ->  Hash  (cost=3.36..3.36 rows=136 width=25)"
"                          ->  Seq Scan on discriminante d  (cost=0.00..3.36 rows=136 width=25)"
"              ->  Hash  (cost=179.69..179.69 rows=8169 width=43)"
"                    ->  Seq Scan on insegn i  (cost=0.00..179.69 rows=8169 width=43)"


-- Esercizio 7
-- Visualizzare il nome e il discriminante degli insegnamenti erogati nel 2008/2009 senza moduli e con crediti
-- maggiore di 9.
--
EXPLAIN SELECT DISTINCT I.nomeins AS nome, D.descrizione AS descrizione
FROM InsErogato IE JOIN Discriminante D ON IE.id_discriminante = D.id
JOIN Insegn I ON IE.id_insegn = I.id
WHERE IE.annoaccademico = '2008/2009'
AND IE.hamoduli = '0'
AND IE.crediti > 9;

"Unique  (cost=6632.41..6635.29 rows=383 width=60)"
"  ->  Sort  (cost=6632.41..6633.37 rows=383 width=60)"
"        Sort Key: i.nomeins, d.descrizione"
"        ->  Nested Loop  (cost=281.81..6615.98 rows=383 width=60)"
"              ->  Hash Join  (cost=281.80..6595.57 rows=616 width=43)"
"                    Hash Cond: (ie.id_insegn = i.id)"
"                    ->  Seq Scan on inserogato ie  (cost=0.00..6305.30 rows=616 width=8)"
"                          Filter: ((crediti > '9'::numeric) AND ((annoaccademico)::text = '2008/2009'::text) AND (hamoduli = '0'::bpchar))"
"                    ->  Hash  (cost=179.69..179.69 rows=8169 width=43)"
"                          ->  Seq Scan on insegn i  (cost=0.00..179.69 rows=8169 width=43)"
"              ->  Memoize  (cost=0.01..0.07 rows=1 width=25)"
"                    Cache Key: ie.id_discriminante"
"                    Cache Mode: logical"
"                    ->  Index Scan using idx_discriminante on discriminante d  (cost=0.00..0.06 rows=1 width=25)"
"                          Index Cond: (id = ie.id_discriminante)"
-- Indici:

CREATE INDEX idx_where ON InsErogato (annoaccademico, hamoduli, crediti);
ANALYZE InsErogato;

CREATE INDEX idx_insegn ON Insegn USING hash(id);
ANALYZE Insegn;

--Inserito indice "triplo" sulle condizioni del WHERE poi su Insegn.id per migliorare anche la foglia del hash join.

EXPLAIN SELECT DISTINCT I.nomeins AS nome, D.descrizione AS descrizione
FROM InsErogato IE JOIN Discriminante D ON IE.id_discriminante = D.id
JOIN Insegn I ON IE.id_insegn = I.id
WHERE IE.annoaccademico = '2008/2009'
AND IE.hamoduli = '0'
AND IE.crediti > 9;

"Unique  (cost=2098.69..2101.58 rows=385 width=60)"
"  ->  Sort  (cost=2098.69..2099.66 rows=385 width=60)"
"        Sort Key: i.nomeins, d.descrizione"
"        ->  Hash Join  (cost=306.10..2082.16 rows=385 width=60)"
"              Hash Cond: (ie.id_insegn = i.id)"
"              ->  Nested Loop  (cost=24.29..1795.06 rows=385 width=25)"
"                    ->  Bitmap Heap Scan on inserogato ie  (cost=24.28..1774.13 rows=617 width=8)"
"                          Recheck Cond: (((annoaccademico)::text = '2008/2009'::text) AND (hamoduli = '0'::bpchar) AND (crediti > '9'::numeric))"
"                          ->  Bitmap Index Scan on idx_where  (cost=0.00..24.13 rows=617 width=0)"
"                                Index Cond: (((annoaccademico)::text = '2008/2009'::text) AND (hamoduli = '0'::bpchar) AND (crediti > '9'::numeric))"
"                    ->  Memoize  (cost=0.01..0.07 rows=1 width=25)"
"                          Cache Key: ie.id_discriminante"
"                          Cache Mode: logical"
"                          ->  Index Scan using idx_discriminante on discriminante d  (cost=0.00..0.06 rows=1 width=25)"
"                                Index Cond: (id = ie.id_discriminante)"
"              ->  Hash  (cost=179.69..179.69 rows=8169 width=43)"
"                    ->  Seq Scan on insegn i  (cost=0.00..179.69 rows=8169 width=43)"

----------------------------------------------------------------------------------------

-- Esercizio 8
-- Visualizzare in ordine alfabetico di nome degli insegnamenti (esclusi di moduli e le unità logistiche) erogati
-- nel 2013/2014 nel corso di 'Laurea in Informatica', riportando il nome, il discriminante, i crediti e gli anni di
-- erogazione.
--
EXPLAIN SELECT I.nomeins AS nome, D.descrizione AS descrizione, IE.crediti AS crediti, IE.annierogazione AS annierogazione
FROM InsErogato IE JOIN Discriminante D ON IE.id_discriminante = D.id
JOIN Insegn I ON IE. id_insegn = I.id
JOIN CorsoStudi CS ON CS.id = IE.id_corsostudi
WHERE IE.modulo = 0
AND IE.annoaccademico = '2013/2014'
AND CS.nome = 'Laurea in informatica'
ORDER BY I. nomeins ;

"Sort  (cost=6492.46..6492.47 rows=3 width=69)"
"  Sort Key: i.nomeins"
"  ->  Hash Join  (cost=6282.01..6492.44 rows=3 width=69)"
"        Hash Cond: (ie.id_discriminante = d.id)"
"        ->  Hash Join  (cost=6276.95..6487.33 rows=5 width=52)"
"              Hash Cond: (i.id = ie.id_insegn)"
"              ->  Seq Scan on insegn i  (cost=0.00..179.69 rows=8169 width=43)"
"              ->  Hash  (cost=6276.89..6276.89 rows=5 width=17)"
"                    ->  Nested Loop  (cost=0.00..6276.89 rows=5 width=17)"
"                          Join Filter: (ie.id_corsostudi = cs.id)"
"                          ->  Seq Scan on corsostudi cs  (cost=0.00..98.94 rows=1 width=4)"
"                                Filter: ((nome)::text = 'Laurea in informatica'::text)"
"                          ->  Seq Scan on inserogato ie  (cost=0.00..6135.26 rows=3416 width=21)"
"                                Filter: ((modulo = '0'::numeric) AND ((annoaccademico)::text = '2013/2014'::text))"
"        ->  Hash  (cost=3.36..3.36 rows=136 width=25)"
"              ->  Seq Scan on discriminante d  (cost=0.00..3.36 rows=136 width=25)"
-- Indici :

CREATE INDEX idx_corsostudi ON InsErogato USING hash( id_corsostudi );
ANALYZE InsErogato;

CREATE INDEX idx_insegn ON Insegn USING hash(id);
ANALYZE Insegn;

CREATE INDEX idx_discriminante ON Discriminante USING hash(id);
ANALYZE Discriminante;

CREATE INDEX idx_where1 ON InsErogato( annoaccademico , modulo );
ANALYZE InsErogato;

CREATE INDEX idx_where2 ON CorsoStudi( nome );
ANALYZE CorsoStudi;


"Sort  (cost=137.52..137.52 rows=3 width=68)"
"  Sort Key: i.nomeins"
"  ->  Nested Loop  (cost=97.49..137.49 rows=3 width=68)"
"        ->  Nested Loop  (cost=97.49..136.95 rows=3 width=33)"
"              ->  Nested Loop  (cost=97.49..136.78 rows=5 width=16)"
"                    ->  Index Scan using idx_where2 on corsostudi cs  (cost=0.28..8.29 rows=1 width=4)"
"                          Index Cond: ((nome)::text = 'Laurea in informatica'::text)"
"                    ->  Bitmap Heap Scan on inserogato ie  (cost=97.22..128.41 rows=8 width=20)"
"                          Recheck Cond: ((id_corsostudi = cs.id) AND ((annoaccademico)::text = '2013/2014'::text) AND (modulo = '0'::numeric))"
"                          ->  BitmapAnd  (cost=97.22..97.22 rows=8 width=0)"
"                                ->  Bitmap Index Scan on idx_corsostudi  (cost=0.00..5.25 rows=166 width=0)"
"                                      Index Cond: (id_corsostudi = cs.id)"
"                                ->  Bitmap Index Scan on idx_where1  (cost=0.00..90.86 rows=3444 width=0)"
"                                      Index Cond: (((annoaccademico)::text = '2013/2014'::text) AND (modulo = '0'::numeric))"
"              ->  Index Scan using idx_discriminante on discriminante d  (cost=0.00..0.02 rows=1 width=25)"
"                    Index Cond: (id = ie.id_discriminante)"
"        ->  Index Scan using idx_insegn on insegn i  (cost=0.00..0.17 rows=1 width=43)"
"              Index Cond: (id = ie.id_insegn)"
----------------------------------------------------------------------------------------

-- Esercizio 9
-- Trovare il massimo numero di crediti degli insegnamenti erogati dall’ateneo nell’a.a. 2013/2014.


EXPLAIN SELECT MAX(IE.crediti) AS massimocrediti
FROM InsErogato IE
WHERE IE.annoaccademico = '2013/2014';

"Aggregate  (cost=5977.98..5977.99 rows=1 width=32)"
"  ->  Seq Scan on inserogato ie  (cost=0.00..5965.21 rows=5108 width=4)"
"        Filter: ((annoaccademico)::text = '2013/2014'::text)"

-- Indici :

CREATE INDEX idx_annoaccademico ON InsErogato ( annoaccademico );
ANALYZE InsErogato ;
EXPLAIN SELECT MAX(IE.crediti) AS massimocrediti
FROM InsErogato IE
WHERE IE.annoaccademico = '2013/2014';

"Aggregate  (cost=5456.33..5456.34 rows=1 width=32)"
"  ->  Bitmap Heap Scan on inserogato ie  (cost=61.55..5443.02 rows=5323 width=5)"
"        Recheck Cond: ((annoaccademico)::text = '2013/2014'::text)"
"        ->  Bitmap Index Scan on idx_annoaccademico  (cost=0.00..60.21 rows=5323 width=0)"
"              Index Cond: ((annoaccademico)::text = '2013/2014'::text)"
-------------------------------------------------------------------------------------
-- Esercizio 10
-- Trovare, per ogni anno accademico, il massimo e il minimo numero di crediti erogati in un insegnamento.

EXPLAIN SELECT IE.annoaccademico AS annoaccademico, MAX(IE.crediti) AS massimocrediti, MIN(IE.crediti) AS minimocrediti
FROM InsErogato IE
GROUP BY IE.annoaccademico
ORDER BY IE.annoaccademico;

"Sort  (cost=6305.78..6305.82 rows=16 width=74)"
"  Sort Key: annoaccademico"
"  ->  HashAggregate  (cost=6305.30..6305.46 rows=16 width=74)"
"        Group Key: annoaccademico"
"        ->  Seq Scan on inserogato ie  (cost=0.00..5795.17 rows=68017 width=14)"

-- Indici :

CREATE INDEX idx_annoaccademico ON InsErogato ( annoaccademico );
CREATE INDEX idx_crediti ON InsErogato ( crediti );
ANALYZE InsErogato;
EXPLAIN SELECT IE.annoaccademico AS annoaccademico, MAX(IE.crediti) AS massimocrediti, MIN(IE.crediti) AS minimocrediti
 FROM InsErogato IE
 GROUP BY IE.annoaccademico
ORDER BY IE.annoaccademico;

-- Creando indice su annoaccademico e/o su crediti NON cambia nulla.

"Sort  (cost=6305.78..6305.82 rows=16 width=74)"
"  Sort Key: annoaccademico"
"  ->  HashAggregate  (cost=6305.30..6305.46 rows=16 width=74)"
"        Group Key: annoaccademico"
"        ->  Seq Scan on inserogato ie  (cost=0.00..5795.17 rows=68017 width=14)"
----------------------------------------------------------------------------------------

--
-- Esercizio 11
-- Trovare il nome dei corsi di studio che non hanno mai erogato insegnamenti che contengono nel nome la stringa
-- 'matematica' (usare ILIKE invece di LIKE per rendere il test non sensibile alle maiuscole/minuscole).
-- Soluzione: meno di 942 accessi.
--

SELECT DISTINCT CS.nome AS nome
FROM CorsoStudi CS
WHERE CS.id NOT IN ( SELECT DISTINCT IE.id_corsostudi
FROM InsErogato IE JOIN INSEGN I ON I.id = IE.id_insegn
WHERE I. nomeins ILIKE '% matematica %'
);

"Unique  (cost=6364.43..6366.02 rows=318 width=86)"
"  ->  Sort  (cost=6364.43..6365.23 rows=318 width=86)"
"        Sort Key: cs.nome"
"        ->  Seq Scan on corsostudi cs  (cost=6252.28..6351.21 rows=318 width=86)"
"              Filter: (NOT (hashed SubPlan 1))"
"              SubPlan 1"
"                ->  Unique  (cost=6251.96..6252.17 rows=42 width=4)"
"                      ->  Sort  (cost=6251.96..6252.07 rows=42 width=4)"
"                            Sort Key: ie.id_corsostudi"
"                            ->  Hash Join  (cost=200.18..6250.83 rows=42 width=4)"
"                                  Hash Cond: (ie.id_insegn = i.id)"
"                                  ->  Seq Scan on inserogato ie  (cost=0.00..5795.17 rows=68017 width=8)"
"                                  ->  Hash  (cost=200.11..200.11 rows=5 width=4)"
"                                        ->  Seq Scan on insegn i  (cost=0.00..200.11 rows=5 width=4)"
"                                              Filter: ((nomeins)::text ~~* '% matematica %'::text)"

-- Indici :

CREATE INDEX idx_insegn ON Insegn USING hash(id);
 ANALYZE Insegn;

CREATE INDEX idx_insegn_2 ON InsErogato USING hash(id_insegn);
ANALYZE InsErogato;

EXPLAIN SELECT DISTINCT CS.nome AS nome
FROM CorsoStudi CS
WHERE CS.id NOT IN ( SELECT DISTINCT IE.id_corsostudi
FROM InsErogato IE JOIN INSEGN I ON I.id = IE.id_insegn
WHERE I. nomeins ILIKE '% matematica %'
);

"HashAggregate  (cost=535.30..538.48 rows=318 width=86)"
"  Group Key: cs.nome"
"  ->  Seq Scan on corsostudi cs  (cost=435.57..534.51 rows=318 width=86)"
"        Filter: (NOT (hashed SubPlan 1))"
"        SubPlan 1"
"          ->  Unique  (cost=435.26..435.47 rows=42 width=4)"
"                ->  Sort  (cost=435.26..435.36 rows=42 width=4)"
"                      Sort Key: ie.id_corsostudi"
"                      ->  Nested Loop  (cost=4.09..434.12 rows=42 width=4)"
"                            ->  Seq Scan on insegn i  (cost=0.00..200.11 rows=5 width=4)"
"                                  Filter: ((nomeins)::text ~~* '% matematica %'::text)"
"                            ->  Bitmap Heap Scan on inserogato ie  (cost=4.09..46.69 rows=11 width=8)"
"                                  Recheck Cond: (id_insegn = i.id)"
"                                  ->  Bitmap Index Scan on idx_insegn_2  (cost=0.00..4.08 rows=11 width=0)"
"                                        Index Cond: (id_insegn = i.id)"

----------------------------------------------------------------------------------------

-- 
-- Esercizio 12
-- Trovare, per ogni anno accademico e per ogni corso di laurea, la somma dei crediti erogati (esclusi i moduli e le
-- unità logistiche: vedi nota sopra) e il massimo e minimo numero di crediti degli insegnamenti erogati sempre
-- escludendo i moduli e le unità logistiche.
-- Soluzione: da ~7408 accessi si passa a...
--

EXPLAIN SELECT IE.annoaccademico, CS.nome , SUM(IE.crediti) AS sommaCrediti, MAX(IE.crediti) AS maxCrediti, MIN(IE.crediti) AS minCrediti
FROM InsErogato IE JOIN CorsoStudi CS ON IE.id_corsostudi = CS.id
WHERE IE.modulo = 0
GROUP BY IE.annoaccademico, CS.nome;

-- QUERY PLAN
-- ---------------------------------------------------------------------------------

"HashAggregate  (cost=7277.82..7404.82 rows=10160 width=192)"
"  Group Key: ie.annoaccademico, cs.nome"
"  ->  Hash Join  (cost=105.29..6702.90 rows=45993 width=100)"
"        Hash Cond: (ie.id_corsostudi = cs.id)"
"        ->  Seq Scan on inserogato ie  (cost=0.00..5965.21 rows=45993 width=18)"
"              Filter: (modulo = '0'::numeric)"
"        ->  Hash  (cost=97.35..97.35 rows=635 width=90)"
"              ->  Seq Scan on corsostudi cs  (cost=0.00..97.35 rows=635 width=90)"

CREATE INDEX idx_modulo ON insErogato ( modulo );
CREATE INDEX idx_corsostudi ON insErogato ( id_corsostudi );
CREATE INDEX idx_corsx ON corsostudi USING hash(id);
ANALYZE insErogato;
ANALYZE corsostudi;
-- Creando indici su modulo, id_corsostudi e id di corsostudi NON cambia nulla.

"HashAggregate  (cost=7277.82..7404.82 rows=10160 width=192)"
"  Group Key: ie.annoaccademico, cs.nome"
"  ->  Hash Join  (cost=105.29..6702.90 rows=45993 width=100)"
"        Hash Cond: (ie.id_corsostudi = cs.id)"
"        ->  Seq Scan on inserogato ie  (cost=0.00..5965.21 rows=45993 width=18)"
"              Filter: (modulo = '0'::numeric)"
"        ->  Hash  (cost=97.35..97.35 rows=635 width=90)"
"              ->  Seq Scan on corsostudi cs  (cost=0.00..97.35 rows=635 width=90)"

