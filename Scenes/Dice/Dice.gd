extends Node2D
onready var sprite: Sprite = get_node("Sprite");
onready var animated_dice: Sprite = get_node("AnimatedDice");
onready var animation_player: AnimationPlayer = animated_dice.get_node("AnimationPlayer");
onready var rng = RandomNumberGenerator.new()
onready var area2d = get_node("Area2D");
onready var area2d_collision = get_node("Area2D/CollisionShape2D");
# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"

func is_rolling() -> bool:
	return animation_player.is_playing()

func done_rolling() -> void:
	var rolled = rng.randi_range(1, 6)
	sprite.frame = rolled;
	
	# Emit Signal Here
	

# TODO: Receive a move signal and reset the dice

func block() -> void:
	area2d_collision.disabled = true
	
func unblock() -> void:
	area2d_collision.disabled = false
	
func roll() -> void:
	animation_player.play("roll")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect Area2d input
	area2d.connect("input_event", self, "_on_Area2D_input_event")
	
	# randomize
	rng.randomize()
	
	# Reset Variables
	reset()
	
func reset() -> void:
	sprite.visible = true;
	sprite.frame = 0;
	animated_dice.visible = false;
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass

func _on_Area2D_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if !(event is InputEventMouseButton):
		return
		
	if !event.pressed:
		return
		
	roll()
