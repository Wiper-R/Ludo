extends Node2D

onready var game: Game = get_node("../../../../../")
onready var dice_base = get_node("../")
signal rolled;
var _ready_to_roll = false;
var rolled = false;
onready var rng = RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()
	reset()
	
func reset() -> void:
	$Sprite.visible = false;
	$AnimatedSprite.stop()
	$AnimatedSprite.visible = false;
	
	
func roll() -> void:
	_ready_to_roll = false
	var rolled = (rng.randi() % 6) + 1
	$Sprite.visible = false
	$AnimatedSprite.visible = true
	$AnimatedSprite.play("roll")
	yield($AnimatedSprite, "animation_finished")
	$Sprite.frame = rolled
	$Sprite.visible = true
	$AnimatedSprite.frame = 0
	$AnimatedSprite.visible = false
	emit_signal("rolled", rolled)
	self.rolled = true;
	
func ready_to_roll() -> void:
	_ready_to_roll = true;
	$Sprite.visible = true;


func _on_Area2D_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if (event is InputEventMouseButton && event.is_pressed()) && !rolled:
		roll()
