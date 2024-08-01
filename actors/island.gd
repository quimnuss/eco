extends Node2D
class_name Island

@export var island_id : int = -1
@export var glv_sample : GLVSample
@onready var highlight : Polygon2D = $Highlight
@onready var tile_map = $TileMap
@onready var collision_shape_2d = $Area2D/CollisionShape2D

@onready var glv : GLV = $GLV
@onready var pops = $Pops
@onready var species_grid : SpeciesGrid = $SpeciesGrid

var migration_matrix : Dictionary = {}

signal island_selected(island_id : int)
signal species_changed(species_names : Array[String])

func _ready():
    if OS.is_debug_build() and self.owner == null:
        self.global_position = get_viewport_rect().size/2

    add_to_group('islands')
    if island_id == -1:
        island_id = get_tree().get_nodes_in_group('islands').find(self)

    species_grid.set_island_name('Island %d' % island_id)

    init_everything()
    set_island_pattern()

    glv.species_names_changed.connect(pops.model_changed)

    var island_rect : Rect2i = tile_map.get_used_rect()
    collision_shape_2d.shape.size = island_rect.size*16

func set_island_pattern():
    # apply random pattern
    const NUM_PATTERNS : int = 9
    var pattern : TileMapPattern = tile_map.tile_set.get_pattern(randi() % NUM_PATTERNS)
    var offset : Vector2 = -pattern.get_size()/2
    tile_map.set_pattern(0, offset, pattern)

func init_everything():

    pops.set_num_species(glv.num_species)
    pops.set_species_names(glv.species_names)

    species_grid._on_glv_species_changed(glv.species_names, glv.mutuality, glv.growth)


func change_emigration(from_island : Island, to_island : Island, species_name : String, migration_value : float):
    var species_index : int = glv.species_names.find(species_name)
    var previous_migration : float = migration_matrix.get(Vector2i(from_island.island_id,to_island.island_id), 0)
    migration_matrix[Vector2i(from_island.island_id, to_island.island_id)] = migration_value
    glv.emigration[species_index] += migration_value - previous_migration

func change_immigration(from_island : Island, to_island : Island, species_name : String, migration_value : float):
    var species_index : int = glv.species_names.find(species_name)
    if species_index != -1:
        apply_migration(species_index, from_island, to_island, migration_value)
    else:
        # TODO new species! where do we get the definition? we probably need a global dictionary
        # and islands apply modifiers?
        var from_island_species_index : int = from_island.glv.species_names.find(species_name)
        # The species available do not match so mutuality matrices do not match either
        #var new_species_mutuality : Array[float] = from_island.glv.mutuality[from_island_species_index]
        var self_mutual_array : Array[float]
        self_mutual_array.resize(glv.num_species+1)
        self_mutual_array[glv.num_species] = from_island.glv.mutuality[from_island_species_index][from_island_species_index]
        glv.add_species(species_name, self_mutual_array, from_island.glv.growth[from_island_species_index])
        species_changed.emit(glv.species_names)
        glv.densities[species_index] = migration_value
        apply_migration(species_index, from_island, to_island, migration_value)
        species_grid._on_glv_species_changed(glv.species_names, glv.mutuality, glv.growth)

func apply_migration(species_index : int, from_island : Island, to_island : Island, migration_value : float):
    var previous_migration : float = migration_matrix.get(Vector2i(from_island.island_id,to_island.island_id), 0)
    migration_matrix[Vector2i(from_island.island_id, to_island.island_id)] = migration_value
    glv.immigration[species_index] = glv.immigration[species_index] + migration_value - previous_migration

func _on_change_species(island : int, species_name : String, growth : float, mutuality : Array):
    if island_id == island:
        var species_index : int = glv.species_names.find(species_name)
        if species_index != -1:
            prints('Changing species', species_name, 'on island', island_id)
            glv.modify_species(species_index, mutuality, growth)
        else:
            prints('Adding species', species_name, 'on island', island_id)
            glv.add_species(species_name, mutuality, growth)
            species_changed.emit(glv.species_names)

        species_grid._on_glv_species_changed(glv.species_names, glv.mutuality, glv.growth)

func _on_area_2d_island_clicked():
    species_grid.visible = not species_grid.visible
