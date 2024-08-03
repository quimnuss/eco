# eco

Ecosystem simulation based on General Lotka-Volterra equations and specialization/generalization

# Plan

## next

[ ] [BUG] negative immigration does not emigrate

[ ] Create 100 species
[ ] Change ui for island population

## later

[ ] Treat adaptation as new species?
[ ] Sort alphabetically on ui

## Done

[x] Create 10 species
[x] Handle extinction in migration
[x] have a "hidden" mutuality copied from the island source on migration or solve the global mutuality problem

--> done with a global complete GLV sample on each island

Currently, when a species migrates, it loses their mutuality information with species not present in the new island.
This will always happen, so either there should be a NxN global mutuality and growth or the whole mutuality is sent
with the migration.

Probably simpler atm to have a global base mutuality, but what do we do with adaptation? It is "solved" if a new
species is set on adaptation, but that is tricky in its own terms, can it reproduce with the origin species? how is
it's density related to the origin species?

We could say that each species has some mutuality wiggle room, as the competitive pressure increases,
the wiggle room is used which lowers the values without changing the "base" values. So if the species migrates,
the baseline is what migrates.

Once the wiggle room threshold is exceeded, reproduction is no longer viable and a new species appears.
