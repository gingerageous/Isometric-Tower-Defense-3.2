extends "res://Towers/Projectiles/ProjectileTemplate.gd"

var resource
var traj_anim = preload("res://Towers/Projectiles/Assets/ArtilleryTrajectoryAnim.tres")
var max_height = -150.0
var max_time = 2.0

func start(_pos, _target):
	.start(_pos, _target)
	var time = (_pos.distance_to(_target.global_position + _target.target_offset)) / max_speed
	$Tween.interpolate_property(self,
								"position",
								_pos, 
								_target.global_position + _target.target_offset,
								time, 
								Tween.TRANS_LINEAR,
								Tween.EASE_OUT_IN)
	$Tween.start()
	
	
	# Extra code just for example
	# Make a duplicate resource
	var new_anim = traj_anim.duplicate()
	$AnimationPlayer.remove_animation("Trajectory")
	$AnimationPlayer.add_animation("Trajectory", new_anim)
	
	var position_track = $AnimationPlayer.get_animation("Trajectory").find_track("Sprite:position")
	$AnimationPlayer.get_animation("Trajectory").track_set_key_value(position_track, 1, Vector2(0.0,time/max_time * max_height))
	$AnimationPlayer.playback_speed = 1/time
	$AnimationPlayer.play("Trajectory")

func movement(delta):
	pass

func _on_Tween_tween_completed(object, key):
	queue_free()
	
	
	resource.new()
	resource.instance()
	resource.duplicate()
	
