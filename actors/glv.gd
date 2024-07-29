extends Node2D
class_name GLV

var num_species : int = 10

var species_names : Array[String]

var densities : Array[float]

var growth : Array[float]

var mutuality : Array[Array]

var sample : GLVSample

@onready var glv_timer : Timer = $GLVTimer

var growth_delta : Array[float]
var mutual_delta : Array[Array]

var tick_count : int = 0

signal densities_update(new_densities : Array[float])
signal num_species_changed(new_num_species : int, species_names : Array[String])

signal species_changed(species_names : Array[String], mutuality : Array[Array], growth : Array)

func _ready():
    sample = get_parent().glv_sample
    glv_timer.timeout.connect(ecotick)
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
    for mutual in mutual_delta:
        mutual.resize(num_species)
    
    num_species_changed.emit(num_species, Array())

func restart(new_sample : GLVSample):
    sample = new_sample
    from_resource()
    growth_delta.resize(num_species)
    
    mutual_delta.resize(num_species)
    for mutual in mutual_delta:
        mutual.resize(num_species)
    num_species_changed.emit(num_species, Array())

func from_resource():
    self.num_species = sample.num_species
    self.species_names = sample.species_names
    self.densities = sample.densities
    self.growth = sample.growth
    self.mutuality = sample.mutuality

func ecotick():
    for si in range(num_species):
        growth_delta[si] = densities[si] * growth[si]
        for sj in range(num_species):
            var mutual : float = mutuality[si][sj]
            mutual_delta[si][sj] = densities[si] * mutual * densities[sj]
    
    # add everything up
    for si in range(num_species):
        densities[si] += growth_delta[si]
        for sj in range(num_species):
            densities[si] += mutual_delta[si][sj]

    tick_count += 1
    #print_glv()
    densities_update.emit(densities)

func print_glv():
    print('\n%d' % [tick_count])
    for si in range(num_species):
        print("%s %f" % [species_names[si], densities[si]])
            
func modify_species(index : int, new_mutuality : Array, new_growth : float):
    for i in range(num_species):
        mutuality[index][i] = new_mutuality[i]
    growth[index] = new_growth

func change_mutuality(index_i : int, index_j : int, new_mutuality : float):
    mutuality[index_i][index_j] = new_mutuality

func change_growth(index_i : int, new_growth : float):
    growth[index_i] = new_growth

func add_species(species_name : String, new_mutuality : Array, new_growth : float):
    for species_index in range(num_species):
        mutuality[species_index].push_back(0)
    mutuality.push_back(new_mutuality)
    growth.push_back(new_growth)
    densities.push_back(1)
    species_names.push_back(species_name)
    self.num_species += 1
    growth_delta.resize(num_species)
    
    mutual_delta.resize(num_species)
    for mutual in mutual_delta:
        mutual.resize(num_species)

    num_species_changed.emit(num_species, species_names)
    

