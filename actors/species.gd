extends Node2D
class_name SpeciesLine

@onready var line_2d : Line2D = $Line2D
@onready var label = $Label
@onready var density_label = $DensityLabel

@export var unitary_bar_size : Vector2 = Vector2(20, 0)
@onready var head : Sprite2D = $Head

var start_text : String = "?"

var height : float = 10

func _ready():
    line_2d.default_color = Color(randf_range(0,1),randf_range(0,1),randf_range(0,1))
    label.set_text(start_text)
    var species_enum : Species.SpeciesEnum = Species.name_enum[start_text]
    head.frame = Species.species_frame[species_enum]

func set_species_name(species_name : String):
    label.set_text(species_name)
    var species_enum : Species.SpeciesEnum = Species.name_enum[species_name]
    head.frame = Species.species_frame[species_enum]

func update_density(density : float):
    line_2d.set_point_position(1, unitary_bar_size * density)
    density_label.set_text("%0.2f" % density)
    if density <= 0:
        label.set("theme_override_colors/font_color",Color.DARK_RED)
        density_label.set("theme_override_colors/font_color",Color.DARK_RED)
    else:
        label.set("theme_override_colors/font_color",Color.GHOST_WHITE)
        density_label.set("theme_override_colors/font_color",Color.GHOST_WHITE)

