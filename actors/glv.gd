extends Node2D
class_name GLV

var num_species : int = 0

var species_names : Array[String]

var densities : Array[float]

var growth : Array[float]

var mutuality : Array[Array]

var immigration : Array[float]

var sample : GLVSample

@export var global_glv_sample : GLVSample

@onready var glv_timer : Timer = $GLVTimer

var growth_delta : Array[float]
var mutual_delta : Array[Array]
const MAX_DELTA : float = 0.5

var tick_count : int = 0

const EPSILON : float = 0.0001

signal densities_update(new_densities : Array[float])
signal num_species_changed(species_names : Array[String])

signal species_changed(species_names : Array[String], mutuality : Array[Array], growth : Array)

signal densities_update_drivers(new_densities : Array[float], mutual_delta : Array[Array], growth_delta : Array[float])

func _ready():
    # sorrynotsorry
    sample = get_parent().glv_sample
    global_glv_sample = get_parent().global_glv_sample
    var start_species_names : Array[String] = get_parent().start_species_names

    if OS.is_debug_build() and self.get_parent().owner == null:
        sample = preload("res://data/3_sample_0.tres")

    glv_timer.timeout.connect(ecotick)
    if sample:
        from_resource()
    elif start_species_names:
        from_names(start_species_names)

    if sample or start_species_names:
        growth_delta.resize(num_species)
        mutual_delta.resize(num_species)
        immigration.resize(num_species)

        for mutual in mutual_delta:
            mutual.resize(num_species)

        num_species_changed.emit(species_names)

    add_to_group('glvs')

func from_resource():
    self.num_species = sample.num_species
    self.species_names = sample.species_names.duplicate()
    self.densities = sample.densities.duplicate()
    self.growth = sample.growth.duplicate()
    self.mutuality = sample.mutuality.duplicate(true)

func from_names(start_species_names : Array[String]):
    self.num_species = len(start_species_names)
    self.species_names = start_species_names
    self.densities.resize(self.num_species)
    self.densities.fill(1.0)
    self.growth.clear()
    self.mutuality.clear()
    for species_name in start_species_names:
        var species_index : int = global_glv_sample.species_names.find(species_name)
        if species_index != -1:
            self.growth.push_back(global_glv_sample.growth[species_index])
            self.mutuality.push_back(Array())
            for other_species_name in start_species_names:
                var other_species_index : int = global_glv_sample.species_names.find(other_species_name)
                var mutual : float = global_glv_sample.mutuality[species_index][other_species_index]
                self.mutuality[-1].push_back(mutual)

func freeze():
    glv_timer.set_paused(not glv_timer.paused)

func ecotick():
    for si in range(num_species):
        growth_delta[si] = densities[si] * growth[si] + immigration[si]
        for sj in range(num_species):
            var mutual : float = mutuality[si][sj]
            mutual_delta[si][sj] = densities[si] * mutual * densities[sj]

    # add everything up
    var delta_densities : Array[float] = []
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

func add_new_species(species_name : String, new_mutuality : Array, new_growth : float):
    for species_index in range(num_species):
        mutuality[species_index].push_back(0)

    mutuality.push_back(new_mutuality)
    growth.push_back(new_growth)
    densities.push_back(1)
    species_names.push_back(species_name)
    self.num_species += 1
    growth_delta.resize(num_species)
    immigration.resize(num_species)

    mutual_delta.resize(num_species)
    for mutual in mutual_delta:
        mutual.resize(num_species)

    num_species_changed.emit(species_names)
    species_changed.emit(species_name, new_mutuality, new_growth)

func add_species(species_name : String):
    var global_species_index : int = global_glv_sample.species_names.find(species_name)
    for species_index in range(num_species):
        var global_species_index_other : int = global_glv_sample.species_names.find(species_names[species_index])
        mutuality[species_index].push_back(global_glv_sample.mutuality[global_species_index_other][global_species_index])
    mutuality.push_back(Array())
    for other_species_name in species_names:
        var other_idx : int = global_glv_sample.species_names.find(other_species_name)
        mutuality[-1].push_back(global_glv_sample.mutuality[global_species_index][other_idx])
    mutuality[-1].push_back(global_glv_sample.mutuality[global_species_index][global_species_index])
    growth.push_back(global_glv_sample.growth[global_species_index])
    densities.push_back(1)
    species_names.push_back(species_name)
    self.num_species += 1
    growth_delta.resize(num_species)
    immigration.resize(num_species)

    mutual_delta.resize(num_species)
    for mutual in mutual_delta:
        mutual.resize(num_species)

    num_species_changed.emit(species_names)
    species_changed.emit(species_names, mutuality, growth)

func add_species_enum(species_enum : Species.SpeciesEnum):
    var species_name : String = Species.name_enum.keys()[species_enum+1]
    var species_exists : bool = self.species_names.find(species_name) != -1
    if not species_exists:
        add_species(species_name)
    else:
        prints('Species',species_name,'already exists on',owner.name)

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
        if densities[idx] > 0:
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

