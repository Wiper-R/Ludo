extends Node2D

onready var game: Game = get_node("../../../");
onready var dice = get_node("Dice");

func _ready() -> void:
	game.connect("turn_changed", self, "_handle_turn_changed")
	dice.connect("rolled", game, "_dice_rolled")


func _handle_turn_changed(color: String) -> void:
	if name != color:
		$Dice.reset()
	else:
		$Dice.ready_to_roll()
