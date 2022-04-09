extends Node2D
onready var area2d :Area2D = get_node("Area2D");


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	area2d.connect("input_event", self, "_on_Area2D_input_event")


func _token_clicked():
	print("Token Clicked")

func _on_Area2D_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if not event is InputEventMouseButton:
		return
		
	if not event.pressed:
		return
		
	if event.button_index != BUTTON_LEFT:
		return
		
	_token_clicked()
	
