-- query-soluzioni.sql — database "pokemon"
-- Tabelle: pokemon, pokemon_species, pokemon_types, types, pokemon_colors, pokemon_shapes
-- Vista:   pokemon_with_type (id, identifier, type, color, shape)
--
-- Legenda: NOVITÀ = costrutto probabilmente nuovo; ATTENZIONE = trabocchetto / errore tipico.
-- Ogni query termina con ";". Per provarne una sola, commenta le altre con "--".
--
-- COSE DA SAPERE SUI DATI (spiegano la maggior parte dei trabocchetti):
--
-- 1) pokemon.id NON è pokemon.species_id.
--    Per i Pokémon "normali" coincidono (bulbasaur: id = 1, species_id = 1), ma ci sono forme
--    alternative (mega evoluzioni, forme regionali, deoxys-attack...) con id molto alto
--    (es. 10001) e species_id della specie base (386). Per collegare pokemon e pokemon_species
--    si usa SEMPRE  p.species_id = ps.id.  Con "p.id = ps.id" non c'è nessun errore, ma le
--    forme alternative (~194 righe) spariscono in silenzio.
--
-- 2) Nella tabella pokemon_types la colonna "id" è l'id del POKÉMON (non del tipo!); l'id del
--    tipo è "type_id". Nome ingannevole: pokemon_types.id = pokemon.id, pokemon_types.type_id = types.id.
--    Un Pokémon con due tipi ha due righe in pokemon_types.
--
-- 3) Le tabelle non hanno PRIMARY KEY dichiarata. Quindi PostgreSQL non "sa" che raggruppare per
--    p.id determina anche p.identifier: bisogna scrivere in GROUP BY tutte le colonne non aggregate.
--
-- 4) weight è in ettogrammi (hg) e height in decimetri: 69 = 6,9 kg.


-- Quanti Pokémon ci sono?
select count(*) from pokemon;

-- Quanti Pokémon di tipo fuoco pesano più di 69 kg?
select count(*)
from pokemon p
join pokemon_with_type pt on pt.id = p.id
where p.weight > 690 and pt.type = 'fire';
-- ATTENZIONE: unità di misura. Il peso è in ettogrammi, quindi 69 kg = 690, non 69.
-- NOVITÀ: una VISTA è una query salvata con un nome, che si usa come fosse una tabella.
-- pokemon_with_type unisce già pokemon, tipi, colori e forme (una riga per ogni coppia Pokémon-tipo).


-- ---- LIVELLO 1: query base ----

-- Id, identifier, altezza e peso di ogni Pokémon.
select id, identifier, height, weight from pokemon;
-- ATTENZIONE: le colonne si separano con le virgole, SENZA parentesi. "select (id, identifier)"
-- non dà un errore ma restituisce UNA sola colonna con dentro una tupla "(1,bulbasaur)".

-- Pokémon con altezza maggiore di 10.
select * from pokemon where height > 10;

-- Pokémon il cui nome finisce con "saur".
select identifier from pokemon where identifier like '%saur';
-- NOVITÀ: LIKE confronta con un modello: % = qualsiasi sequenza di caratteri (anche vuota),
-- _ = un carattere qualsiasi. '%saur' = "qualsiasi cosa che finisce con saur".

-- Pokémon dal più pesante al più leggero.
select identifier, weight from pokemon order by weight desc;
-- ORDER BY è crescente di default; desc = decrescente.

-- I cinque Pokémon con base_experience più alta.
select identifier, base_experience from pokemon order by base_experience desc limit 5;
-- NOVITÀ: LIMIT n tiene solo le prime n righe (dopo l'ordinamento: senza ORDER BY non
-- c'è un "primo" garantito). In caso di parità al 5º posto LIMIT ne taglia alcuni arbitrariamente.


-- ---- LIVELLO 2: filtri ed espressioni ----

-- Nome e peso in chilogrammi.
select identifier, weight / 10.0 as weight_kg from pokemon;
-- ATTENZIONE: weight è un intero e 10 è un intero: "weight / 10" fa la divisione INTERA e
-- tronca (69 / 10 = 6, non 6.9). Scrivendo 10.0 (decimale) si ottiene 6.9.

-- Pokémon alti più di 10, pesanti più di 500 e il cui nome contiene la lettera x oppure z.
select identifier, height, weight
from pokemon
where height > 10
  and weight > 500
  and (identifier like '%x%' or identifier like '%z%');
-- ATTENZIONE: le parentesi attorno all'OR sono indispensabili. AND ha la precedenza su OR:
-- senza parentesi "a and b and c or d" significa "(a and b and c) or d", cioè il filtro su
-- altezza/peso varrebbe solo per una delle due lettere e restituirebbe molte più righe.
-- (Controlla anche di aver scritto la lettera richiesta: x e z, non a e z.)

-- Tutte le forme non di default.
select identifier, is_default from pokemon where is_default = false;
-- Equivalente più leggibile per i booleani: "where not is_default".

-- Specie leggendarie o mitiche, con nome e generazione.
select identifier, generation_id
from pokemon_species
where is_legendary = true or is_mythical = true;


-- ---- LIVELLO 3: JOIN ----

-- Ogni Pokémon con il nome della sua specie.
select p.*, ps.identifier as species_name
from pokemon p
join pokemon_species ps on ps.id = p.species_id;
-- ATTENZIONE: p.species_id = ps.id (vedi punto 1 in alto), non p.id = ps.id.
-- "p.*" = tutte le colonne della tabella p.

-- Ogni Pokémon con colore e forma.
select p.identifier, pc.identifier as color, psh.identifier as shape
from pokemon p
join pokemon_species ps on ps.id = p.species_id
join pokemon_colors pc on pc.id = ps.color_id
join pokemon_shapes psh on psh.id = ps.shape_id;
-- Tre JOIN a catena: pokemon -> specie -> colore, e specie -> forma.
-- Usa "as" per dare nomi diversi alle due colonne "identifier" del risultato (e controlla che
-- l'alias corrisponda alla tabella: color per colori, shape per forme).
-- ATTENZIONE: i JOIN normali scartano i Pokémon senza colore o senza forma (valori NULL).

-- Ogni Pokémon con i suoi tipi (vista pokemon_with_type).
select identifier, type
from pokemon_with_type
order by identifier;
-- Un Pokémon con due tipi compare su due righe. Fare il join con pokemon non serve:
-- la vista contiene già l'identifier.

-- Pokémon di tipo fuoco.
select identifier, type from pokemon_with_type where type = 'fire';

-- Pokémon che hanno sia acqua sia ghiaccio.
select p.identifier
from pokemon p
where exists (select 1 from pokemon_with_type w where w.id = p.id and w.type = 'water')
  and exists (select 1 from pokemon_with_type w where w.id = p.id and w.type = 'ice');
-- ATTENZIONE: "where type = 'water' and type = 'ice'" non restituisce MAI righe: ogni riga ha
-- un solo valore in "type". Servono due righe diverse dello stesso Pokémon (una per tipo).
-- NOVITÀ: EXISTS (subquery) è vero se la subquery restituisce almeno una riga; la subquery è
-- "correlata" perché usa p.id della query esterna.
-- Alternativa con raggruppamento:
--   select identifier from pokemon_with_type where type in ('water', 'ice')
--   group by id, identifier having count(distinct type) = 2;
-- Per eliminare i duplicati in PostgreSQL si usa DISTINCT ("unique" non esiste).

-- Nome e tutti i tipi come array.
select identifier, array_agg(type) as types
from pokemon_with_type
group by id, identifier;
-- NOVITÀ: array_agg(colonna) raccoglie in un unico valore (array PostgreSQL, {water,ice}) i valori
-- di tutte le righe del gruppo. Raggruppa per id (oltre a identifier) così due forme diverse con
-- lo stesso nome non verrebbero fuse.


-- ---- LIVELLO 4: aggregazioni ----

-- Quanti Pokémon per tipo.
select type, count(*) as n_pokemon
from pokemon_with_type
group by type
order by n_pokemon desc;
-- GROUP BY crea un gruppo per ogni valore di "type"; count(*) conta le righe del gruppo.
-- Un Pokémon con due tipi viene contato in entrambi i tipi (è giusto: la domanda è per tipo).

-- Peso medio per tipo.
select pwt.type, avg(p.weight) as average_weight
from pokemon p
join pokemon_with_type pwt on pwt.id = p.id
group by pwt.type
order by average_weight desc;

-- Il Pokémon più pesante per ogni tipo.
select distinct on (pwt.type) pwt.type, p.identifier, p.weight
from pokemon p
join pokemon_with_type pwt on pwt.id = p.id
order by pwt.type, p.weight desc;
-- Con "max(weight)" si ottiene il numero ma non CHI ha quel peso: le funzioni aggregate
-- perdono l'identità della riga. E non si può aggiungere p.identifier al SELECT (non è in GROUP BY).
-- NOVITÀ: DISTINCT ON (colonna) è una funzione specifica di PostgreSQL: dopo l'ordinamento
-- tiene la PRIMA riga di ogni valore di "colonna". Qui: ordina per tipo e peso decrescente,
-- tieni la prima = la più pesante di ogni tipo. Il primo criterio di ORDER BY deve essere la stessa colonna.
-- Versione standard SQL (stessa tecnica dell'ultimo esercizio) con funzione finestra:
--   select type, identifier, weight from (
--     select pwt.type, p.identifier, p.weight,
--            rank() over (partition by pwt.type order by p.weight desc) as rnk
--     from pokemon p join pokemon_with_type pwt on pwt.id = p.id
--   ) t where rnk = 1;
-- (rank() restituisce tutti i Pokémon a pari merito; DISTINCT ON ne sceglie uno solo.)

-- Quanti Pokémon per colore.
select pc.identifier as color, count(*) as n_pokemon
from pokemon p
join pokemon_species ps on ps.id = p.species_id
join pokemon_colors pc on pc.id = ps.color_id
group by pc.identifier
order by n_pokemon desc;
-- ATTENZIONE: non usare la vista pokemon_with_type: ha una riga per ogni TIPO, quindi un Pokémon
-- con due tipi verrebbe contato due volte (e uno senza tipi mai). Per contare Pokémon
-- si parte da pokemon (una riga per Pokémon) e si arriva al colore tramite la specie.
-- (Se invece raggruppi per colore con la vista, ricorda di scrivere "group by color", non "group by type":
-- ogni colonna del SELECT non aggregata deve stare nel GROUP BY, altrimenti errore.)

-- Solo i tipi con più di 50 Pokémon.
select type, count(*) as n_pokemon
from pokemon_with_type
group by type
having count(*) > 50;
-- NOVITÀ: HAVING filtra i GRUPPI dopo l'aggregazione; WHERE filtra le RIGHE prima.
-- Non si può scrivere "where count(*) > 50": a quel punto i conteggi non esistono ancora.

-- Per ogni generazione: specie, specie leggendarie, specie mitiche.
select generation_id as generation,
       count(*) as num_species,
       count(*) filter (where is_legendary) as number_of_legendary,
       count(*) filter (where is_mythical)  as number_of_mythical
from pokemon_species
group by generation_id
order by generation_id;
-- NOVITÀ: "count(*) FILTER (WHERE condizione)" conta solo le righe del gruppo che rispettano la condizione:
-- permette più conteggi diversi nella stessa query.
-- Basta la tabella pokemon_species: generazione e flag leggendario/mitico sono attributi della specie,
-- non serve il join con pokemon (e il join con p.id = ps.id sarebbe comunque sbagliato).


-- ---- LIVELLO 5: query più difficili ----

-- Pokémon senza tipo.
select p.identifier
from pokemon p
where not exists (select 1 from pokemon_types pt where pt.id = p.id);
-- NOVITÀ: NOT EXISTS = "non esiste nessuna riga che...". Alternativa: LEFT JOIN e filtro "is null"
--   select p.identifier from pokemon p left join pokemon_types pt on pt.id = p.id where pt.id is null;
-- (LEFT JOIN tiene i Pokémon anche senza riga corrispondente, con le colonne dell'altra tabella a NULL;
-- il filtro IS NULL isola proprio quelli.)
-- ATTENZIONE: qui si usa pokemon_types e non la vista: la vista scarta anche i Pokémon senza colore o
-- forma, quindi "non compare nella vista" non significa "non ha tipo".

-- Specie che non evolvono da un'altra specie.
select identifier
from pokemon_species
where evolves_from_species_id is null;
-- Si controlla NULL con IS NULL, mai con "= NULL".

-- Specie che hanno almeno un'evoluzione.
select identifier
from pokemon_species
where id in (
    select evolves_from_species_id
    from pokemon_species
    where evolves_from_species_id is not null
)
order by identifier;
-- Idea: una specie ha un'evoluzione se un'ALTRA specie la indica come "evolves_from_species_id".
-- NOVITÀ: IN (subquery) = "il valore è tra quelli restituiti dalla subquery".
-- Variante: where exists (select 1 from pokemon_species e where e.evolves_from_species_id = pokemon_species.id)

-- Pokémon che hanno TUTTI i tipi.
select p.identifier, count(distinct pt.type_id) as num_types
from pokemon p
join pokemon_types pt on pt.id = p.id
group by p.id, p.identifier
having count(distinct pt.type_id) = (select count(*) from types);
-- Idea: contare i tipi di ogni Pokémon e confrontarli con il numero di righe di "types".
-- ATTENZIONE: serve HAVING (altrimenti elenchi tutti i Pokémon con almeno un tipo) e tutte le
-- colonne non aggregate nel GROUP BY.
-- Risultato: nessuna riga, ed è corretto: "types" ha 20 righe (comprese 'unknown' e 'shadow', mai assegnate)
-- e nessun Pokémon ha più di 2 tipi. Controlla sempre che il risultato "vuoto" sia sensato.

-- Pokémon con la stessa combinazione di tipi di bulbasaur.
with tipi_per_pokemon as (
    select id, array_agg(type_id order by type_id) as tipi
    from pokemon_types
    group by id
)
select p.identifier
from tipi_per_pokemon t
join pokemon p on p.id = t.id
where t.tipi = (
    select tipi
    from tipi_per_pokemon
    where id = (select id from pokemon where identifier = 'bulbasaur')
)
order by p.identifier;
-- NOVITÀ: WITH ... AS (...) = CTE, "tabella temporanea con nome" valida per questa query.
-- Idea: ridurre i tipi di ogni Pokémon a un array ORDINATO; due Pokémon hanno la stessa combinazione
-- se i due array sono uguali. L'ORDER BY dentro array_agg è fondamentale: {grass,poison} e {poison,grass}
-- altrimenti risulterebbero diversi.
-- Risultato: bulbasaur compare a sua volta (è uguale a sé stesso); aggiungi "and p.identifier <> 'bulbasaur'" per toglierlo.

-- Il tipo con il peso medio più alto.
select t.identifier as type, avg(p.weight) as avg_weight
from pokemon p
join pokemon_types pt on pt.id = p.id
join types t on t.id = pt.type_id
group by t.identifier
order by avg_weight desc
limit 1;
-- Come "peso medio per tipo", più "order by ... desc limit 1" per tenere solo il gruppo vincente.

-- Per ogni tipo, classifica dei Pokémon dal più pesante al più leggero (funzione finestra).
select t.identifier as type,
       p.identifier as pokemon,
       p.weight,
       rank() over (partition by t.identifier order by p.weight desc) as weight_rank
from pokemon p
join pokemon_types pt on pt.id = p.id
join types t on t.id = pt.type_id
order by t.identifier, weight_rank;
-- NOVITÀ: una funzione finestra ("... OVER (...)") calcola un valore per ogni riga SENZA
-- raggruppare le righe (a differenza di GROUP BY). PARTITION BY ricomincia la classifica per ogni tipo;
-- l'ORDER BY dentro OVER stabilisce l'ordine della classifica.
-- rank() assegna lo stesso numero ai pari merito (1, 1, 3); row_number() numera sempre 1, 2, 3...

-- Il Pokémon più pesante che non è leggendario né mitico.
select p.identifier, p.weight
from pokemon p
join pokemon_species ps on ps.id = p.species_id
where coalesce(ps.is_legendary, false) = false
  and coalesce(ps.is_mythical, false) = false
order by p.weight desc
limit 1;
-- is_legendary e is_mythical stanno in pokemon_species, quindi serve il join con p.species_id = ps.id.
-- NOVITÀ: coalesce(x, false) sostituisce NULL con false: le colonne possono essere NULL e
-- "NULL = false" non è vero, quindi quei Pokémon verrebbero esclusi per errore.
