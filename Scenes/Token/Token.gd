extends Node2D

onready var player: Node2D = get_node("../");
onready var start_point: Vector2 = player.get_path_curve().get_point_position(player.global_home_path_index)


# -1 means in base.
var current_position_idx = -1; 

func is_in_base() -> bool:
	return player.global_home_path_index != current_position_idx

func _ready() -> void:		
	assert($Sprite.texture != null, "ERROR: Token sprite must have a texture.");
	var animation = Animation.new();
	animation.set_length(1)
	
	# Position Animation
	var track_idx = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(track_idx, ":position")
	animation.track_insert_key(track_idx, 0.00, position)
	var new_pos: Vector2 = Vector2(start_point.x, start_point.y);
	new_pos.y -= $Sprite.texture.get_size().y * $Sprite.scale.y / 2
	animation.track_insert_key(track_idx, 0.75, new_pos)
	$AnimationPlayer.add_animation("move_to_start_point", animation);
	
func _process(delta: float) -> void:	
	if Input.is_action_pressed("ui_up") and is_in_base():
		$AnimationPlayer.play("move_to_start_point")
		yield($AnimationPlayer, "animation_finished")
		current_position_idx = player.global_home_path_index
		

