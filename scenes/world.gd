extends Node2D

@onready var cli = $Cli

func _ready():
    for island : Island in get_tree().get_nodes_in_group('islands'):
        cli.change_species.connect(island._on_change_species)


