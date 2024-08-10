extends ReferenceRect


@export var target : Control

func _process(delta):
    self.position = target.position
    self.size = target.size

func _on_migration_button_toggled(toggled_on):
    self.position = target.position
    self.size = target.size
