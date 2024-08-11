extends Control

var is_hovered := false
var is_selected := false

func _ready():
    add_to_group('island_selectors')

var num_hovered : int = 0

func _on_mouse_entered():
    num_hovered += 1
    if num_hovered > 2:
        num_hovered = 2
    is_hovered = true
    #$TextureRect.visible = true
    $"../TileMap".modulate.r = 0.7

func _on_mouse_exited():
    # hack because two area2d influence hovered
    num_hovered -= 1
    if num_hovered <= 0:
        num_hovered = 0
        is_hovered = false
        if not is_selected:
            $TextureRect.visible = false
            $"../TileMap".modulate.r = 1

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
        $"../TileMap".modulate.r = 1

func _on_texture_button_toggled(toggled_on):
    $"../Pops".visible = toggled_on


func _on_texture_button_2_toggled(toggled_on):
    $"../SpeciesGrid".visible = toggled_on


func _gui_input(event):
    pass
    #if event is InputEventMouseButton and event.is_pressed():
        #if event.button_index == MOUSE_BUTTON_LEFT:
            #is_selected = not is_selected
            #if is_selected:
                #select_island()
            #get_tree().call_group('island_selectors', 'deselect')

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
