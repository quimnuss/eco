extends Node2D

const DEFENSE_THRESHOLD : float = 0.05
const RELAX_THRESHOLD : float = 5
const TIED_THRESHOLD : float = 0.01

func _on_glv_densities_update_drivers(
    new_densities : Array[float],
    mutual_delta : Array[Array],
    growth_delta : Array[float]
):
    var num_species : int = len(new_densities)
    for i in range(num_species):
        if new_densities[i] < DEFENSE_THRESHOLD:
            var archenemy : int = mutual_delta[i].find(mutual_delta[i].max())
            specialize_against(archenemy)
        elif new_densities[i] > RELAX_THRESHOLD:
            var archenemy : int = mutual_delta[i].find(mutual_delta[i].max())
            generalize_against(archenemy)

func specialize_against(species_id : int):    
    pass

func generalize_against(species_id : int):
    pass

func check_tied_drivers(mutual_delta : Array[float]):
    var sorted_mutual_delta : Array[float] = mutual_delta.duplicate()
    sorted_mutual_delta.sort()
    if sorted_mutual_delta[0] - sorted_mutual_delta[1] < TIED_THRESHOLD:
        return true
