extends Node2D
onready var area2d: Area2D = get_node("Area2D");
onready var player = get_node("../../");

var global_position_on_board: int = -1;
var local_position_on_board: int = -1;

signal token_clicked(token);

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	area2d.connect("input_event", self, "_on_Area2D_input_event")
	connect("token_clicked", player, "_on_token_clicked");
	

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
	return true
	
