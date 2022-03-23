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

# -1 means in base.
var current_position_idx: int = -1
var _unused;
var points_to_move: int = 0;
var is_moving: bool = false;
	

func has_turn() -> bool:
	return player.has_turn


func is_in_base() -> bool:
	return current_position_idx == -1


func _ready() -> void:
	_add_move_to_start_animation()

	# Connecting Signals
	animation_player.connect("animation_finished", self, "_animation_player_animation_finished")

func _get_absolute_position_of_path(idx: int) -> Vector2:
	var pos = player.get_path_curve().get_point_position(idx) - (player.global_position - board.global_position)
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

func _animation_player_animation_finished(anim_name: String) -> void:
	if anim_name == "move_to_start_point":
		current_position_idx = 0
		is_moving = false;
		
	elif anim_name == "do_move":
		current_position_idx += points_to_move
		points_to_move = 0
		is_moving = false;
		


func _process(_delta: float) -> void:
	if !has_turn() || is_moving:
		return
		
	if Input.is_action_just_pressed("ui_up") and is_in_base():
		_move_to_start_point()

	if Input.is_action_just_pressed("ui_down"):
		move(4)

func move(points: int):
	points_to_move = points;
	var animation = Animation.new();
	var skip = 0.5;
	var length = points * skip;
	animation.set_length(length)

	var pos_track_idx = animation.add_track(Animation.TYPE_VALUE)
	var scale_track_idx = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(pos_track_idx, ":position");
	animation.track_set_path(scale_track_idx, ":scale");
	
	animation.track_insert_key(scale_track_idx, 0, initial_scale)
	
	for i in range(0, points + 1):
		animation.track_insert_key(pos_track_idx, i * skip, _get_absolute_position_of_path(current_position_idx + i))
		animation.track_insert_key(scale_track_idx, i * skip + skip, initial_scale)
		
	
	for i in range(0, points):
		animation.track_insert_key(scale_track_idx, i * skip + skip / 2.5, initial_scale * 1.4)
		
	animation_player.add_animation("do_move", animation);
	animation_player.play("do_move");
	is_moving = true;
	


