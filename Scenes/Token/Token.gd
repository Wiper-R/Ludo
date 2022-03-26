extends Node2D
class_name Token
onready var player: Player = get_node("../../")
onready var animation_player: AnimationPlayer = get_node("AnimationPlayer")
onready var game: Game = player.get_node("../../../")
onready var start_point: Vector2 = player.get_path_curve().get_point_position(
	player.global_home_path_index
)
onready var sprite: Sprite = get_node("Sprite")
onready var board: Board = player.get_node("../../")
onready var initial_scale: Vector2 = sprite.scale;
onready var move_audio: AudioStreamPlayer = get_node("MoveAudio");

# Temp variable
export (bool) var should_process;

# -1 means in base.
var current_position_idx: int = -1
var is_moving: bool = false;
var is_in_home_row = false;
var is_in_home = false;
	

func has_turn() -> bool:
	return player.has_turn


func is_in_base() -> bool:
	return current_position_idx == -1


func _ready() -> void:
	pass
	
func can_move() -> bool:
	return true && !is_moving
	
func switch_moveable_animation(switch: bool):
	if $MoveableSprite.visible == switch:
		return
		
	$MoveableSprite.set_deferred("visible", switch)

func _get_absolute_position_of_path(idx: int) -> Vector2:
	var pos;
	
	if !is_in_home_row:
		pos = player.get_path_curve().get_point_position(idx) - (player.global_position - board.global_position)
	else:
		pos = player.get_home_path_curve().get_point_position(idx) - (player.global_position - board.global_position)
		
	pos.y -= $Sprite.texture.get_size().y * $Sprite.scale.y / 2
	return pos;



func _move_to_start():
	is_moving = true;
	
	var length = 0.5;
	var animation = Animation.new()
	animation.set_length(length)
	
	# Position Animation
	var pos_track_idx = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(pos_track_idx, ":position")
	animation.track_insert_key(pos_track_idx, 0.00, position)
	var new_pos: Vector2 = _get_absolute_position_of_path(player.global_home_path_index)
	animation.track_insert_key(pos_track_idx, length, new_pos)
	
	# Scale Animation
	var scale_track_idx = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(scale_track_idx, "Sprite:scale");
	animation.track_insert_key(scale_track_idx, 0.00, initial_scale);
	animation.track_insert_key(scale_track_idx, length / 2, initial_scale * 1.4);
	animation.track_insert_key(scale_track_idx, length, initial_scale);
	animation_player.add_animation("move_to_start", animation)
	
	animation_player.play("move_to_start")
	yield(animation_player, "animation_finished")
	current_position_idx = player.global_home_path_index
	is_moving = false

func _process(_delta: float) -> void:
	if !should_process:
		return
	
	if !has_turn() || is_moving:
		return
		
	if Input.is_action_just_pressed("ui_up"):
		if is_in_base():
			_move_to_start()
		else:
			move(4)
			
	switch_moveable_animation(can_move())


func move(points: int) -> void:
	is_moving = true;
	var length = 0.2
	var wait_time = 0.08
	
		
	for i in range(points):
		current_position_idx += 1
		
		if current_position_idx > 51:
			current_position_idx = 0
		
		if current_position_idx - 1 == player.home_row_entry_point  && !is_in_home_row:
			is_in_home_row = true;
			current_position_idx = 0
			
		if current_position_idx == 5 && is_in_home_row:
			is_in_home = true;
		
		var animation = Animation.new()
		animation.set_length(length)
		
		# Position
		var track_idx = animation.add_track(Animation.TYPE_VALUE)
		animation.track_set_path(track_idx, ":position")
		animation.track_insert_key(track_idx, 0, position)
		animation.track_insert_key(track_idx, length, _get_absolute_position_of_path(current_position_idx))
		
		
		# Scale
		track_idx = animation.add_track(Animation.TYPE_VALUE)
		animation.track_set_path(track_idx, "Sprite:scale")
		animation.track_insert_key(track_idx, 0, initial_scale)
		animation.track_insert_key(track_idx, length / 2, initial_scale * 1.4)
		animation.track_insert_key(track_idx, length, initial_scale)
		
		
		animation_player.add_animation("move", animation)
		animation_player.play("move")
		yield(animation_player, "animation_finished")
		# move_audio.play()
		yield(get_tree().create_timer(wait_time), "timeout")
		
	# Do Rest of the things (i.e checking for another token or group etc)
	
	
	
	
	# Reset Variables
	is_moving = false
		

func _on_Area2D_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if (event is InputEventMouseButton && event.is_pressed()):
		print("Clicked: ", player.color)
