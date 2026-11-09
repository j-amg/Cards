extends Resource

class_name Card_data

enum card_actions {
	attack,
	block,
	draw
}

@export var card_name: String
@export var card_initiative: int
@export var value: int
@export var action: card_actions
