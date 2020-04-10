extends Node2D

export (float, 100) var strength = 50.0 setget set_strength
var aiming = false

var gravity = -9.8
var num_of_points = 50


func _input(event):
	if event.is_action_pressed("action"):
		aiming = true
	if event.is_action_released("action"):
		aiming = false
	
	if aiming:
		if event is InputEventMouseMotion:
			self.strength += event.relative.x/5.0
			
func _physics_process(delta):
	if aiming:
		$Pivot.rotation = $Pivot.global_position.angle_to_point(get_global_mouse_position()) + PI
		
func calculate_trajectory():
	var points = []
	var total_air_time = 10.0
	var x_component = strength * cos($Pivot.rotation * -1.0)
	var y_component = strength * sin($Pivot.rotation * -1.0)
	for point in num_of_points:
		var time = total_air_time * point / num_of_points
		var dx = time * x_component
		var dy = -1.0 * (time * y_component + 0.5 * gravity * time * time)
		
		points.append(Vector2(dx,dy))
		
	$Line2D.points = points
		
func set_strength(num):
	strength = num
	clamp(strength, 0.0, 100.0)

	if $Pivot/TextureProgress:
		$Pivot/TextureProgress.value = num
		
	calculate_trajectory()
	
	