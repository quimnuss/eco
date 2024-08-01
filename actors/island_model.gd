extends Node
class_name IslandModel

var active_num_species : int = 3
var active_species : Array[String]

var max_num_species : int = 10

var species_names : Array[String]

var densities : Array[float]

var growth : Array[float]

var mutuality : Array[Array]

var immigration : Array[float]
var emigration : Array[float]

var start_species : Array[int]

@export var sample : GLVSample

var growth_delta : Array[float]
var mutual_delta : Array[Array]

func _ready():
    var island_node : Island = get_node("../..")
    if OS.is_debug_build() and self.owner == null:
        sample = preload("res://data/3_sample_0.tres")
    else:
        sample = island_node.glv_sample

    var num_species : int = max_num_species
    if sample:
        from_resource()
    else:
        species_names.resize(num_species)
        densities.resize(num_species)
        growth.resize(num_species)
        mutuality.resize(num_species)
        for mutual in mutuality:
            mutual.resize(num_species)

    growth_delta.resize(num_species)
    mutual_delta.resize(num_species)
    immigration.resize(num_species)
    emigration.resize(num_species)

    for mutual in mutual_delta:
        mutual.resize(num_species)


func from_resource():
    self.num_species = sample.num_species
    self.species_names = sample.species_names.duplicate()
    self.densities = sample.densities.duplicate()
    self.growth = sample.growth.duplicate()
    self.mutuality = sample.mutuality.duplicate(true)


func name_to_id(species_name : String) -> int:
    return species_names.find(species_name)

func get_num_active_species():
    return active_num_species

func get_mutuality(species_id : int):
    return mutuality[species_id]

func get_mutual(species_id : int, other_species_id : int):
    return mutuality[species_id][other_species_id]
