extends Control

onready var email_address_input = get_node("EmailAddress")
onready var password_input = get_node("Password")
onready var repeat_password_input = get_node("RepeatPassword")
onready var main_interface = get_parent().get_node(".")
onready var confirm_button = get_node("ConfirmButton")
onready var back_button = get_node("BackButton")

func disable_button_login():
	confirm_button.disabled = true
	back_button.disabled = true

func enable_button_login():
	confirm_button.disabled = false
	back_button.disabled = false

func clear_inputs():
	email_address_input.clear()
	password_input.clear()
	repeat_password_input.clear()

func change_to_login_screen():
	get_node("../CreateAccountContainer").hide()
	get_node("../LoginContainer").show()

func _on_ConfirmButton_button_down():
	if email_address_input.text == "":
		main_interface.enable_confirm_popup("Please provide a valid email.", self)
	elif password_input.text == "":
		main_interface.enable_confirm_popup("Please provide a valid password.", self)
	elif repeat_password_input.text == "":
		main_interface.enable_confirm_popup("Please repeat your password.", self)
	elif repeat_password_input.text != password_input.text:
		main_interface.enable_confirm_popup("Password don't match.", self)
	elif password_input.text.length() <= 2:
		main_interface.enable_confirm_popup("Password must contain at least 3 characters.", self)
	else:
		disable_button_login()
		main_interface.set_label_popup("Creating account.", self)
		Gateway.connect_to_server(email_address_input.text, password_input.text, true)
		clear_inputs()

func _on_BackButton_button_down():
	change_to_login_screen()
