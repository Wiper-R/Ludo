extends Node2D

var has_turn: bool = false;

func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	if has_turn:
		print(name)
