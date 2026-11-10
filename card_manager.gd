extends Control

@onready var player_hand_pos: Control = $player_hand
var selected_card: Card
var card_scene = preload("res://card.tscn")
var card_distance = 75
var card_rotation = 5
var hand_max_count = 15
var last_selected_index = 0

var player_hand: Array[Card] = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(hand_max_count):
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
	card.card_hover.connect(on_card_hover)
	card.card_exit.connect(on_card_exit)
	
func on_card_hover(card: Card) -> void:
	card.scale = Vector2(1.25, 1.25)
	card.z_index = 25

func on_card_exit(card: Card) -> void:
	card.scale = Vector2(1, 1)
	
func on_card_input(card: Card) -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(card, "rotation", 0, 0.1)
	var card_index = player_hand.find(card)
	
	if card_index != -1: player_hand.remove_at(card_index)
		
	if selected_card != null:
		player_hand.insert(card_index, selected_card)
	
	selected_card = card
	selected_card.z_index = 20
	last_selected_index = card_index
	arrange_player_hand()
	
func arrange_player_hand() -> void:
	for i in range(player_hand.size()):
		var tween = get_tree().create_tween()
		
		var card = player_hand[i]
		var pos_x = (player_hand_pos.position.x) - card.size.x/2 + ((i - (float(player_hand.size() - 1)) / 2) * card_distance)
		var pos_y = player_hand_pos.position.y + sin(-PI/2 +(abs(i - (float(player_hand.size() - 1)) / 2) * .25)) * 100
		var rot = deg_to_rad((i - (float(player_hand.size() - 1)) / 2) * card_rotation)
		
		tween.tween_property(card, "rotation", rot, 0.1)
		tween.tween_property(card, "position", Vector2(pos_x, pos_y), 0.1)
		card.z_index = i
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		print("unhandled input")
		if event.button_index == 2 && event.pressed:
			print("left press")
			if selected_card != null:
				player_hand.insert(last_selected_index, selected_card)
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
	
