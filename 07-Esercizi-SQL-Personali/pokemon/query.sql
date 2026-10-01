-- count pokemons
-- select count(*) from pokemon;

-- count all fire pokemon that weight more than 69Kg
-- select count(*) from pokemon p join pokemon_with_type pt on p.id = pt.id where p.weight > 69 and pt.type = 'fire';

-- Level 1: Basic queries

-- Display the id, identifier, height, and weight of every Pokémon.
-- select (id, identifier, height, weight) from pokemon;

-- Display only Pokémon with height greater than 10.
-- select * from pokemon where height > 10;

-- Find Pokémon whose name ends with saur.
-- select identifier from pokemon where identifier like '%saur';

-- Display Pokémon ordered from heaviest to lightest.
-- select identifier,weight from pokemon order by weight desc;

-- Find the five Pokémon with the highest base_experience.
-- select identifier, base_experience from pokemon order by base_experience desc limit 5;


-- Level 2: Filtering and expressions

-- Display each Pokémon’s name and weight in kilograms. The CSV stores weight in hectograms, so divide by 10.
-- select identifier, weight/10 as weight_kg from pokemon;

-- Find Pokémon that are both:

-- taller than 10
-- heavier than 500
-- Find Pokémon whose name contains the letter x or the letter z.

select identifier, height, weight
from pokemon
where height > 10
    and weight > 500
    and (identifier like '%a%' or identifier like '%z%'); 

-- Display all non-default Pokémon forms.

-- select (identifier, is_default) from pokemon where is_default = false; 

-- Find all legendary or mythical species, showing their name and generation.
-- select identifier, generation_id from pokemon_species where is_legendary = true or is_mythical = true;


-- Level 3: Joins

-- Display every Pokémon together with its species name.

select p.*, ps.identifier as species_name from pokemon p join pokemon_species ps on p.id = ps.id;

-- Display every Pokémon together with its color and shape.
select p.identifier, pc.identifier, psh.identifier as color from pokemon p
    join pokemon_species ps on p.id = ps.id
    join pokemon_colors pc on ps.color_id = pc.id
    join pokemon_shapes psh on ps.shape_id = psh.id;

-- Display every Pokémon and its types using the pokemon_with_type view.
select p.identifier, pwt.type
from pokemon p join pokemon_with_type pwt on pwt.id = p.id;

-- Find all Pokémon having the fire type.
select p.identifier, pwt.type
from pokemon p join pokemon_with_type pwt on pwt.id = p.id
where pwt.type = 'fire';

-- Find Pokémon that have both water and ice as types.
select unique(p.identifier)
from pokemon p join pokemon_with_type pwt on pwt.id = p.id
where exists (select 1 from pokemon_with_types w where w.id = p.id and w.type = 'ice')
and exists (select 1 from pokemon_with_types w where w.id = p.id and w.type = 'water')

-- Display each Pokémon’s name and all its types as a PostgreSQL array using array_agg.
select p.identifier, array_agg(pwt.type) from pokemon p join pokemon_with_type pwt on pwt.id = p.id group by p.identifier;

-- Level 4: Aggregation

-- Count how many Pokémon exist for each type.
select pwt.type, count(*) from pokemon p join pokemon_with_type pwt on pwt.id = p.id group by pwt.type;

-- Find the average weight for each type.
select pwt.type, avg(p.weight) as average_weight from pokemon p join pokemon_with_type pwt on pwt.id = p.id group by pwt.type order by average_weight desc;

-- Find the heaviest Pokémon of every type.
select pwt.type, max(p.weight) from pokemon p join pokemon_with_type pwt on pwt.id = p.id group by pwt.type; -- ? how to get the p.identifier of that max? subquery?

-- Count how many Pokémon exist for each color.
select pwt.color, count(p.identifier) from pokemon p join pokemon_with_type pwt on pwt.id = p.id group by pwt.color;

-- Display only types having more than 50 Pokémon.
select pwt.type, count(p.identifier) as count from pokemon p join pokemon_with_type pwt on pwt.id = p.id group by pwt.type having count(p.identifier) > 50;


-- For each generation, calculate:

-- number of species
-- number of legendary species
-- number of mythical species

select 
    ps.generation_id as generation,
    count(ps.identifier) as num_species,
    count(ps.is_legendary) filter (where ps.is_legendary = true) as number_of_legendary,
    count(ps.is_mythical) filter (where ps.is_mythical = true) as number_of_mythical
from pokemon p join pokemon_species ps on p.id = ps.id group by ps.generation_id order by ps.generation_id;


-- Level 5: Harder queries

-- Find Pokémon with no type.
-- select p.identifier, pwt.type from pokemon p left join pokemon_with_type pwt on pwt.id = p.id where pwt.type is null;

-- Find species that do not evolve from another species.
-- select p.identifier, ps.evolves_from_species_id from pokemon p join pokemon_species ps on ps.id = p.id where ps.evolves_from_species_id is null;

-- Find species that have at least one evolution.
-- select p.id, p.identifier, ps.evolves_from_species_id from
--     pokemon p left join pokemon_species ps on ps.id = p.id
--     where p.id in ()
--     limit 10
-- ;
-- select * from pokemon p join pokemon_species ps on ps.id = p.id
-- where p.id in (
--     select id from pokemon_species where ps.evolves_from_species_id = p.id 
-- )


-- Find Pokémon that have every type assigned to them. In other words, find Pokémon whose number of types equals the total number of types in the types table.
select p.id, p.identifier from pokemon p join pokemon_types pt on pt.id = p.id join types t on t.id = pt.type_id group by p.id;

-- Find Pokémon that have the same type combination as bulbasaur.

-- Find the type with the greatest average Pokémon weight.


-- For each type, rank Pokémon from heaviest to lightest using a window function.

-- Find the heaviest Pokémon that is not legendary or mythical.