extends Node

signal mouse_released

func _input(event):
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
        if not event.is_pressed():
            mouse_released.emit()
            
