extends Node2D

onready var players: Node2D = get_node('Players');

func add_player(color: String, home_position: Vector2) -> void:
	var player_scene: PackedScene = load("res://Scenes/Players/%s.tscn" % color)
	var player = player_scene.instance()
	player.position = home_position
	players.add_child(player)
