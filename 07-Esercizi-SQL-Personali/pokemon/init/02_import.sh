#!/usr/bin/env bash
# Import the pokedex CSVs (https://github.com/veekun/pokedex) into the tables
# created by 01_schema.sql. Runs inside the container at first startup.
set -euo pipefail
D=/docker-entrypoint-initdb.d/csv

for t in pokemon types pokemon_types pokemon_colors pokemon_shapes; do
  psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "\\copy $t from '$D/$t.csv' CSV HEADER"
done
psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "\\copy pokemon_species (id, identifier, generation_id, evolves_from_species_id, evolution_chain_id, color_id, shape_id, habitat_id, gender_rate, capture_rate, base_happiness, is_baby, hatch_counter, has_gender_differences, growth_rate_id, forms_switchable, is_legendary, is_mythical, \"order\", conquest_order) from '$D/pokemon_species.csv' CSV HEADER"
