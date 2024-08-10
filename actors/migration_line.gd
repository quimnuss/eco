extends Node2D
class_name MigrationLine

@onready var migration_popup_anchor = $Path2D/Marker2D
@onready var grid_container = $Path2D/Marker2D/Control/Panel/GridContainer

@export var from_island : Island
@export var to_island : Island
@onready var path_2d : Path2D = $Path2D


const LINE_OFFSET : Vector2 = Vector2(0,5)
const EMIGRATION_THRESHOLD : float = 0.1

var species_names : Array[String]

var interaction_point : Vector2

signal change_migration(from_island : Island, to_island : Island, species_name : String, migration_value : float)

signal migration_cancelled(from_island : Island, to_island : Island, species_name : String)

func _ready():
    self.global_position = (from_island.global_position + to_island.global_position)/2.0
    path_2d.curve = Curve2D.new()
    #path_2d.curve.clear_points()
    if from_island.global_position.x < to_island.global_position.x:
        path_2d.curve.add_point(from_island.global_position - self.global_position, Vector2.ZERO, 100*Vector2.UP)
        path_2d.curve.add_point(to_island.global_position - self.global_position, 100*Vector2.UP, Vector2.ZERO)
    else:
        path_2d.curve.add_point(from_island.global_position - self.global_position + LINE_OFFSET, Vector2.ZERO, 100*Vector2.DOWN)
        path_2d.curve.add_point(to_island.global_position - self.global_position + LINE_OFFSET, 100*Vector2.DOWN, Vector2.ZERO)
    var migration_points : PackedVector2Array = path_2d.curve.get_baked_points()
    interaction_point = Vector2(migration_points[floor(len(migration_points)/2.0)])
    migration_popup_anchor.global_position = interaction_point + self.global_position


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

func reset_migration_ui(species_name : String):
    var i = species_names.find(species_name)
    if i != -1:
        var species_migrations = grid_container.get_children()
        var species_migration = species_migrations[2*i + 1] as RangeRect
        species_migration.set_color(0)

func get_migration_value(species_name : String) -> float:
    var i = species_names.find(species_name)
    if i != -1:
        var species_migrations = grid_container.get_children()
        var species_migration = species_migrations[2*i + 1] as RangeRect
        return species_migration.get_value()
    return 0

func _on_change_migration_rate(index_i : int, new_value : float):
    var species_name : String = species_names[index_i]
    if not can_migrate(species_name, new_value):
        reset_migration_ui(species_name)
    else:
        change_migration.emit(from_island, to_island, species_name, new_value)

func can_migrate(species_name : String, new_value : float) -> bool:
    if new_value > 0: # emigrating
        var from_species_index : int = from_island.glv.species_names.find(species_name)
        if from_species_index == -1:
            return false
        elif from_island.glv.densities[from_species_index] < EMIGRATION_THRESHOLD:
            return false
    elif new_value < 0: # immigrating
        var to_species_index : int = to_island.glv.species_names.find(species_name)
        if to_species_index == -1:
            return false
        elif to_island.glv.densities[to_species_index] < EMIGRATION_THRESHOLD:
            return false
    return true

func _on_selected_migration_line():
    migration_popup_anchor.visible = true

func _on_glv_densities_update(species_densities : Dictionary):
    for species_name in species_densities:
        if species_densities[species_name] < EMIGRATION_THRESHOLD:
            if get_migration_value(species_name) > 0:
                change_migration.emit(from_island, to_island, species_name, 0)
                migration_cancelled.emit(from_island, to_island, species_name)
                reset_migration_ui(species_name)

