extends Node2D

export(int) var num_players = null
onready var board: Node2D = get_node("Board")

# All players that we have.
const ALL_PLAYERS = ["Blue", "Red", "Green", "Yellow"]

# Player Board Positions
const PLAYER_HOME_POSITIONS = [
	Vector2(-324, 324),
	Vector2(-324, -324),
	Vector2(324, -324),
	Vector2(324, 324),
]

func initiate_player(color: String, home_position: Vector2) -> void:
	board.add_player(color, home_position)


func _ready() -> void:
	# Check that players must be set.
	assert(num_players != null, "ERROR: You must set number of players before adding game to tree.")
	var skip: int = int(ceil(4 / num_players))
	for idx in range(0, num_players * skip, skip):
		initiate_player(ALL_PLAYERS[idx], PLAYER_HOME_POSITIONS[idx])
