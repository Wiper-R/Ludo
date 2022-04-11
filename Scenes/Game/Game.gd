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

	for pname in ALL_PLAYERS:
		var player: Player = get_node("Players/%s" % pname);
		if not pname in current_players:
			player.queue_free()
		else:
			player.initialize()


func switch_turn() -> void:
	turn_idx += 1;

	if turn_idx >= len(current_players):
		turn_idx = 0 

	for player in players.get_children():
		player.has_turn = false;
	
	
	var player = players.get_node(current_players[turn_idx]);
	player.has_turn = true;
	var dice_position = player.get_node("DicePosition")
	dice.reset()
	dice.position = dice_position.position;
	dice.unblock()

func _ready() -> void:
	dice.block()
	_assign_players(4)
	switch_turn()
	dice.visible = true;
	
	
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_up"):
		switch_turn()

func dice_rolled(rolled: int) -> void:
	var cp = players.get_node(current_players[turn_idx])
	var moveable_tokens = cp.can_any_token_move(rolled);
	if len(moveable_tokens) > 0:
		cp.handle_move(rolled)
		if len(moveable_tokens) == 1:
			cp._on_token_clicked(moveable_tokens[0])
	else:
		yield(get_tree().create_timer(0.5), "timeout")
		switch_turn()
