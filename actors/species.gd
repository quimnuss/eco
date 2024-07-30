extends Node2D
class_name Species

@onready var line_2d : Line2D = $Line2D
@onready var label = $Label
@onready var density_label = $DensityLabel

@export var unitary_bar_size : Vector2 = Vector2(20, 0)

var height : float = 10

func _ready():
    line_2d.default_color = Color(randf_range(0,1),randf_range(0,1),randf_range(0,1))

func set_species_name(species_name : String):
    label.set_text(species_name)

func update_density(density : float):
    line_2d.set_point_position(1, unitary_bar_size * density)
    density_label.set_text("%0.2f" % density)
    if density <= 0:
        label.set("theme_override_colors/font_color",Color.DARK_RED)
    else:
        label.set("theme_override_colors/font_color",Color.GHOST_WHITE)

