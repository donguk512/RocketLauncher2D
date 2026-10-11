class_name VABBluprint

static func group_linked_parts(all_parts: Array[PartBase]) -> Array[Array]:
	var clusters: Array[Array] = []
	var unvisited: Array[PartBase] = all_parts.duplicate()
	
	while unvisited.size() > 0:
		var start_part: PartBase = unvisited.pop_back()
		var this_cluster: Array[PartBase] = [start_part]
		var queue: Array[PartBase] = [start_part]
		
		while queue.size() > 0:
			var this_part: PartBase = queue.pop_front()
			
			for socket in this_part.get_snap_points():
				if not socket.connected_point:
					continue
				
				var neighbor = socket.connected_point.part
				var idx = unvisited.find(neighbor)
				
				if idx != -1:
					unvisited.remove_at(idx)
					this_cluster.append(neighbor)
					queue.append(neighbor)
		
		clusters.append(this_cluster)
		
	return clusters

static func get_clusters(
	all_parts: Array[PartBase],
	space_state: PhysicsDirectSpaceState2D
) -> Array[Array]:
	
	var initial_clusters: Array[Array] = group_linked_parts(all_parts)
	
	# Sort in descending order 5 4 3 2 1
	initial_clusters.sort_custom(func(a, b):
		return a.size() > b.size()
	)
	

const TOLERANCE_VECTOR: Vector2 = Vector2.ONE * 1.05

static func _clusters_touching(
	cluster_big: Array,
	cluster_small: Array,
	space_state: PhysicsDirectSpaceState2D
) -> bool:
	
	for part: PartBase in cluster_small:
		var collision_shape = part.collision_shape
		
		var params = PhysicsShapeQueryParameters2D.new()
		params.shape = collision_shape.shape
		params.transform = collision_shape.global_transform.scaled_local(
			TOLERANCE_VECTOR
		)
		params.collide_with_areas = true
		params.collide_with_bodies = false
		
		var hits = space_state.intersect_shape(params)
		for hit in hits:
			var collider = hit.collider
			if collider is Area2D and collider.get_parent() is PartBase:
				var neighbor = collider.get_parent()
				
				if neighbor in cluster_big:
					return true
		
	return false
