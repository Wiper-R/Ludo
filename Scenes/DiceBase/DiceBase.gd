extends Node2D

onready var player: Player = get_node("../");
onready var game: Game = get_node("../../../../");

func _ready() -> void:
	game.connect("turn_changed", self, "_on_turn_changed")
	$Dice.connect("rolled", player, "_on_dice_roll")
	
func _on_turn_changed(color: String) -> void:
	if color == player.name:
		$Dice.ready_to_roll()
	else:
		$Dice.reset()
