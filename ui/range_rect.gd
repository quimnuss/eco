extends TextureRect

var index_i : int
var index_j : int

signal turn_up(index_i, index_j)
signal turn_down(index_i, index_j)

func _input(event):
    if event is InputEventMouseButton and event.is_pressed():
        if event.button_index == MOUSE_BUTTON_WHEEL_UP:
            turn_up.emit(index_i, index_j)
        elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
            turn_down.emit(index_i, index_j)
