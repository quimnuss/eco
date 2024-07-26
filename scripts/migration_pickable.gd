extends Node2D
class_name Island

@export var island_id : int = -1
@export var glv_sample : GLVSample
@onready var highlight : Polygon2D = $Highlight

@onready var glv : GLV = $GLV
@onready var pops = $Pops

signal island_selected(island_id : int)

func _ready():
    if OS.is_debug_build() and self.owner == null:
        self.global_position = get_viewport_rect().size/2
        glv_sample = preload("res://data/3_sample_0.tres")
        glv.restart(glv_sample)

    add_to_group('islands')
    if island_id == -1:
        island_id = get_tree().get_nodes_in_group('islands').find(self)
    
    pops.set_num_species(glv.num_species)
    pops.set_species_names(glv.species_names)
    
    var island_shape : CollisionShape2D = $Area2D/CollisionShape2D as CollisionShape2D
    var island_rect : Rect2i = $TileMap.get_used_rect()
    island_shape.shape.size = island_rect.size
    island_shape.position = island_rect.position

func _on_change_species(island : int, species_name : String, growth : float, mutuality : Array):
    if island_id == island:
        var species_index : int = glv.species_names.find(species_name)
        if species_index != -1:
            prints('Changing species', species_name, 'on island', island_id)
            glv.modify_species(species_index, mutuality, growth)
        else:
            prints('Adding species', species_name, 'on island', island_id)
            glv.add_species(species_name, mutuality, growth)
