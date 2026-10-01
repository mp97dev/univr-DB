create table if not exists pokemon (
    id serial, 
    identifier varchar(100) not null,
    species_id int not null,
    height int not null,
    weight int not null,
    base_experience int not null,
    "order" int not null,
    is_default boolean not null
);

create table if not exists types (
    id serial,
    identifier varchar(100) not null,
    generation_id int not null,
    damage_class_id int
);

create table if not exists pokemon_types (
    id serial,
    type_id int not null,
    slot int not null
);

create table if not exists pokemon_species (
    id serial,
    identifier varchar(100) not null,
    generation_id int,
    evolves_from_species_id int null,
    evolution_chain_id int,
    color_id int,
    shape_id int,
    habitat_id int,
    gender_rate int,
    capture_rate int,
    base_happiness int,
    is_baby boolean,
    hatch_counter int,
    has_gender_differences boolean,
    growth_rate_id int,
    forms_switchable boolean,
    is_legendary boolean,
    is_mythical boolean,
    "order" int,
    conquest_order int null
);

alter table pokemon_species add column if not exists is_legendary boolean;
alter table pokemon_species add column if not exists is_mythical boolean;

create table if not exists pokemon_shapes (
    id serial,
    identifier varchar(100)
);

create table if not exists pokemon_colors (
    id serial,
    identifier varchar(100)
);


create or replace view pokemon_with_type as
	select p.id, p.identifier, t.identifier as type, c.identifier as color, s.identifier as shape
	from pokemon p
	inner join pokemon_types pt on p.id = pt.id
	inner join types t on pt.type_id = t.id
	inner join pokemon_species ps on p.species_id = ps.id
	inner join pokemon_colors c on ps.color_id = c.id
	inner join pokemon_shapes s on ps.shape_id = s.id;
