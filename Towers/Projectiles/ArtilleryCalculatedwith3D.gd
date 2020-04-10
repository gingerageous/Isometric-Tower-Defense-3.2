extends Path2D

var num_of_points = 30.0
var gravity = -9.8


func _ready():
	var texture = $PathFollow2D/Viewport.get_texture()
	$PathFollow2D/Sprite.texture = texture
	

func start(_pos, _target):
	position = _pos
	calculate_trajectory(_pos, _target.global_position + _target.target_offset)
	
	
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
	
	
	# Model rotations
	var vertical_direction = sign(_End.y - _Start.y)
	var vertical_rotation = 160.0
	var speed_factor = 8.0
	if vertical_direction  == -1:
		vertical_rotation = 90.0
		speed_factor = 5.5
		
	var horizontal_rotation = rad2deg(Vector2(0, -1).angle_to((_End - _Start).normalized()))
	var tween_type = Tween.TRANS_LINEAR
	if abs(horizontal_rotation) > 140.0:
		tween_type = Tween.TRANS_CUBIC
		
		
	$Tween.interpolate_property($PathFollow2D/Viewport/basicmissile,
								"rotation_degrees",
								Vector3(0.0, 0.0, 0.0),
								Vector3(vertical_rotation * vertical_direction, horizontal_rotation * vertical_direction, 0.0),
								total_time/speed_factor,
								tween_type,
								Tween.EASE_OUT)
	

	# projectile movement
	$Tween.interpolate_property($PathFollow2D, 
								"unit_offset",
								0.0,
								1.0,
								total_time/speed_factor,
								Tween.TRANS_QUAD,
								Tween.EASE_IN)
								
	$Tween.start()
	
	

func _on_Tween_tween_completed(object, key):
	if key == ":unit_offset":
		queue_free()

#	if abs(horizontal_rotation) > 90.0:
#		var s = sign(horizontal_rotation)
#		horizontal_rotation -= horizontal_rotation - s * 90
