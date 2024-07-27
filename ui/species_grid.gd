@tool
extends Control
@onready var grid_container : GridContainer = %GridContainer
@export var square : Control

@export var num_species : int = 3

@export var rebuild : bool = false

var species_names : Array[String]

func _ready():
    refresh_grid()

func refresh_grid():
    # Too late
    #for child in grid_container.get_children():
        #child.queue_free()
    var papa = grid_container.get_parent()
    grid_container.queue_free()
    grid_container = GridContainer.new()
    grid_container.columns = num_species+1
    papa.add_child(grid_container)
    var empty_square : Label = Label.new()
    empty_square.set_size(Vector2(32,32))
    grid_container.add_child(empty_square)
    
    for i in range(num_species):
        var species_name : Label = create_species_label(i)
        grid_container.add_child(species_name)
    
    for i in range(num_species):
        var species_name : Label = create_species_label(i)
        grid_container.add_child(species_name)
        
        for j in range(num_species):
            var one_square = square.duplicate()
            one_square.visible = true
            one_square.modulate = Color.GRAY
            grid_container.add_child(one_square)

func create_species_label(index : int) -> Label:
    var species_name : Label = Label.new()
    species_name.clip_text = true
    species_name.set_custom_minimum_size(Vector2(32,32))
    species_name.set_text_overrun_behavior(TextServer.OVERRUN_TRIM_CHAR) 
    var s_name : String = species_names[index] if species_names else 'foo'
    species_name.set_text(s_name)
    return species_name

func _process(delta):
    if rebuild:
        rebuild = false
        refresh_grid()

func _on_glv_species_changed(new_species_names : Array, mutuality : Array, growth : Array):
    num_species = len(new_species_names)
    species_names = new_species_names
    refresh_grid()
    var grid_children : Array = grid_container.get_children()
    var max_mutuality : float = 0
    for species_mutual : Array in mutuality:
        max_mutuality = max(abs(species_mutual.max()),abs(species_mutual.min()))
    for i in range(num_species):
        for j in range(num_species):
            if abs(mutuality[i][j]) > 0.0001:
                var ratio = clamp(abs(mutuality[i][j]/max_mutuality),0,1)*0.3 + 0.7
                var base_color = Color.DARK_RED if mutuality[i][j] < 0 else Color.DARK_GREEN
                var children_index : int = (i+1)*(num_species+1) + (j+1)
                var square : TextureRect = grid_children[children_index]
                square.set_modulate(base_color*ratio)

func _on_button_pressed():
    self.visible = false
