extends Node2D

var num_of_points = 50.0
var gravity = -9.8

func _ready():
	calculate_trajectory()
	
	
func _physics_process(delta):
	$End.global_position = get_global_mouse_position()
	calculate_trajectory()
	
func calculate_trajectory():
	var points = []
	var DOT = Vector2(1,0).dot(($End.global_position - $Start.global_position).normalized()) 
	var angle = 90 - 45 * DOT

	var x_dis = $End.global_position.x - $Start.global_position.x
	var y_dis = -1.0 * ($End.global_position.y - $Start.global_position.y)
	
	var speed = sqrt(((0.5 * gravity * x_dis * x_dis) / pow(cos(deg2rad(angle)), 2.0)) / (y_dis - (tan(deg2rad(angle)) * x_dis)))
	var x_component = (cos(deg2rad(angle)) * speed)
	var y_component = (sin(deg2rad(angle)) * speed)
	
	var total_time = x_dis / x_component
	 
	for point in num_of_points:
		var time = total_time * (point / num_of_points)
		var dx = time * x_component
		var dy = -1.0 * (time * y_component + 0.5 * gravity * time * time)
		points.append($Start.global_position + Vector2(dx,dy))


	$Line2D.points = points