extends Path2D

var num_of_points = 30.0
var gravity = -9.8



func start(_pos, _target):
	position = _pos
	calculate_trajectory(_pos, _target.global_position)
	
	
func calculate_trajectory(_Start, _End):
	
	var DOT = Vector2(1,0).dot((_End - _Start).normalized()) 
	var angle = 90 - 45 * DOT

	
	var x_dis = _End.x - _Start.x
	var y_dis = -1.0 * (_End.y - _Start.y)
	
	
	var speed = sqrt(((0.5 * gravity * x_dis * x_dis) / pow(cos(deg2rad(angle)), 2.0)) / (y_dis - (tan(deg2rad(angle)) * x_dis)))
	var x_component = (cos(deg2rad(angle)) * speed)
	var y_component = (sin(deg2rad(angle)) * speed)
	
	var total_time = x_dis / x_component
	var new_curve = Curve2D.new()
	 
	for point in num_of_points:
		var time = total_time * (point / num_of_points)
		var dx = time * x_component
		var dy = -1.0 * (time * y_component + 0.5 * gravity * time * time)
		
		new_curve.add_point(Vector2(dx,dy))
	
	curve = new_curve

	
	$Tween.interpolate_property($PathFollow2D, 
								"unit_offset",
								0.0,
								1.0,
								total_time/10.0,
								Tween.TRANS_QUAD,
								Tween.EASE_IN)
	$Tween.start()


func _on_Tween_tween_completed(object, key):
	if key == ":unit_offset":
		queue_free()
