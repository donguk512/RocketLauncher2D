extends Node

var launch_blueprint: Array = []
var time: float = 0.0
var time_scale: float = 0.1
var world_scale: float = 0.1

var origin_offset_x: float = 0.0
var origin_offset_y: float = 0.0

var bodies: Dictionary = {}
var frame_body: CelestialBody		#지역 좌표계의 중심이 될 천체
