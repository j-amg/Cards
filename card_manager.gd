extends Control

@onready var player_hand_pos: Control = $player_hand
var selected_card: Card
var hovered_card: Card
var card_scene = preload("res://card.tscn")
var card_distance = 100
var card_rotation = 2.5
var card_hover_scale = 1.75
var hand_max_count = 10
var last_selected_index = 0

var player_hand: Array[Card] = []

var screen_size: Vector2


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_window().get_viewport().get_visible_rect().size
	for i in range(hand_max_count):
		create_card_in_hand(generate_card())

	for slot in get_tree().get_nodes_in_group("card_slot"):
		if slot is Card_slot:
			slot.card_slot_input.connect(on_slot_input)
			slot.card_slot_hover.connect(on_slot_hover)
			slot.card_slot_exit.connect(on_slot_exit)
		
func _process(_delta: float) -> void:
	if selected_card != null: selected_card.position = get_global_mouse_position() + Vector2(20, 20)
	
func on_slot_hover(card_slot: Card_slot):
	print("hovered slot")
	pass
	
func on_slot_input(card_slot: Card_slot):
	print("slot input")
	if selected_card != null:
		var existing_card = try_add_card_to_slot(selected_card, card_slot)
		
		if existing_card != null:
			select_card(existing_card)
		else:
			selected_card = null
	elif card_slot.card_in_slot != null:
		select_card(card_slot.card_in_slot)
		card_slot.card_in_slot = null
	
func on_slot_exit(card_slot: Card_slot):
	pass
	
func try_add_card_to_slot(card: Card, slot: Card_slot) -> Card:
	var existing_card = slot.card_in_slot
	slot.card_in_slot = card
	
	var tween = get_tree().create_tween()
	var pos_x = slot.global_position.x
	var pos_y = slot.global_position.y
	var rot = 0
	
	tween.set_parallel(true)
	tween.tween_property(card, "rotation", rot, 0.1)
	tween.tween_property(card, "position", Vector2(pos_x, pos_y), 0.1)
	tween.tween_property(card, "scale", Vector2(1,1), 0.15)
	card.z_index = 10
	
	return existing_card
	
	
func create_card_in_hand(card_data: Card_data) -> void:
	var card: Card = card_scene.instantiate()
	add_child(card)
	player_hand.append(card)
	arrange_player_hand()
	card.set_data(card_data)
	card.card_input.connect(on_card_input)
	card.card_hover.connect(on_card_hover)
	card.card_exit.connect(on_card_exit)
	
func on_card_hover(card: Card) -> void:
	if selected_card != null: return

	if player_hand.find(card) != -1:
		card.scale = Vector2(card_hover_scale, card_hover_scale)
		card.rotation = 0
		card.z_index = 25
		card.position.y = screen_size.y - card.size.y
	

func on_card_exit(card: Card) -> void:
	var index = player_hand.find(card)
	if index != -1: set_card_in_hand_at_index(index)
	
	
	
func on_card_input(card: Card) -> void:
	if selected_card != null: return
	var card_index = player_hand.find(card)
	
	if card_index != -1:
		player_hand.remove_at(card_index)
		last_selected_index = card_index
		
	if selected_card != null:
		player_hand.insert(card_index, selected_card)
		
	select_card(card)
	arrange_player_hand()
	
func select_card(card: Card):
	selected_card = card
	card.z_index = 100
	card.rotation = 0
	card.scale = Vector2(card_hover_scale, card_hover_scale)
	card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	
func arrange_player_hand() -> void:
	for i in range(player_hand.size()):
		set_card_in_hand_at_index(i)
	
func set_card_in_hand_at_index(i: int):
	var card = player_hand[i]
	var tween = get_tree().create_tween()
	var pos_x = (player_hand_pos.position.x) - card.size.x/2 + ((i - (float(player_hand.size() - 1)) / 2) * card_distance)
	var pos_y = player_hand_pos.position.y + sin(-PI/2 +(abs(i - (float(player_hand.size() - 1)) / 2) * .2)) * 100
	var rot = deg_to_rad((i - (float(player_hand.size() - 1)) / 2) * card_rotation)
	
	tween.set_parallel(true)
	tween.tween_property(card, "rotation", rot, 0.1)
	tween.tween_property(card, "position", Vector2(pos_x, pos_y), 0.1)
	tween.tween_property(card, "scale", Vector2(1,1), 0.15)
	card.z_index = i
	card.mouse_filter = Control.MOUSE_FILTER_STOP
	
	
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
	
