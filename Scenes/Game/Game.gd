extends Node2D
onready var players = get_node("Players");
const MAX_PLAYERS = 4.0;
const ALL_PLAYERS = ["Blue", "Red", "Green", "Yellow"];
var current_players = [];
var turn_idx = -1;

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
		
	players.get_node(current_players[turn_idx]).has_turn = true;

func _ready() -> void:
	$Dice.block()
	_assign_players(2)
	switch_turn()
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_up"):
		switch_turn()
