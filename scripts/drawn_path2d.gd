extends Path2D

const head_angle : float = PI/6
const head_length : float = 20.0

const line_width : float = 3
const line_color : Color = Color.AQUAMARINE

var ends_down : bool = true

func _draw():
    var points : PackedVector2Array = self.curve.get_baked_points()
    draw_polyline(points, line_color, line_width, true)
    var value : Vector2 = points[-1]
    var head_direction = Vector2.DOWN if ends_down else Vector2.UP
    var head : Vector2 = -head_direction * head_length
    draw_line(value, value + head.rotated(head_angle),  line_color, line_width)
    draw_line(value, value + head.rotated(-head_angle),  line_color, line_width)
    
