extends Node2D
export (int) var global_home_path_index = null;
onready var path_curve: Curve2D = get_path_curve();

func _ready() -> void:
	pass
	# var pos = path_curve.get_point_position(global_home_path_index);
	# pos.y -= $T1/Sprite.texture.get_size().y * $T1/Sprite.scale.y / 2
	# $T1.position = pos;
	
	
func get_path_curve() -> Curve2D:
	assert (global_home_path_index != null, "ERROR: Global home path index must be set in player node.");
	return get_node("../../Paths/CommonPath").get_curve()


