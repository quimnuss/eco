extends Node2D

var num_species : int
var species_lines : Array[Species]

func set_species_names(species_names : Array[String]):
    num_species = len(species_names)
    for line in species_lines:
        line.queue_free()
    species_lines.clear()

    var offset : float = 0
    for species_name in species_names:
        var line : Species = preload("res://actors/species.tscn").instantiate()
        species_lines.append(line)
        offset += (line.height + 10)
        line.position.y += offset
        line.start_text = species_name
        add_child(line)

func update_densities(densities : Array[float]):
    for i in range(len(densities)):
        if i >= len(species_lines):
            print('silencing size line error')
            continue
        var density : float = densities[i]
        species_lines[i].update_density(density)

func _on_glv_densities_update(densities : Array[float]):
    update_densities(densities)

func _on_glv_num_species_changed(new_species_names : Array):
    # assumes no names updates...
    if len(species_lines) != len(new_species_names):
        set_species_names(new_species_names)
