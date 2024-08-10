extends PanelContainer

var num_species : int = len(Species.name_enum)


func _ready():
    assert(len(Species.name_enum) == num_species)


