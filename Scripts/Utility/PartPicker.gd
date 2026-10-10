class_name PartPicker

static func get_part_at_pos(
	space_state: PhysicsDirectSpaceState2D,
	world_pos: Vector2
) -> PartBase:
	
	var query = PhysicsPointQueryParameters2D.new()
	query.position = world_pos
	query.collide_with_areas = true
	query.collide_with_bodies = false
	
	var hits = space_state.intersect_point(query)
	for hit in hits:
		var collider: CollisionObject2D = hit.collider
		
		if collider is Area2D and collider.get_parent() is PartBase:
			return collider.get_parent() as PartBase
			
	return null
