extends Control
class_name SpeciesGrid

@onready var grid_container : GridContainer = $PanelContainer/VBoxContainer/GridContainer
@onready var growths : HBoxContainer = $PanelContainer/VBoxContainer/Growths
@onready var island_label : Label = $PanelContainer/VBoxContainer/HBoxContainer/IslandLabel

@export var num_species : int = 3

var species_names : Array[String]

var max_mutuality : float

signal change_mutuality(index_i : int, index_j : int, new_mutuality : float)
signal change_growth(index_i : int, new_growth : float)

const EPSILON : float = 0.0001

func _ready():
    refresh_grid()

func set_island_name(island_name : String):
    island_label.set_text(island_name)

func refresh_grid():
    # Too late
    #for child in grid_container.get_children():
        #child.queue_free()
    var papa = grid_container.get_parent()
    growths.queue_free()
    growths = HBoxContainer.new()
    papa.add_child(growths)
    grid_container.queue_free()
    grid_container = GridContainer.new()
    grid_container.columns = num_species+1
    papa.add_child(grid_container)

    var empty_square : Label = Label.new()
    empty_square.set_size(Vector2(32,32))
    grid_container.add_child(empty_square)

    var empty_square2 : Label = Label.new()
    empty_square2.set_size(Vector2(32,32))
    empty_square2.set_custom_minimum_size(Vector2(32,32))
    growths.add_child(empty_square2)
    for i in range(num_species):
        var one_square = preload('res://ui/range_rect.tscn').instantiate()
        one_square.is_growth = true
        one_square.index_i = i
        one_square.index_j = -1
        one_square.change_growth.connect(_on_change_growth)
        growths.add_child(one_square)

    for i in range(num_species):
        var species_name : Label = create_species_label(i)
        grid_container.add_child(species_name)

    for i in range(num_species):
        var species_name : Label = create_species_label(i)
        grid_container.add_child(species_name)

        for j in range(num_species):
            var one_square = preload('res://ui/range_rect.tscn').instantiate()
            one_square.index_i = i
            one_square.index_j = j
            one_square.change_mutuality.connect(_on_change_mutuality)
            grid_container.add_child(one_square)




func _on_change_mutuality(index_i : int, index_j : int, new_value : float):
    change_mutuality.emit(index_i, index_j, new_value)

    # update maximum in grid
    var new_max_mutuality : float = 0
    for child in grid_container.get_children():
        if child is RangeRect:
            new_max_mutuality = max(new_max_mutuality, abs(child.value))
    if abs(new_max_mutuality - self.max_mutuality) > EPSILON and new_max_mutuality > EPSILON:
        for child in grid_container.get_children():
            if child is RangeRect:
                child.change_max_value(new_max_mutuality)

func _on_change_growth(index_i : int, new_value : float):
    change_growth.emit(index_i, new_value)

func create_species_label(index : int) -> Label:
    var species_name : Label = Label.new()
    species_name.clip_text = true
    species_name.set_custom_minimum_size(Vector2(32,32))
    species_name.set_text_overrun_behavior(TextServer.OVERRUN_TRIM_CHAR)
    var s_name : String = species_names[index] if species_names else 'foo'
    species_name.set_text(s_name)
    return species_name


func _process(_delta):
    if is_following_mouse:
        self.global_position = get_global_mouse_position() - mouse_clicked_at

func _on_glv_species_changed(new_species_names : Array, mutuality : Array, growth : Array):
    update_mutuality(new_species_names, mutuality)
    update_growth(growth)

func update_mutuality(new_species_names : Array, mutuality : Array):
    num_species = len(new_species_names)
    species_names = new_species_names
    refresh_grid()
    var grid_children : Array = grid_container.get_children()
    var new_max_mutuality : float = 0
    for species_mutual : Array in mutuality:
        new_max_mutuality = max(new_max_mutuality, abs(species_mutual.max()), abs(species_mutual.min()))
    self.max_mutuality = new_max_mutuality
    #prints('mutuality',mutuality,'max_mutuality',max_mutuality)
    for i in range(num_species):
        for j in range(num_species):
            if abs(mutuality[i][j]) > 0.0001:
                var children_index : int = (i+1)*(num_species+1) + (j+1)
                var square : RangeRect = grid_children[children_index]
                square.max_value = self.max_mutuality
                square.set_color(mutuality[i][j])

func update_growth(growth : Array[float]):
    var growth_children : Array = growths.get_children()
    for i in range(num_species):
        var square : RangeRect = growth_children[i+1]
        square.max_value = growth.max()
        square.set_color(growth[i])

func _on_button_pressed():
    self.visible = false

var is_following_mouse : bool = false
var mouse_clicked_at : Vector2
func _on_title_gui_input(event):
    if event is InputEventMouseButton:
        mouse_clicked_at = get_local_mouse_position()
        is_following_mouse = event.is_pressed()
