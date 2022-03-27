extends Node2D

signal rolled;
var ready_to_roll = false;
onready var rng = RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()
	reset()
	
func reset() -> void:
	$Sprite.visible = false;
	$AnimatedSprite.visible = false;
	$Sprite.frame = 0;
	
	
func roll() -> void:
	ready_to_roll = false
	var rolled = (rng.randi() % 6) + 1
	$Sprite.set_deferred("visible", false)
	$AnimatedSprite.set_deferred("visible", true)
	$AnimatedSprite.play("roll")
	yield($AnimatedSprite, "animation_finished")
	$Sprite.frame = rolled
	$Sprite.set_deferred("visible", true)
	$AnimatedSprite.frame = 0
	$AnimatedSprite.stop()
	$AnimatedSprite.set_deferred("visible", false);
	emit_signal("rolled", rolled)
	
func ready_to_roll() -> void:
	ready_to_roll = true;
	$Sprite.visible = true;


func _on_Area2D_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if (event is InputEventMouseButton && event.is_pressed()) && ready_to_roll:
		roll()
