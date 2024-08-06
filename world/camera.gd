extends Camera2D

var is_mouse_at_edge : bool = false

func _process(delta):
    if is_mouse_at_edge:
        if get_global_mouse_position() < Vector2(1400,1000):
            self.global_position = self.global_position.move_toward(get_global_mouse_position(), 300*delta)

func _on_area_2d_mouse_entered():
    is_mouse_at_edge = false

func _on_area_2d_mouse_exited():
    is_mouse_at_edge = true
