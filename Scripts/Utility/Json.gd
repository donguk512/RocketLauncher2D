class_name JsonIO

static func load_from_path(path: String):
	var file = FileAccess.open(path, FileAccess.READ)
	
	if file:
		var json_string = file.get_as_text()
		var json = JSON.new()
		var success = json.parse(json_string)
		
		file.close()
		
		if success == OK:
			print("Successfully loaded json: ", path)
			return json.data
	else:
		printerr("Cannot open file: ", path)
	
	return {}


static func save_to_path(path: String, data) -> void:
	var file = FileAccess.open(path, FileAccess.WRITE)
	
	if file:
		var json_string = JSON.stringify(data, "\t", false)
		file.store_string(json_string)
		
		print("Saved json at: ", path)
	else:
		printerr("Cannot save file: ", path)
	file.close()
	
