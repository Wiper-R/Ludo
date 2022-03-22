extends Node2D
export (int) var global_home_path_index;
onready var path_curve: Curve2D = get_path_curve();

export (String) var _color;
var _color_initalized: bool = false;
var color: String setget _set_color, _get_color;

func _get_color() -> String:
	assert(_color != null && typeof(_color) == TYPE_STRING, "ERROR: Player color must be set properly.");
	return _color;

func _set_color(ncolor: String) -> void:
	if _color_initalized:
		assert(false, "ERROR: You can't modify player color after initialization.")
	_color = ncolor
	_color_initalized = true;

	
func get_path_curve() -> Curve2D:
	assert (typeof(global_home_path_index) != TYPE_NIL, "ERROR: Global home path index must be set in player node.");
	return get_node("../../Paths/CommonPath").get_curve()
