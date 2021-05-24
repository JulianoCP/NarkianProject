extends Node

var skill_data
var data_stats = {
	"stats" : {
		"str" : 43,
		"agi" : 53,
		"int" : 63,
	}
}

func _ready():
	get_data_skill()

func return_data_skill(skill_name):
	if skill_data.has(str(skill_name)):
		return skill_data[str(skill_name)]
	else:
		return null

func get_data_skill():
	var file = File.new()
	file.open("res://Data/Skill/SkillData.json",File.READ)
	var json_file = JSON.parse(file.get_as_text())
	file.close()
	skill_data = json_file.result
