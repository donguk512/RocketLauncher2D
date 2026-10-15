class_name OrbitMath
extends RefCounted

static func calculate_pos(
	theta: float, 
	eccentricity: float, 
	semi_major_axis: float, 
	arg_of_periapsis: float,
	kepler_iterations: int = 4
) -> Array:
	
	# Update Mean Anomaly
	var mean_anomaly = fmod(theta, PI * 2.0)
	var x: float
	var y: float
	
	if eccentricity < 1.0:
		# Calculating approximate Eccentric Anomaly
		var E: float = mean_anomaly
		
		# M = E - e sin(E)
		# Newton-Raphson
		for i in range(kepler_iterations):
			E -= (
				E - eccentricity * sin(E) - mean_anomaly
				) / (
				1 - eccentricity * cos(E)
			)
		
		x = semi_major_axis * (cos(E) - eccentricity)
		y = semi_major_axis * sqrt(1 - eccentricity ** 2) * sin(E)
	
	else:
		var H: float = mean_anomaly
		for i in range(kepler_iterations):
			H -= (
				(eccentricity * sinh(H) - H - mean_anomaly) 
				/ 
				(eccentricity * cosh(H) - 1.0)
			)
			
		x = semi_major_axis * (eccentricity - cosh(H))
		y = semi_major_axis * sqrt(eccentricity ** 2 - 1.0) * sinh(H)
	
	var sin_omega = sin(arg_of_periapsis)
	var cos_omega = cos(arg_of_periapsis)
	
	var x_rotated = x * cos_omega - y * sin_omega
	var y_rotated = x * sin_omega + y * cos_omega
	
	return [x_rotated, y_rotated]
