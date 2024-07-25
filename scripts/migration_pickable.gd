extends Area2D

@export var island_id : int = 0
@onready var highlight : Polygon2D = $Highlight

@onready var glv = $GLV
@onready var pops = $Pops

signal island_clicked(point : Vector2, island_id : int)

func _ready():
    add_to_group('islands')
    
    island_id = get_tree().get_nodes_in_group('islands').find(self)
    
    mouse_entered.connect(_on_mouse_entered)
    mouse_exited.connect(_on_mouse_exited)
    
    pops.set_num_species(glv.num_species)
    pops.set_species_names(glv.species_names)

func _input_event(viewport, event, shape_idx):
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
        if event.pressed:
            island_clicked.emit(event.position, island_id)

func _on_mouse_entered():
    highlight.visible = true

func _on_mouse_exited():
    highlight.visible = false
