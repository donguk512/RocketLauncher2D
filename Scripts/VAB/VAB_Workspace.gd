extends Node2D
class_name Workspace

func get_all_parts() -> Array[PartBase]:
	var parts: Array[PartBase] = []
	for part in get_children():
		if part is not PartBase:
			continue
		parts.append(part)
		
	return parts
