extends Node

var scene_path = null

func _ready():
	scene_data_path()

func get_scene_path(name_scene):
	if scene_path.has(str(name_scene)):
		return scene_path[str(name_scene)]
	else:
		return null

func scene_data_path():
	var file = File.new()
	file.open("res://Data/Scene/SceneData.json",File.READ)
	var json_file = JSON.parse(file.get_as_text())
	file.close()
	scene_path = json_file.result
