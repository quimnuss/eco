extends Area2D

signal island_clicked
@onready var control = $"../Control"

func _ready():
    pass

func _input_event(viewport, event, _shape_idx):
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
        if event.pressed and control.is_hovered and not control.is_selected:
            island_clicked.emit()
            #viewport.set_input_as_handled()

