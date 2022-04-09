extends Node2D
onready var area2d: Area2D = get_node("Area2D");
onready var player = get_node("../../");
onready var rolling_base = get_node("RollingBase");
onready var animation_player = get_node("AnimationPlayer");
onready var move_player: AnimationPlayer = get_node("MovePlayer");
onready var initial_scale: Vector2 = scale;



const GLOBAL_HOME_POSITIONS = {
	"Blue": 0,
	"Red": 13,
	"Green": 26,
	"Yellow": 39,
}


var global_position_on_board: int = -1;
var local_position_on_board: int = -1;

signal token_clicked(token);


func is_in_home_row():
	return local_position_on_board >= 52 - 1;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	area2d.connect("input_event", self, "_on_Area2D_input_event")
	connect("token_clicked", player, "_on_token_clicked");
	set_rolling_animation(false)

func _token_clicked():
	emit_signal("token_clicked", self)

func _on_Area2D_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if not event is InputEventMouseButton:
		return
		
	if not event.pressed:
		return
		
	if event.button_index != BUTTON_LEFT:
		return
		
	_token_clicked()

func can_move(rolled: int, game) -> bool:
	if global_position_on_board == -1:
		if rolled == 6:
			return true
		else:
			return false
			
	return true;
	
func set_rolling_animation(value: bool) -> void:
	rolling_base.visible = value;
	if value:
		animation_player.play("rolling")
	else:
		animation_player.stop()

func _get_global_point_position(pidx: int) -> Vector2:
	return player.game.get_node("Path2D").get_curve().get_point_position(pidx)
	

func _move_token_to_out():
	var length = 0.5;
	var animation = Animation.new()
	animation.set_length(length)
	
	# Position Animation
	var pos_track_idx = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(pos_track_idx, ":position")
	animation.track_insert_key(pos_track_idx, 0.00, position)
	var new_pos: Vector2 =  _get_global_point_position(GLOBAL_HOME_POSITIONS[player.name])
	animation.track_insert_key(pos_track_idx, length, new_pos)
	
	# Scale Animation
	var scale_track_idx = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(scale_track_idx, ":scale");
	animation.track_insert_key(scale_track_idx, 0.00, initial_scale);
	animation.track_insert_key(scale_track_idx, length / 2, initial_scale * 1.4);
	animation.track_insert_key(scale_track_idx, length, initial_scale);
	move_player.add_animation("move", animation)
	move_player.play("move")
	
func _move_token_by_points(points: int):
	var length = 0.2
	var wait_time = 0.08
	var current_ts = 0;
	
	var animation = Animation.new()
	animation.set_length(length * points + wait_time * points);
	var pos_track_idx = animation.add_track(Animation.TYPE_VALUE);
	animation.track_set_path(pos_track_idx, ":position")
	var scale_track_idx = animation.add_track(Animation.TYPE_VALUE);
	animation.track_set_path(scale_track_idx, ":scale")
	
	for i in range(points):
		global_position_on_board += 1;
		
		if global_position_on_board == 52:
			global_position_on_board = 0;
			
		# Position
		animation.track_insert_key(pos_track_idx, current_ts, _get_global_point_position(global_position_on_board - 1))
		animation.track_insert_key(pos_track_idx, current_ts + length, _get_global_point_position(global_position_on_board))
		
		# Scale
		animation.track_insert_key(scale_track_idx, current_ts, initial_scale)
		animation.track_insert_key(scale_track_idx, current_ts + length / 2, initial_scale * 1.4)
		animation.track_insert_key(scale_track_idx, current_ts + length, initial_scale)
		
		current_ts += length + wait_time
		
	move_player.add_animation("move", animation)
	move_player.play("move")

func run_move(rolled: int) -> void:
	var has_extra_chance = false;
	# yield(get_tree().create_timer(0.5), "timeout")
	
	if global_position_on_board == -1:
		_move_token_to_out()
		global_position_on_board = GLOBAL_HOME_POSITIONS[player.name]
	else:
		_move_token_by_points(rolled)
		
	
	yield(move_player, "animation_finished")
	move_player.remove_animation("move")
	
	if rolled == 6:
		has_extra_chance = true;
		
	player.emit_signal("token_done_moving", has_extra_chance)
