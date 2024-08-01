extends Node2D
class_name GLV

@onready var island_model : IslandModel = $IslandModel

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

signal species_names_changed(species_names : Array[String])

func _ready():
    glv_timer.timeout.connect(ecotick)
    num_species_changed.emit(num_species, Array())

func restart(new_sample : GLVSample):
    sample = new_sample
    from_resource()
    growth_delta.resize(num_species)

    mutual_delta.resize(num_species)
    for mutual in mutual_delta:
        mutual.resize(num_species)
    num_species_changed.emit(num_species, Array())

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
    if Settings.use_gaia:
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
    var has_adapted : bool = false
    for idx in range(num_species):
        if densities[idx] < DEFENSE_THRESHOLD:
            var archenemy : int = mutual_delta[idx].find(mutual_delta[idx].min())
            var archfriend : int = mutual_delta[idx].find(mutual_delta[idx].max())
            specialize_against(idx, archenemy, archfriend)
            has_adapted = true
        elif densities[idx] > RELAX_THRESHOLD:
            var archenemy : int = mutual_delta[idx].find(mutual_delta[idx].max())
            generalize_predation_against(idx, archenemy)
            has_adapted = true
    if has_adapted:
        species_changed.emit(species_names, mutuality, growth)


# Defensive Specialize 1: decrease 1%. the archimutuality and increase 1%. the other negative mutuals
func specialize_against(species_id : int, archenemy : int, archfriend : int):
    for i in range(num_species):
        if i == species_id:
            continue
        var mutual = mutuality[species_id][i]
        if mutual < 0:# and i != species_id:
            var factor = 0.999 if i == archenemy else 1.001
            mutuality[species_id][i] = factor * mutuality[species_id][i]
            if mutuality[i][species_id] > 0:
                mutuality[i][species_id] = factor * mutuality[i][species_id]
        elif mutual > 0:
            var factor = 1.001 if i == archfriend else 0.999
            mutuality[species_id][i] = factor * mutuality[species_id][i]
            if mutuality[i][species_id] < 0:
                mutuality[i][species_id] = factor * mutuality[i][species_id]

func generalize_predation_against(species_id, archenemy):
    for i in range(num_species):
        var mutual = mutuality[species_id][i]
        if mutual > 0:
            var factor = 0.999 if i == archenemy else 1.001
            mutuality[species_id][i] = factor * mutuality[species_id][i]
            if mutuality[i][species_id] < 0:
                mutuality[i][species_id] = factor * mutuality[i][species_id]

