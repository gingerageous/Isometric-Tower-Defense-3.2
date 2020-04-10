extends Area2D

export var max_speed = 250
var speed = 250

func _physics_process(delta):
	movement(delta)
	
	
func start(_pos, _target):
	position = _pos
	$Sprite.rotation = Vector2(1,0).angle_to((_target.global_position - _pos + _target.target_offset).normalized())
	$Shadow.rotation = $Sprite.rotation
	var rot_offset = abs(Vector2(1,0).dot((_target.global_position - _pos + _target.target_offset).normalized()))
	scale.y = 0.5 + (0.5 * rot_offset)

	speed = (max_speed / 2) +((max_speed/2) * rot_offset)
	
func movement(delta):
	var velocity = Vector2(speed * delta,0)
	position += velocity.rotated($Sprite.rotation)
#	print("Hello")

func _on_Timer_timeout():
	queue_free()
