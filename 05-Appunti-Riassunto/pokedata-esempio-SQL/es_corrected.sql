-- es_corrected.sql
--
-- Corrected + annotated version of es.sql. Every query below was actually
-- run against `pokedata` with `psql -d pokedata -f es_corrected.sql` while
-- writing this, so the comments describe real, verified behavior (errors,
-- silent wrong results, etc.), not just theory.
--
-- Two schema facts explain most of the "hard" bugs below, so read these first:
--
-- 1) `pokemon.id` is NOT the same as `pokemon.species_id`.
--    Most Pokémon have id == species_id (e.g. bulbasaur is id=1, species_id=1),
--    which makes it easy to accidentally join `pokemon p ... on p.id = ps.id`
--    and have it *look* right. But 194 rows in `pokemon` are alternate forms
--    (mega evolutions, regional forms, deoxys-attack, etc.) whose id is far
--    outside the species id range (e.g. deoxys-attack has id=10001 but
--    species_id=386). Joining on p.id = ps.id silently drops those 194 rows
--    instead of erroring, because it's an INNER JOIN — a classic "silently
--    wrong data" bug. Always join pokemon -> pokemon_species with
--    `p.species_id = ps.id`. (This is exactly what the pokemon_with_type view
--    in views.sql does correctly.)
--
-- 2) `tables.sql` declares `id serial` on every table but never adds
--    `PRIMARY KEY`. Postgres's "functional dependency" GROUP BY shortcut
--    (letting you SELECT a non-aggregated, non-grouped column when the
--    GROUP BY column is a primary/unique key of that table) therefore does
--    NOT kick in here, even for p.id. That's why a query like
--    `group by p.id` followed by `select p.id, p.identifier` raises
--    `column "p.identifier" must appear in the GROUP BY clause...` even
--    though logically it's safe. You'll see this below (Level 5, "every
--    type"). Fix: either add p.identifier to GROUP BY too, or (cleaner)
--    add real PRIMARY KEY constraints in tables.sql.


-- count pokemons
-- select count(*) from pokemon;

-- count all fire pokemon that weight more than 69Kg
-- select count(*) from pokemon p join pokemon_with_type pt on p.id = pt.id where p.weight > 69 and pt.type = 'fire';

-- Level 1: Basic queries

-- Display the id, identifier, height, and weight of every Pokémon.
-- BUG: select (id, identifier, height, weight) from pokemon;
-- Wrapping the column list in parentheses turns it into a single ROW
-- (composite) expression, so you get ONE column back containing a tuple
-- like (1,bulbasaur,7,69), not four separate columns. Parentheses after
-- SELECT are for grouping an expression, not for listing columns — just
-- separate them with commas.
select id, identifier, height, weight from pokemon;

-- Display only Pokémon with height greater than 10.
select * from pokemon where height > 10;

-- Find Pokémon whose name ends with saur.
select identifier from pokemon where identifier like '%saur';

-- Display Pokémon ordered from heaviest to lightest.
select identifier, weight from pokemon order by weight desc;

-- Find the five Pokémon with the highest base_experience.
select identifier, base_experience from pokemon order by base_experience desc limit 5;


-- Level 2: Filtering and expressions

-- Display each Pokémon's name and weight in kilograms. The CSV stores weight in hectograms, so divide by 10.
select identifier, weight/10 as weight_kg from pokemon;
-- Note: weight and 10 are both integers, so weight/10 does INTEGER division
-- (69/10 = 6, not 6.9) — truncated, not rounded. If you want the real
-- kilogram value, cast one side to numeric: weight / 10.0 as weight_kg.
-- select identifier, weight / 10.0 as weight_kg from pokemon;

-- Find Pokémon that are both:
--   taller than 10
--   heavier than 500
-- Find Pokémon whose name contains the letter x or the letter z.
--
-- BUG (operator precedence): the original was
--   where height > 10 and weight > 500 and identifier like '%a%' or identifier like '%z%'
-- AND binds tighter than OR in SQL, so this parses as:
--   (height > 10 AND weight > 500 AND identifier LIKE '%a%') OR (identifier LIKE '%z%')
-- i.e. "(tall AND heavy AND has an a) OR (has a z anywhere, tall/heavy or not)"
-- — that's a much bigger, wrong result set (278 rows when tested). It also
-- used '%a%' instead of '%x%', which isn't what the exercise asked for.
-- The fix is to parenthesize the OR explicitly, since it must be applied
-- ONLY to the "contains x or z" part, and that whole thing must be ANDed
-- with the height/weight filters:
select identifier, height, weight
from pokemon
where height > 10
  and weight > 500
  and (identifier like '%x%' or identifier like '%z%');
-- (Verified: 55 rows vs. 278 for the buggy version — a real difference.)

-- Display all non-default Pokémon forms.
-- BUG: select (identifier, is_default) from pokemon where is_default = false;
-- Same ROW-expression bug as the first query — parentheses collapse the two
-- columns into one composite column.
select identifier, is_default from pokemon where is_default = false;

-- Find all legendary or mythical species, showing their name and generation.
select identifier, generation_id from pokemon_species where is_legendary = true or is_mythical = true;


-- Level 3: Joins

-- Display every Pokémon together with its species name.
-- BUG: ... join pokemon_species ps on p.id = ps.id ...
-- This is the p.id vs p.species_id mistake described at the top of the file.
-- It happens to "work" for ~898 rows because Postgres silently only returns
-- matches, but it drops all 194 alternate-form Pokémon (mega/regional/etc.)
-- whose id doesn't coincide with a species id — no error, just missing rows.
select p.*, ps.identifier as species_name
from pokemon p
join pokemon_species ps on p.species_id = ps.id;

-- Display every Pokémon together with its color and shape.
-- Same p.id/p.species_id bug as above, fixed the same way. Also note the
-- original aliased the color join as `pc` and the shape join as `psh` but
-- then labeled *shape*'s output column `as color` — a copy-paste labeling
-- mix-up (harmless for the result, since aliases are just labels, but
-- confusing to read).
select p.identifier, pc.identifier as color, psh.identifier as shape
from pokemon p
join pokemon_species ps on p.species_id = ps.id
join pokemon_colors pc on ps.color_id = pc.id
join pokemon_shapes psh on ps.shape_id = psh.id;

-- Display every Pokémon and its types using the pokemon_with_type view.
select p.identifier, pwt.type from pokemon p join pokemon_with_type pwt on pwt.id = p.id;

-- Find all Pokémon having the fire type.
select p.identifier, pwt.type from pokemon p join pokemon_with_type pwt on pwt.id = p.id where pwt.type = 'fire';

-- Find Pokémon that have both water and ice as types.
-- BUG: ... where pwt.type = 'ice' and pwt.type = 'water';
-- Each row of the join has exactly ONE value for pwt.type, so this asks
-- "is this single value simultaneously equal to 'ice' AND 'water'?", which
-- is never true — the query always returns 0 rows (verified). You cannot
-- test "has type A and type B" with AND on a single column from a joined
-- row; each Pokémon needs to be matched against two *different* rows (its
-- water-type row and its ice-type row). Two ways to do it correctly:
--
-- (a) EXISTS twice — reads like the English sentence directly:
select p.identifier
from pokemon p
where exists (select 1 from pokemon_with_type w where w.id = p.id and w.type = 'water')
  and exists (select 1 from pokemon_with_type w where w.id = p.id and w.type = 'ice');
--
-- (b) aggregate + HAVING, using the same "count distinct matching things"
--     pattern you'll want for the "every type" exercise later:
-- select p.identifier
-- from pokemon p join pokemon_with_type pwt on pwt.id = p.id
-- where pwt.type in ('water', 'ice')
-- group by p.identifier
-- having count(distinct pwt.type) = 2;

-- Display each Pokémon's name and all its types as a PostgreSQL array using array_agg.
select p.identifier, array_agg(pwt.type) from pokemon p join pokemon_with_type pwt on pwt.id = p.id group by p.identifier;
-- This one's correct as written. Note it's only legal because every column
-- in SELECT is either in GROUP BY (p.identifier) or wrapped in an aggregate
-- (array_agg) — the same rule that trips up the "every type" query below.


-- Level 4: Aggregation

-- Count how many Pokémon exist for each type.
select pwt.type, count(*) from pokemon p join pokemon_with_type pwt on pwt.id = p.id group by pwt.type;

-- Find the average weight for each type.
select pwt.type, avg(p.weight) as average_weight from pokemon p join pokemon_with_type pwt on pwt.id = p.id group by pwt.type order by average_weight desc;

-- Find the heaviest Pokémon of every type.
-- BUG: max(p.weight) alone only gives you the *number*, not which Pokémon
-- has it — your own comment already spotted this ("how to get the
-- identifier of that max?"). max()/avg()/count() collapse a group down to
-- one value and throw away which row it came from, so you can't just add
-- p.identifier to the SELECT list (it would error: identifier isn't
-- grouped or aggregated). Two idiomatic fixes:
--
-- (a) DISTINCT ON — a handy Postgres-specific trick: keeps the first row
--     per group after sorting, so sort by weight desc and take row #1
--     of each type:
select distinct on (pwt.type) pwt.type, p.identifier, p.weight
from pokemon p join pokemon_with_type pwt on pwt.id = p.id
order by pwt.type, p.weight desc;
--
-- (b) a window function (standard SQL, works outside Postgres too) — this
--     is the general technique the last exercise in this file asks for:
-- select type, identifier, weight from (
--   select pwt.type, p.identifier, p.weight,
--          rank() over (partition by pwt.type order by p.weight desc) as rnk
--   from pokemon p join pokemon_with_type pwt on pwt.id = p.id
-- ) ranked where rnk = 1;
-- (rank() ties multiple Pokémon at #1 if they're exactly tied on weight;
-- row_number() would arbitrarily pick just one instead.)

-- Count how many Pokémon exist for each color.
-- BUG: select pwt.color, count(p.identifier) from pokemon p join pokemon_with_type pwt on pwt.id = p.id group by pwt.type;
-- This actually ERRORS at run time: `column "pwt.color" must appear in the
-- GROUP BY clause or be used in an aggregate function`. The SELECT list
-- asks for pwt.color, but the query groups by pwt.type — every non-
-- aggregated SELECT column must match what you're grouping by. Since the
-- question is "per color", group by color, not type:
select pwt.color, count(p.identifier) from pokemon p join pokemon_with_type pwt on pwt.id = p.id group by pwt.color;

-- Display only types having more than 50 Pokémon.
select pwt.type, count(p.identifier) as count from pokemon p join pokemon_with_type pwt on pwt.id = p.id group by pwt.type having count(p.identifier) > 50;
-- Correct, and a good example of the GROUP BY -> HAVING pattern: WHERE
-- filters rows before grouping, HAVING filters *groups* after aggregation
-- (you can't write `where count(...) > 50`, since count() doesn't exist
-- yet at the row-filtering stage).


-- For each generation, calculate:
-- number of species
-- number of legendary species
-- number of mythical species
--
-- BUG: the original joins `pokemon p ... on p.id = ps.id`, which is (1) the
-- same p.id/species_id mistake as before, and (2) pointless here anyway —
-- the question is entirely about pokemon_species (generation, legendary,
-- mythical are all species-level attributes), so there's no need to touch
-- the pokemon table at all. It happened to give the same numbers when
-- tested here, purely because every species 1..898 has a same-numbered
-- default-form Pokémon — that's a coincidence of this dataset, not
-- something you should rely on. Also, `count(ps.is_legendary) filter
-- (where ps.is_legendary = true)` works but is redundant: count(column)
-- already ignores NULLs, then FILTER further restricts to TRUE rows; it's
-- simpler and clearer to just `count(*) filter (where ps.is_legendary)`.
select
    ps.generation_id as generation,
    count(*) as num_species,
    count(*) filter (where ps.is_legendary) as number_of_legendary,
    count(*) filter (where ps.is_mythical) as number_of_mythical
from pokemon_species ps
group by ps.generation_id
order by ps.generation_id;


-- Level 5: Harder queries

-- Find Pokémon with no type.
select p.identifier, pwt.type from pokemon p left join pokemon_with_type pwt on pwt.id = p.id where pwt.type is null;
-- Correct, and this is the standard "anti-join" idiom worth internalizing:
-- LEFT JOIN keeps every row of pokemon even when there's no matching type
-- row, filling the type side with NULLs; filtering `where pwt.type is null`
-- then keeps exactly the Pokémon that had no match at all. (An INNER JOIN
-- here would have silently thrown away the very rows you're looking for.)

-- Find species that do not evolve from another species.
-- BUG: same p.id = ps.id join mistake, and again unnecessary — this
-- question is purely about pokemon_species, no need to involve pokemon.
select identifier, evolves_from_species_id from pokemon_species where evolves_from_species_id is null;

-- Find species that have at least one evolution.
-- Your attempts got stuck figuring out the subquery — here's the idea:
-- a species "has an evolution" exactly when some OTHER species' row lists
-- it as evolves_from_species_id. So build the set of all
-- evolves_from_species_id values that exist, then check membership:
select identifier
from pokemon_species ps
where ps.id in (
    select evolves_from_species_id
    from pokemon_species
    where evolves_from_species_id is not null
)
order by identifier;
-- (The `is not null` matters: without it, the subquery includes NULL, and
-- `x IN (set containing NULL)` can make the whole IN evaluate to UNKNOWN
-- instead of the FALSE you'd expect for genuine non-matches — a classic
-- SQL NULL gotcha with NOT IN especially, worth remembering even though
-- plain IN here isn't broken by it.)

-- Find Pokémon that have every type assigned to them. In other words, find
-- Pokémon whose number of types equals the total number of types in the
-- types table.
-- BUG: the original never filters anything —
--   select p.id, p.identifier from pokemon p join pokemon_types pt on pt.id = p.id join types t on t.id = pt.type_id group by p.id;
-- (1) it groups by p.id but selects p.identifier too, which — per the note
--     at the top of this file about missing PRIMARY KEYs — actually ERRORS
--     in this schema (`column "p.identifier" must appear in the GROUP BY
--     clause...`); (2) even if you fix that by grouping on both columns,
--     there's no HAVING clause, so it would just list every Pokémon that
--     has at least one type (i.e. all of them) instead of the ones with
--     ALL types. You need to count each Pokémon's distinct types and
--     compare that count to the total number of types:
select p.identifier, count(distinct pt.type_id) as num_types
from pokemon p
join pokemon_types pt on pt.id = p.id
group by p.id, p.identifier
having count(distinct pt.type_id) = (select count(*) from types);
-- Heads up: this correctly returns ZERO rows. It's not a bug in the query —
-- the `types` table actually has 20 rows, but 2 of them ('unknown' and
-- 'shadow', ids 10001/10002) are placeholder/mechanic types that are never
-- actually assigned to any Pokémon in pokemon_types (checked: max types on
-- any single real Pokémon is 2). So "equals the total row count of types"
-- is an impossible condition here — a good reminder to sanity-check a
-- reference table's contents rather than assume every row represents a
-- realistic value. If you meant "every type that's actually in use",
-- compare against the types actually assigned instead:
-- having count(distinct pt.type_id) = (select count(distinct type_id) from pokemon_types)
-- — still 0 rows though, since real Pokémon top out at 2 types each; this
-- exercise's honest answer is simply "no Pokémon qualifies".

-- Find Pokémon that have the same type combination as bulbasaur.
-- Idea: reduce each Pokémon's type_ids to a sorted array (two Pokémon have
-- "the same combination" iff those arrays are equal — arrays compare
-- element-by-element in Postgres, so the ORDER BY inside array_agg matters,
-- otherwise {grass,poison} and {poison,grass} would count as different).
with type_sets as (
    select id, array_agg(type_id order by type_id) as types
    from pokemon_types
    group by id
),
bulbasaur_types as (
    select types
    from type_sets
    where id = (select id from pokemon where identifier = 'bulbasaur')
)
select p.identifier
from type_sets ts
join pokemon p on p.id = ts.id
join bulbasaur_types bt on ts.types = bt.types
order by p.identifier;

-- Find the type with the greatest average Pokémon weight.
select t.identifier as type, avg(p.weight) as avg_weight
from pokemon p
join pokemon_types pt on pt.id = p.id
join types t on t.id = pt.type_id
group by t.identifier
order by avg_weight desc
limit 1;
-- (Same GROUP BY/aggregate shape as the "average weight for each type"
-- query above — the only new idea is order by ... desc limit 1 to keep
-- just the single winning group instead of all of them.)

-- For each type, rank Pokémon from heaviest to lightest using a window function.
select
    t.identifier as type,
    p.identifier as pokemon,
    p.weight,
    rank() over (partition by t.identifier order by p.weight desc) as weight_rank
from pokemon p
join pokemon_types pt on pt.id = p.id
join types t on t.id = pt.type_id
order by t.identifier, weight_rank;
-- Window functions (the `... over (...)` part) compute a value per row
-- *without* collapsing rows the way GROUP BY does — PARTITION BY restarts
-- the ranking for each type, ORDER BY inside OVER decides the ranking
-- order within each partition. This is exactly the general-purpose version
-- of the DISTINCT ON trick used earlier for "heaviest Pokémon of every
-- type" (that's just this query filtered down to weight_rank = 1).

-- Find the heaviest Pokémon that is not legendary or mythical.
select p.identifier, p.weight
from pokemon p
join pokemon_species ps on p.species_id = ps.id
where coalesce(ps.is_legendary, false) = false
  and coalesce(ps.is_mythical, false) = false
order by p.weight desc
limit 1;
-- Two things worth noting: (1) this needs p.species_id = ps.id, the
-- correct join from the top of this file — is_legendary/is_mythical live
-- on pokemon_species, not pokemon. (2) coalesce(..., false) guards against
-- NULL: is_legendary/is_mythical are nullable columns (see tables.sql), and
-- `NULL = false` is NULL (not true), which would silently exclude any
-- Pokémon whose flag was never set, rather than correctly treating
-- "unknown/unset" as "not legendary".
