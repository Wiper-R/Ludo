extends Node2D
onready var players = get_node("Players");
onready var dice = get_node("Dice");
const MAX_PLAYERS = 4.0;
const ALL_PLAYERS = ["Blue", "Red", "Green", "Yellow"];
var current_players = [];
var turn_idx = -1;

class_name Game

func _assign_players(num: int) -> void:
	assert (num > 1, "ERROR: Ludo requires atleast 2 players.")
	
	var skip: int = int(floor(MAX_PLAYERS / num));

	for pidx in range(0, num * skip, skip):
		current_players.push_back(ALL_PLAYERS[pidx])

	for player in ALL_PLAYERS:
		if not player in current_players:
			get_node("Players/%s" % player).queue_free()


func switch_turn() -> void:
	turn_idx += 1;

	if turn_idx >= len(current_players):
		turn_idx = 0 

	for player in players.get_children():
		player.has_turn = false;
	
	
	var player: Player = players.get_node(current_players[turn_idx]);
	player.has_turn = true;
	var dice_position = player.get_node("DicePosition")
	dice.reset()
	dice.position = dice_position.position;
	dice.unblock()

func _ready() -> void:
	dice.block()
	_assign_players(2)
	switch_turn()
	
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_up") and !dice.is_rolling():
		switch_turn()

func dice_rolled(rolled: int) -> void:
	print("Dice rolled: %s" % rolled)
