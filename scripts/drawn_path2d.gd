extends Path2D

const head_angle : float = PI/6
const head_length : float = 20.0

var start_color : Color = Color.RED
var end_color : Color = Color.FOREST_GREEN

const line_width : float = 2
var line_color : Color = 0.5*(start_color+end_color)

var points : PackedVector2Array
var color_array : PackedColorArray

var value : Vector2
var head_direction
var head : Vector2

var is_init : bool = false

const ALPHA_NORMAL : float = 0.1
const ALPHA_HOVERED : float = 1

func _ready():
    line_color.a = ALPHA_NORMAL
    start_color.a = ALPHA_NORMAL
    end_color.a = ALPHA_NORMAL

func hover(is_hovered : bool):
    var alpha : float = ALPHA_HOVERED if is_hovered else ALPHA_NORMAL
    line_color.a = alpha
    start_color.a = alpha
    end_color.a = alpha
    for i in range(len(color_array)):
        color_array[i].a = alpha
    self.queue_redraw()

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

