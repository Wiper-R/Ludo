extends Node2D
onready var player: Node2D = get_node("../../")
onready var animation_player: AnimationPlayer = get_node("AnimationPlayer")
onready var game: Node2D = player.get_node("../../../")
onready var start_point: Vector2 = player.get_path_curve().get_point_position(
	player.global_home_path_index
)
onready var sprite: Sprite = get_node("Sprite")
onready var board: Node2D = player.get_node("../../")
onready var initial_scale: Vector2 = scale;
onready var move_audio: AudioStreamPlayer = get_node("MoveAudio");

# Temp variable
export (bool) var should_process;

# -1 means in base.
var current_position_idx: int = -1
var _unused;
var is_moving: bool = false;
var is_in_home_row = false;
	

func has_turn() -> bool:
	return player.has_turn


func is_in_base() -> bool:
	return current_position_idx == -1


func _ready() -> void:
	_add_move_to_start_animation()

func _get_absolute_position_of_path(idx: int) -> Vector2:	
	if is_in_home_row:
		idx -= player.home_row_entry_point
	
	var pos = player.get_home_path_curve().get_point_position(idx) - (player.global_position - board.global_position)
	pos.y -= $Sprite.texture.get_size().y * $Sprite.scale.y / 2
	return pos;


func _add_move_to_start_animation():
	var animation = Animation.new()
	animation.set_length(1)
	
	# Position Animation
	var pos_track_idx = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(pos_track_idx, ":position")
	animation.track_insert_key(pos_track_idx, 0.00, position)
	var new_pos: Vector2 = _get_absolute_position_of_path(player.global_home_path_index)
	animation.track_insert_key(pos_track_idx, 0.75, new_pos)
	
	# Scale Animation
	var scale_track_idx = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(scale_track_idx, ":scale");
	animation.track_insert_key(scale_track_idx, 0.00, initial_scale);
	animation.track_insert_key(scale_track_idx, 0.2, initial_scale * 1.4);
	animation.track_insert_key(scale_track_idx, 0.8, initial_scale);
	
	_unused = animation_player.add_animation("move_to_start_point", animation)


func _move_to_start_point() -> void:
	is_moving = true;
	animation_player.play("move_to_start_point")
	yield(animation_player, "animation_finished")
	current_position_idx = player.global_home_path_index
	is_moving = false
		


func _process(_delta: float) -> void:
	if !should_process:
		return
	
	if !has_turn() || is_moving:
		return
		
	if Input.is_action_just_pressed("ui_up") and is_in_base():
		_move_to_start_point()

	if Input.is_action_just_pressed("ui_down"):
		move(4)
	

func move(points: int) -> void:
	is_moving = true;
	var length = 0.2
	var wait_time = 0.08
	
		
	for i in range(points):
		current_position_idx += 1
		
		if current_position_idx > player.home_row_entry_point && !is_in_home_row:
			is_in_home_row = true;
		
		var animation = Animation.new()
		animation.set_length(length)
		
		# Position
		var track_idx = animation.add_track(Animation.TYPE_VALUE)
		animation.track_set_path(track_idx, ":position")
		animation.track_insert_key(track_idx, 0, position)
		animation.track_insert_key(track_idx, length, _get_absolute_position_of_path(current_position_idx))
		
		
		# Scale
		track_idx = animation.add_track(Animation.TYPE_VALUE)
		animation.track_set_path(track_idx, ":scale")
		animation.track_insert_key(track_idx, 0, initial_scale)
		animation.track_insert_key(track_idx, length / 2, initial_scale * 1.4)
		animation.track_insert_key(track_idx, length, initial_scale)
		
		
		animation_player.add_animation("move", animation)
		animation_player.play("move")
		yield(animation_player, "animation_finished")
		move_audio.play()
		yield(get_tree().create_timer(wait_time), "timeout")
		
	# Do Rest of the things (i.e checking for another token or group etc)
	
	
	
	
	# Reset Variables
	is_moving = false
		
		


