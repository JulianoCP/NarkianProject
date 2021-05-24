extends Node

var currentScene = null
var thread = null
var progress_bar = null
var fade = null
var scene_name = null

signal scene_started

func thread_load(path):
	var ril = ResourceLoader.load_interactive(path)
	var total = ril.get_stage_count()
	var res = null
	assert(ril)
	if progress_bar != null: progress_bar.call_deferred("set_max", total)
	
	while true:
		if progress_bar != null: progress_bar.call_deferred("set_value", ril.get_stage())
		var err = ril.poll()
		if err == ERR_FILE_EOF:
			res = ril.get_resource()
			break
		elif err != OK:
			print("Error Loading")
			break
	call_deferred("thread_done", res)

func thread_done(resource):
	assert(resource)
	
	thread.wait_to_finish()
	currentScene.queue_free()
	currentScene = resource.instance()

	get_tree().root.add_child(currentScene)
	
	emit_signal("scene_started")

func set_param_change_scene(progress_ref = null, fade_ref = null, scene_name_ref = "main",node_ref = null):
	progress_bar = progress_ref
	fade = fade_ref
	scene_name = scene_name_ref
	currentScene = node_ref.get_tree().get_root().get_child(get_tree().get_root().get_child_count() -1)

func change_scene():
	var path = get_scene_path()
	if progress_bar != null: progress_bar.show()
	if path == null:
		print("ERROR: Path scene not found")
		return
	
	thread = Thread.new()
	thread.start(self, "thread_load",path,2)

func get_scene_path():
	var data_path = GameData.get_scene_path(scene_name)
	if data_path == null:
		return null
	return data_path["path"]
