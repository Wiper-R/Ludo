extends Node2D

onready var sprite = load("res://assets/{name}-token.png".format({"name": name.to_lower()}))
onready var token_scene = preload("res://Scenes/Token/Token.tscn")
onready var game = get_node("../../")

class_name Player
var consecutive_sixes = 0;
var tokens = []
var _has_turn: bool = false;
var has_turn setget _set_has_turn, _get_has_turn

func _set_has_turn(value: bool):
	_has_turn = value;
	consecutive_sixes = 0
	
func _get_has_turn():
	return _has_turn


var tokens_can_move = [];

signal token_clicked_for_move(token);
signal token_done_moving(has_extra_chance);

func _ready() -> void:
	assert(
		sprite != null, "ERROR: Couldn't load {name} Token resource.".format({"name": name})
	)

func _process(_delta: float) -> void:
	# return
	if _get_has_turn():
		print(name)
		print(consecutive_sixes)

func initialize():
	var tokens = Node2D.new()
	tokens.name = "Tokens"

	for idx in range(1, 5):
		var token = token_scene.instance()
		token.name = "T%s" % idx;
		token.position = get_node("BasePositions/T%s" % idx).position;
		token.get_node("Sprite").texture = sprite;
		tokens.add_child(token)
		
	self.tokens = tokens.get_children()
	
	add_child(tokens)


func _on_token_clicked(token):
	if !_get_has_turn():
		return
		
	emit_signal("token_clicked_for_move", token)
		
	
func can_any_token_move(rolled:int) -> Array:
	tokens_can_move = [];
	
	if rolled == 6:
		consecutive_sixes += 1;
	else:
		consecutive_sixes = 0;
	
	# Return, No Token can move and pass the round to other player, if there are 3 consecutive sixes
	if consecutive_sixes >= 3:
		return []
		
	for token in tokens:
		if token.can_move(rolled, game):
			tokens_can_move.push_back(token)
			token.set_rolling_animation(true);
			
	return tokens_can_move


func handle_move(rolled: int):
	var token;
	
	while true:
		token = yield(self, "token_clicked_for_move")
		if token in tokens_can_move:
			break;
				
	for t in tokens:
		t.set_rolling_animation(false);
		
	print("Token Clicked %s" % token);
	print("Moving...")
		
	token.run_move(rolled)
	
	var has_more_turn = yield(self, "token_done_moving");
	
	if has_more_turn:
		game.get_node("Dice").reset()
	else:
		game.switch_turn()
	
	
	
	
	
