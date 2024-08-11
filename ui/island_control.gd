extends Control

var is_hovered := false
var is_selected := false

func _ready():
    add_to_group('island_selectors')

func _on_mouse_entered():
    is_hovered = true
    $TextureRect.visible = true


func _on_mouse_exited():
    is_hovered = false
    if not is_selected:
        $TextureRect.visible = false

func deselect():
    if not is_hovered:
        is_selected = false
        $Radial.visible = false
        $TextureRect.visible = false

func _on_texture_button_toggled(toggled_on):
    $"../Pops".visible = toggled_on


func _on_texture_button_2_toggled(toggled_on):
    $"../SpeciesGrid".visible = toggled_on


func _on_gui_input(event):
    if event is InputEventMouseButton and event.is_pressed():
        if event.button_index == MOUSE_BUTTON_LEFT:
            is_selected = not is_selected
            $Radial.visible = is_selected
            get_tree().call_group('island_selectors', 'deselect')




func _on_texture_button_3_toggled(toggled_on):
    $"../SpeciesScrollbox".visible = toggled_on


func _on_pops_closed():
    var butt : TextureButton = $Radial/DensityButton as TextureButton
    butt.set_pressed_no_signal(false)


func _on_species_grid_closed():
    var butt : TextureButton = $Radial/MutualityButton as TextureButton
    butt.set_pressed_no_signal(false)
