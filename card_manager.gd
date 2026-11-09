extends Control

@onready var player_hand_pos: Control = $player_hand
var selected_card: Card
var card_scene = preload("res://card.tscn")
var card_distance = 128

var player_hand: Array[Card] = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(5):
		add_card_to_hand(generate_card())
		
func _process(delta: float) -> void:
	if selected_card != null: selected_card.position = get_global_mouse_position() + Vector2(20, 20)
	
	
func add_card_to_hand(card_data: Card_data) -> void:
	var card: Card = card_scene.instantiate()
	add_child(card)
	player_hand.append(card)
	arrange_player_hand()
	card.set_data(card_data)
	card.card_input.connect(on_card_input)
	
func on_card_input(card: Card) -> void:
	var card_index = player_hand.find(card)
	if selected_card != null:
		player_hand.append(selected_card)
		
	if card_index != 0:
		player_hand.remove_at(card_index)
		
	
	selected_card = card
	selected_card.set_data(card.card_data)
	arrange_player_hand()
	
func arrange_player_hand() -> void:
	for i in range(player_hand.size()):
		var tween = get_tree().create_tween()
		
		var card = player_hand[i]
		tween.tween_property(card, "position", Vector2((player_hand_pos.position.x) + ((i - (float(player_hand.size())) / 2) * card_distance), player_hand_pos.position.y - card.size.y / 2), 0.1)
		print(player_hand[i].position.x)
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		print("unhandled input")
		if event.button_index == 2 && event.pressed:
			print("left press")
			if selected_card != null:
				player_hand.append(selected_card)
				selected_card = null
				arrange_player_hand()
				

	
func generate_card() -> Card_data:
	var card_data: Card_data = Card_data.new()
	var action:Card_data.card_actions = Card_data.card_actions.values().pick_random()
	card_data.card_name = Card_data.card_actions.keys()[action].capitalize()
	card_data.action = action
	card_data.value = randi_range(1, 5)
	card_data.card_initiative = randi_range(1, 99)
	return card_data
	
