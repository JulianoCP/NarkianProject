extends Control

onready var username_input = get_node("LoginContainer/Username")
onready var password_input = get_node("LoginContainer/Password")
onready var login_button = get_node("LoginContainer/LoginButton")
onready var popup_control = get_node("PopUp")

func enable_confirm_popup(text, node):
	popup_control.enable_confirm_popup(text, node)

func set_label_popup(text, node):
	popup_control.set_label_popup(text, node)

func clear_inputs():
	username_input.clear()
	password_input.clear()

func disable_button_login():
	login_button.disabled = true

func enable_button_login():
	login_button.disabled = false

func _on_LoginButton_button_down():
	if username_input.text == "" or password_input.text == "":
		enable_confirm_popup("Invalid user, try again.", self)
	else:
		set_label_popup("Trying connection...", self)
		SceneManager.set_param_change_scene(get_parent().get_node("ProgressBar"), null, "main", self)
		Gateway.connect_to_server(username_input.text.to_lower(), password_input.text, false)
		clear_inputs()

func _on_CreateAccountButton_button_down():
	get_node("LoginContainer").hide()
	get_node("CreateAccountContainer").show()

func return_to_login_screen():
	get_node("CreateAccountContainer").hide()
	get_node("LoginContainer").show()

