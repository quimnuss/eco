extends Node2D

var num_species : int
var lines : Array[Species]


func set_num_species(new_num_species : int):
    num_species = new_num_species
    for i in range(num_species):
        var line : Species = preload("res://actors/species.tscn").instantiate()
        lines.append(line)
        line.position.y += i*(line.height + 10)
        add_child(line)

func set_species_names(species_names):
    for i in range(len(lines)):
        lines[i].set_species_name(species_names[i])
        

func update_densities(densities : Array[float]):
    for i in range(len(densities)):
        var density : float = densities[i]
        lines[i].update_density(density)

func _on_glv_densities_update(densities : Array[float]):
    update_densities(densities)

func _on_glv_num_species_changed(new_num_species):
    set_num_species(new_num_species)
