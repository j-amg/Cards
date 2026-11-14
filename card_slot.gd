extends TextureRect

class_name Card_slot

var card_in_slot: Card

signal card_slot_input(card_slot: Card_slot)
signal card_slot_hover(card_slot: Card_slot)
signal card_slot_exit(card_slot: Card_slot)

var hovered = false

func _on_mouse_entered() -> void:
	hovered = true
	print("hovered slot")
	emit_signal("card_slot_hover", self)
	
func _on_mouse_exited() -> void:
	hovered = false
	emit_signal("card_slot_exit", self)
	
func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == 1 && event.pressed:
			emit_signal("card_slot_input", self)
