extends Node2D

var num_species : int = 10

var species_to_id : Array[String]

var densities : Array[float]

var growth : Array[float]

var mutuality : Array[float]

@export var sample : GLVSample

@onready var glv_timer : Timer = $GLVTimer

var growth_delta : Array[float]
var mutual_delta : Array[float]

var tick_count : int = 0

func _ready():
    glv_timer.timeout.connect(ecotick)
    if sample:
        from_resource()
    else:
        species_to_id.resize(num_species)
        densities.resize(num_species)
        growth.resize(num_species)
        mutuality.resize(num_species*num_species)

    growth_delta.resize(num_species)
    mutual_delta.resize(num_species*num_species)


func from_resource():
    self.num_species = sample.num_species
    self.species_to_id = sample.species_to_id
    self.densities = sample.densities
    self.growth = sample.growth
    self.mutuality = sample.mutuality

func ecotick():
    for si in range(num_species):
        growth_delta[si] = densities[si] * growth[si]
        for sj in range(num_species):
            var mutual : float = mutuality[si*num_species + sj]
            mutual_delta[si*num_species + sj] = densities[si] * mutual * densities[sj]
    
    # add everything up
    for si in range(num_species):
        densities[si] += growth_delta[si]
        for sj in range(num_species):
            densities[si] += mutual_delta[si*num_species + sj]

    tick_count += 1
    print_glv()

func print_glv():
    print('\n%d' % [tick_count])
    for si in range(num_species):
        print("%s %f" % [species_to_id[si], densities[si]])
            
