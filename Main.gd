extends Node2D
onready var gamescene: PackedScene = preload("res://Scenes/Game/Game.tscn");

func _ready() -> void:
	var game: Node2D = gamescene.instance();
	add_child(game)
