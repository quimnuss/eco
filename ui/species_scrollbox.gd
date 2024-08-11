extends Control
@onready var v_box_container = %VBoxContainer

signal add_species(species : Species.SpeciesEnum)
signal pressed()

func _ready():
    # remove none
    # TODO remove all species already present in the island
    for species_enum : Species.SpeciesEnum in range(len(Species.species_frame)-1):
        var species_button : SpeciesTextureButton = SpeciesTextureButton.new()
        species_button.species_enum = species_enum
        species_button.pressed_species.connect(_on_pressed)
        v_box_container.add_child(species_button)

func _on_button_2d_toggled(toggled_on):
    self.visible = toggled_on

func _on_pressed(species_enum : Species.SpeciesEnum):
    add_species.emit(species_enum)
    pressed.emit()
