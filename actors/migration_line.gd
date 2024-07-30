extends Node2D
class_name MigrationLine

@onready var migration_popup = $Path2D/Control
@onready var grid_container = $Path2D/Control/Panel/GridContainer

@export var from_island : Island
@export var to_island : Island
@onready var path_2d : Path2D = $Path2D
@onready var panel : Panel = $Path2D/Control/Panel

const LINE_OFFSET : Vector2 = Vector2(0,5)

var species_names : Array[String]

var interaction_point : Vector2

signal change_migration(from_island : Island, to_island : Island, species_name : String, migration_value : float)

func _ready():
    self.global_position = (from_island.global_position + to_island.global_position)/2.0
    path_2d.curve = Curve2D.new()
    #path_2d.curve.clear_points()
    var ease_in : Vector2 = Vector2.ZERO
    var ease_out : Vector2 = Vector2.ZERO
    if from_island.global_position.x < to_island.global_position.x:
        path_2d.curve.add_point(from_island.global_position - self.global_position, Vector2.ZERO, 100*Vector2.UP)
        path_2d.curve.add_point(to_island.global_position - self.global_position, 100*Vector2.UP, Vector2.ZERO)
        path_2d.ends_down = true
    else:        
        path_2d.curve.add_point(from_island.global_position - self.global_position + LINE_OFFSET, Vector2.ZERO, 100*Vector2.DOWN)
        path_2d.curve.add_point(to_island.global_position - self.global_position + LINE_OFFSET, 100*Vector2.DOWN, Vector2.ZERO)
        path_2d.ends_down = false
    var migration_points : PackedVector2Array = path_2d.curve.get_baked_points()
    interaction_point = Vector2(migration_points[floor(len(migration_points)/2.0)]) + Vector2(0,-30)
    migration_popup.global_position = interaction_point + self.global_position - Vector2(0,panel.get_custom_minimum_size().y + 20)
    
    for i in range(len(species_names)):
        var species_name : String = species_names[i]
        add_species_ui(species_name)

func add_species_ui(new_species_name : String):
    var i = species_names.find(new_species_name)
    var species_label : Label = Label.new()
    species_label.set_text(new_species_name)
    grid_container.add_child(species_label)
    var one_square = preload('res://ui/range_rect.tscn').instantiate()
    one_square.is_growth = true
    one_square.index_i = i
    one_square.index_j = -1
    one_square.change_growth.connect(_on_change_migration_rate)
    grid_container.add_child(one_square)

func add_species(new_species_names : Array[String]):
    # TODO handle deletion?
    for species_name : String in new_species_names:
        if not self.species_names.has(species_name):
            self.species_names.append(species_name)
            add_species_ui(species_name)

func _on_change_migration_rate(index_i : int, new_value : float):
    var species_name : String = species_names[index_i]
    change_migration.emit(from_island, to_island, species_name, new_value)

func _on_selected_migration_line():
    migration_popup.visible = true
