-- Schema: turista(username PK, nome, cognome, data_nascita, email, citta)
--         attrazione(codice PK, nome, citta, tipo, costo_biglietto)
--         prenotazione((turista, attrazione, data) PK, data_visita, orario_visita)
--
-- Nota sui dati: "data" = quando è stata fatta la prenotazione, "data_visita" = quando
-- avviene davvero la visita. Nella query 1 conta la VISITA (quindi uso data_visita),
-- nella query 2 contano le PRENOTAZIONI (quindi uso data, il giorno in cui sono state
-- effettuate) — per questo in 02_data.sql ci sono un paio di prenotazioni apposta a
-- cavallo di due anni diversi, per testare che la distinzione venga rispettata.


-- 1. Conteggio dei turisti che nel 2026 hanno visitato più attrazioni distinte che nel 2025.
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
-- LEFT JOIN + COALESCE qui è corretto (al contrario della query della scuola!): un turista
-- che nel 2025 non ha visitato nulla ha "0 attrazioni", quindi se nel 2026 ne visita almeno
-- una va contato comunque. Risultato atteso con i dati in 02_data.sql: 4
-- (alice92, carlav, giuliat, hugob).


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
-- NOT EXISTS gestisce correttamente anche il caso di un'attrazione senza alcuna
-- prenotazione prima del 2025 (nessuna riga da confrontare => condizione vacuamente vera).
-- Risultato atteso: COL, DUO, POM.
-- (UFF e VAT escluse perché un anno precedente ha prenotazioni >= a quelle del 2025;
--  TRE esclusa perché non ha affatto prenotazioni nel 2025, quindi lo JOIN su c2025 la elimina.)
