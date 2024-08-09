extends Path2D

const head_angle : float = PI/6
const head_length : float = 20.0

var start_color : Color = Color.RED
var end_color : Color = Color.GREEN

const line_width : float = 2
var line_color : Color = 0.5*(start_color+end_color)

var points : PackedVector2Array
var color_array : PackedColorArray

var value : Vector2
var head_direction
var head : Vector2

var is_init : bool = false

func _ready():
    line_color.a = 0.6
    start_color.a = 0.6
    end_color.a = 0.6

func ease_in_out_quint(x: float) -> float:
    return 16 * x * x * x * x * x if x < 0.5 else 1 - pow(-2 * x + 2, 5) / 2


func initialize():
    points = self.curve.get_baked_points()
    for i in len(points):
        var ratio : float = ease_in_out_quint(float(i)/len(points))
        color_array.push_back(start_color * (1-ratio) + ratio*end_color)
    value = points[len(points)/2]
    head_direction =  (points[len(points)/2] - points[len(points)/2-1]).normalized()
    head = -head_direction * head_length
    is_init = false

func _draw():
    if not is_init:
        initialize()
    draw_polyline_colors(points, color_array, line_width, true)
    draw_line(value, value + head.rotated(head_angle),  line_color, line_width)
    draw_line(value, value + head.rotated(-head_angle),  line_color, line_width)

