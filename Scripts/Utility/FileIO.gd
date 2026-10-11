class_name FileIO

var BLUEPRINT_DIR_PATH = "user://blueprints/"

func save_blueprint(blueprint_name: String, data_dict: Dictionary):
	DirAccess.make_dir_absolute(BLUEPRINT_DIR_PATH)
	
	var path = BLUEPRINT_DIR_PATH + blueprint_name + ".json"
	var file = FileAccess.open(path, FileAccess.WRITE)
	
	if file:
		var json_string = JSON.stringify(data_dict, "\t")
		file.store_string(json_string)
		file.close()
		print("Saved blueprint at", path)

func load_blueprint(blueprint_name: String) -> Dictionary:
	var path = BLUEPRINT_DIR_PATH + blueprint_name + ".json"
	if not FileAccess.file_exists(path):
		return {}
	
	var file = FileAccess.open(path, FileAccess.READ)
	var json_string = file.get_as_text()
	file.close()
	
	var parsed_data = JSON.parse_string(json_string)
	if parsed_data is Dictionary:
		return parsed_data
	
	return {}
