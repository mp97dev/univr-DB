-- query-soluzioni.sql — database "turismo"
-- Schema: turista(username PK, nome, cognome, data_nascita, email, citta)
--         attrazione(codice PK, nome, citta, tipo, costo_biglietto)
--         prenotazione((turista, attrazione, data) PK, data_visita, orario_visita)
--
-- Due colonne data diverse in prenotazione:
--   data        = il giorno in cui è stata EFFETTUATA la prenotazione
--   data_visita = il giorno in cui avviene la VISITA
-- Prima di scrivere la query bisogna capire quale delle due serve (qui: query 1 data_visita,
-- query 2 data). Leggere bene la traccia è metà dell'esercizio.


-- 1. Quanti turisti nel 2026 hanno visitato più attrazioni distinte che nel 2025.
with visite_2025 as (
    select turista, count(distinct attrazione) as n_attrazioni
    from prenotazione
    where extract(year from data_visita) = 2025
    group by turista
),
visite_2026 as (
    select turista, count(distinct attrazione) as n_attrazioni
    from prenotazione
    where extract(year from data_visita) = 2026
    group by turista
)
select count(*) as turisti_piu_attrazioni_2026
from visite_2026 v26
left join visite_2025 v25 on v25.turista = v26.turista
where v26.n_attrazioni > coalesce(v25.n_attrazioni, 0);
-- NOVITÀ: WITH ... AS (...) = CTE, una "tabella temporanea con nome" per spezzare il problema
--   in passi: prima le visite per turista del 2025, poi quelle del 2026, infine il confronto.
-- NOVITÀ: EXTRACT(YEAR FROM data) estrae l'anno da una data.
-- NOVITÀ: count(distinct x) conta i valori diversi: se un turista visita la stessa attrazione
--   due volte, conta una volta sola ("attrazioni DISTINTE").
-- NOVITÀ: LEFT JOIN + COALESCE. Un turista che nel 2025 non ha visitato nulla non compare in
--   visite_2025: con un JOIN normale sparirebbe, ma se nel 2026 ha visitato qualcosa va contato.
--   Con LEFT JOIN la parte 2025 è NULL e coalesce(x, 0) sostituisce il NULL con 0.
-- Nota: la stessa tecnica nel database "scuola" (query sulle medie scritti/orali) sarebbe SBAGLIATA,
--   perché lì "nessun esame scritto" non vuol dire "media 0" ma "niente da confrontare".
--   Per scegliere tra JOIN e LEFT JOIN + COALESCE chiediti: "l'assenza di righe equivale davvero a 0?"
-- Risultato atteso: 4 (alice92, carlav, giuliat, hugob).


-- 2. Attrazioni le cui prenotazioni del 2025 sono più numerose di quelle di ogni anno precedente.
with conteggio_annuale as (
    select attrazione, extract(year from data)::int as anno, count(*) as n_prenotazioni
    from prenotazione
    group by attrazione, extract(year from data)
)
select a.codice, a.nome
from attrazione a
join conteggio_annuale c2025
  on c2025.attrazione = a.codice and c2025.anno = 2025
where not exists (
    select 1
    from conteggio_annuale cprec
    where cprec.attrazione = a.codice
      and cprec.anno < 2025
      and cprec.n_prenotazioni >= c2025.n_prenotazioni
)
order by a.codice;
-- Idea: "più numerose di OGNI anno precedente" = "NON ESISTE un anno precedente con un numero
--   di prenotazioni uguale o maggiore". Si trasforma un "per ogni" in un NOT EXISTS del contrario.
-- NOVITÀ: NOT EXISTS con subquery correlata (usa a.codice e c2025 della query esterna).
-- NOVITÀ: "::int" converte il tipo (cast): extract restituisce un numero decimale, qui lo si vuole intero.
-- Attrazioni senza prenotazioni prima del 2025: NOT EXISTS è vero (nessun anno da battere);
--   l'attrazione senza prenotazioni nel 2025 è esclusa dal JOIN con c2025.
-- Risultato atteso: COL, DUO, POM.
