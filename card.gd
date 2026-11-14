extends PanelContainer

class_name Card

signal card_input(card: Card)
signal card_hover(card: Card)
signal card_exit(card: Card)

@onready var name_label: Label = $MarginContainer/VBoxContainer/name
@onready var description_label: Label = $MarginContainer/VBoxContainer/description
@onready var initiative_label: Label = $MarginContainer/VBoxContainer/HBoxContainer/CenterContainer/initiative

var card_data: Card_data
var hovered: bool = false

func _on_mouse_entered() -> void:
	hovered = true
	emit_signal("card_hover", self)
	
func _on_mouse_exited() -> void:
	hovered = false
	emit_signal("card_exit", self)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == 1 && event.pressed:
			emit_signal("card_input", self)

func set_data(card: Card_data) -> void:
	card_data = card
	name_label.text = card.card_name
	description_label.text = str(card.value) + " " + Card_data.card_actions.keys()[card.action]
	initiative_label.text = str(card.card_initiative)
