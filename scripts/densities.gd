extends Node

var species_to_id : Array[String]

var densities : Array[float]

var mutuality : Dictionary

var densities_matrix : Dictionary

@export var timer : Timer

func _ready():
    timer.timeout.connect(ecotick)
    
func ecotick():
    
