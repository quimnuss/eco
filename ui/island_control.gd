extends Control

var is_hovered := false
var is_selected := false

var highlight_color : Color = Color(0.7,1,1)
var base_color : Color = Color(1,1,1)

func _ready():
    add_to_group('island_selectors')
    match owner.island_type:
        Island.IslandType.NORMAL:
            highlight_color = Color(0.7, 1, 1)
            base_color = Color(1,1,1)
        Island.IslandType.FIRE:
            highlight_color = Color(1, 0.7, 0.7)
            base_color = Color(1, 0.8, 0.8)
        Island.IslandType.WATER:
            highlight_color = Color(0, 0.8, 1)
            base_color = Color(0, 0.9, 1)
        Island.IslandType.AIR:
            highlight_color = Color(0.5, 1, 0.5)
            base_color = Color(0.5, 0.8, 0.5)
    $"../TileMap".call_deferred('set_modulate',base_color)

var num_hovered : int = 0

func _on_mouse_entered():
    num_hovered += 1
    if num_hovered > 2:
        num_hovered = 2
    is_hovered = true
    $"../TileMap".modulate = highlight_color

func _on_mouse_exited():
    # hack because two area2d influence hovered
    num_hovered -= 1
    if num_hovered <= 0:
        num_hovered = 0
        is_hovered = false
        if not is_selected:
            $TextureRect.visible = false
            $"../TileMap".modulate = base_color

func select_island():
    is_selected = true
    $TextureRect.visible = true
    $Radial.visible = is_selected

# called by unhandled input
func deselect():
    if not is_hovered and is_selected:
        is_selected = false
        $Radial/AddSpeciesButton.set_pressed(false)
        $Radial.visible = false
        $TextureRect.visible = false
        $"../TileMap".modulate = base_color

func _on_texture_button_toggled(toggled_on):
    $"../Pops".visible = toggled_on


func _on_texture_button_2_toggled(toggled_on):
    $"../SpeciesGrid".visible = toggled_on

func _on_texture_button_3_toggled(toggled_on):
    $"../SpeciesScrollbox".visible = toggled_on

func _on_pops_closed():
    var butt : TextureButton = $Radial/DensityButton as TextureButton
    butt.set_pressed(false)

func _on_species_grid_closed():
    var butt : TextureButton = $Radial/MutualityButton as TextureButton
    butt.set_pressed_no_signal(false)

func _on_species_scrollbox_pressed():
    var butt : TextureButton = $Radial/AddSpeciesButton as TextureButton
    butt.set_pressed(false)
