extends Node2D

export (int) var num_players = null;
onready var board: Node2D = get_node("Board");


# All players that we have.
const ALL_PLAYERS = ["Blue", "Red", "Green", "Yellow"];

var players: Dictionary = {};

func initiate_player(color: String) -> void:
	players[color] = {
		'tokens': {
			'T1': -1,
			'T2': -1,
			'T3': -1,
			'T4': -1,
		}
	}

	board.add_player(color)
	

func _ready() -> void:
	# Check that players must be set.
	assert(num_players != null, "ERROR: You must set players.")
	var skip: int = int(ceil(4 / num_players));
	for idx in range(0, num_players * skip, skip):
		initiate_player(ALL_PLAYERS[idx])
