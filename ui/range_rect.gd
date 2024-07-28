extends TextureRect

var index_i : int
var index_j : int

var max_value : float
var value : float

@export var increments : float = 0.001

signal turn_up(index_i, index_j)
signal turn_down(index_i, index_j)

func set_color(new_value, max_value):
    if abs(new_value) < 0.0001:
        self.modulate = Color.GRAY
        return
    var ratio = clamp(abs(new_value/max_value),0,1)*0.3 + 0.7
    var base_color = Color.DARK_RED if new_value < 0 else Color.DARK_GREEN
    self.set_modulate(base_color*ratio)

func _input(event):
    if event is InputEventMouseButton and event.is_pressed():
        if event.button_index == MOUSE_BUTTON_WHEEL_UP:
            self.value += increments
            self.set_color(self.value,self.max_value)
            turn_up.emit(index_i, index_j)
        elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
            self.value -= increments
            self.set_color(self.value,self.max_value)
            turn_down.emit(index_i, index_j)
