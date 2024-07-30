extends Node2D

@onready var cli = $Cli
@onready var migration_lines = $MigrationLines

func _ready():
    var islands : Array = get_tree().get_nodes_in_group('islands')
    for island : Island in islands:
        cli.change_species.connect(island._on_change_species)
        for island_to : Island in islands:
            if island == island_to or island.island_id > island_to.island_id:
                continue
            if island.global_position.distance_to(island_to.global_position) < 500:
                prints("Establishing migration line from",island.island_id,'-->',island_to.island_id)
                var migration_line : MigrationLine = preload('res://actors/migration_line.tscn').instantiate()
                migration_line.from_island = island
                migration_line.to_island = island_to
                var available_species : Array[String] = island.glv.species_names.duplicate() #+ island_to.glv.species_names
                migration_line.species_names = available_species
                migration_line.change_migration.connect(island_to.change_immigration)
                migration_line.change_migration.connect(island.change_emigration)
                island.species_changed.connect(migration_line.add_species)
                island_to.species_changed.connect(migration_line.add_species)
                migration_lines.add_child(migration_line)


