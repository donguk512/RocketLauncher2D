class_name VABTransform

static var _rotate_functions = [
	func (vec: Vector2) -> Vector2:
		return vec,
		
	func (vec: Vector2) -> Vector2:
		return Vector2(-vec.y, vec.x),
		
	func (vec: Vector2) -> Vector2:
		return Vector2(-vec.x, -vec.y),
		
	func (vec: Vector2) -> Vector2:
		return vec.orthogonal()
]

static func get_aabb(parts: Array[PartBase]) -> Rect2:
	var min_pos = Vector2( INF, INF)
	var max_pos = Vector2(-INF,-INF)
	
	for part in parts:
		var rect = part.collision_shape.shape.get_rect()
		var g_rect = part.global_transform * rect
		
		min_pos.x = min(min_pos.x, g_rect.position.x)
		min_pos.y = min(min_pos.y, g_rect.position.y)
		max_pos.x = max(max_pos.x, g_rect.end.x)
		max_pos.y = max(max_pos.y, g_rect.end.y)
	
	return Rect2(min_pos, max_pos - min_pos)

static func rotate_parts(
	parts: Array[PartBase], 
	quarters: int
):
	var aabb := get_aabb(parts)
	var pivot = aabb.position + aabb.size / 2.0
	pivot = pivot.snapped(Vector2.ONE * Constants.GRID_SIZE)
	
	quarters %= 4
	
	for part in parts:
		var offset = part.global_position - pivot
		var offset_rotated = _rotate_functions[quarters].call(offset)
		
		part.global_position = pivot + offset_rotated		# revolution
		part.rotation += quarters * PI / 2.0				# rotation
