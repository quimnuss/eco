extends Area2D

@onready var highlight : Polygon2D = $"../Highlight"

signal island_clicked

func _ready():
    mouse_entered.connect(_on_mouse_entered)
    mouse_exited.connect(_on_mouse_exited)

func _input_event(viewport, event, _shape_idx):
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
        if event.pressed and highlight.visible:
            island_clicked.emit()
            viewport.set_input_as_handled()

func _on_mouse_entered():
    highlight.visible = true

func _on_mouse_exited():
    highlight.visible = false

