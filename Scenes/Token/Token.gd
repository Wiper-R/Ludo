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
var is_moving: bool = false
var _unused;


func has_turn() -> bool:
	return player.has_turn


func is_in_base() -> bool:
	return player.global_home_path_index != current_position_idx


func _ready() -> void:
	_add_move_to_start_animation()

	# Connecting Signals
	_unused = animation_player.connect("animation_finished", self, "_animation_player_animation_finished")


func _add_move_to_start_animation():
	var animation = Animation.new()
	animation.set_length(1)
	
	# Position Animation
	var pos_track_idx = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(pos_track_idx, ":position")
	animation.track_insert_key(pos_track_idx, 0.00, position)
	var new_pos: Vector2 = (
		Vector2(start_point.x, start_point.y)
		- (player.global_position - board.global_position)
	)
	new_pos.y -= $Sprite.texture.get_size().y * $Sprite.scale.y / 2
	animation.track_insert_key(pos_track_idx, 0.75, new_pos)
	
	# Scale Animation
	var scale_track_idx = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(scale_track_idx, ":scale");
	animation.track_insert_key(scale_track_idx, 0.00, initial_scale);
	animation.track_insert_key(scale_track_idx, 0.2, initial_scale * 1.4);
	animation.track_insert_key(scale_track_idx, 0.8, initial_scale);
	
	_unused = animation_player.add_animation("move_to_start_point", animation)


func _move_to_start_point() -> void:
	is_moving = true
	animation_player.play("move_to_start_point")


func _animation_player_animation_finished(anim_name: String) -> void:
	if anim_name == "move_to_start_point":
		current_position_idx = player.global_home_path_index
		is_moving = false


func _process(_delta: float) -> void:
	if !has_turn():
		return
		
	if Input.is_action_just_pressed("ui_up") and is_in_base():
		_move_to_start_point()
