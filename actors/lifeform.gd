extends Node2D
class_name Lifeform

@onready var head : Sprite2D = $Head


static var species_frame : Dictionary = { # [Species : enum, frame : int]
    Species.SpeciesEnum.NONE:-1,
    Species.SpeciesEnum.BEAR:51,
    Species.SpeciesEnum.RABBIT:47,
    Species.SpeciesEnum.CARROT:150,
    Species.SpeciesEnum.WOLF:9,
    Species.SpeciesEnum.BEE:99,
    Species.SpeciesEnum.BERRY:141,
    Species.SpeciesEnum.BIRD:67,
    Species.SpeciesEnum.FISH:89,
    Species.SpeciesEnum.FOX:10,
    Species.SpeciesEnum.GRASS:119,
    Species.SpeciesEnum.TREE:121,
    Species.SpeciesEnum.WORM:107,
    Species.SpeciesEnum.ALGAE:143
}

var species_enum : Species.SpeciesEnum

func _ready():
    head.frame = species_frame[species_enum]


func set_species(species : Species.SpeciesEnum):
    species_enum = species
    #head.frame = species_frame[species]

