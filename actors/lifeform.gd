extends Node2D
class_name Lifeform

@onready var head : Sprite2D = $Head


var species_enum : Species.SpeciesEnum

func _ready():
    head.frame = Species.species_frame[species_enum]


func set_species(species : Species.SpeciesEnum):
    species_enum = species
    #head.frame = species_frame[species]

