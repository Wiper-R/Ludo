extends Node2D

class_name Game
signal turn_changed(color);

func _ready() -> void:
	emit_signal("turn_changed", "Blue")
