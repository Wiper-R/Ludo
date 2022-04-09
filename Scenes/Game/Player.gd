extends Node2D

onready var sprite = load("res://assets/{name}-token.png".format({"name": name.to_lower()}))
onready var token_scene = preload("res://Scenes/Token/Token.tscn")

class_name Player

var has_turn: bool = false


func _ready() -> void:
	assert(
		token_scene != null, "ERROR: Couldn't load {name} Token resource.".format({"name": name})
	)


func _process(_delta: float) -> void:
	pass


func initialize():
	var tokens = Node2D.new()
	tokens.name = "Tokens"

	for idx in range(1, 5):
		var token = token_scene.instance()
		token.position = get_node("BasePositions/T%s" % idx).position;
		token.get_node("Sprite").texture = sprite;
		tokens.add_child(token)

	add_child(tokens)
