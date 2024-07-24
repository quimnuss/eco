extends Node

@export var example_glv_sample : GLVSample

func _ready():
    create()
    pass

func create():
    var glv_sample : GLVSample = GLVSample.new()
    glv_sample.num_species = 3
    glv_sample.species_to_id = ['grass', 'rabbit', 'fox']
    glv_sample.densities = [1, 1, 1]
    glv_sample.growth = [0.03, 0.02, 0.01]
    glv_sample.mutuality = [
        -0.01, -0.01, 0,
        0.01, -0.01, -0.01,
        0,     0.01, -0.01
    ]
    ResourceSaver.save(glv_sample, 'res://data/3_sample_0.tres')
