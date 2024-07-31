extends Node2D
class_name GLV

var num_species : int = 10

var species_names : Array[String]

var densities : Array[float]

var growth : Array[float]

var mutuality : Array[Array]

var immigration : Array[float]
var emigration : Array[float]

var sample : GLVSample

@onready var glv_timer : Timer = $GLVTimer

var growth_delta : Array[float]
var mutual_delta : Array[Array]
const MAX_DELTA : float = 0.5

var tick_count : int = 0

const EPSILON : float = 0.0001

signal densities_update(new_densities : Array[float])
signal num_species_changed(new_num_species : int, species_names : Array[String])

signal species_changed(species_names : Array[String], mutuality : Array[Array], growth : Array)

signal densities_update_drivers(new_densities : Array[float], mutual_delta : Array[Array], growth_delta : Array[float])

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
    immigration.resize(num_species)
    emigration.resize(num_species)
    
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
        growth_delta[si] = densities[si] * (growth[si] + immigration[si] - emigration[si])
        for sj in range(num_species):
            var mutual : float = mutuality[si][sj]
            mutual_delta[si][sj] = densities[si] * mutual * densities[sj]
    
    # add everything up
    var delta_densities : Array[float]
    delta_densities.resize(num_species)
    delta_densities.fill(0)
    for si in range(num_species):
        delta_densities[si] += growth_delta[si] 
        for sj in range(num_species):
            delta_densities[si] += mutual_delta[si][sj]
        delta_densities[si] = clamp(delta_densities[si], -MAX_DELTA, MAX_DELTA)
            
    for si in range(num_species):
        densities[si] += delta_densities[si]
        if densities[si] < EPSILON:
            densities[si] = 0
        densities[si] = clamp(densities[si],0,10000)
    
    # gaia karma
    gaia_adaptation()

    tick_count += 1
    #print_glv()
    densities_update.emit(densities)
    densities_update_drivers.emit(densities, mutual_delta, growth_delta)

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
    immigration.resize(num_species)
    emigration.resize(num_species)
    
    mutual_delta.resize(num_species)
    for mutual in mutual_delta:
        mutual.resize(num_species)

    num_species_changed.emit(num_species, species_names)
    
# Gaia
const DEFENSE_THRESHOLD : float = 0.5
const RELAX_THRESHOLD : float = 5
# if you need to keep track of adaptations, you'll have to use a mutual layer
#var gaia_mutuality : Array[Array]
func gaia_adaptation():
    if num_species == 0:
        return
    var has_adapted : bool = true
    for idx in range(num_species):
        if densities[idx] < DEFENSE_THRESHOLD:
            var archenemy : int = mutual_delta[idx].find(mutual_delta.min())
            specialize_defense_against(idx, archenemy)
        elif densities[idx] > RELAX_THRESHOLD:
            var archenemy : int = mutual_delta[idx].find(mutual_delta.max())
            generalize_predation_against(idx, archenemy)
        else:
            has_adapted = false
    if has_adapted:
        species_changed.emit(species_names, mutuality, growth)

# Defensive Specialize 1: decrease 1%. the archimutuality and increase 1%. the other negative mutuals
func specialize_defense_against(species_id, archenemy):
    for i in range(num_species):
        var mutual = mutuality[species_id][i]
        if mutual < 0:
            var factor = 0.9 if i == archenemy else 1.1
            mutuality[species_id][archenemy] = factor * mutuality[species_id][archenemy]
            mutuality[archenemy][species_id] = (1-factor) * mutuality[archenemy][species_id]

func generalize_predation_against(species_id, archenemy):
    for i in range(num_species):
        var mutual = mutuality[species_id][i]
        if mutual > 0:
            var factor = 0.9 if i == archenemy else 1.1
            mutuality[species_id][archenemy] = factor * mutuality[species_id][archenemy]
            mutuality[archenemy][species_id] = (1-factor) * mutuality[archenemy][species_id]

