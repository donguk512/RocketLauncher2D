class_name SnapSolver

static func calc_group_snap_offset(
	selected_parts: Array[PartBase],
	all_sockets: Array[Node],
) -> Vector2:
	
	var best_dist_sqr: float = Constants.SNAP_DISTANCE ** 2
	var best_offset: Vector2 = Vector2.ZERO
	
	# Make a hash map of selected parts - O(1)
	var selected_set = {}
	
	for part in selected_parts:
		selected_set[part] = true
	
	var boundaries = get_boundary_socks(selected_parts, selected_set)
	var stationaries = get_stationary_socks(selected_set, all_sockets)
	
	for i_sock in boundaries:
		var i_dir = i_sock.global_transform.y.normalized()
		
		for o_sock in stationaries:
			var o_dir = o_sock.global_transform.y.normalized()
			
			# The two rotations must be opposite. check check
			# Dot product == -1 means they're facing exactly opposite
			if i_dir.dot(o_dir) > -0.9:
				continue
			
			# Using squared one because it's cheaper
			var dist_sqr = i_sock.global_position.distance_squared_to(
				o_sock.global_position
			)
			
			if dist_sqr < best_dist_sqr:
				best_dist_sqr = dist_sqr
				best_offset = o_sock.global_position - i_sock.global_position
	
	return best_offset


static func link_sockets(
	selected_parts: Array[PartBase],
	all_sockets: Array[Node],
) -> void:
	
	var link_tolerance_sqr: float = Constants.SOCKET_LINK_TOLERANCE ** 2
	
	# Make a hash map of selected parts - O(1)
	var selected_set = {}
	
	for part in selected_parts:
		selected_set[part] = true
	
	var boundaries = get_boundary_socks(selected_parts, selected_set)
	var stationaries = get_stationary_socks(selected_set, all_sockets)
	
	for i_sock in boundaries:
		var i_dir = i_sock.global_transform.y.normalized()
		
		for o_sock in stationaries:
			var o_dir = o_sock.global_transform.y.normalized()
			
			# The two rotations must be opposite. check check
			# Dot product == -1 means they're facing exactly opposite
			if i_dir.dot(o_dir) > -0.9:
				continue
			
			# Using squared one because it's cheaper
			var dist_sqr = i_sock.global_position.distance_squared_to(
				o_sock.global_position
			)
			
			if dist_sqr < link_tolerance_sqr:
				i_sock.link_to(o_sock)
				break


# Returns array of sockets of the selected parts but not connected internally
static func get_boundary_socks(
	selected_parts: Array[PartBase],
	selected_set: Dictionary
) -> Array[SnapPoint]:
	
	var boundaries: Array[SnapPoint] = []
	
	for part in selected_parts:
		for sock in part.get_snap_points():
			# Socket connected internally needs to be filtered
			if sock.linked_point and sock.linked_point.part in selected_set:
				continue
			
			boundaries.append(sock)
			
	return boundaries

# Returns array of sockets outside the selected parts that can be connected with
static func get_stationary_socks(
	selected_set: Dictionary,
	all_sockets: Array[Node]
) -> Array[SnapPoint]:
	
	var stationaries: Array[SnapPoint] = []
	
	for outer_sock: SnapPoint in all_sockets:
		# Filter socket of the selected part
		if outer_sock.part in selected_set:
			continue
		# Filter socket which is already connected
		if outer_sock.linked_point != null:
			continue
		
		stationaries.append(outer_sock)
	
	return stationaries
