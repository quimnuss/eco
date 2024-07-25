extends Node2D


var migration_lines : Array[Line2D]

var migration_line : Line2D

var migrating_island : int = -1

signal migration_established(from, to)

func _process(delta):
    if migration_line and is_instance_valid(migration_line) and migrating_island != -1:
        migration_line.set_point_position(1, get_global_mouse_position())

func _input(event):
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
        cancel_migration()

func _on_island_clicked(point : Vector2, island_id : int):
    if migrating_island == -1:
        migration_line = Line2D.new()
        migration_line.add_point(point)
        migration_line.add_point(get_global_mouse_position())
        migration_line.width = 3
        migration_line.default_color = Color.OLIVE_DRAB
        add_child(migration_line)
        migrating_island = island_id
    elif island_id != migrating_island:
        migration_line.set_point_position(1, point)
        migration_lines.append(migration_line)
        migration_line = null
        migrating_island = -1
        migration_established.emit(migrating_island, island_id)
    else:
        cancel_migration()

func cancel_migration():
    print("stopped migrating")
    migrating_island = -1
    if migration_line:
        migration_line.queue_free()

