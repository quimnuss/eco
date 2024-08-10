extends Node2D

@onready var pressed_sprite : Sprite2D = $Pressed
@onready var normal_sprite : Sprite2D = $Normal

@onready var hover = $Hover


var pressed : bool = false :
    set(is_pressed):
        pressed=is_pressed
        pressed_sprite.visible = is_pressed
        normal_sprite.visible = not is_pressed
    get:
        return pressed

signal toggled(toggled_on : bool)
signal hovered(hover_on : bool)

func toggle():
    pressed = !pressed
    toggled.emit(pressed)

func _on_area_2d_input_event(viewport, event, shape_idx):
    if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
        toggle()
        viewport.set_input_as_handled()

func _on_area_2d_mouse_entered():
    hover.visible = true
    hovered.emit(true)


func _on_area_2d_mouse_exited():
    hover.visible = false
    hovered.emit(false)
