extends Node2D
onready var area2d: Area2D = get_node("Area2D");
onready var player = get_node("../../");
onready var rolling_base = get_node("RollingBase");
onready var animation_player = get_node("AnimationPlayer");
onready var move_player: AnimationPlayer = get_node("MovePlayer");
onready var initial_scale: Vector2 = scale;
onready var home_row_path: Curve2D = get_node("../../Path2D").get_curve();



const GLOBAL_HOME_POSITIONS = {
	"Blue": 0,
	"Red": 13,
	"Green": 26,
	"Yellow": 39,
}


const SAFE_ZONES = [
	0, 8, 13, 21, 26, 34, 39, 47
]

var global_position_on_board: int = -1;
var local_position_on_board: int = -1;

signal token_clicked(token);
signal died;

func is_in_home_row(lp = null):
	if lp == null:
		return local_position_on_board >= 52 - 1;
	else:
		return lp >= 52 - 1;

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
		scale = Vector2.ONE
	else:
		animation_player.stop()
		scale = Vector2.ONE * 0.9

func _get_global_point_position(pidx: int) -> Vector2:
	return player.game.get_node("Path2D").get_curve().get_point_position(pidx)
	
func _get_home_row_point_position(pidx: int) -> Vector2:
	return home_row_path.get_point_position(pidx)
	
	
func _get_all_tokens_on_position(pidx: int) -> Array:
	if pidx == -1:
		return [];
	
	var tokens = []
	
	if !is_in_home_row(pidx):
		for p in player.game.players.get_children():
				for token in p.tokens:
						if token.global_position_on_board == pidx:
							tokens.push_back(token) 
	else:
		for token in player.tokens:
			if token.is_in_home_row() && token.local_position_on_board == pidx:
				tokens.push_back(token)
					
					
	return tokens;

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
		var prev_pos = global_position_on_board;
		
		global_position_on_board += 1;
		local_position_on_board += 1;
		
		
		if global_position_on_board == 52:
			global_position_on_board = 0;
			
			
		var prev_pos_vec: Vector2;
		var new_pos_vec: Vector2;
		
		if is_in_home_row(local_position_on_board):
			new_pos_vec = _get_home_row_point_position(local_position_on_board - 51)
			
			if is_in_home_row(local_position_on_board - 1):
				prev_pos_vec = _get_home_row_point_position(local_position_on_board - 51 - 1)
			else:
				prev_pos_vec = _get_global_point_position(prev_pos)
				
		else:
			prev_pos_vec = _get_global_point_position(prev_pos)
			new_pos_vec = _get_global_point_position(global_position_on_board)
			
			
			
		# Position
		animation.track_insert_key(pos_track_idx, current_ts, prev_pos_vec)
		animation.track_insert_key(pos_track_idx, current_ts + length, new_pos_vec)
		
		# Scale
		animation.track_insert_key(scale_track_idx, current_ts, initial_scale)
		animation.track_insert_key(scale_track_idx, current_ts + length / 2, initial_scale * 1.4)
		animation.track_insert_key(scale_track_idx, current_ts + length, initial_scale)
		
		current_ts += length + wait_time
		
	move_player.add_animation("move", animation)
	move_player.play("move")
	
func _do_tokens_reposition(tokens: Array):
	var num_tokens = len(tokens);
	
	var mid_token;
	
	if num_tokens % 2 == 0:
		mid_token = 0
	else:
		mid_token = num_tokens - 1 / 2
	
	if num_tokens > 1:
		for i in range(num_tokens):
			tokens[i].reset_position()
			tokens[i].scale = Vector2.ONE * 0.7
		
		if num_tokens % 2 == 0:
			var offset = 0;
			var cp = num_tokens / 2;
			for i in range(1, cp + 1):
				if i == 1:
					offset += 7.5;
				else:
					offset += 15;
				tokens[cp - i].position.x -= offset
				tokens[cp + i - 1].position.x += offset
		else:
			var offset = 0;
			var cp = (num_tokens + 1) / 2;
			for i in range(1, cp + 1):
				offset += 7.5;
				tokens[cp - i].position.x -= offset
				tokens[cp + i - 2].position.x += offset
	else:
		for token in tokens:
			token.reset_position()
			token.scale = Vector2.ONE * 0.9

func reset_position() -> void:
	if !is_in_home_row():
		position = _get_global_point_position(global_position_on_board)
		scale = Vector2.ONE
		
		
func died() -> void:
	var length = 0.1
	var current_ts = 0;
	var animation = Animation.new()
	animation.set_length(length * (local_position_on_board + 1));
	
	var pos_track_idx = animation.add_track(Animation.TYPE_VALUE);
	animation.track_set_path(pos_track_idx, ":position")
	
	for i in range(local_position_on_board, -1, -1):
		var prev_pos = global_position_on_board;
		
		global_position_on_board -= 1;
		local_position_on_board -= 1;
		
		if global_position_on_board == -1:
			global_position_on_board = 51;
			
		var  new_pos = global_position_on_board;
		
		var prev_pos_vec: Vector2 = _get_global_point_position(prev_pos);
		var new_pos_vec: Vector2 = _get_global_point_position(new_pos);
		
		
		# Position
		animation.track_insert_key(pos_track_idx, current_ts, prev_pos_vec)
		animation.track_insert_key(pos_track_idx, current_ts + length, new_pos_vec)
		
		current_ts += length
	
	animation.track_insert_key(pos_track_idx, current_ts, get_node("../../BasePositions/%s" % name).position)
	move_player.add_animation("move", animation)
	move_player.play("move")
	yield(move_player, "animation_finished")
	local_position_on_board = -1;
	global_position_on_board = -1;
	emit_signal("died")
	move_player.remove_animation("move")

func run_move(rolled: int) -> void:
	var has_extra_chance = false;
	# yield(get_tree().create_timer(0.5), "timeout")
	
	var tokens: Array;
	
	if !is_in_home_row():
		tokens = _get_all_tokens_on_position(global_position_on_board);
	else:
		tokens = _get_all_tokens_on_position(local_position_on_board)
		
	tokens.erase(self)
	
	_do_tokens_reposition(tokens);
		
	
	if global_position_on_board == -1:
		_move_token_to_out()
		global_position_on_board = GLOBAL_HOME_POSITIONS[player.name]
		local_position_on_board = 0;
	else:
		_move_token_by_points(rolled)
	
	yield(move_player, "animation_finished")
	move_player.remove_animation("move")
	
	if !is_in_home_row():
		tokens = _get_all_tokens_on_position(global_position_on_board);
	else:
		tokens = _get_all_tokens_on_position(local_position_on_board)
	
	var _tokens = [] + tokens;
	
	if !(global_position_on_board in SAFE_ZONES):
		for token in tokens:
			if token.player != player:
				token.died()
				yield (token, "died")
				_tokens.erase(token)
				has_extra_chance = true;
				# TODO: Add break here

	_do_tokens_reposition(_tokens);
	
	if rolled == 6:
		has_extra_chance = true;
		
	player.emit_signal("token_done_moving", has_extra_chance)
