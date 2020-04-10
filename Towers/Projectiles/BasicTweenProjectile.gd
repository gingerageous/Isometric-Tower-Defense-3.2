extends "res://Towers/Projectiles/ProjectileTemplate.gd"




func start(_pos, _target):
	.start(_pos, _target)
	var time = (_pos.distance_to(_target.global_position + _target.target_offset)) / max_speed
	$Tween.interpolate_property(self,
								"position",
								_pos, 
								_target.global_position + _target.target_offset,
								time, 
								Tween.TRANS_LINEAR, 
								Tween.EASE_IN)
	$Tween.start()
	
	
	
	

func movement(delta):
	pass

func _on_Tween_tween_all_completed():
	queue_free()
