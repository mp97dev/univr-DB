-- query-soluzioni.sql — database "scuola"
-- Schema: insegnante, classe, studente, esame
--
-- Legenda dei commenti:
--   NOVITÀ:      costrutto SQL che gli studenti vedono probabilmente per la prima volta
--   ATTENZIONE:  trabocchetto / errore tipico
--   Risultato:   cosa dovrebbe uscire con i dati di 02_data.sql
--
-- Ogni query termina con ";": è obbligatorio per separare una query dalla successiva.
-- Per provarne una sola, commenta le altre con "--".
--
-- Tre idee che servono quasi ovunque:
--  * NULL significa "valore sconosciuto/assente" (qui: voto NULL = studente assente).
--    Non si confronta con "=" ma con "IS NULL" / "IS NOT NULL". Le funzioni di aggregazione
--    (avg, count(colonna), min, max) ignorano i NULL; count(*) invece conta tutte le righe.
--  * JOIN = unisce le righe di due tabelle. LEFT JOIN tiene anche le righe della tabella di
--    sinistra senza corrispondenza (le colonne dell'altra tabella diventano NULL).
--  * Se nel SELECT c'è una colonna "normale" accanto a una funzione di aggregazione
--    (avg, count...), quella colonna va nel GROUP BY.


-- ---- LIVELLO 1: SELECT / WHERE / ORDER BY ----

-- 1. Studenti nati dopo il 2009-01-01, ordinati per data di nascita.
select nome, cognome, data_nascita
from studente
where data_nascita > '2009-01-01'
order by data_nascita;
-- Le date si scrivono tra apici nel formato 'AAAA-MM-GG' e si confrontano con > < =.
-- Si può anche usare EXTRACT(YEAR FROM data_nascita), ma qui non serve e confrontare
-- direttamente la data è più preciso: "dopo il 2009-01-01" è una data, non un anno
-- (con EXTRACT(YEAR ...) >= 2009 includeresti anche chi è nato esattamente il 2009-01-01).


-- 2. Insegnanti di 'Matematica' oppure 'Fisica'.
select *
from insegnante
where materia in ('Matematica', 'Fisica');
-- NOVITÀ: IN (...) è una scorciatoia per "materia = 'Matematica' OR materia = 'Fisica'".
-- Le stringhe vanno tra apici SINGOLI (gli apici doppi indicano nomi di colonne/tabelle).


-- 3. Esami orali con voto < 6, esclusi gli assenti.
select *
from esame
where tipo = 'orale'
  and voto < 6;
-- NOVITÀ: con voto NULL il confronto "voto < 6" non è né vero né falso (è "sconosciuto") e
-- WHERE scarta le righe non vere: gli assenti sono già esclusi. Aggiungere
-- "and voto is not null" non sbaglia, ma è ridondante.


-- ---- LIVELLO 2: JOIN tra più tabelle ----

-- 4. Per ogni esame: studente, insegnante, materia, voto.
select s.cognome as cognome_studente, s.nome as nome_studente,
       i.cognome as cognome_insegnante, i.nome as nome_insegnante,
       e.materia, e.voto
from esame e
join studente   s on s.id = e.studente_id
join insegnante i on i.id = e.insegnante_id;
-- NOVITÀ: gli alias di tabella (esame e, studente s...) abbreviano i nomi; servono per forza
-- quando due tabelle hanno colonne con lo stesso nome (qui nome e cognome esistono in
-- entrambe). "as" rinomina la colonna nel risultato.
-- ATTENZIONE: la traccia chiede cognome E nome di entrambi: non dimenticare il nome dell'insegnante.


-- 5. Tutte le classi con il coordinatore, anche quelle senza coordinatore.
select c.nome, c.anno, c.sezione, i.nome as nome_coordinatore, i.cognome as cognome_coordinatore
from classe c
left join insegnante i on i.id = c.coordinatore_id;
-- NOVITÀ: LEFT JOIN. Con un JOIN normale la classe 5A (coordinatore_id NULL) sparirebbe;
-- con LEFT JOIN resta, con nome e cognome del coordinatore a NULL.


-- 6. Tutti gli studenti con la classe, anche chi non ha classe.
select s.nome, s.cognome, c.nome as classe
from studente s
left join classe c on c.id = s.classe_id;
-- Risultato: Elisa Lombardi compare con classe NULL.


-- ---- LIVELLO 3: aggregazioni GROUP BY / HAVING ----

-- 7. Per ogni studente: numero di esami sostenuti e media voti (assenti esclusi), media decrescente.
select s.id, s.nome, s.cognome,
       count(e.voto) as esami_sostenuti,
       avg(e.voto)   as media
from studente s
left join esame e on e.studente_id = s.id
group by s.id, s.nome, s.cognome
order by media desc nulls last;
-- NOVITÀ: GROUP BY forma un gruppo per ogni studente e le funzioni aggregate lavorano gruppo per gruppo.
-- NOVITÀ: count(e.voto) conta solo i voti NON NULL (gli assenti no); count(*) li conterebbe.
-- Si raggruppa per s.id (univoco) e non solo per nome/cognome: due studenti omonimi
-- altrimenti verrebbero fusi in un unico gruppo.
-- LEFT JOIN partendo da studente: chi non ha esami resta in elenco (conteggio 0, media NULL).
-- ATTENZIONE: in PostgreSQL con "order by ... desc" i NULL vengono PRIMA di tutto;
-- "nulls last" li manda in fondo.


-- 8. Per ogni materia: numero di esami e voto medio, solo le materie con più di 4 esami sostenuti.
select materia, count(voto) as esami_sostenuti, avg(voto) as media
from esame
group by materia
having count(voto) > 4;
-- NOVITÀ: HAVING filtra i GRUPPI dopo l'aggregazione; WHERE filtra le RIGHE prima.
-- Non si può scrivere "where count(voto) > 4": il conteggio non esiste ancora a quel punto.
-- ATTENZIONE: "esami sostenuti" esclude gli assenti, quindi count(voto) e non count(*).
-- Differenza reale sui dati: Inglese ha 5 esami ma uno è un'assenza, quindi 4 sostenuti
-- e NON passa il filtro "> 4".


-- 9. Per ogni classe il numero di studenti, anche 0.
select c.nome as classe, count(s.id) as studenti
from classe c
left join studente s on s.classe_id = c.id
group by c.id, c.nome
order by c.nome;
-- ATTENZIONE: serve count(s.id) e non count(*): per la classe 5A il LEFT JOIN produce
-- UNA riga con s.id NULL; count(*) darebbe 1, count(s.id) ignora il NULL e dà 0.
-- (coalesce(count(...), 0) è superfluo: count non restituisce mai NULL.)


-- ---- LIVELLO 4: subquery scalari e subquery in WHERE ----

-- 10. Studenti con almeno un voto superiore alla media di TUTTI i voti.
select s.nome, s.cognome, max(e.voto) as voto_massimo
from studente s
join esame e on e.studente_id = s.id
group by s.id, s.nome, s.cognome
having max(e.voto) > (select avg(voto) from esame);
-- NOVITÀ: subquery scalare = una SELECT tra parentesi che restituisce un solo valore
-- (qui un numero) e che si usa come se fosse una costante.
-- "Almeno un voto > X" equivale a "il voto massimo > X".
-- Variante senza GROUP BY: select distinct s.nome, s.cognome from studente s
--   join esame e on e.studente_id = s.id where e.voto > (select avg(voto) from esame);
-- ATTENZIONE: DISTINCT è necessario lì, altrimenti lo studente compare una volta per voto.


-- 11. Insegnante/i assunto/i più di recente.
select *
from insegnante
where data_assunzione = (select max(data_assunzione) from insegnante);
-- Risultato: Elena Ferrari e Maurizio Lercio (stessa data: per questo non basta "limit 1").
-- Si usa la subquery con max() e non "order by ... desc limit 1": se ci fosse una data NULL,
-- in PostgreSQL "desc" mette i NULL per primi e sbaglieresti.


-- 12. Classi con più studenti della media di studenti per classe (solo classi con almeno uno studente).
with studenti_per_classe as (
    select c.id, c.nome, count(*) as n_studenti
    from classe c
    join studente s on s.classe_id = c.id
    group by c.id, c.nome
)
select nome, n_studenti
from studenti_per_classe
where n_studenti > (select avg(n_studenti) from studenti_per_classe);
-- NOVITÀ: WITH ... AS (...) è una CTE: una "tabella temporanea con nome" valida solo per
-- questa query; rende leggibili le query a più passaggi. Qui la usiamo due volte.
-- Il JOIN normale esclude già le classi senza studenti, come richiesto.


-- ---- LIVELLO 5: subquery correlate, EXISTS / NOT EXISTS ----

-- 13. Studenti che non hanno mai sostenuto un esame.
select s.nome, s.cognome
from studente s
where not exists (
    select 1
    from esame e
    where e.studente_id = s.id
);
-- NOVITÀ: subquery CORRELATA = la subquery usa una colonna della query esterna (s.id), quindi
-- viene valutata per ogni studente. EXISTS è vero se la subquery restituisce almeno una riga;
-- NOT EXISTS se non ne restituisce nessuna. Il contenuto del SELECT è irrilevante: per questo "select 1".
-- ATTENZIONE: se manca "e.studente_id = s.id" la subquery non dipende più dallo studente: esiste sempre
-- almeno un esame nel database, quindi NOT EXISTS è sempre falso e non esce nessuna riga.
-- Risultato: Davide Barbieri ed Elisa Lombardi.
-- Variante equivalente: select ... from studente s left join esame e on e.studente_id = s.id
--   where e.id is null;


-- 14. Insegnanti che non coordinano alcuna classe.
select i.nome, i.cognome
from insegnante i
where not exists (
    select 1
    from classe c
    where c.coordinatore_id = i.id
);
-- Risultato: Neri, Conti, Ferrari, Lercio.


-- 15. Studenti con almeno un'assenza (voto NULL): nome, cognome, materia.
select s.nome, s.cognome, e.materia
from studente s
join esame e on e.studente_id = s.id
where e.voto is null;
-- Qui basta un JOIN: ogni riga di esame con voto NULL è un'assenza e porta con sé la materia.
-- Si può farlo con EXISTS, ma poi non si potrebbe mostrare la materia (sta nella subquery).
-- ATTENZIONE: si scrive "voto IS NULL", mai "voto = NULL" (non è mai vero).
-- Risultato: Alessandro Marino, Inglese.


-- ---- LIVELLO 6: subquery con ALL / ANY ----

-- 16. Studenti il cui voto minimo è maggiore del voto massimo di 'Matteo Bruno'.
select s.nome, s.cognome, min(e.voto) as voto_minimo
from studente s
join esame e on e.studente_id = s.id
group by s.id, s.nome, s.cognome
having min(e.voto) > (
    select max(e2.voto)
    from esame e2
    join studente b on b.id = e2.studente_id
    where b.nome = 'Matteo' and b.cognome = 'Bruno'
);
-- Il massimo di Matteo è 9.5, quindi con questi dati non esce nessuno (risultato vuoto: è corretto).
-- NOVITÀ: equivalente con ALL: "min(e.voto) > ALL (subquery che restituisce molti valori)"
-- è vero se è maggiore di TUTTI i valori restituiti. ANY/SOME = maggiore di ALMENO uno.
--   having min(e.voto) > all (select e2.voto from esame e2 join studente b on b.id = e2.studente_id
--                             where b.nome = 'Matteo' and b.cognome = 'Bruno' and e2.voto is not null)
-- ATTENZIONE: con ALL un solo NULL nel risultato della subquery rende il confronto "sconosciuto":
-- per questo si aggiunge "is not null".


-- 17. Insegnanti tutti i cui voti assegnati sono >= 6 (ignora le assenze).
select i.nome, i.cognome
from insegnante i
where exists (select 1 from esame e where e.insegnante_id = i.id and e.voto is not null)
  and 6 <= all (select e.voto from esame e where e.insegnante_id = i.id and e.voto is not null);
-- "6 <= ALL (voti)" = ogni voto è almeno 6.
-- ATTENZIONE: su un insieme VUOTO "ALL" è sempre vero: un insegnante senza esami (Ferrari, Lercio)
-- passerebbe senza che abbia mai dato un voto. Il primo EXISTS li esclude.
-- Variante: where not exists (select 1 from esame e where e.insegnante_id = i.id and e.voto < 6)
--   (+ la stessa condizione "ha dato almeno un voto").


-- ---- LIVELLO 7: subquery annidate multiple / query per gruppo ----

-- 18. Per ogni classe, lo studente con la media voti più alta.
with medie as (
    select c.id as classe_id, c.nome as classe, s.id as studente_id, s.nome, s.cognome,
           avg(e.voto) as media
    from classe c
    join studente s on s.classe_id = c.id
    join esame e on e.studente_id = s.id
    group by c.id, c.nome, s.id, s.nome, s.cognome
)
select classe, nome, cognome, round(media, 2) as media
from medie m
where media = (select max(media) from medie where classe_id = m.classe_id)
order by classe;
-- Schema "il migliore per gruppo": 1) calcola il valore per ogni (gruppo, elemento);
-- 2) tieni le righe il cui valore è uguale al massimo del PROPRIO gruppo (subquery correlata).
-- In caso di parità escono tutti gli studenti a pari merito.
-- round(x, 2) arrotonda a 2 decimali.
-- Variante con funzione finestra: rank() over (partition by classe order by media desc) = 1.


-- 19. Classi la cui media voti è superiore alla media generale della scuola.
select c.nome as classe, round(avg(e.voto), 2) as media
from classe c
join studente s on s.classe_id = c.id
join esame e on e.studente_id = s.id
group by c.id, c.nome
having avg(e.voto) > (select avg(voto) from esame)
order by c.nome;
-- Qui "media della classe" = media di tutti i voti degli studenti della classe
-- (non la media delle medie dei singoli studenti: sono numeri diversi).
-- Gli studenti senza classe non vengono considerati dai JOIN.


-- 20. Per ogni studente e materia: media dello studente in quella materia > media generale della materia.
select s.nome, s.cognome, e.materia,
       round(avg(e.voto), 2) as media_studente,
       round((select avg(x.voto) from esame x where x.materia = e.materia), 2) as media_materia
from studente s
join esame e on e.studente_id = s.id
group by s.id, s.nome, s.cognome, e.materia
having avg(e.voto) > (select avg(x.voto) from esame x where x.materia = e.materia)
order by e.materia, s.cognome;
-- La subquery è correlata a e.materia, che è nel GROUP BY, quindi può essere usata nell'HAVING.
-- "x" è un secondo alias sulla stessa tabella esame (serve per distinguerla da "e" esterna).


-- ---- LIVELLO 8: insiemistica e "divisione relazionale" ----

-- 21. Email non nulle di studenti e insegnanti in un'unica lista, con colonna 'ruolo'.
select email, 'studente' as ruolo
from studente
where email is not null
union all
select email, 'insegnante'
from insegnante
where email is not null
order by ruolo, email;
-- NOVITÀ: UNION impila i risultati di due SELECT (stesso numero di colonne e tipi compatibili).
-- Un valore fisso tra apici ('studente') crea una colonna costante.
-- UNION elimina i duplicati (più lento); UNION ALL li tiene: qui non possono esserci duplicati
-- tra le due tabelle perché ogni riga ha un ruolo diverso, quindi UNION ALL è la scelta giusta.
-- ORDER BY si scrive una sola volta, alla fine.


-- 22. (Divisione relazionale) Studenti con almeno un esame in OGNI materia insegnata.
select s.nome, s.cognome
from studente s
where not exists (
    select 1
    from (select distinct materia from insegnante) m
    where not exists (
        select 1
        from esame e
        where e.studente_id = s.id
          and e.materia = m.materia
          and e.voto is not null
    )
);
-- Si legge: "studente per cui NON esiste una materia per cui NON esiste un suo esame".
-- Doppio NOT EXISTS: è il modo classico di dire "per ogni" in SQL (che non ha un "FOR ALL").
-- Con i dati nessuno qualifica: Motoria (Lercio) non ha nessun esame, quindi il risultato è vuoto.
-- Variante con conteggio (più corta, valida se tutte le materie degli esami esistono in insegnante):
--   select s.nome, s.cognome from studente s join esame e on e.studente_id = s.id
--   where e.voto is not null group by s.id, s.nome, s.cognome
--   having count(distinct e.materia) = (select count(distinct materia) from insegnante);
-- Il distinct è importante: uno studente può fare più esami nella stessa materia.


-- 23. Insegnanti che insegnano una materia in cui esiste sia un voto < 6 sia un voto >= 9.
select i.nome, i.cognome, i.materia
from insegnante i
where exists (select 1 from esame e where e.materia = i.materia and e.voto < 6)
  and exists (select 1 from esame e where e.materia = i.materia and e.voto >= 9);
-- Ogni condizione "esiste un..." è un EXISTS separato (due righe diverse della stessa tabella:
-- un solo "where voto < 6 and voto >= 9" non sarebbe mai vero).
-- Si guardano TUTTI gli esami della materia, anche quelli dati da altri insegnanti.
-- Risultato: Maria Rossi ed Elena Ferrari (Matematica: ha 4.5 e 10).
