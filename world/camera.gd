extends Camera2D

var is_mouse_at_edge : bool = false

func _process(delta):
    if is_mouse_at_edge:
        self.global_position = self.global_position.move_toward(get_global_mouse_position(), 10)

func _on_area_2d_mouse_entered():
    is_mouse_at_edge = false

func _on_area_2d_mouse_exited():
    is_mouse_at_edge = true
