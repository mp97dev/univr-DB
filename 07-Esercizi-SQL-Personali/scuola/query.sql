-- Nomi degli studenti che hanno una media degli esami orali maggiore di quella degli esami scritti
--
-- Bug della versione originale: usava LEFT JOIN + COALESCE(sc.media, 0). Così uno
-- studente senza NESSUN esame scritto (es. chi ha solo esami orali) risultava comunque
-- "vero" nel confronto (media_orale > 0), pur non avendo nulla da confrontare.
-- Correzione: serve un INNER JOIN, la condizione ha senso solo se esistono entrambe le medie.
-- with mediaOrali AS (
--     select avg(e.voto) as media, e.studente_id
--     from esame e
--     where e.tipo = 'orale'
--     group by e.studente_id
-- ),
-- mediaScritti AS (
--     select avg(e.voto) as media, e.studente_id
--     from esame e
--     where e.tipo = 'scritto'
--     group by e.studente_id
-- )
-- select s.nome, s.cognome, o.media as media_orale, sc.media as media_scritti
-- from mediaOrali o
-- join mediaScritti sc on o.studente_id = sc.studente_id
-- join studente s on s.id = o.studente_id
-- where o.media > sc.media
-- order by s.cognome, s.nome;


-- =====================================================================
-- ESERCIZI (difficoltà crescente) — schema: insegnante, classe, studente, esame
-- Scrivi la query sotto ogni enunciato. Le soluzioni le scrivo io, le correzioni le fai tu :)
-- =====================================================================

-- ---- LIVELLO 1: SELECT / WHERE / ORDER BY ----

-- 1. Elenca nome e cognome degli studenti nati dopo il 2009-01-01, ordinati per data di nascita.
-- select s.nome, s.cognome, s.data_nascita
-- from studente s
-- where EXTRACT(YEAR from s.data_nascita) >= 2009
-- order by s.data_nascita;

-- 2. Elenca gli insegnanti la cui materia è 'Matematica' oppure 'Fisica'.
-- select * from insegnante i
-- where i.materia = 'Matematica' or i.materia = 'Fisica';

-- 3. Elenca gli esami di tipo 'orale' con voto minore di 6 (escludi gli assenti, cioè voto NULL).
-- select * from esame e
-- where e.tipo = 'orale' and e.voto < 6 and e.voto is not null;

---- LIVELLO 2: JOIN tra più tabelle ----

-- 4. Per ogni esame mostra: cognome e nome dello studente, cognome e nome dell'insegnante, materia e voto.
-- select s.cognome, s.nome, i.cognome as docente, e.materia, e.voto
-- from esame e join studente s on e.studente_id = s.id
-- join insegnante i on e.insegnante_id = i.id;

-- 5. Elenca tutte le classi con nome, anno, sezione e nome/cognome del coordinatore;
-- --    includi anche le classi senza coordinatore.
-- select c.nome, c.anno, c.sezione, i.nome as nome_coord, i.cognome as cognome_coord
-- from classe c left join insegnante i on c.coordinatore_id = i.id; 

-- 6. Elenca tutti gli studenti con il nome della classe di appartenenza;
--    includi anche chi non è assegnato a nessuna classe.
-- select s.nome, s.cognome, c.nome as classe
-- from studente s left join classe c on s.classe_id = c.id;

-- ---- LIVELLO 3: aggregazioni GROUP BY / HAVING ----

-- 7. Per ogni studente calcola numero di esami sostenuti e media dei voti (esclusi gli assenti);
--    ordina per media decrescente.
-- select s.nome, s.cognome,  count(e.voto) as count, avg(e.voto) as media
-- from esame e right join studente s on e.studente_id = s.id
-- group by s.nome, s.cognome;

-- 8. Per ogni materia mostra il numero di esami e il voto medio; mostra solo le materie
--    con più di 4 esami sostenuti.
-- with esPerMat as (
-- select e.materia, count(e.materia) as count_esami, avg(e.voto) as media_esami
-- from esame e group by e.materia)
-- select x.materia, x.count_esami, x.media_esami from esPerMat x where x.count_esami > 4;

-- 9. Per ogni classe conta quanti studenti sono assegnati; includi anche le classi senza
--    studenti (il conteggio deve risultare 0, non deve mancare la riga).
-- select c.nome as classe, coalesce(count(s.id), 0) as alunni
-- from classe c left join studente s on c.id = s.classe_id
-- group by c.nome 

-- ---- LIVELLO 4: subquery scalari e subquery in WHERE ----

-- 10. Trova gli studenti che hanno ottenuto almeno un voto superiore alla media di TUTTI
--     i voti presenti nel database.
-- with maxStudente as (
--     select s.id, s.nome, s.cognome, max(e.voto) as max
--     from esame e join studente s on e.studente_id = s.id
--     group by s.id, s.nome, s.cognome
-- )
-- select m.nome, m.cognome, m.max
-- from maxStudente m join esame e on e.studente_id = m.id
-- where m.max > (select avg(x.voto) from esame x);

-- 11. Trova l'insegnante (o gli insegnanti) assunto/i più di recente.
-- with primaData as (
--     select i.data_assunzione as ass from insegnante i group by i.data_assunzione order by i.data_assunzione desc limit 1
-- )
-- select * from insegnante i join primaData p on p.ass = i.data_assunzione;

-- 12. Trova le classi che hanno un numero di studenti superiore alla media di studenti
--     per classe (considera solo le classi con almeno uno studente).

-- with cs as (
--     select c.id, c.nome, c.anno, c.sezione, c.aula, count(s.id)
--     from classe c join studente s on s.classe_id = c.id
--     group by c.id, c.nome, c.anno, c.sezione, c.aula
-- )
-- select cs.id, cs.nome, cs.anno, cs.sezione, cs.aula from cs where cs.count > (select avg(x.count) from cs x);


-- ---- LIVELLO 5: subquery correlate, EXISTS / NOT EXISTS ----

-- 13. Trova gli studenti che non hanno mai sostenuto un esame.
-- select * from studente s
-- where not exists (
--     select * from esame e join studente st on e.studente_id = st.id 
-- );


-- 14. Trova gli insegnanti che non coordinano alcuna classe.
-- select * from insegnante i
-- where not exists (
--     select * from classe c where c.coordinatore_id = i.id
-- );

-- 15. Trova gli studenti che hanno almeno un'assenza (voto NULL) in un esame; mostra
--     nome, cognome e materia dell'esame in cui sono risultati assenti.

-- select s.nome, s.cognome, es.materia
-- from studente s left join esame es on s.id = es.studente_id
-- where not exists (
--     select * from esame e where e.studente_id = s.id
-- )

-- select s.nome, s.cognome, e.materia, e.voto
-- from studente s left join esame e on s.id = e.studente_id
-- where exists (
--     select * from esame where voto is NULL
-- )


-- ---- LIVELLO 6: subquery con ALL / ANY ----

-- 16. Trova gli studenti il cui voto minimo (tra tutti i loro esami) è maggiore del voto
--     massimo ottenuto dallo studente 'Matteo Bruno'.


-- 17. Trova gli insegnanti tutti i cui voti assegnati sono maggiori o uguali a 6
--     (nessun voto insufficiente assegnato; ignora le assenze).


-- ---- LIVELLO 7: subquery annidate multiple / query per gruppo ----

-- 18. Per ogni classe, trova lo studente con la media voti più alta della classe
--     (mostra classe, nome, cognome, media).

-- with mediaClassi as ( 
--     select
-- ) 



-- 19. Trova le classi la cui media voti degli studenti è superiore alla media voti
--     generale di tutta la scuola.


-- 20. Per ogni studente e materia in cui ha almeno un esame, trova i casi in cui la sua
--     media in quella materia supera la media generale della materia calcolata su tutti
--     gli studenti.


-- ---- LIVELLO 8: insiemistica e "divisione relazionale" ----

-- 21. Elenca in un'unica lista (con una colonna 'ruolo') le email non nulle di studenti
--     e insegnanti, specificando se appartengono a uno studente o a un insegnante.


-- 22. (Divisione relazionale) Trova gli studenti che hanno sostenuto almeno un esame in
--     OGNI materia tra quelle insegnate (nessuna materia, tra quelle esistenti in
--     insegnante, deve risultare "mancante" per lo studente).


-- 23. Trova gli insegnanti che insegnano una materia in cui esiste sia almeno un voto
--     insufficiente (<6) sia almeno un voto eccellente (>=9).
