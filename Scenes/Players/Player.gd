extends Node2D
class_name Player
export (int) var global_home_path_index = -1;
export (int) var home_row_entry_point = -1;
export (Texture) var texture;
onready var game: Game = get_node("../../../");
onready var path_curve: Curve2D = get_path_curve();
onready var home_path_curve: Curve2D = get_home_path_curve();
var has_turn: bool = false;


func get_path_curve() -> Curve2D:
	return get_node("../../Paths/CommonPath").get_curve()
	
func get_home_path_curve() -> Curve2D:
	print("../../Paths/PlayerPaths/%sHomePath" % name)
	return get_node("../../Paths/PlayerPaths/%sHomePath" % name).get_curve();
	
	
func _ready() -> void:
	print(game.name)
	assert (texture != null, "ERROR: Player sprite must be set in player node.")
	assert (home_row_entry_point != -1, "ERROR: Home row entry path must be set in player node.");
	assert (global_home_path_index != -1, "ERROR: Global home path index must be set in player node.");
	game.connect("turn_changed", self, "_on_turn_changed");
	var tokens = $Tokens.get_children();
	
	for token in tokens:
		token.sprite.texture = texture

func _on_turn_changed(color: String):
	if name == color:
		has_turn = true;
	else:
		has_turn = false;

func token_clicked(token):
	game.emit_signal("turn_changed", "Red")
	
