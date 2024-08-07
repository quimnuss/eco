extends Node2D
class_name LifeformSpawner

var size : Vector2 = Vector2(200,200)

var species_names : Array[String]

var species_density : Dictionary = {} #[Species, Lifeform]

# the array is actually a reference :) it's convinient
func set_species_names(new_species_names : Array[String]):
    self.species_names = new_species_names

func spawn_lifeform(species_enum : Species.SpeciesEnum):
    var spawn_point := Vector2(randf_range(-size.x/2, size.x/2), randf_range(-size.y/2, size.y/2))
    var lifeform : Lifeform = preload('res://actors/lifeform.tscn').instantiate()
    lifeform.global_position = spawn_point
    lifeform.set_species(species_enum)
    species_density.get(species_enum, Array()).push_back(lifeform)
    add_child(lifeform)

func update_lifeform_density(new_densities : Array[float]):
    for idx in range(len(new_densities)):
        var species_name : String = species_names[idx]
        var species_enum : Species.SpeciesEnum = Species.name_enum[species_name]
        if not species_density.has(species_enum):
            species_density[species_enum] = [] as Array[Lifeform]
        var lifeforms : Array[Lifeform] = species_density[species_enum]
        if len(lifeforms) < ceil(new_densities[idx]):
            var lifeforms_to_spawn : int = ceil(new_densities[idx]) - len(lifeforms)
            for i in range(lifeforms_to_spawn):
                spawn_lifeform(species_enum)
        elif ceil(new_densities[idx]) < len(lifeforms):
            var one_lifeform : Lifeform = lifeforms.pop_at(randi_range(0,len(lifeforms)-1))
            one_lifeform.queue_free()

func _on_glv_densities_update(new_densities : Array[float]):
    update_lifeform_density(new_densities)
