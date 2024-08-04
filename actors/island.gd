extends Node2D
class_name Island

@export var island_id : int = -1

@export var start_species_names : Array[String]
@export var glv_sample : GLVSample
@export var global_glv_sample : GLVSample = preload("res://data/3_sample_2_negative_growth.tres")

@onready var highlight : Polygon2D = $Highlight
@onready var tile_map = $TileMap
@onready var collision_shape_2d = $Area2D/CollisionShape2D

@onready var glv : GLV = $GLV
@onready var pops = $Pops
@onready var species_grid : SpeciesGrid = $SpeciesGrid
@onready var lifeform_spawner : LifeformSpawner = $LifeformSpawner

var migration_matrix : Dictionary = {} # Vector3i(id_from, id_to, species_index)

signal island_selected(island_id : int)
signal species_changed(species_names : Array[String])
signal densities_update(species_densities : Dictionary) #Dictionary[String,float]


func _ready():
    if OS.is_debug_build() and self.owner == null:
        self.global_position = get_viewport_rect().size/2

    # unnecessary since we do get_parent on glv...
    glv.global_glv_sample = global_glv_sample

    add_to_group('islands')
    if island_id == -1:
        island_id = get_tree().get_nodes_in_group('islands').find(self)

    species_grid.set_island_name('Island %d' % island_id)

    init_everything()

    # apply random pattern
    const NUM_PATTERNS : int = 9
    var pattern : TileMapPattern = tile_map.tile_set.get_pattern(randi() % NUM_PATTERNS)
    var offset : Vector2 = -pattern.get_size()/2
    tile_map.set_pattern(0, offset, pattern)

    var island_rect : Rect2i = tile_map.get_used_rect()
    collision_shape_2d.shape = collision_shape_2d.shape.duplicate()
    collision_shape_2d.shape.size = island_rect.size*16

func init_everything():
    pops.set_species_names(glv.species_names)
    species_grid._on_glv_species_changed(glv.species_names, glv.mutuality, glv.growth)
    lifeform_spawner.set_species_names(glv.species_names)

func change_emigration(from_island : Island, to_island : Island, species_name : String, migration_value : float):
    var species_index : int = glv.species_names.find(species_name)
    if species_index == -1:
        push_error('%s emigrating %d <- %d does not exist' % [species_name, from_island, to_island])
    apply_migration(species_index, from_island, to_island, -migration_value)

func is_immigrating(from_island : Island, to_island: Island, species_name : String) -> bool:
    var species_index : int = self.glv.species_names.find(species_name)
    if species_index < 0:
        return false
    var migration_value : float = migration_matrix.get(Vector3i(from_island.island_id, to_island.island_id, species_index), 0)
    return migration_value != 0

func change_immigration(from_island : Island, to_island : Island, species_name : String, migration_value : float):
    if migration_value == 0 and not is_immigrating(from_island, to_island, species_name):
        return
    var species_index : int = glv.species_names.find(species_name)
    if species_index != -1:
        apply_migration(species_index, from_island, to_island, migration_value)
    else:
        glv.add_species(species_name)
        species_changed.emit(glv.species_names)
        species_index = glv.species_names.find(species_name)
        glv.densities[species_index] = migration_value
        apply_migration(species_index, from_island, to_island, migration_value)
        species_grid._on_glv_species_changed(glv.species_names, glv.mutuality, glv.growth)

func apply_migration(species_index : int, from_island : Island, to_island : Island, migration_value : float):
    var previous_migration : float = migration_matrix.get(Vector3i(from_island.island_id,to_island.island_id, species_index), 0)
    migration_matrix[Vector3i(from_island.island_id, to_island.island_id, species_index)] = migration_value
    glv.immigration[species_index] += migration_value - previous_migration

func _on_change_species(island : int, species_name : String, growth : float, mutuality : Array):
    if island_id == island:
        var species_index : int = glv.species_names.find(species_name)
        if species_index != -1:
            prints('Changing species', species_name, 'on island', island_id)
            glv.modify_species(species_index, mutuality, growth)
        else:
            prints('Adding species', species_name, 'on island', island_id)
            glv.add_new_species(species_name, mutuality, growth)
            species_changed.emit(glv.species_names)

        species_grid._on_glv_species_changed(glv.species_names, glv.mutuality, glv.growth)

func _on_add_species(island : int, species_name : String):
    if island_id == island:
        glv.add_species(species_name)

func _on_area_2d_island_clicked():
    species_grid.visible = not species_grid.visible


func _on_glv_densities_update(new_densities : Array[float]):
    var species_densities = Util.zip(glv.species_names, new_densities)
    densities_update.emit(species_densities)

