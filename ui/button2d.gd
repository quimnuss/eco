extends Node2D
class_name Button2D

@onready var pressed_sprite : Sprite2D = $Pressed
@onready var normal_sprite : Sprite2D = $Normal

@onready var hover = $Hover

@export var button_type : ButtonType = ButtonType.MIGRATE
@export var toggle_mode : bool = true

enum ButtonType {
    MIGRATE,
    ADD_SPECIES
}

var pressed : bool = false :
    set(is_pressed):
        pressed=is_pressed
        pressed_sprite.visible = is_pressed
        normal_sprite.visible = not is_pressed
    get:
        return pressed

signal toggled(toggled_on : bool)
signal hovered(hover_on : bool)

func _ready():
    match button_type:
        ButtonType.ADD_SPECIES:
            pressed_sprite.texture = load("res://assets/icons/Grass-Buttons-pressed-+.png")
            normal_sprite.texture = load("res://assets/icons/Grass-Buttons-+.png")
        ButtonType.MIGRATE:
            pressed_sprite.texture = load("res://assets/icons/Grass-Buttons-pressed-return2.png")
            normal_sprite.texture = load("res://assets/icons/Grass-Buttons-return2.png")

func toggle():
    pressed = !pressed
    toggled.emit(pressed)
    if not toggle_mode and pressed:
        get_tree().create_timer(0.3).timeout.connect(toggle)


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
