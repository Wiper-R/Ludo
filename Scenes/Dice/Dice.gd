extends Node2D
onready var sprite: Sprite = get_node("Sprite");
onready var rng = RandomNumberGenerator.new()

# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"

func roll() -> void:
	var rolled = rng.randi_range(1, 6)
	sprite.frame = rolled;
	
	# Emit Signal Here
	

# TODO: Receive a move signal and reset the dice
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rng.randomize()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
