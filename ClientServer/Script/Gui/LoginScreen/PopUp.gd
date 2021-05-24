extends Control

onready var popup_control = get_node(".")
onready var label_popup = get_node("Label")
onready var button_popup = get_node("Button")
var node_ref

func set_label_popup(text,node):
	label_popup.text = text
	popup_control.show()
	if node != null: node.disable_button_login()

func enable_confirm_popup(text,node):
	label_popup.text = text
	popup_control.show()
	button_popup.show()
	if node != null: node.disable_button_login()
	node_ref = node

func _on_Button_button_down():
	popup_control.hide()
	button_popup.hide()
	if node_ref != null: node_ref.enable_button_login()
	
