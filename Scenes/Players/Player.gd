extends Node2D
export (int) var global_home_path_index;
onready var path_curve: Curve2D = get_path_curve();

func _ready() -> void:
	pass
	
	
func get_path_curve() -> Curve2D:
	# print(typeof(global_home_path_index))
	# assert (typeof(global_home_path_index) != TYPE_NIL, "ERROR: Global home path index must be set in player node.");
	return get_node("../../Paths/CommonPath").get_curve()
